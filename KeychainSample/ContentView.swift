//
//  ContentView.swift
//  KeychainSample
//
//  Created by 김영빈 on 6/5/24.
//

import SwiftUI

struct ContentView: View {
    @State var tabType: Int = 1
    
    var body: some View {
        TabView {
            KeychainCredentialView()
                .tabItem {
                    Label("CredentialView", systemImage: "person.badge.key")
                }
            
            Text("String")
                .tabItem {
                    Label("String", systemImage: "text.bubble")
                }
        }
    }

}

#Preview {
    ContentView()
}
