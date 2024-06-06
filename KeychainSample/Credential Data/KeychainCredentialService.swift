//
//  KeychainCredentialService.swift
//  KeychainSample
//
//  Created by 김영빈 on 6/5/24.
//

import Foundation

struct Credentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

struct KeychainCredentialService {


    static let server = "com.kybeen.KeychainSample"
    
    static let defaultCredentials = Credentials(username: "Default_Name", password: "Default_PW")
    
    // MARK: - Save Item
    static func addKeychainItem(){
        print("\n[ADD]")
        let account = defaultCredentials.username // KEY
        let password = defaultCredentials.password.data(using: .utf8)! // VALUE
        
        let query: [String: Any] = [
            // item class 종류
            kSecClass as String: kSecClassInternetPassword,
            
            // 저장하고자 하는 정보
            kSecAttrAccount as String: account, // item의 계정 이름을 나타냄
            kSecAttrServer as String: server, // item의 서버를 나타냄
            
            // Data 인스턴스로 인코딩된 password
            kSecValueData as String: password // item의 데이터
        ]
        print("query: \(query)")
        
        do {
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                print("add 중 오류")
                throw KeychainError.unhandledError(status: status)
            }
            print("Success!!! - Add Keychain Item")
        } catch {
            print("Fail... - Add Keychain Item")
        }
    }
    
    // MARK: - Search Item
    static func searchKeychainItem() -> Credentials? {
        print("\n[SEARCH]")
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            
            // 일종의 key의 역할 - server attribute가 매치되는 item을 찾게 됨
            kSecAttrServer as String: server,
            
            kSecMatchLimit as String: kSecMatchLimitOne, // result를 하나의 value로
            
            // attribute와 data 둘 다 요청
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        print("query: \(query)")
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        do {
            guard status != errSecItemNotFound else {
                print("search 중 오류 1")
                throw KeychainError.noPassword
            }
            guard status == errSecSuccess else {
                print("search 중 오류 2")
                throw KeychainError.unhandledError(status: status)
            }
            
            // 검색 시 1개의 결과만 요청했으므로 단일 딕셔너리로 옴
            guard let existingItem = item as? [String: Any],
                  let passwordData = existingItem[kSecValueData as String] as? Data,
                  let password = String(data: passwordData, encoding: .utf8),
                  let account = existingItem[kSecAttrAccount as String] as? String
            else {
                print("search 중 오류 3")
                throw KeychainError.unexpectedPasswordData
            }
            
            let credentials = Credentials(username: account, password: password)
            print("Success!!! - Search Keychain Item 👉 \(credentials)")
            return credentials
        } catch {
            print("Fail... - Search Keychain Item")
            return nil
        }
    }
    
    // MARK: - Update Item
    static func updateKeychainItem(newCredentials: Credentials) {
        print("\n[UPDATE]")
        // 업데이트 작업 수행 시에 암시적으로 검색을 먼저 해야 하기 때문에 검색할때와 같은 형식으로 쿼리 생성
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]
        print("update 시 검색 query: \(query)")
        
        // 업데이트할 내용에 대한 쿼리 생성
        let account = newCredentials.username
        let password = newCredentials.password.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecAttrAccount as String: account,
            kSecValueData as String: password
        ]
        print("update 할 query: \(query)")
        
        do {
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard status != errSecItemNotFound else {
                print("update 중 오류 1")
                throw KeychainError.noPassword
            }
            guard status == errSecSuccess else {
                print("update 중 오류 2")
                throw KeychainError.unhandledError(status: status)
            }
            print("Success!!! - Update Keychain Item 👉 \(newCredentials)")
        } catch {
            print("Fail... - Update Keychain Item")
        }
    }
    
    // MARK: - Delete Item
    static func deleteKeychainItem() {
        print("\n[DELETE]")
        // 삭제할 item을 검색하기 위한 쿼리
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]
        print("query: \(query)")
        
        do {
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                print("delete 중 오류")
                throw KeychainError.unhandledError(status: status)
            }
            print("Success!!! - Delete Keychain Item")
        } catch {
            print("Fail... - Delete Keychain Item")
        }
    }
}
