//
//  ArtistTableViewCell.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 6. 23..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit

class ArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var albumTrackCountLabel: UILabel!
//    @IBOutlet weak var artistLabel: UILabel!
//    @IBOutlet weak var artistImage: UIImageView!
//    @IBOutlet weak var albumTrackCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
