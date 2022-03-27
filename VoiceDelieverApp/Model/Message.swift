//
//  Message.swift
//  VoiceDelieverApp
//
//  Created by peter wi on 3/26/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable {
    @DocumentID var id: String?
    
    let audioURL, groupID, senderID: String
    let timestamp: Date
    let formatter = RelativeDateTimeFormatter()
    
    var timeAgo: String {
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
