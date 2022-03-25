//
//  VoiceViewModel.swift
//  VoiceDelieverApp
//
//  Created by peter wi on 3/24/22.
//

import Foundation
import AVFoundation

class VoiceViewModel : NSObject, ObservableObject , AVAudioPlayerDelegate{
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    
    var indexOfPlayer = 0
    let dateFormatter = DateFormatter()

    // check if recording has started , we will need it while playing with UI.
    @Published var isRecording : Bool = false
    
    // Array to store our URL of recordings and some details, and the type of that array is Recording.
    @Published var recordingsList = [Recording]()
    
    @Published var countSec = 0
    @Published var timerCount : Timer?
    @Published var blinkingCount : Timer?
    @Published var timer : String = "0:00"
    @Published var toggleColor : Bool = false
    
    var playingURL : URL?
    
    // We are initialising and call a function here letter .
    override init() {
        dateFormatter.dateFormat = "dd-MM-YY 'at' HH:mm:ss"
        super.init()
        
        fetchAllRecording()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       
        for i in 0..<recordingsList.count {
            if recordingsList[i].fileURL == playingURL {
                recordingsList[i].isPlaying = false
            }
        }
    }
    
  
    // Creating the start recording function and doing some formalities , but there are some lines to understand are as follow .
    func startRecording() {
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup the Recording")
        }
        
        // The path will contain the directory of the recording.
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // a unique name to every recording file , so we are giving the name as current date and time . Notice the last words “.m4a” is really important to give . We are using a function call to fetch the current date into string . You can find that function in extension folder in project repository.
        let fileName = path.appendingPathComponent("CO-Voice : \(dateFormatter.string(from: Date())).m4a")

        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            // When we started our recording successfully , then we are doing true that variable.
            isRecording = true
            
            timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timer = self.covertSecToMinAndHour(seconds: self.countSec)
            })
            blinkColor()
            
        } catch {
            print("Failed to Setup the Recording")
        }
    }
    
    // function to stop the recording and converting that recording variable as false.
    func stopRecording(){
        
        audioRecorder.stop()
        
        isRecording = false
        
        self.countSec = 0
        
        timerCount!.invalidate()
        blinkingCount!.invalidate()
        
    }
    
    
    func fetchAllRecording(){
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        
        // We are traveling in our directory of recordings and appending the recording in our array.
        for i in directoryContents {
            recordingsList.append(Recording(fileURL : i, createdAt:getFileDate(for: i), isPlaying: false))
        }
        
        // We are sorting the array as in descending order.
        recordingsList.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
        
    }
    
    // We are passing the url of recorded file , so that we can play that audio url only.
    func startPlaying(url : URL) {
        
        playingURL = url
        
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            // Here we iterating over the list and making the isPlaying variable as true since it is playing now .
            for i in 0..<recordingsList.count {
                if recordingsList[i].fileURL == url {
                    recordingsList[i].isPlaying = true
                }
            }
            
        } catch {
            print("Playing Failed")
        }
        
        
    }
    
    // Stop playing will stop all the playing audios , but the reason we are taking the url is to toggle the variable in our list of recordings .
    func stopPlaying(url : URL) {
        
        audioPlayer.stop()
        // We are iterating in our list and making that recording file as false .
        for i in 0..<recordingsList.count {
            if recordingsList[i].fileURL == url {
                recordingsList[i].isPlaying = false
            }
        }
    }
    
    // To delete the recording from the system , we need their url .
    func deleteRecording(url : URL) {
        
        do {
            // In this line , we are deleting that recording .
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Can't delete")
        }
        
        // We are iterating over the our recording list and checking if the audio is playing , if playing then stop it the check if it is the recording we want to delete.
        for i in 0..<recordingsList.count {
            
            if recordingsList[i].fileURL == url {
                if recordingsList[i].isPlaying == true{
                    stopPlaying(url: recordingsList[i].fileURL)
                }
                // Finally we are deleting recording from our recording array .
                recordingsList.remove(at: i)
                
                break
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
