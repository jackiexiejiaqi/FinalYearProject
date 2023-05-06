//
//  PurchaseView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 22/04/2023.
//

import SwiftUI
import FirebaseFirestore

struct PurchaseView: View {
    @Binding var isPresented: Bool
    let product: Product
    
    @State private var location: String = ""
    @State private var transactionDate: Date = Date().addingTimeInterval(60 * 60) // Add one hour to the current time
    @StateObject private var chatViewModel = ChatViewModel()

    private func sendTransactionDetailsMessage() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: transactionDate)
        
        let message = "Hello, I've confirmed the purchase of '\(product.title)'. Let's meet at '\(location)' on \(formattedDate) to complete the transaction."
        
        chatViewModel.sendMessageWithChatUpdate(to: product.sellerId, text: message)
    }
    
    private func updateProductStatus() {
        let db = Firestore.firestore()
        let productRef = db.collection("products").document(product.id)
        
        productRef.updateData([
            "status": "unavailable"
        ]) { error in
            if let error = error {
                print("Error updating product status: \(error)")
            } else {
                print("Product status updated successfully")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Transaction Location", text: $location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(
                        Text("Only within the University of Leeds")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemBackground))
                            .foregroundColor(.secondary)
                            .offset(y: -8), // Adjust the vertical position
                        alignment: .topLeading
                    )
                
                DatePicker("Transaction Time", selection: $transactionDate, displayedComponents: [.date, .hourAndMinute])
                    .padding()
                
                Button(action: {
                    print("Purchase confirmed")
                    sendTransactionDetailsMessage()
                    updateProductStatus()
                    isPresented = false
                }) {
                    Text("Confirm Purchase")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(location.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(location.isEmpty) // Disable the button if the location is empty
            }
            .navigationTitle("Purchase \(product.title)")
        }
    }
}
