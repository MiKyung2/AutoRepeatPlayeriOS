//
//  CurrentPlaylistTableViewController.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 27..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit
import MediaPlayer

protocol CurrentPlayListDelegate {
    func CurrentPlayListDelegate(currentTrackIndex:Int)
}

class CurrentPlaylistTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var player:MP3Player?
    var notificationCenter: NotificationCenter
    var bundle: Bundle
    
    var delegate : CurrentPlayListDelegate?
    
    var albums:[AlbumInfo]?
    
    
    @IBOutlet weak var tableView: UITableView!
    typealias PlaylistViewControllerDependencies = (player: MP3Player, bundle: Bundle, notificationCenter: NotificationCenter)
    
    required init?(coder aDecoder: NSCoder) {
        let audioSession = AVAudioSession.sharedInstance()
        self.notificationCenter = NotificationCenter.default
        self.bundle = Bundle.main
        self.player = MP3Player.sharedInstance
        
        super.init(coder: aDecoder)
        
        self.configureNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func configureNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(CurrentPlaylistTableViewController.onTrackChanged), name: NSNotification.Name(rawValue: AudioPlayerOnTrackChangedNotification), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.onPlaybackStateChanged), name: NSNotification.Name(rawValue: AudioPlayerOnPlaybackStateChangedNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albums![0].songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentPlaylistCell", for: indexPath) as! CurrentPlaylistCell

        cell.titleLabel?.text = albums?[indexPath.section].songs[indexPath.row].songTitle
        
        if let artist: String = albums?[indexPath.section].songs[indexPath.row].artistName {
            cell.singerLabel?.text = artist
        }else {
            cell.singerLabel?.text = ""
        }
        
        if let imageSound: MPMediaItemArtwork = albums?[indexPath.section].songs[indexPath.row].artName {
            cell.audioImage?.image = imageSound.image(at: CGSize(width: cell.audioImage.frame.size.width, height: cell.audioImage.frame.size.height))
        }else {
            cell.audioImage?.image = UIImage(named: "album")
        }
        return cell;
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {        
        //TODO
        delegate?.CurrentPlayListDelegate(currentTrackIndex: indexPath.row)
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentPlaylistCell", for: indexPath as IndexPath) as! CurrentPlaylistCell
//        cell.moveImage.isHidden = false
//        cell.moveImage.
//        NSLayoutConstraint
    }
    

}
