//
//  KeychainStringService.swift
//  KeychainSample
//
//  Created by 김영빈 on 6/6/24.
//

import Foundation

enum KeychainStringServiceError: Error {
    case invalidData
    case noKeychainItem
    case unhandledError
    case unexpectedData
}

struct KeychainItemKey {
    static let uid = "uid"
    static let deviceToken = "deviceToken"
}

struct KeychainItem {
    
    let service: String = "com.kybeen.KeychainSample" // Bundle.main.bundleIdentifier로 수정
    let account: String // 저장할 keychain item에 대한 식별자(key)로 사용할 값
    
    init(key account: String) {
        self.account = account
    }
    
    // MARK: - Search Item
    func searchItem() throws -> String {
        print("\n[SEARCH]")
        // 쿼리 생성
        var query = KeychainItem.keychainQuery(withService: service, account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne // 한개의 결과만 받아옴
        query[kSecReturnAttributes as String] = true // attribute를 요청
        query[kSecReturnData as String] = true // data를 요청
        print("query: \(query)")
        
        // 검색 수행
        var searchResult: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &searchResult)
        
        // 결과 처리
        guard status != errSecItemNotFound else {
            print("search 중 오류 1")
            throw KeychainStringServiceError.noKeychainItem
        }
        guard status == noErr else {
            print("search 중 오류 2")
            throw KeychainStringServiceError.unhandledError
        }
        
        // 쿼리 결과로 얻은 data에서 원하는 값을 파싱
        guard let existingItem = searchResult as? [String: Any],
              let data = existingItem[kSecValueData as String] as? Data,
              let itemValue = String(data: data, encoding: String.Encoding.utf8)
        else {
            print("search 중 오류 3")
            throw KeychainStringServiceError.unexpectedData
        }
        
        return itemValue
    }
    
    // MARK: - Add & Update Item
    func saveItem(_ itemValue: String) throws {
        // 저장할 값을 인코딩
        guard let encodedValue = itemValue.data(using: String.Encoding.utf8) else {
            throw KeychainStringServiceError.invalidData
        }
        
        do { /// [ 기존 item이 존재하는 경우 ]
            // 동일한 item이 키체인에 존재하는지 체크
            try _ = searchItem()
            
            print("\n기존 item이 존재하기 때문에 기존 item을 [UPDATE]!!")
            // 기존 item의 값을 새롭게 업데이트하기 위한 쿼리
            let attributeToUpdate: [String: Any] = [
                kSecValueData as String: encodedValue
            ]
            // 업데이트 전 검색을 위한 쿼리
            let query = KeychainItem.keychainQuery(withService: service, account: account)
            let status = SecItemUpdate(query as CFDictionary, attributeToUpdate as CFDictionary)
            
            guard status != errSecItemNotFound else {
                print("update 중 오류 1")
                throw KeychainStringServiceError.noKeychainItem
            }
            guard status == errSecSuccess else {
                print("update 중 오류 2")
                throw KeychainStringServiceError.unhandledError
            }
        } catch KeychainStringServiceError.noKeychainItem { /// [ 기존 item이 존재하지 않는 경우 ]
            print("\n기존 item이 존재하지 않기 때문에 새로 [ADD]!!")
            // 새로 저장할 item의 쿼리 생성
            var newQuery = KeychainItem.keychainQuery(withService: service, account: account)
            newQuery[kSecValueData as String] = encodedValue
            
            let status = SecItemAdd(newQuery as CFDictionary, nil)
            guard status == errSecSuccess else {
                print("add 중 오류")
                throw KeychainStringServiceError.unhandledError
            }
        }
    }
    
    // MARK: - Delete Item
    func deleteItem() throws {
        print("\n[DELETE]")
        // 삭제할 item의 쿼리 생성
        let query = KeychainItem.keychainQuery(withService: service, account: account)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            // 삭제할 item이 없는 경우는 에러 반환 x
            print("delete 중 오류")
            throw KeychainStringServiceError.unhandledError
        }
    }
    
    // MARK: - 쿼리 생성
    private static func keychainQuery(
        withService service: String, // 서비스 종류 (앱 식별용)
        account: String? = nil // 저장할 데이터의 key로 사용할 문자열
    ) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        if let account = account {
            query[kSecAttrAccount as String] = account
        }
        
        return query
    }
    
    // MARK: - 불러오기
    
    // deviceToken
    static var curentDeviceToken: String? {
        do {
            let deviceToken = try KeychainItem(key: "deviceToken").searchItem()
            return deviceToken
        } catch {
            return nil
        }
    }
    
    // uid
    static var currentUid: String? {
        do {
            let uid = try KeychainItem(key: "uid").searchItem()
            return uid
        } catch {
            return nil
        }
    }
}
