//
//  KeychainCredentialView.swift
//  KeychainSample
//
//  Created by 김영빈 on 6/6/24.
//

import SwiftUI

struct KeychainCredentialView: View {
    
    @State var credentials: Credentials? // 키체인으로 불러올 값
    @State var username: String = "" // 업데이트 시 입력할 값
    @State var password: String = "" // 업데이트 시 입력할 값
    @State var isKeychainItemExist: Bool = false // 키체인 아이템이 있는지
    
    var body: some View {
        VStack {
            Spacer()
            
            // MARK: - Keychain Item 확인하는 부분
            HStack {
                Text("Keychain Item Credentials 조회하기")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Username : \(credentials?.username ?? "??")")
                        .font(.title2)
                        .foregroundStyle(.gray)
                    Spacer()
                }
                HStack {
                    Text("Password  : \(credentials?.password ?? "??")")
                        .font(.title2)
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
            
            Spacer()
            
            // MARK: - UPDATE
            VStack(alignment: .leading) {
                HStack {
                    Text("Keychain Item 업데이트")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button {
                        KeychainCredentialService.updateKeychainItem(newCredentials: Credentials(username: username, password: password))
                        searchCredentials()
                    } label: {
                        MyButtonLabel(text: "UPDATE", width: 80)
                    }
                    .disabled((username.isEmpty || password.isEmpty))
                }
                
                VStack {
                    TextField("username", text: $username)
                        .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 0))
                        .border(.gray, width: 1)
                    TextField("password", text: $password)
                        .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 0))
                        .border(.gray, width: 1)
                }
            }
            
            Divider()
            
            // MARK: - ADD, DELETE
            VStack {
                HStack {
                    Text("기본값 추가하기 ➕").bold().foregroundStyle(.green)
                    Spacer()
                    Button {
                        KeychainCredentialService.addKeychainItem()
                        searchCredentials()
                    } label: {
                        MyButtonLabel(text: "ADD")
                    }
                }
                HStack {
                    Text("Keychain Item 삭제하기 ❌").bold().foregroundStyle(.red)
                    Spacer()
                    Button {
                        KeychainCredentialService.deleteKeychainItem()
                        searchCredentials()
                    } label: {
                        MyButtonLabel(text: "DELETE", backgroundColor: .red)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            searchCredentials()
        }
    }
    
    // MARK: - SEARCH
    private func searchCredentials() {
        credentials = KeychainCredentialService.searchKeychainItem()
        isKeychainItemExist = credentials != nil
    }
}

struct MyButtonLabel: View {
    let text: String
    var tintColor: Color = .white
    var backgroundColor: Color = .cyan
    var width: CGFloat = 100
    
    var body: some View {
        Text("\(text)")
            .tint(tintColor)
            .frame(width: width)
            .padding()
            .background {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
    }
}

#Preview {
    KeychainCredentialView()
}
