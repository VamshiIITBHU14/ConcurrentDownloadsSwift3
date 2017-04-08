//
//  ImageDetailViewController.swift
//  ConcurrentDownloadSwift3
//
//  Created by Vamshi Krishna on 08/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imagePath:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image =  UIImage(contentsOfFile: imagePath)
    }

}
