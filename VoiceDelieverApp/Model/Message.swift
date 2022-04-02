//
//  Message.swift
//  VoiceDelieverApp
//
//  Created by peter wi on 3/26/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Codable, Identifiable {
    let id = UUID()
    
    let audioURL, groupID, senderID: String
    let timestamp: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()

        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
