//
//  CategoryTableViewController.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 6..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit

class CategoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var mp3Player:MP3Player
    let notificationCenter: NotificationCenter
    let bundle: Bundle

    typealias PlaylistViewControllerDependencies = (player: MP3Player, bundle: Bundle, notificationCenter: NotificationCenter)
    
    @IBOutlet var categoryTable: UITableView!
    
    let category : [String] = ["playlist","album","artist","second"]
    let category2 : [String] = ["재생목록","앨범","아티스트","장르"]
    
    required init?(coder aDecoder: NSCoder) {
        self.mp3Player = MP3Player.sharedInstance
        self.notificationCenter = NotificationCenter.default
        self.bundle = Bundle.main

        super.init(coder: aDecoder)
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "category"
        
        //navigation right button -> edit
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return category.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell",for: indexPath) as! CategoryCell
        
        
        cell.titleLabel?.text = category2[indexPath.row] as! String
        cell.imageView?.image = UIImage(named : category[indexPath.row] as! String)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.row{
            
        case 0:
            self.performSegue(withIdentifier: "playlistSegue", sender: self)
            break
            
        case 1:
            self.performSegue(withIdentifier: "albumSegue", sender: self)
            break
            
        case 2:
            self.performSegue(withIdentifier: "artistSegue", sender: self)
            break
            
        case 3:
            self.performSegue(withIdentifier: "genreSegue", sender :self)
            break
        
        case 4:
            self.performSegue(withIdentifier: "songSegue", sender :self)
            break
            
        default:
            break
        }
//        switch indexPath.row
//        {
//            print("0")
//            self.performSegue(withIdentifier: "playlistSegue", sender: self)
//        }
//        else if indexPath.row == 1
//        {
//            print("1")
//            self.performSegue(withIdentifier: "artistSegue", sender: self)
//        }
//        else if indexPath.row == 2
//        {
//            print("2")
//            self.performSegue(withIdentifier: "albumSegue", sender: self)
//        }
//        else if indexPath.row == 3
//        {
//            self.performSegue(withIdentifier: "genreSegue", sender :self)
//        }
//        else if indexPath.row == 4
//        {
//            self.performSegue(withIdentifier: "songSegue", sender :self)
//        }
        
    }
//

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "playlistSegue" {
//            if let destination = segue.destination as? PlaylistViewController {
//                destination.category = "Playlist"
//            }
//        }else if segue.identifier == "albumSegue" {
//            if let destination = segue.destination as? AlbumCollectionViewController {
//                destination.category = "Album"
//            }
//        }else if segue.identifier == "artistSegue" {
//            if let destination = segue.destination as? ArtistViewController {
//                destination.category = "Artist"
//            }
//        }else if segue.identifier == "genreSegue" {
//            if let destination = segue.destination as? GenreViewController {
//                destination.category = "Genre"
//            }
//        }else {
//            if let destination = segue.destination as? TableViewController {
//                destination.category = "Songs"
//            }
//        }
        
//        let cell = sender as! CategoryCell
//        let index = categoryTable.indexPath(for: cell)
//        if let indexPath = index?.row {
//            let destination = segue.destination as! TableViewController
//            switch indexPath{
//                
//            case 0:
//                self.performSegue(withIdentifier: "playlistSegue", sender: self)
//                destination.category = "Playlist"
//                break
//                
//            case 1:
//                self.performSegue(withIdentifier: "albumSegue", sender: self)
//                destination.category = "Album"
//                break
//                
//            case 2:
//                self.performSegue(withIdentifier: "artistSegue", sender: self)
//                destination.category = "Artist"
//                break
//                
//            case 3:
//                self.performSegue(withIdentifier: "genreSegue", sender :self)
//                destination.category = "Genre"
//                break
//                
//            case 4:
//                self.performSegue(withIdentifier: "songSegue", sender :self)
//                destination.category = "Songs"
//                break
//                
//            default:
//                break
//            }
//        }
    }

}


