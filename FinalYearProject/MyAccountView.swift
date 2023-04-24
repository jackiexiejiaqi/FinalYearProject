//
//  MyAccountView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 08/04/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyAccountView: View {
    @State private var isLoggedIn: Bool = false
    @State private var userData: [String: Any] = [:]
    @State private var handle: AuthStateDidChangeListenerHandle?
    
    private func fetchUserData() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let document = document, document.exists {
                    userData = document.data() ?? [:]
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func checkLoginStatus() {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.isLoggedIn = true
                self.fetchUserData()
            } else {
                self.isLoggedIn = false
            }
        }
    }

    var body: some View {
        NavigationView {
            if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
            } else {
                VStack {
                    Text("Name: \(userData["name"] as? String ?? "N/A")")
                    Text("Student ID: \(userData["studentID"] as? String ?? "N/A")")

                    NavigationLink(destination: ListProductView()) {
                        Text("List a Product")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: PurchasedProductsView()) {
                        Text("View Purchased Products")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: SoldProductsView()) {
                        Text("View Sold Products")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        isLoggedIn = false
                        try? Auth.auth().signOut()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("My Account")
        .onAppear(perform: checkLoginStatus)
        .onDisappear(perform: removeAuthListener)
    }
    
    private func removeAuthListener() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

struct MyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountView()
    }
}


