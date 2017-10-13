//
//  AudioPlayerDelegate.swift
//  AudioPlayer
//
//  Created by Appinventiv on 04/10/17.
//  Copyright © 2017 Com. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerDelegate: class{
    
    func didStartPlaying(url: URL?, player: AVAudioPlayer?, atIndex indexPath: IndexPath?)
    func didUpdateProgress(progress: Float,seconds: Int ,player: AVAudioPlayer, atIndex indexPath: IndexPath?)
    func didFinishPlaying(url: URL?, player: AVAudioPlayer?, atIndex indexPath: IndexPath?)
    func didFinishPlaying(with error: Error?, url: URL?, player: AVAudioPlayer?, atIndex indexPath: IndexPath?)
    func didStopPlaying(url: URL?, player: AVAudioPlayer, atIndex indexPath: IndexPath?)
    func didRemoveFromStack(url: URL?, atIndex indexPath: IndexPath?)
    func playerDidPause(url: URL?, player: AVAudioPlayer?, atIndex indexPath: IndexPath?)
    func playerDidResume(url: URL?, player: AVAudioPlayer?, atIndex indexPath: IndexPath?)
}
