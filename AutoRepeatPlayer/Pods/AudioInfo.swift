//
//  AudioInfo.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 7. 12..
//  Copyright © 2017년 jmk. All rights reserved.
//

import Foundation
//import EZAudio
//import MediaPlayer
//
//class AudioInfo: NSObject,EZAudioFileDelegate {
//    var category = "Songs"
//    var albums: [AlbumInfo] = []
//    
//    var songQuery: SongQuery = SongQuery()
//    
//    
//    required init?(coder aDecoder: NSCoder) {
//        self.audioFile = EZAudioFile(url: nil as URL!)
//    }
//    
//    var audioFile :EZAudioFile
////    self.audioFile = [EZAudioFile audioFileWithURL : [ NSURL  fileURLWithPath : self.albums[0].songs[0] ] delegate : self ];
//    
//    
//    func viewDidLoad() {
//        MPMediaLibrary.requestAuthorization { (status) in
//            if status == .authorized {
//                self.albums = self.songQuery.get(songCategory: self.category)
//                DispatchQueue.main.async {
//                    //                    self.tableView?.rowHeight = UITableViewAutomaticDimension;
//                    //                    self.tableView?.estimatedRowHeight = 60.0;
//                    //                    self.tableView?.reloadData()
//                }
//            } else {
//                //                self.displayMediaLibraryError()
//            }
//        }
//    }
//    
//    func openFileWithFilePathURL(filePathURL:NSURL){
//        self.audioFile = EZAudioFile(url: filePathURL as URL!)
//        self.audioFile.delegate = self
//        
//        var buffer = self.audioFile.getWaveformData().buffer(forChannel: 0)
//        var bufferSize = self.audioFile.getWaveformData().bufferSize
////        self.audioPlot.updateBuffer(buffer, withBufferSize: bufferSize)
//        
//    }
//}
