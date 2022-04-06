//
//  SocketService.swift
//  VoiceDelieverApp
//
//  Created by peter wi on 3/31/22.
//

import Foundation
import SocketIO

final class SocketService: ObservableObject {
    
    @Published var status = [String]()
    @Published var messages = [Message]()
    
    static let shared = SocketService()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private let hostURL = "http://localhost:8080"
    
    let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ssZZZ"

        configureSocketClient()
        addHandlers()
        establishConnection()
    }
    
    func configureSocketClient() {
        guard let url = URL(string: hostURL) else {
            print("url is invalid")
            return
        }
        print("url is valid")
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        guard let manager = manager else {
            print("manager is invalid")
            return
        }
        print("manager is valid")
        socket = manager.defaultSocket
    }
    
    func establishConnection() {
        guard let socket = socket else {
            print("socket for connection is invalid")
            return
        }
        print("socket for connection is valid")
        
        socket.connect()
    }
    
    func addHandlers() {
        guard let socket = socket else {
            print("socket for handling is invalid")
            return
        }
        
        // When Connection is established
        socket.on(clientEvent: .connect) { (data, ack) in
            print("This is finally connected!")
            // Send: hi message to server
            socket.emit("Hi Server", "Hello, Node.js Server!")
        }
        
        // Received: hi message from server
        socket.on("Hi Client") { [weak self] (data, ack) in
            if let data = data[0] as? [String: String], let rawMessage = data["msg"] {
                DispatchQueue.main.async {
                    self?.status.append(rawMessage)
                    print("iOS Client Port work? YES")
                }
            }
        }
        
        // Received: message from server
        socket.on("Message To Client") { [weak self] (data, ack) in
            if let data = data[0] as? [String: String], let senderID = data["senderID"], let timestamp = data["timestamp"], let groupID = data["groupID"], let audioURL = data["audioURL"] {
                DispatchQueue.main.async {
                    print("Received Message: \(data)")
                    let message = Message(audioURL: audioURL, groupID: groupID, senderID: senderID, timestamp: self?.dateFormatter.date(from: timestamp) ?? Date())
                    self?.messages.append(message)
                    VoiceViewModel.shared.startPlaying2(url: audioURL)
                }
                // Reply: message to server
                print("Reply to server")
                socket.emit("Client Received Message", "Client Received Message")
            }
        }
    }
    
    func sendToServer(message: [String: Any]) {
        guard let socket = socket else {
            print("socket for sending message is invalid")
            return
        }
        // Send: message to server
        socket.emit("Message To Server", message)
        print("I sent message to server")
    }
}
