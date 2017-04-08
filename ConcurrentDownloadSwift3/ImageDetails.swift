//
//  ImageDetails.swift
//  ConcurrentDownloadSwift3
//
//  Created by Vamshi Krishna on 08/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import Foundation

class ImageDetails{
    var name:String?
    var type: String?
    var downloadURL: String?
    
    init(name:String?, type:String?, downloadURL:String?){
        self.name = name
        self.type = type
        self.downloadURL = downloadURL
    }
}

