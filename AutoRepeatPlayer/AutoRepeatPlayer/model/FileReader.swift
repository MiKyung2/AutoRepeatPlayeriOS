//
//  FileReader.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 5. 31..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit

class FileReader: NSObject {
    //파일 목록 가져오기
    class func readFiles() -> [String] {
        return Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        
    }
}

