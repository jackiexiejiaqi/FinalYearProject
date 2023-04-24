//
//  SignUpView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 09/04/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var name = ""
    @State private var studentID = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @Binding var isSignUpPresented: Bool

    private func signUp() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            showAlert = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }

            guard let user = authResult?.user else { return }

            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "name": name,
                "studentID": studentID,
                "email": email,
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showAlert = true
                } else {
                    print("User signed up successfully.")
                    isSignUpPresented = false
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, geometry.size.height * 0.15)

                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                TextField("Student ID", text: $studentID)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

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

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: signUp) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Sign Up Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(isSignUpPresented: .constant(false))
    }
}
