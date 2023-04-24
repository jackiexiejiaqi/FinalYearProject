//
//  PurchaseView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 22/04/2023.
//

import SwiftUI

struct PurchaseView: View {
    @Binding var isPresented: Bool
    let product: Product
    
    @State private var location: String = ""
    @State private var transactionDate: Date = Date()
    
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
                    // Implement your purchase confirmation logic here
                    print("Purchase confirmed")
                    isPresented = false
                }) {
                    Text("Confirm Purchase")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Purchase \(product.title)")
        }
    }
}
