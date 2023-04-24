//
//  LoginView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 09/04/2023.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isSignUpPresented: Bool = false
    @Binding var isLoggedIn: Bool

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }

            // User login successful
            print("User login successful: \(authResult?.user.uid ?? "")")
            isLoggedIn = true
        }
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, geometry.size.height * 0.15)

                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Button(action: login) {
                        Text("Log In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        isSignUpPresented.toggle()
                    }) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }

                    .padding(.top)

                    Spacer()
                }
                .sheet(isPresented: $isSignUpPresented) {
                    SignUpView(isSignUpPresented: $isSignUpPresented)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}


