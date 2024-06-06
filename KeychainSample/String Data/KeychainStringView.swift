//
//  KeychainStringView.swift
//  KeychainSample
//
//  Created by 김영빈 on 6/6/24.
//

import SwiftUI

/*
 - account로 uid
 - password로 deviceToken
 */


struct KeychainStringView: View {
    @State var uid: String?
    
    var body: some View {
        VStack {
            Text("키체인 아이템 👉 ")
                .font(.largeTitle)
                .bold()
            
            Button {
                
            } label: {
                
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    KeychainStringView()
}
