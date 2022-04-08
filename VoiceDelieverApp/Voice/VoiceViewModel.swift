//
//  VoiceViewModel.swift
//  VoiceDelieverApp
//
//  Created by peter wi on 3/24/22.
//

import Foundation
import AVFoundation
import Firebase

class VoiceViewModel : NSObject, ObservableObject , AVAudioPlayerDelegate{
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    
    var indexOfPlayer = 0
    let dateFormatter = DateFormatter()
    
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let storageRef = FirebaseManager.shared.storage.reference()
    
    let socketService = SocketService.shared
    
    var firestoreListener: ListenerRegistration?

    // check if recording has started , we will need it while playing with UI.
    @Published var isRecording : Bool = false
    
    // Array to store our URL of recordings and some details, and the type of that array is Recording.
    @Published var recordingsList = [Recording]()
    @Published var messageList = [Message]()
    @Published var urlList = [String]()
    
    @Published var countSec = 0
    @Published var timerCount : Timer?
    @Published var blinkingCount : Timer?
    @Published var timer : String = "0:00"
    @Published var toggleColor : Bool = false
    @Published var isPlaying : Bool = false
    
    @Published var uploadStatus = "nothing"
    
    static let shared = VoiceViewModel()
        
    var playingURL : URL?
    
    var audioName: String = ""
    
    var audioPlayer2: AVPlayer?
    var playingURL2 : String = ""
    
    // We are initialising and call a function here letter .
    override init() {
        dateFormatter.dateFormat = "dd-MM-YY 'at' HH:mm:ss"
        super.init()
        // fetchAllRecording()
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0..<recordingsList.count {
            if recordingsList[i].fileURL == playingURL {
                recordingsList[i].isPlaying = false
            }
        }
    }
    
    func blinkColor() {
        
        blinkingCount = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (value) in
            self.toggleColor.toggle()
        })
        
    }
    
    
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
}
