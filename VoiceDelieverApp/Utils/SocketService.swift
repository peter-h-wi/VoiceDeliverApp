//
//  SocketService.swift
//  VoiceDelieverApp
//
//  Created by peter wi on 3/31/22.
//

import Foundation
import SocketIO

final class SocketService: ObservableObject {
    @Published var messages = [String]()
    
    static let shared = SocketService()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    let hostURL = "http://localhost:8080"
    
    init() {
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
        socket.on(clientEvent: .connect) { (data, ack) in
            print("This is finally connected!")
            socket.emit("NodeJS Server Port", "Hello, Node.js Server!")
            print("I emit NodeJS Server Port!")
        }
        
        socket.on("Send Message To Client") { (data, ack) in
            print("Client receive message")
            if let data = data[0] as? [String: String] {
                DispatchQueue.main.async {
                    print(data)
                    print("I received something")
                }
                socket.emit("Client Received Message", "Client Received Message")
                print("I emit Received MEssage Successfully to Server Port!")
            }
        }
        
        socket.on("chat message") { [weak self] (data, ack) in
            if let data = data[0] as? String {
                DispatchQueue.main.async {
                    self?.messages.append(data)
                    print("Chat Message work? YES")
                }
            }
        }
        
        
        socket.on("iOS Client Port") { [weak self] (data, ack) in
            if let data = data[0] as? [String: String], let rawMessage = data["msg"] {
                DispatchQueue.main.async {
                    self?.messages.append(rawMessage)
                    print("iOS Client Port work? YES")
                }
            }
        }
    }
    
    func sendToServer(message: [String: Any]) {
        guard let socket = socket else {
            print("socket for sending message is invalid")
            return
        }
        socket.emit("Send Message To Server", message)
        socket.emit("chat message", "chat message sent")
        print("I sent message to server")
    }
}
