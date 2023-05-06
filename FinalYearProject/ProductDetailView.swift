//
//  ProductDetailView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 22/04/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProductDetailView: View {
    let product: Product
    @State private var showChatView = false
    @State private var showAlert = false
    @State private var showPurchaseView = false
    @State private var alertMessage = ""
    
    private var isCurrentUserSeller: Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        return currentUserId == product.sellerId
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RemoteImage(url: product.imageUrl)
                    .scaledToFit()
                    .cornerRadius(10)
                
                Text(product.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("£\(product.price, specifier: "%.2f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Description")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(product.itemDescription)
                    .font(.body)
                
                Spacer()
                
                HStack {
                    purchaseButton
                    messageButton
                }
            }.padding()
        }
        .navigationBarTitle("Product Detail", displayMode: .inline)
    }
    
    private var purchaseButton: some View {
        Button(action: {
            if isCurrentUserSeller {
                alertMessage = "You cannot purchase your own product."
                showAlert = true
            } else {
                showPurchaseView = true
            }
        }) {
            Text("Purchase")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showPurchaseView) {
            PurchaseView(isPresented: $showPurchaseView, product: product)
        }
    }
    
    private var messageButton: some View {
        Button(action: {
            if isCurrentUserSeller {
                alertMessage = "You cannot message yourself."
                showAlert = true
            } else if product.sellerId.isEmpty {
                alertMessage = "Error: recipient ID is empty."
                showAlert = true
            } else {
                showChatView = true
            }
        }) {
            Text("Message")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showChatView) {
            NavigationView {
                ChatView(recipientId: product.sellerId)
                    .onAppear {
                        if product.sellerId.isEmpty {
                            alertMessage = "Error: recipient ID is empty."
                            showAlert = true
                        }
                    }
            }
        }
    }
}
    
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: Product(id: "1", title: "Sample Product", itemDescription: "This is a sample product description.", price: 19.99, imageUrl: "", sellerId: "sample_seller_id", category: "All"))
    }
}
