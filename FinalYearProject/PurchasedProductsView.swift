//
//  PurchasedProductsView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 21/04/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PurchasedProductsView: View {
    @State private var purchasedProducts: [Product] = []
    
    let gridLayout = [
        GridItem(.flexible(minimum: 150, maximum: 200), spacing: 10),
        GridItem(.flexible(minimum: 150, maximum: 200), spacing: 10)
    ]
    
    private func fetchData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let purchasedProductsRef = db.collection("products")
            .whereField("buyerId", isEqualTo: userId)
            .whereField("status", isEqualTo: "unavailable")

        purchasedProductsRef.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }

            purchasedProducts = documents.map { document -> Product in
                let data = document.data()
                return Product(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    itemDescription: data["description"] as? String ?? "",
                    price: data["price"] as? Double ?? 0.0,
                    imageUrl: data["imageUrl"] as? String ?? "",
                    sellerId: data["sellerId"] as? String ?? "",
                    buyerId: data["buyerId"] as? String,
                    category: data["category"] as? String ?? "",
                    status: data["status"] as? String
                )
            }
        }
    }

    private func productCard(for product: Product) -> some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack {
                RemoteImage(url: product.imageUrl)
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .clipped()
                Text(product.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text("£\(product.price, specifier: "%.2f")")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }

    var body: some View {
        VStack {
            Text("Purchased Products")
                .font(.title)
                .padding()

            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: 10) {
                    ForEach(purchasedProducts) { product in
                        productCard(for: product)
                    }
                }
                .padding(10)
            }
        }
        .onAppear {
            fetchData()
        }
    }
}

struct PurchasedProductsView_Previews: PreviewProvider {
    static var previews: some View {
        PurchasedProductsView()
    }
}
