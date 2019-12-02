//
//  MusicHelper.swift
//  OwlGame
//
//  Created by Никита Главацкий on 13/03/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol MusicDelegate: class {
    func updateStates()
}

enum Effect: String{
    case star = "starSound"
    case crown = "crownSound"
    case pro = "123-2"
}

enum Hint{
    case auto
    case manual
}

class MusicHelper: NSObject {
    static let sharedHelper = MusicHelper()
    var audioPlayer: AVAudioPlayer?
    var effectPlayer: AVAudioPlayer?
    var hintAndSpeechPlayer: AVAudioPlayer?
    var isRecognition: Bool = false
    weak var delegate: MusicDelegate?
    
    func playBackgroundMusic() {
        setAudioSession()
        let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mp3")!)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:aSound as URL)
            audioPlayer!.numberOfLoops = -1
            if UserDefaults.standard.getFirstLaunchMusic(){
                audioPlayer!.numberOfLoops = 1
            }
            audioPlayer!.delegate = self
//            audioPlayer!.prepareToPlay()
            if UserDefaults.standard.getBackgroundMusicState() {
                audioPlayer!.play()
            }
            
        } catch {
            print("Cannot play the file")
        }
    }
    
    
    
    func playEffect(of effect: Effect, forNumber number: Int = -1){
        var path: String? = ""
        if number >= 0 {
            path = Bundle.main.path(forResource: "\(effect.rawValue)\(number)", ofType: "mp3")
        }else{
            path = Bundle.main.path(forResource: "\(effect.rawValue)", ofType: "mp3")
        }
        
        if let path = path{
            let aSound = NSURL(fileURLWithPath: path)
            if let effectPlayer = effectPlayer{
                if effectPlayer.isPlaying{
                    effectPlayer.stop()
                }
            }
            do{
                effectPlayer = try AVAudioPlayer(contentsOf: aSound as URL)
                effectPlayer!.play()
            }
            catch{
                
            }
        }
        
    }
    
    func playVoiceSwitchEffect(type: Int, view: ToolsUIView){
        setAudioSession()
        do{
            let path = Bundle.main.path(forResource: "\(Constants.voiceTypes[type])_hello", ofType: "mp3")
            var aSound: NSURL
            if let path = path{
                aSound = NSURL(fileURLWithPath: path)
            }else{
                return
            }
            if let effectPlayer = effectPlayer{
                if effectPlayer.isPlaying{
                    effectPlayer.stop()
                }
            }
            
            effectPlayer = try AVAudioPlayer(contentsOf: aSound as URL)
            effectPlayer?.delegate = view
            effectPlayer?.prepareToPlay()
            effectPlayer!.play()
        }catch{
            
        }
    }
    
    func continueBackgroundMusic(){
        setAudioSession()
        if UserDefaults.standard.getBackgroundMusicState() {
            if let audioPlayer = audioPlayer{
                audioPlayer.play()
            }
        }
    }
    
    func setAudioSession(){
        print("set audio session")
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch let error as NSError {
            print(error.description)
        }
    }
    
    func playHint(for type: Hint, forSound soundUrl: URL?, delegate: ToolsUIView?){
        if type == .auto{
            if !UserDefaults.standard.getAudioResults(){
                return
            }
        }
        if let audioURL = soundUrl{
            do {
                if let hintPlayer = hintAndSpeechPlayer{
                    if hintPlayer.isPlaying{
                        hintPlayer.stop()
                    }
                }
                
                if SREngine.sharedInstance.isActive && !SREngine.sharedInstance.isPaused {
                    SREngine.sharedInstance.pause()
                }
                setAudioSession()
                
                hintAndSpeechPlayer = try AVAudioPlayer(contentsOf: audioURL)
                guard hintAndSpeechPlayer != nil else { return }
                
                if let delegate = delegate {
                    hintAndSpeechPlayer?.delegate = delegate
                }
                hintAndSpeechPlayer?.prepareToPlay()
                hintAndSpeechPlayer?.play()
            }catch{
                
            }
        }
    }
    
    func stopEffect(){
        if let audioPlayer = effectPlayer{
            audioPlayer.stop()
        }
    }
    
    func stopBackgroundMusic(){
        if let audioPlayer = audioPlayer{
            audioPlayer.pause()
            print("stop background")
        }
    }
    
    func stopHint(){
        if let player = hintAndSpeechPlayer{
            player.stop()
        }
    }
    
    func hintIsPlaying() -> Bool{
        if let player = hintAndSpeechPlayer{
            return player.isPlaying
        }
        return false
    }
    
}

extension MusicHelper: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if UserDefaults.standard.getFirstLaunchMusic(){
            UserDefaults.standard.setFirstLaunchMusic(state: false)
            UserDefaults.standard.setBackgroundMusic(state: false)
            if let delegate = delegate{
                delegate.updateStates()
            }
        }
    }
}
