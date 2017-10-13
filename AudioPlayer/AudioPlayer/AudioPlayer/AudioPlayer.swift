//
//  AudioPlayer.swift
//  Inabit
//
//  Created by Appinventiv on 28/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import AVFoundation

let audioPlayer = AudioPlayer.shared

class AudioPlayer: NSObject{
    
    static var shared = AudioPlayer()
    
    fileprivate var url: URL?
    fileprivate var indexPath: IndexPath?
    //fileprivate var duration: Float64
    fileprivate var audioPlayer: AVAudioPlayer?
    fileprivate let session = AVAudioSession.sharedInstance()
    fileprivate var link: CADisplayLink?
    fileprivate var avPlayer: AVPlayer?
    fileprivate var playerStack: [(URL,IndexPath?)] = []
    var state: AudioPlayerState = .none
    weak var delegate: AudioPlayerDelegate?
    
    override init(){
        
        //self.url = url
        //duration = CMTimeGetSeconds(AVURLAsset(url: url).duration)
        //super.init()
    }
    
    func playAudio(url: URL, atIndex indexPath: IndexPath? = nil){
        
        DispatchQueue.global(qos: .background).async {
            
            if self.state == .playing{
                
                if let playItem = self.playerStack.first{
                    
                    if url == playItem.0{
                        self.pause()
                    }else{
                        self.stop()
                        self.play(url: url, atIndex: indexPath)
                    }
                }else {
                    self.stop()
                    self.play(url: url, atIndex: indexPath)
                }
                
            }else if self.state == .pause{
                
                if let playItem = self.playerStack.first{
                    
                    if url == playItem.0{
                        
                        //self.audioPlayer?.play()
                        self.resume()
                    }else{
                        self.stop()
                        self.play(url: url, atIndex: indexPath)
                    }
                }else {
                    self.stop()
                    self.play(url: url, atIndex: indexPath)
                }
                
            }else{
                
                self.play(url: url, atIndex: indexPath)
            }
        }
    }
    
    private func play(url: URL, atIndex indexPath: IndexPath? = nil){
        
        if !self.playerStack.isEmpty{
            
            let result = self.playerStack.removeFirst()
            self.delegate?.didRemoveFromStack(url: result.0, atIndex: result.1)
        }
        self.url = url
        self.indexPath = indexPath
        self.playerStack.append((url,indexPath))
        
        do{
            try self.session.setCategory(AVAudioSessionCategoryPlayback)
            let data = try Data(contentsOf: url)
            //audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer!.delegate = self
            
            if self.audioPlayer!.prepareToPlay(){
                
                self.audioPlayer?.play()
                self.state = .playing
                self.delegate?.didStartPlaying(url: url, player: self.audioPlayer, atIndex: indexPath)
                DispatchQueue.main.async(execute: {
                    self.startMetering()
                })
                //self.startMetering()
            }
        }
        catch let error{
            
            self.delegate?.didFinishPlaying(with: error, url: url, player: self.audioPlayer, atIndex: indexPath)
            print(error)
        }
    }
    
    func pause(){
        
        switch state {
            
        case .playing:
            
            audioPlayer?.pause()
            delegate?.playerDidPause(url: url, player: audioPlayer, atIndex: indexPath)
            state = .pause
            //stopMetering()
            
        default:
            break
        }
    }
    
    func resume(){
        
        delegate?.playerDidResume(url: url, player: audioPlayer, atIndex: indexPath)
        self.audioPlayer?.play()
        state = .playing
        //startMetering()
    }
    
    func stop() {
        
        switch state {
            
        case .playing:
            
            audioPlayer?.stop()
            delegate?.didFinishPlaying(url: url, player: audioPlayer, atIndex: indexPath)
            audioPlayer = nil
            stopMetering()
            playerStack = []
        default:
            break
        }
        
        state = .none
    }
    
    func getDuration(url: URL)->Float64{
        
        let asset = AVURLAsset(url: url)
        let audioDuration = asset.duration
        return CMTimeGetSeconds(audioDuration)
    }
    
    func getStatus()->AudioPlayerState{
        
        return self.state
    }
    
    // MARK: - Metering
    
    func updateProgress() {
        
        guard let audioPlayer = audioPlayer else  { return }
        let progress = audioPlayer.currentTime / audioPlayer.duration
        delegate?.didUpdateProgress(progress: Float(progress), seconds: Int(audioPlayer.currentTime), player: audioPlayer, atIndex: indexPath)
    }
    
    fileprivate func startMetering() {
        
        link = CADisplayLink(target: self, selector: #selector(AudioPlayer.updateProgress))
        link?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func stopMetering() {
        
        link?.invalidate()
        link = nil
    }
}

extension AudioPlayer: AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        stopMetering()
        //player.ur
        if flag{
            delegate?.didFinishPlaying(url: url, player: player, atIndex: indexPath)
        }else{
            delegate?.didFinishPlaying(with: nil, url: url, player: player, atIndex: indexPath)
        }
        
        state = .stop
    }
}
