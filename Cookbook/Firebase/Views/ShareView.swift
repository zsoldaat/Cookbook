//
//  ShareView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-21.
//

import SwiftUI
import FirebaseAuth

struct ShareView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        if authService.signedIn {
            AccountView()
        } else {
            LoginView()
        }
    }
}

//#Preview {
//    ShareView()
//}
