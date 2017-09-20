//
//  ArtistViewController.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 23..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var category = "Artist"
    var albums: [AlbumInfo] = []
    var songQuery: SongQuery = SongQuery()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Do any additional setup after loading the view.
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
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int  {
        
        return albums.count
    }
    
    func tableView( _ tableView: UITableView, cellForRowAt indexPath:IndexPath ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ArtistTableViewCell",
            for: indexPath) as! ArtistTableViewCell
        
        cell.artistLabel?.text = albums[indexPath.row].albumArtist
        cell.artistImage?.image = UIImage(named:"album")
        cell.albumTrackCountLabel?.text = "앨범 \(albums[indexPath.row].albumTrackCount)장"
        
//        if albums[indexPath.section].songs[indexPath.row].artistName == nil{
//            cell.singerLabel?.text = ""
//        }else {
//            cell.singerLabel?.text = albums[indexPath.section].songs[indexPath.row].artistName
//        }
//        
//        let songId: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
//        let item: MPMediaItem = songQuery.getItem( songId: songId )
//        
//        if  let imageSound: MPMediaItemArtwork = item.value( forProperty: MPMediaItemPropertyArtwork ) as? MPMediaItemArtwork {
//            cell.audioImage?.image = imageSound.image(at: CGSize(width: cell.audioImage.frame.size.width, height: cell.audioImage.frame.size.height))
//        }else {
//            cell.audioImage?.image = UIImage(named: "album")
//        }
        return cell;
    }}
