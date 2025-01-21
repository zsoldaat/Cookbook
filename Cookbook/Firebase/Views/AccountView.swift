//
//  AccountView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-21.
//

import SwiftUI


struct AccountView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            Text("Home Screen")
                .navigationTitle("Share")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log out") {
                            print("Log out tapped!")
                            authService.regularSignOut { error in
                                
                                if let e = error {
                                    print(e.localizedDescription)
                                }
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    AccountView()
}
