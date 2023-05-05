//
//  ChatBoxView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 24/04/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ChatBoxView: View {
    let recipientId: String
    let lastMessage: String
    let timestamp: String
    let hasUnreadMessage: Bool

    @State private var recipientName: String = ""
    
    private func fetchRecipientName() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(recipientId)

        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching recipient name: \(error)")
                return
            }

            if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                self.recipientName = documentSnapshot.data()?["name"] as? String ?? "Unknown"
            }
        }
    }
    
    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))

                if hasUnreadMessage {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 6, y: -6)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recipientName)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(timestamp)
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Text(lastMessage)
                    .font(.subheadline)
                    .lineLimit(1)

            }
            Spacer()
        }
        .padding(.vertical, 8)
        .onAppear {
            fetchRecipientName()
        }
    }
}

struct ChatBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBoxView(recipientId: "John Doe", lastMessage: "Hey, how are you?", timestamp: "14:30", hasUnreadMessage: true)
    }
}
