//
//  TableViewController.swift
//  AutoRepeatPlayer
//7
//  Created by jmk on 2017. 5. 31..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Mp3PlayerDelegate {
    var player:MP3Player?
    let notificationCenter: NotificationCenter
    let bundle: Bundle
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentplaybar: UIView!

    let myTableView: UITableView = UITableView( frame: CGRect.zero, style: .grouped )
    var category = "Songs"
    var albums: [AlbumInfo] = []
    
    var songQuery: SongQuery = SongQuery()
    
    typealias PlaylistViewControllerDependencies = (player: MP3Player, bundle: Bundle, notificationCenter: NotificationCenter)
    
    required init?(coder aDecoder: NSCoder) {
        let audioSession = AVAudioSession.sharedInstance()
        self.notificationCenter = NotificationCenter.default
        self.bundle = Bundle.main
        
        self.player = MP3Player.sharedInstance

        super.init(coder: aDecoder)
        self.player?.delegate = self
        
        self.configureNotifications()
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.title = category
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.albums = self.songQuery.get(songCategory: self.category)
                DispatchQueue.main.async {
                    self.tableView?.rowHeight = UITableViewAutomaticDimension;
                    self.tableView?.estimatedRowHeight = 60.0;
                    self.tableView?.reloadData()
                }
            } else {
                self.displayMediaLibraryError()
            }
        }
        
        let swipeUP = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUP.direction = UISwipeGestureRecognizerDirection.up
        self.currentplaybar.addGestureRecognizer(swipeUP)
    }
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "PlayerViewController")
                self.present(controller, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return albums.count
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int  {
        
        return albums[section].songs.count
    }
    
    func tableView( _ tableView: UITableView, cellForRowAt indexPath:IndexPath ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CustomCell",
            for: indexPath) as! CustomCell
        
        cell.titleLabel?.text = albums[indexPath.section].songs[indexPath.row].songTitle

        if let artist: String = albums[indexPath.section].songs[indexPath.row].artistName {
            cell.singerLabel?.text = artist
        }else {
            cell.singerLabel?.text = ""
        }
        
        if let imageSound: MPMediaItemArtwork = albums[indexPath.section].songs[indexPath.row].artName {
            cell.audioImage?.image = imageSound.image(at: CGSize(width: cell.audioImage.frame.size.width, height: cell.audioImage.frame.size.height))
        }else {
            cell.audioImage?.image = UIImage(named: "album")
        }
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PlayerViewController {
            if segue.identifier == "SongSegue" {
                let cell = sender as! CustomCell
                let index = tableView.indexPath(for: cell)
                if let indexPath = index?.row {
                    if player?.currentTrackIndex == indexPath {
                        
                    }else {
                        controller.albums = self.albums
                        controller.currentTrackIndex = indexPath
                        player?.setTrack(tracks: self.albums,index: indexPath)
                    }
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 54.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        player?.play()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func configureNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.onTrackChanged), name: NSNotification.Name(rawValue: AudioPlayerOnTrackChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.onTrackAndPlaybackStateChange), name: NSNotification.Name(rawValue: AudioPlayerOnPlaybackStateChangedNotification), object: nil)
    }
    
    func onTrackAndPlaybackStateChange() {
        self.updateCurrentPlayerBar(animated: true)
//        self.updateControls()
        self.tableView.reloadData()
    }

    
    //MARK: - Updates
    
    //현재 플레이되는 음악 표시 bar
    func updateCurrentPlayerBar(animated: Bool) {
        let updateView = {
            if false {
                self.currentplaybar.isHidden = true
                self.currentplaybar.alpha = 0
            }
            else {
                self.currentplaybar.isHidden = false
                self.currentplaybar.alpha = 1
            }
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: updateView, completion: nil)
        }
        else {
            updateView()
        }
    }

    func Mp3PlayerDelegate(TEST: String) {
        print(TEST)
    }

    func displayMediaLibraryError() {
        
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by corporate or parental settings"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown error"
        }
        
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }))
        present(controller, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
}
