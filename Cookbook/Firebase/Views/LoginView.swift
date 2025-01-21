//
//  LoginView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-21.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertShowing: Bool = false
    @State private var privacyPolicyShowing: Bool = false
    @State private var errorMessage: String = ""
    @State private var createAccountMode: Bool = false
    
    var body: some View {
        NavigationView {
            
            VStack {
                CardView {
                    HStack {
                        
                        Button {
                            createAccountMode.toggle()
                        } label: {
                            createAccountMode ? Label("Login", systemImage: "arrow.left") : Label("Create Account", systemImage: "plus")
                        }
                        
                        Spacer()
                        
                        if (privacyPolicyShowing) {
                            Button {
                                privacyPolicyShowing = false
                            } label: {
                                Label("Close", systemImage: "xmark")
                                    .labelStyle(.iconOnly)
                            }
                            
                        } else {
                            Button {
                                privacyPolicyShowing = true
                            } label: {
                                Label("Info", systemImage: "questionmark.circle")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .padding()
                    
                    if (privacyPolicyShowing) {
                        Text("Create an account if you would like to share your recipes and grocery lists with other people. It's totally optional, and nothing bad will happen to you. (No emails, no data collection, etc.) I would do this without collecting emails if I could, but most backend services don't allow you to submit records without authentication.")
                            .font(.caption)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    if (!errorMessage.isEmpty) {
                        Text(errorMessage)
                            .font(.caption)
                    }
                    
                    if (createAccountMode) {
                        HStack {
                            Spacer()
                            Button("Create Account") {
                                authService.regularCreateAccount(email: email, password: password) { error in
                                    if let e = error {
                                        errorMessage = e.localizedDescription
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    
                    if (!createAccountMode) {
                        HStack {
                            Spacer()
                            Button("Login") {
                                authService.regularSignIn(email: email, password: password) { error in
                                    if let e = error {
                                        print(e.localizedDescription)
                                        alertShowing = true
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .alert("There is no account that matches these credentials. Create one?", isPresented: $alertShowing, actions: {
                Button {
                    createAccountMode = true
                } label: {
                    Label("Yes", systemImage: "checkmark")
                }
                
                Button {
                    alertShowing = false
                } label: {
                    Label("No", systemImage: "xmark")
                }
            })
        }
    }
}
#Preview {
    LoginView()
}
