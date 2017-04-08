//
//  ImageDetailCell.swift
//  ConcurrentDownloadSwift3
//
//  Created by Vamshi Krishna on 08/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit

protocol ImageDetailCellDelegate{
    
    func pauseClicked(_ cell:ImageDetailCell)
    func resumeClicked(_ cell:ImageDetailCell)
    func cancelClicked(_ cell:ImageDetailCell)
    func downloadClicked(_ cell:ImageDetailCell)
    
}
class ImageDetailCell: UITableViewCell {

    var delegate:ImageDetailCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
  
    @IBAction func resumeClicked(_ sender: Any) {
        if(pauseButton.titleLabel?.text == "Pause"){
            delegate?.pauseClicked(self)
        }
        else{
            delegate?.resumeClicked(self)
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        delegate?.cancelClicked(self)
    }
    
    @IBAction func downloadClicked(_ sender: Any) {
        delegate?.downloadClicked(self)
    }
}
