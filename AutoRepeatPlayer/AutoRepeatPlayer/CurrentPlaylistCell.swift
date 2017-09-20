//
//  CurrentPlaylistCell.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 27..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit
class CurrentPlaylistCell: UITableViewCell {

    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var moveImage: NSLayoutConstraint!
    
//    let player: MP3Player
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//    }
//    
//    func updateAccessoryView() {
//        
//        if true {
//            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//            self.accessoryView = containerView
//            
//            let imageView = UIImageView(frame: CGRect(x: self.contentView.bounds.maxX + 5, y: self.contentView.bounds.midY - 10, width: 20, height: 20))
//            
//            imageView.contentMode = .scaleAspectFit
//            self.addSubview(imageView)
//            
//            if self.player.isPlaying {
//                var images = [UIImage]()
//                for i in 1...9 {
//                    images.append(UIImage(named: "bars\(i)")!)
//                }
//                
//                imageView.animationImages = images
//                imageView.animationDuration = 1
//                imageView.startAnimating()
//            }
//            else {
//                imageView.image = UIImage(named: "bars1")
//            }
//            
////            self.barsImageView = imageView
//        }
//        else {
//            self.accessoryView = nil
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        print("setselected")
    }
}
