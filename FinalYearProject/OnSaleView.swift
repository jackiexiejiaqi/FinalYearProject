//
//  OnSaleView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 22/04/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine
import Foundation

struct RemoteImage: View {
    let url: String
    @State private var imageData: Data = Data()
    @State private var imageSubscription: AnyCancellable?

    var body: some View {
        Group {
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
            } else {
                // Display a placeholder if the image is not available.
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            loadImageFromURL()
        }
        .onDisappear {
            cancelSubscription()
        }
    }

    private func loadImageFromURL() {
        guard let url = URL(string: url) else { return }

        imageSubscription = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .replaceError(with: Data())
            .receive(on: DispatchQueue.main)
            .sink { data in
                imageData = data
            }
    }

    private func cancelSubscription() {
        imageSubscription?.cancel()
    }
}

struct Product: Identifiable {
    var id: String
    var title: String
    var itemDescription: String
    var price: Double
    var imageUrl: String
    var sellerId: String
    var buyerId: String?
}


struct OnSaleView: View {
    @State private var products: [Product] = []

    let gridLayout = [
        GridItem(.flexible(minimum: 150, maximum: 200), spacing: 10),
        GridItem(.flexible(minimum: 150, maximum: 200), spacing: 10)
    ]

    private func fetchData() {
        let db = Firestore.firestore()
        
        // Get the reference to the "products" collection
        let productsRef = db.collection("products").whereField("status", isEqualTo: "available")
        
        // Query the data and map it to the "Product" struct
        productsRef.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            products = documents.map { document in
                let data = document.data()
                return Product(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    itemDescription: data["description"] as? String ?? "",
                    price: data["price"] as? Double ?? 0.0,
                    imageUrl: data["imageUrl"] as? String ?? "",
                    sellerId: data["sellerId"] as? String ?? "",
                    buyerId: data["buyerId"] as? String
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
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: 10) {
                    ForEach(products) { product in
                        productCard(for: product)
                    }
                }
                .padding(10)
            }
            .navigationTitle("On Sale")
            .onAppear {
                fetchData()
            }
        }
    }
}

struct OnSaleView_Previews: PreviewProvider {
    static var previews: some View {
        OnSaleView()
    }
}
