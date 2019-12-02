//
//  toolsUIView.swift
//  OwlGame
//
//  Created by Никита Главацкий on 19/06/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//

import UIKit
import AVFoundation

protocol ToolsDelegate: class {
    func voiceChanged() -> Void
    func voiceDidFinishChanging() -> Void
}

class ToolsUIView: UIView {
    
    weak var delegate: ToolsDelegate?
    
    var buttonSize: CGFloat = 45
    
    weak var soundButton: UIButton!
    weak var voiceTypeButton: UIButton!
    
    let enabledVoices = [true, //girl
                         true, //woman
                         true, //man
                         true] //boy
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initVoiceButton(){
        let voiceTypeButton = UIButton(frame: CGRect(x: 50, y: 0, width: 40, height: 40))
        voiceTypeButton.imageView?.contentMode = .scaleToFill
        voiceTypeButton.addTarget(self, action: #selector(voiceTapped(_sender:)), for: .touchUpInside)
        voiceTypeButton.contentVerticalAlignment = .fill
        voiceTypeButton.contentHorizontalAlignment = .fill
        self.addSubview(voiceTypeButton)
        self.voiceTypeButton = voiceTypeButton
        setVoiceTypeImage()
    }
    
    func initSoundButton(){
        let soundButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        if !UserDefaults.standard.getBackgroundMusicState() {
            
            soundButton.setImage(#imageLiteral(resourceName: "soundOff"), for: .normal)
        }else{
            soundButton.setImage(#imageLiteral(resourceName: "soundOn"), for: .normal)
        }
//        soundButton.imageEdgeInsets = UIEdgeInsets(top: 55, left: 55, bottom: 55, right: 55)
//        soundButton.imageView?.contentMode = UIView.C8ontentMode.scaleAspectFit
        soundButton.contentVerticalAlignment = .fill
        soundButton.contentHorizontalAlignment = .fill
        soundButton.addConstraint(NSLayoutConstraint(item: soundButton, attribute: .height, relatedBy: .equal, toItem: soundButton, attribute: .width, multiplier: 8.0 / 9.0, constant: 0))
//        soundButton.contentMode = .sc aleAspectFit
        soundButton.addTarget(self, action: #selector(soundTapped(_sender:)), for: .touchUpInside)
        self.addSubview(soundButton)
        self.soundButton = soundButton
    }
    
    func initVoiceButtonConstraits(){
        let margins = self.layoutMarginsGuide
        voiceTypeButton.translatesAutoresizingMaskIntoConstraints = false
        voiceTypeButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        voiceTypeButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        voiceTypeButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        voiceTypeButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
    }
    
    func initSoundButtonConstraits(){
        let margins = self.layoutMarginsGuide
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        soundButton.trailingAnchor.constraint(equalTo: voiceTypeButton.leadingAnchor, constant: -15).isActive = true
        soundButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        soundButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        soundButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
    }
    
    func constructView(){
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone{
            self.buttonSize = 35
        }
        
        initVoiceButton()
        initSoundButton()

        self.backgroundColor = #colorLiteral(red: 0.7627626061, green: 0.1724063158, blue: 0.1582213342, alpha: 0)
        initSoundButtonConstraits()
        initVoiceButtonConstraits()
        
        MusicHelper.sharedHelper.delegate = self
    }
    
    @objc func soundTapped(_sender: UIButton){
        let bgMusicState = UserDefaults.standard.getBackgroundMusicState()
        UserDefaults.standard.setBackgroundMusic(state: !bgMusicState)
        if bgMusicState{
            _sender.setImage(#imageLiteral(resourceName: "soundOff"), for: .normal)
            MusicHelper.sharedHelper.stopBackgroundMusic()
        }else{
            _sender.setImage(#imageLiteral(resourceName: "soundOn"), for: .normal)
            MusicHelper.sharedHelper.playBackgroundMusic()
        }
        
    }
    
    func updateView(){
        let bgMusicState = UserDefaults.standard.getBackgroundMusicState()
        if !bgMusicState{
            soundButton.setImage(#imageLiteral(resourceName: "soundOff"), for: .normal)
        }else{
            soundButton.setImage(#imageLiteral(resourceName: "soundOn"), for: .normal)
        }
        setVoiceTypeImage()
    }
    
    @objc func voiceTapped(_sender: UIButton){
        MusicHelper.sharedHelper.stopEffect()
        var voiceType = UserDefaults.standard.getVoiceType()
        while !enabledVoices[(voiceType+1)%4]{
           voiceType = (voiceType+1)%4
        }
        UserDefaults.standard.setVoiceType(state: (voiceType+1)%4)
        setVoiceTypeImage()
        if let delegate = delegate{
            delegate.voiceChanged()
        }
        MusicHelper.sharedHelper.playVoiceSwitchEffect(type: (voiceType+1)%4, view: self)
    }
    
    
    
    func setVoiceTypeImage(){
        let voiceType = UserDefaults.standard.getVoiceType()
        switch voiceType {
        case 0:
            voiceTypeButton.setImage(UIImage(named: "girl"), for: .normal)
        case 1:
            voiceTypeButton.setImage(UIImage(named: "woman"), for: .normal)
        case 2:
            voiceTypeButton.setImage(UIImage(named: "man"), for: .normal)
        case 3:
            voiceTypeButton.setImage(UIImage(named: "boy"), for: .normal)
        default:
            voiceTypeButton.setImage(UIImage(named: "girl"), for: .normal)
        }
    }
    
    func disableSoundTap(){
        soundButton.isEnabled = false
    }
    func enableSoundTap(){
        soundButton.isEnabled = true
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension ToolsUIView: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let delegate = delegate{
            delegate.voiceDidFinishChanging()
        }
    }
}

extension ToolsUIView: MusicDelegate{
    func updateStates() {
        self.updateView()
    }
}
