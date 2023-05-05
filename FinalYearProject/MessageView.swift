//
//  MessageView.swift
//  FinalYearProject
//
//  Created by Jiaqi Xie on 24/04/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Chat: Identifiable {
    var id: String
    var chatId: String
    var senderId: String
    var lastMessage: String
    var timestamp: String
    var recipientId: String
    var hasUnreadMessage: Bool
}

struct MessageView: View {
    @State private var chats: [Chat] = []
    @StateObject private var chatViewModel = ChatViewModel()

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    private func fetchChats() {
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

                var groupedChats: [String: Chat] = [:]

                let sortedDocuments = documents.sorted { doc1, doc2 in
                    guard let timestamp1 = doc1["timestamp"] as? Timestamp,
                          let timestamp2 = doc2["timestamp"] as? Timestamp else {
                        return false
                    }
                    return timestamp1.dateValue() > timestamp2.dateValue()
                }

                for document in sortedDocuments {
                    let data = document.data()
                    guard
                        let lastMessage = data["text"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp,
                        let participants = data["participants"] as? [String],
                        let isRead = data["isRead"] as? Bool,
                        let recipientId = participants.first(where: { $0 != currentUserId }),
                        let senderId = participants.first(where: { $0 != recipientId }),
                        let receiverId = data["receiverId"] as? String
                    else {
                        continue
                    }

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd HH:mm"
                    let formattedTimestamp = dateFormatter.string(from: timestamp.dateValue())

                    let chat = Chat(
                        id: document.documentID,
                        chatId: document.documentID,
                        senderId: senderId,
                        lastMessage: lastMessage,
                        timestamp: formattedTimestamp,
                        recipientId: recipientId,
                        hasUnreadMessage: !isRead && receiverId == currentUserId
                    )

                    if groupedChats[recipientId] == nil {
                        groupedChats[recipientId] = chat
                    }
                }

                chats = Array(groupedChats.values)
            }
    }

    
    private func deleteChat(at offsets: IndexSet) {
        let db = Firestore.firestore()

        offsets.forEach { index in
            let chat = chats[index]
            let chatRef = db.collection("chats").document(chat.chatId)

            chatRef.delete { error in
                if let error = error {
                    print("Error deleting chat: \(error)")
                } else {
                    print("Chat successfully deleted")
                }
            }
        }

        chats.remove(atOffsets: offsets)
    }


    var body: some View {
        NavigationView {
            List {
                ForEach(chats) { chat in
                    NavigationLink(destination: ChatView(recipientId: chat.recipientId)) {
                        ChatBoxView(recipientId: chat.recipientId, lastMessage: chat.lastMessage, timestamp: chat.timestamp, hasUnreadMessage: chat.hasUnreadMessage)
                    }
                }.onDelete(perform: deleteChat)
            }.navigationTitle("Messages")
        }.onAppear {
            fetchChats()
        }.onChange(of: chatViewModel.messages) { _ in
            fetchChats()
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}

