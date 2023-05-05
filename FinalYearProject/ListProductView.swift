//
//  ListProductView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 21/04/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ListProductView: View {
    @State private var productTitle = ""
    @State private var productPrice = ""
    @State private var productDescription = ""
    @State private var productImage: UIImage?
    @State private var showingImagePicker = false
    @State private var selectedCategory: String? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showingCustomAlert = false

    
    private let categories = [
        "Electronics", "Clothing", "Home & Kitchen", "Books", "Toys & Games", "Sports & Outdoors", "Beauty & Personal Care", "Automotive", "Health & Wellness", "Other"
    ]

    // Custom binding for category selection
    private var categoryBinding: Binding<String?> {
        Binding(
            get: { selectedCategory },
            set: { newValue in
                if let newValue = newValue, !newValue.isEmpty {
                    selectedCategory = newValue
                } else {
                    selectedCategory = nil
                }
            }
        )
    }

    private func saveProduct() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        guard let productImage = productImage else {
            print("Product image missing")
            return
        }

        guard !productTitle.isEmpty else {
            print("Product title missing")
            return
        }

        guard let price = Double(productPrice) else {
            print("Invalid product price")
            return
        }
        
        guard let category = selectedCategory else {
            print("Category not selected")
            return
        }

        // Upload product image and save product data to Firestore
        uploadProductImage(image: productImage) { imageUrl in
            guard let imageUrl = imageUrl else {
                print("Error uploading image")
                return
            }

            let productData: [String: Any] = [
                "title": self.productTitle,
                "price": price,
                "description": self.productDescription,
                "imageUrl": imageUrl,
                "category": category,
                "sellerId": userId,
                "timestamp": Timestamp(),
                "status": "available",
                "buyerId": ""
            ]

            let db = Firestore.firestore()
            db.collection("products").addDocument(data: productData) { error in
                if let error = error {
                    print("Error saving product data: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.showingCustomAlert = true
                } else {
                    print("Product data saved successfully")
                    self.resetForm()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func uploadProductImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard (Auth.auth().currentUser?.uid) != nil else {
            print("User not logged in")
            completion(nil)
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to JPEG data")
            completion(nil)
            return
        }

        let imageId = UUID().uuidString
        let storageRef = Storage.storage().reference().child("product_images/\(imageId).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting image download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let imageUrl = url?.absoluteString else {
                    print("Failed to get image download URL")
                    completion(nil)
                    return
                }

                completion(imageUrl)
            }
        }
    }

    private func resetForm() {
        productTitle = ""
        productPrice = ""
        productDescription = ""
        productImage = UIImage(systemName: "photo")!
        selectedCategory = ""
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                Form {
                    Section {
                        TextField("Product Title", text: $productTitle)
                        TextField("Price", text: $productPrice)
                    }
                    
                    Section {
                        TextEditor(text: $productDescription)
                            .frame(height: 100)
                    }
                    
                    Section {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let productImage = productImage {
                                Image(uiImage: productImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            } else {
                                Text("Select Product Image")
                            }
                        }
                        .sheet(isPresented: $showingImagePicker, onDismiss: nil) {
                            ImagePicker(selectedImage: $productImage, sourceType: .photoLibrary)
                        }
                    }
                    
                    Section {
                        Picker(selection: categoryBinding, label: selectedCategory == nil ? Text("Category").foregroundColor(.gray) : Text("Category")) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category as String?)
                            }
                        }
                    }
                    
                    Section {
                        Button(action: saveProduct) {
                            Text("List Product")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .navigationTitle("List Product")
                if showAlert {
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showAlert = false
                        }
                }
            }
        }
    }
}

struct ListProductView_Previews: PreviewProvider {
    static var previews: some View {
        ListProductView()
    }
}
