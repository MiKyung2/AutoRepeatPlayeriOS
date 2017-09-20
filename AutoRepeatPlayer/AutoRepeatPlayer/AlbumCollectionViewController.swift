//
//  AlbumCollectionViewController.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 23..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit

class AlbumCollectionViewController: UIViewController {
    var category = "Album"
    var albums: [AlbumInfo] = []
    var songQuery: SongQuery = SongQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
