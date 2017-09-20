//
//  MP3Player.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 5. 31..
//  Copyright © 2017년 jmk. All rights reserved.
//

//
//  MP3Player.swift
//  MP3Player
//
//  Created by James Tyner on 7/17/15.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

let AudioPlayerOnTrackChangedNotification = "AudioPlayerOnTrackChangedNotification"
let AudioPlayerOnPlaybackStateChangedNotification = "AudioPlayerOnPlaybackStateChangedNotification"

protocol Mp3PlayerDelegate {
    func Mp3PlayerDelegate(TEST:String)
}

class MP3Player: NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = MP3Player()
    var delegate : Mp3PlayerDelegate?

    let audioSession: AVAudioSession
    let commandCenter: MPRemoteCommandCenter
    let nowPlayingInfoCenter: MPNowPlayingInfoCenter
    let notificationCenter: NotificationCenter

    typealias AudioPlayerDependencies = (audioSession: AVAudioSession, commandCenter: MPRemoteCommandCenter, nowPlayingInfoCenter: MPNowPlayingInfoCenter, notificationCenter: NotificationCenter)
    
    var player: AVAudioPlayer?
    //재생, 일시 정지, 정지를 사용할 클래스
    var currentTrackIndex = -1
    //현재 재생될 mp3 추적
    var tracks: [AlbumInfo] = [AlbumInfo]()
    //mp3 목록에 대한 경로 배열
    var shuffleMode: Bool = false
    var repaetMode : Bool = false //false : 전체 한번 반복, true: 전체 무한 반복
    var oneRepeatMode : Bool = false
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }

    var nowPlayingInfo: [String: AnyObject]?

    override private init() {
        self.commandCenter = MPRemoteCommandCenter.shared()
        self.nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        self.notificationCenter = NotificationCenter.default
        self.audioSession = AVAudioSession.sharedInstance()

        super.init()

        self.configureCommandCenter()
    }

    func setTrack(tracks: [AlbumInfo], index: Int) {
        self.tracks = tracks
        self.currentTrackIndex = index
        queueTrack();

    }

//    func playItem(_ playbackItem: SongInfo) {
//        guard let audioPlayer = try? AVAudioPlayer(contentsOf: playbackItem.songURL as URL) else {
//            self.endPlayback()
//            return
//        }
//        
//        audioPlayer.delegate = self
//        audioPlayer.prepareToPlay()
//        audioPlayer.play()
//        
//        self.audioPlayer = audioPlayer
//        
//        self.currentPlaybackItem = playbackItem
//        
//        self.updateNowPlayingInfoForCurrentPlaybackItem()
//        self.updateCommandCenter()
//        
//        self.notifyOnTrackChanged()
//    }
    
    func queueTrack() {
        if (player != nil) {
            player = nil
        }

        let url = tracks[0].songs[currentTrackIndex].songURL
        do {
            
            try player = AVAudioPlayer(contentsOf: url as URL)

            player?.prepareToPlay()
            player?.delegate = self
            player?.enableRate = true

            do {
                try! self.audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try! self.audioSession.setActive(true)
            } catch {
                print("error")
            }

            self.updateNowPlayingInfoForCurrentPlaybackItem()

            self.notifyOnTrackChanged()
        } catch {
            print("Error ==> \(error)")
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SetTrackNameText"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SetTrackDurationText"), object: nil)

    }
    
    func getUrl(completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()){
        if let url = self.player?.url {
            export(url as URL, completionHandler: completionHandler)
        }
    }
    func play() {
        if player?.isPlaying == false {
            player?.play()
            self.updateNowPlayingInfoElapsedTime()
            self.notifyOnPlaybackStateChanged()
        }
    }

    func stop() {
        if player?.isPlaying == true {
            player?.stop()
            player?.currentTime = 0
        }
    }

    func pause() {
        if player?.isPlaying == true {
            player?.pause()
            self.updateNowPlayingInfoElapsedTime()
            self.notifyOnPlaybackStateChanged()
        }
    }

    func nextSong(songFinishedPlaying: Bool) {
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }

        if shuffleMode == true {
            currentTrackIndex = shuffleIndex()
            
        } else {
            currentTrackIndex += 1
        }

        if currentTrackIndex >= tracks[0].songs.count {
            currentTrackIndex = 0
        }

        queueTrack()
        if playerWasPlaying || songFinishedPlaying {
//            player?.play()
        }
    }

    func previousSong() {
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }

        if shuffleMode == true {
            currentTrackIndex = shuffleIndex()
        } else {
            currentTrackIndex -= 1
        }

        if currentTrackIndex < 0 {
            currentTrackIndex = tracks[0].songs.count - 1
        }

        queueTrack()
        if playerWasPlaying {
//            player?.play()
        }
    }

    func getSampleRate() ->Float64{
        let asset = AVAsset(url:  tracks[0].songs[currentTrackIndex].songURL as URL)
        let track = asset.tracks[0]
        let desc = track.formatDescriptions[0] as! CMAudioFormatDescription
        let basic = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
        
        return (basic?.pointee.mSampleRate)!

    }
    
    func getCurrentTrackName() -> String {
        let trackName = tracks[0].songs[currentTrackIndex].songTitle

        return trackName
    }

    func getCurrentTrackArtist() -> String {
        var artistName:String
        
        if let artist : String = tracks[0].songs[currentTrackIndex].artistName {
            artistName =  artist
        }else {
            artistName = ""
        }
    
        return artistName
    }
    
    func getCurrentTrackArtwork() -> MPMediaItemArtwork{
        var artwork:MPMediaItemArtwork
        
        if let imageSound: MPMediaItemArtwork = tracks[0].songs[currentTrackIndex].artName {
            artwork  = imageSound
        }else {
            artwork  = MPMediaItemArtwork(image: UIImage(named:"basicBackground")!)
        }
        
        return artwork
    }
    
    func setCurrentDuration(changeTime:TimeInterval) {
        if (player?.isPlaying)! {
            player?.stop()
            player?.currentTime = changeTime
            player?.prepareToPlay()
            player?.play()
            
        }else {
            player?.currentTime = changeTime
        }
        print("현재시간\(player?.currentTime)")
    }
    
    func getCurrentDuration() -> TimeInterval {
        return (player?.currentTime)!
    }
    
    func getDurationFloat() -> Float {
        return Float((player?.duration)!)
    }

    func getDuration() -> String {
        var secounds = 0
        var minutes = 0
        if let time = player?.duration {
            secounds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d", minutes, secounds)
    }

    func getCurrentTimeAsString() -> String {
        var secounds = 0
        var minutes = 0
        if let time = player?.currentTime {
            secounds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }

        return String(format: "%0.2d:%0.2d", minutes, secounds)
    }
    
    func changeAudioTime(sliderValue : TimeInterval) {
        
        if (player?.isPlaying)! {
            player?.stop()
            player?.currentTime = sliderValue
            player?.prepareToPlay()
            player?.play()
        }else {
            player?.currentTime = sliderValue
        }
        
    }
    
    func onePlayMode(state : Bool) {
        
        if state {
            oneRepeatMode = true
            player?.numberOfLoops = -1
        } else {
            oneRepeatMode = false
            player?.numberOfLoops = 0
        }
    }
    
    func getProgress() -> Float {
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        if let currentTime = player?.currentTime, let duration = player?.duration {
            theCurrentTime = currentTime
            theCurrentDuration = duration
        }
        return Float(theCurrentTime / theCurrentDuration)
    }
    
    func setVolume(volume: Float) {
        player?.volume = volume
    }

    func setRate(rate: Float) {
        player?.rate = rate

    }

    func getRate() -> Float {
        return (player?.rate)!
    }
    
    func setShuffleMode(mode: Bool) {
        shuffleMode = mode
    }

    func setCurrentTrackIndex(currentTrackIndex: Int) {
        self.currentTrackIndex = currentTrackIndex
    }
    func shuffleIndex() -> Int {
        let listCnt = tracks[0].songs.count
        let index: UInt32 = arc4random_uniform(UInt32(listCnt))

        return Int(index)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            if tracks[0].songs.count <= currentTrackIndex+1 {
                if repaetMode == true {
                    nextSong(songFinishedPlaying: true)
                }else {
                    
                }
            }else {
                nextSong(songFinishedPlaying: true)
            }
            
        } else {
            
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error.debugDescription)
    }

    internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        self.notifyOnPlaybackStateChanged()
    }

    //CommandCenter

    func configureCommandCenter() {
        self.commandCenter.playCommand.addTarget(handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let sself = self else {
                return .commandFailed
            }
            sself.play()
            return .success
        })

        self.commandCenter.pauseCommand.addTarget(handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let sself = self else {
                return .commandFailed
            }
            sself.pause()
            return .success
        })

        self.commandCenter.nextTrackCommand.addTarget(handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let sself = self else {
                return .commandFailed
            }
            sself.nextSong(songFinishedPlaying: (self?.player?.isPlaying)!)
            return .success
        })

        self.commandCenter.previousTrackCommand.addTarget(handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let sself = self else {
                return .commandFailed
            }
            sself.previousSong()
            return .success
        })

        self.commandCenter.changeShuffleModeCommand.addTarget(handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let sself = self else {
                return .commandFailed
            }
            sself.setShuffleMode(mode: true)
            return .success
        })

    }


    //Now Playing Info

    func updateNowPlayingInfoForCurrentPlaybackItem() {
        guard self.player != nil else {
            self.configureNowPlayingInfo(nil)
            return
        }

        var nowPlayingInfo = [MPMediaItemPropertyTitle: tracks[0].songs[currentTrackIndex].songTitle,
                              MPMediaItemPropertyAlbumTitle: tracks[0].songs[currentTrackIndex].albumTitle ?? "",
                              MPMediaItemPropertyArtist: tracks[0].songs[currentTrackIndex].artistName ?? "",
                              MPMediaItemPropertyPlaybackDuration: player?.duration ?? "",
                              MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0 as Float)] as [String: Any]

        if let imageSound: MPMediaItemArtwork = tracks[0].songs[currentTrackIndex].artName {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = imageSound
        }else {
                    }

        self.configureNowPlayingInfo(nowPlayingInfo as [String: AnyObject]?)
        self.updateNowPlayingInfoElapsedTime()
    }

    func updateNowPlayingInfoElapsedTime() {

        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: player?.currentTime as! Double);

        self.configureNowPlayingInfo(nowPlayingInfo)
    }

    func configureNowPlayingInfo(_ nowPlayingInfo: [String: AnyObject]?) {
        self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        self.nowPlayingInfo = nowPlayingInfo
    }

    func notifyOnPlaybackStateChanged() {
        //TODO
//        delegate?.Mp3PlayerDelegate(TEST: "TEST!!!!")

        self.notificationCenter.post(name: Notification.Name(rawValue: AudioPlayerOnPlaybackStateChangedNotification), object: self)
    }

    func notifyOnTrackChanged() {
        self.notificationCenter.post(name: Notification.Name(rawValue: AudioPlayerOnTrackChangedNotification), object: self)
    }

    
    func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, ExportError.unableToCreateExporter)
            return
        }
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")
        
        exporter.outputURL = fileURL
        exporter.outputFileType = "com.apple.m4a-audio"
        
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
    }
    
    enum ExportError: Error {
        case unableToCreateExporter
    }
}

