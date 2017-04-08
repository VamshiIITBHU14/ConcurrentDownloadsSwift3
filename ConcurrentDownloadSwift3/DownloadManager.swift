//
//  DownloadManager.swift
//  ConcurrentDownloadSwift3
//
//  Created by Vamshi Krishna on 08/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
    
    var url:String
    var isDownloading = false
    var progress:Float = 0.0
    
    var downloadTask:URLSessionDownloadTask?
    var resumeData:Data?
    
    init(url:String){
        self.url = url
    }

}
