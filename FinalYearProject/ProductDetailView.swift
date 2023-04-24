//
//  ItemDetailView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 22/04/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProductDetailView: View {
    let product: Product
    
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
                
                purchaseButton
                
            }.padding()
        }
        .navigationBarTitle("Product Detail", displayMode: .inline)
    }
    
    private var purchaseButton: some View {
        NavigationLink(destination: PurchaseView(isPresented: .constant(true), product: product)) {
            Text("Purchase")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    private func purchaseProduct() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: user not logged in")
            return
        }

        let db = Firestore.firestore()
        let productRef = db.collection("products").document(product.id)

        db.runTransaction { transaction, errorPointer in
            let productDocument: DocumentSnapshot
            do {
                try productDocument = transaction.getDocument(productRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            // Perform the purchase transaction
            // (e.g., process payment, update inventory, etc.)

            // Update the buyerId field with the current user's ID
            transaction.updateData(["buyerId": currentUserId], forDocument: productRef)
            return nil
        } completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: Product(id: "1", title: "Sample Product", itemDescription: "This is a sample product description.", price: 19.99, imageUrl: "", sellerId: "sample_seller_id"))
    }
}
