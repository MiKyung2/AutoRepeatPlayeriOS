////
////  test.swift
////  AutoRepeatPlayer
////
////  Created by jmk on 2017. 7. 14..
////  Copyright © 2017년 jmk. All rights reserved.
////
//
//import UIKit
////import EZAudio
//import MediaPlayer
//
//class test: UIViewController,EZAudioFileDelegate{
//    var category = "Songs"
//    var albums: [AlbumInfo] = []
//    var songQuery: SongQuery = SongQuery()
//    
//    var audioFile:EZAudioFile!
//    var audioPlot:EZAudioPlot!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        MPMediaLibrary.requestAuthorization { (status) in
//            if status == .authorized {
//                self.albums = self.songQuery.get(songCategory: self.category)
//                DispatchQueue.main.async {
//                    
//                }
//            } else {
////                self.displayMediaLibraryError()
//            }
//            
//        }
//        
//        // Do any additional setup after loading the view, typically from a nib.
//        
//        //波形
//        self.audioPlot = EZAudioPlot(frame: self.view.frame)
//        self.audioPlot.backgroundColor = UIColor.orange
//        self.audioPlot.color = UIColor.white
//        self.audioPlot.plotType = EZPlotType.buffer
//        self.audioPlot.shouldFill = true
//        self.audioPlot.shouldMirror = true
//        self.audioPlot.shouldOptimizeForRealtimePlot = false
//        self.openFileWithFilePathURL(filePathURL: NSURL(fileURLWithPath: Bundle.main.path(forResource: "a320", ofType: "mp3")!))
//        self.view.addSubview(self.audioPlot)
//        
//        print(self.albums[0].songs[0].songURL)
//        
//        print(self.audioFile.getWaveformData())
////        self.audioFile.getWaveformData(withNumberOfPoints numberOfPoints: UInt32)
//    }
//    
//    func openFileWithFilePathURL(filePathURL:NSURL){
//        print(filePathURL)
//
//        self.audioFile = EZAudioFile(url: filePathURL as URL!)
//        self.audioFile.delegate = self
//        
//        var buffer = self.audioFile.getWaveformData().buffer(forChannel: 0)
//        var bufferSize = self.audioFile.getWaveformData().bufferSize
//        self.audioPlot.updateBuffer(buffer, withBufferSize: bufferSize)
//        print(buffer)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//}
