//
//  CurrentPlayStateBarView.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 20..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit
import MediaPlayer

class CurrentPlayStateBarView: UIView {
    var player:MP3Player?
    let notificationCenter: NotificationCenter
    let bundle: Bundle
    
    @IBOutlet var currentPlayStateBar: UIView!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    
    var contentView : UIView?
    
    typealias PlaylistViewControllerDependencies = (player: MP3Player, bundle: Bundle, notificationCenter: NotificationCenter)
    
    override init(frame: CGRect) {
        self.notificationCenter = NotificationCenter.default
        self.bundle = Bundle.main

        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        
        let audioSession = AVAudioSession.sharedInstance()
        self.notificationCenter = NotificationCenter.default
        self.bundle = Bundle.main
        self.player = MP3Player.sharedInstance
        
        super.init(coder: aDecoder)
        
        self.configureNotifications()
        xibSetup()
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
        
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func barPlaySong(_ sender: AnyObject) {
        player?.play()
        playBtn.isHidden = true
        pauseBtn.isHidden = false
    }
    
    @IBAction func pauseSong(_ sender: AnyObject) {
        player?.pause()
        playBtn.isHidden = false
        pauseBtn.isHidden = true
    }
    
    @IBAction func playNextSong(_ sender: AnyObject) {
        player?.nextSong(songFinishedPlaying: false)
    }
    
    @IBAction func playPreviousSong(_ sender: AnyObject) {
        player?.previousSong()
    }
    
    func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentPlayStateBarView.onTrackChanged), name: NSNotification.Name(rawValue: AudioPlayerOnTrackChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentPlayStateBarView.onTrackAndPlaybackStateChange), name: NSNotification.Name(rawValue: AudioPlayerOnPlaybackStateChangedNotification), object: nil)
    }
    
    func onTrackAndPlaybackStateChange() {
//        self.updateCurrentPlayerBar(animated: true)
                self.updateControls()
//        self.tableView.reloadData()
    }
    
    func onTrackChanged() {
        //        if !self.isViewLoaded { return }
        
        //        if self.player.currentPlaybackItem == nil {
        //            self.close()
        //            return
        //        }
        self.titleLabel.text = self.player?.getCurrentTrackName()
        self.artistLabel.text = self.player?.getCurrentTrackArtist()
        
        if let imageSound: MPMediaItemArtwork = self.player?.getCurrentTrackArtwork() {
            self.albumImage.image = imageSound.image(at: CGSize(width: self.albumImage.frame.size.width, height: self.albumImage.frame.size.height))
        }else {
            self.albumImage.image = UIImage(named: "album")
        }
    }
    
    func onPlaybackStateChanged() {
//        if !self.isViewLoaded { return }
        
        self.updateControls()
        
    }
    
    func updateControls() {
        if (self.player?.isPlaying)! {
            playBtn.isHidden = true
            pauseBtn.isHidden = false
        }else {
            playBtn.isHidden = false
            pauseBtn.isHidden = true
        }
    }
}
