//
//  ChatView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 24/04/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    func sendMessageWithChatUpdate(to recipientId: String, text: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid, !text.isEmpty else { return }

        let db = Firestore.firestore()
        let messagesRef = db.collection("messages")
        let chatsRef = db.collection("chats")

        let messageData: [String: Any] = [
            "text": text,
            "senderId": currentUserId,
            "receiverId": recipientId,
            "timestamp": Timestamp(),
            "participants": [currentUserId, recipientId],
            "isRead": false
        ]

        messagesRef.addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                // Update the chat data
                let chatId = "\(currentUserId)_\(recipientId)"
                let chatData: [String: Any] = [
                    "lastMessage": text,
                    "timestamp": Timestamp(),
                    "participants": [currentUserId, recipientId]
                ]

                // Add/Update the chat document in Firestore
                chatsRef.document(chatId).setData(chatData, merge: true) { error in
                    if let error = error {
                        print("Error updating chat data: \(error)")
                    } else {
                        print("Chat data updated successfully!")
                    }
                }
            }
        }
    }
    
    func markMessagesAsRead(senderId: String, receiverId: String) {
        guard (Auth.auth().currentUser?.uid) != nil else { return }

        let db = Firestore.firestore()
        let messagesRef = db.collection("messages")

        messagesRef
            .whereField("senderId", isEqualTo: senderId)
            .whereField("receiverId", isEqualTo: receiverId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching unread messages: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        messagesRef.document(document.documentID).updateData([
                            "isRead": true
                        ]) { error in
                            if let error = error {
                                print("Error updating message: \(error)")
                            } else {
                                print("Message updated successfully!")
                            }
                        }
                    }
                }
            }
    }

}

struct Message: Identifiable, Equatable {
    let id: String
    let text: String
    let senderId: String
    let receiverId: String
    let timestamp: Timestamp
    
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatView: View {
    let recipientId: String
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var newMessage = ""
    @State private var recipientName: String = ""
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private var lastMessageId: String? {
        chatViewModel.messages.last?.id
    }
    
    private func fetchMessages() {
        guard let currentUserId = currentUserId else { return }
        
        let db = Firestore.firestore()
        let messagesRef = db.collection("messages")
        
        messagesRef
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching messages: \(error!)")
                    return
                }
                
                chatViewModel.messages = documents.compactMap { document in
                    let data = document.data()
                    guard
                        let text = data["text"] as? String,
                        let senderId = data["senderId"] as? String,
                        let receiverId = data["receiverId"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        return nil
                    }
                    
                    if (senderId == currentUserId && receiverId == recipientId) || (senderId == recipientId && receiverId == currentUserId) {
                        return Message(
                            id: document.documentID,
                            text: text,
                            senderId: senderId,
                            receiverId: receiverId,
                            timestamp: timestamp
                        )
                    } else {
                        return nil
                    }
                }.sorted(by: { $0.timestamp.dateValue() < $1.timestamp.dateValue() })
        }
    }

    
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
    
    private func sendMessage() {
        guard let currentUserId = currentUserId, !newMessage.isEmpty else { return }
        
        let db = Firestore.firestore()
        let messagesRef = db.collection("messages")
        let chatsRef = db.collection("chats")
        
        let messageData: [String: Any] = [
            "text": newMessage,
            "senderId": currentUserId,
            "receiverId": recipientId,
            "timestamp": Timestamp(),
            "participants": [currentUserId, recipientId],
            "isRead": false
        ]
        
        messagesRef.addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                // Update the chat data
                let chatId = "\(currentUserId)_\(recipientId)"
                let chatData: [String: Any] = [
                    "lastMessage": newMessage,
                    "timestamp": Timestamp(),
                    "participants": [currentUserId, recipientId]
                ]
                
                // Add/Update the chat document in Firestore
                chatsRef.document(chatId).setData(chatData, merge: true) { error in
                    if let error = error {
                        print("Error updating chat data: \(error)")
                    } else {
                        print("Chat data updated successfully!")
                    }
                }
                newMessage = ""
            }
        }
    }
    
    

    var body: some View {
        VStack {
            ScrollViewReader{ proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(chatViewModel.messages) { message in
                            if message.senderId == currentUserId {
                                HStack {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.trailing, 20)
                                        .padding(.bottom, 4)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                                }
                            } else {
                                HStack {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .foregroundColor(Color.primary)
                                        .cornerRadius(10)
                                        .padding(.leading, 20)
                                        .padding(.bottom, 4)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .onChange(of: chatViewModel.messages) { _ in
                        scrollToBottom(proxy)
                    }
                }
                .onAppear {
                    scrollToBottom(proxy)
                }
            }
            
            HStack {
                TextField("Enter message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 24))
                        .padding(.trailing)
                }
            }
        }
        .padding(.top)
        .navigationBarTitle(" \(recipientName)", displayMode: .inline)
        .onAppear {
            fetchMessages()
            fetchRecipientName()
            chatViewModel.markMessagesAsRead(senderId: recipientId, receiverId: currentUserId ?? "")
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let lastMessageId = lastMessageId {
                proxy.scrollTo(lastMessageId, anchor: .bottom)
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(recipientId: "Jiaqi Xie")
    }
}
