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
    var category: String
}


struct OnSaleView: View {
    @State private var products: [Product] = []
    @State private var searchText: String = ""
    @State private var isSortPickerShown = false
    @State private var isFilterPickerShown = false
    @State private var selectedSortOption: SortOption = .default
    @State private var selectedFilterOption: FilterOption = .all

    enum SortOption: String, CaseIterable, Identifiable {
        case `default`
        case priceLowToHigh
        case priceHighToLow

        var id: String { self.rawValue }
    }

    enum FilterOption: String, CaseIterable, Identifiable {
        case all
        case electronics = "Electronics"
        case clothing = "Clothing"
        case homeAndKitchen = "Home & Kitchen"
        case books = "Books"
        case toysAndGames = "Toys & Games"
        case sportsAndOutdoors = "Sports & Outdoors"
        case beautyAndPersonalCare = "Beauty & Personal Care"
        case automotive = "Automotive"
        case healthAndWellness = "Health & Wellness"
        case other = "Other"

        var id: String { self.rawValue }
    }

    private var displayedProducts: [Product] {
        var result: [Product] = searchText.isEmpty ? products : products.filter { $0.title.lowercased().contains(searchText.lowercased()) }

        switch selectedFilterOption {
        case .all:
            break
        default:
            result = result.filter { $0.category.lowercased() == selectedFilterOption.rawValue.lowercased() }
        }

        switch selectedSortOption {
        case .priceLowToHigh:
            result.sort { $0.price < $1.price }
        case .priceHighToLow:
            result.sort { $0.price > $1.price }
        case .default:
            break
        }

        return result
    }
    
    let gridLayout = [
        GridItem(.flexible(minimum: 150, maximum: 200), spacing: 10),
        GridItem(.flexible(minimum: 150, maximum: 200), spacing: 10)
    ]

    private func fetchData() {
        let db = Firestore.firestore()
        let productsRef = db.collection("products").whereField("status", isEqualTo: "available")

        productsRef.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }

            products = documents.map { document -> Product in
                let data = document.data()
                return Product(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    itemDescription: data["description"] as? String ?? "",
                    price: data["price"] as? Double ?? 0.0,
                    imageUrl: data["imageUrl"] as? String ?? "",
                    sellerId: data["sellerId"] as? String ?? "",
                    buyerId: data["buyerId"] as? String,
                    category: data["category"] as? String ?? ""
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
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal, 11)
                    

                HStack {
                    Button(action: {
                        isSortPickerShown.toggle()
                    }) {
                        HStack {
                            Text("Sort")
                            Image(systemName: "arrow.up.arrow.down.circle")
                        }
                        .padding(.horizontal, 55)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $isSortPickerShown) {
                        VStack {
                            Text("Sort Options")
                                .font(.title)
                                .padding()
                            ForEach(SortOption.allCases) { option in
                                Button(action: {
                                    selectedSortOption = option
                                    isSortPickerShown = false
                                }) {
                                    Text(option.rawValue.capitalized)
                                        .padding()
                                        .foregroundColor(selectedSortOption == option ? .blue : .black)
                                }
                            }
                        }
                    }


                    Button(action: {
                        isFilterPickerShown.toggle()
                    }) {
                        HStack {
                            Text("Filter")
                            Image(systemName: "line.horizontal.3.decrease.circle")
                        }
                        .padding(.horizontal, 55)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $isFilterPickerShown) {
                        VStack {
                            Text("Filter Options")
                                .font(.title)
                                .padding()
                            ForEach(FilterOption.allCases) { option in
                                Button(action: {
                                    selectedFilterOption = option
                                    isFilterPickerShown = false
                                }) {
                                    Text(option.rawValue.capitalized)
                                        .padding()
                                        .foregroundColor(selectedFilterOption == option ? .blue : .black)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: gridLayout, spacing: 10) {
                        ForEach(displayedProducts) { product in
                            productCard(for: product)
                        }
                    }
                    .padding(10)
                }
            }
            .navigationTitle("On Sale")
            .onAppear {
                fetchData()
            }
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.systemBlue))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct OnSaleView_Previews: PreviewProvider {
    static var previews: some View {
        OnSaleView()
    }
}
