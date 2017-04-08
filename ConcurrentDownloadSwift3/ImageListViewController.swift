//
//  ImageListViewController.swift
//  ConcurrentDownloadSwift3
//
//  Created by Vamshi Krishna on 08/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit
import Foundation

class ImageListViewController: UITableViewController , ImageDetailCellDelegate, URLSessionDelegate, URLSessionDownloadDelegate{
    
    var activeDownloads = [String: DownloadManager]()
    let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    var imageDetailsArray = [ImageDetails]()
    
    
    lazy var downloadsSession: Foundation.URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self .formImageDetailModel()
        _ = self.downloadsSession
    }
   
    //Useful if your results are fetched via API
    func formImageDetailModel(){
        let imageDetailDictionaries = [["name": "image1", "type": "type1", "downloadURL":"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg"], ["name": "image2", "type": "type2", "downloadURL":"http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg"],["name": "image3", "type": "type3", "downloadURL":"http://spaceflight.nasa.gov/gallery/images/apollo-soyuz/apollo-soyuz/hires/s75-33375.jpg"], ["name": "image4", "type": "type4", "downloadURL":"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-134-20380.jpg"], ["name": "image5", "type": "type5", "downloadURL":"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-140-21497.jpg"], ["name": "image6", "type": "type6", "downloadURL":"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-148-22727.jpg"]]
        // Get the results array
        if let array: AnyObject = imageDetailDictionaries as AnyObject? {
            for imageDictionary in array as! [AnyObject] {
                if let imageDictionary = imageDictionary as? [String: AnyObject], let downloadURL = imageDictionary["downloadURL"] as? String {
                    let name = imageDictionary["name"] as? String
                    let type = imageDictionary["type"] as? String
                    imageDetailsArray.append(ImageDetails(name: name, type: type, downloadURL: downloadURL))
                    
                } else {
                    print("Not a dictionary")
                }
            }
        } else {
            
        }
      
        DispatchQueue.main.async {
            self.tableView.reloadData()
            //self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDetailsArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageDetailCell", for: indexPath) as!ImageDetailCell
        
        cell.delegate = self
        let image = imageDetailsArray[indexPath.row]

        cell.nameLabel.text = image.name
        cell.typeLabel.text = image.type
        
        var showDownloadControls = false
        if let download = activeDownloads[image.downloadURL!] {
            showDownloadControls = true
            
            cell.progressView.progress = download.progress
            cell.progressLabel.text = (download.isDownloading) ? "Downloading..." : "Paused"
            
            let title = (download.isDownloading) ? "Pause" : "Resume"
            cell.pauseButton.setTitle(title, for: UIControlState())
        }
        cell.progressView.isHidden = !showDownloadControls
        cell.progressLabel.isHidden = !showDownloadControls
        
        // If the track is already downloaded, enable cell selection and hide the Download button
        let downloaded = localFileExistsForImage(image)
        cell.selectionStyle = downloaded ? UITableViewCellSelectionStyle.gray : UITableViewCellSelectionStyle.none
        cell.downloadButton.isHidden = downloaded || showDownloadControls
        
        cell.pauseButton.isHidden = !showDownloadControls
        cell.cancelButton.isHidden = !showDownloadControls
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let image = imageDetailsArray[indexPath.row]
        if localFileExistsForImage(image) {
            showImage(image)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let image = imageDetailsArray[indexPath.row]
        if localFileExistsForImage(image) {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
             let image = imageDetailsArray[indexPath.row]
            deleteDownloadedImage(image)
        }
    }
    
    // This method attempts to play the local file (if it exists) when the cell is tapped
    func showImage(_ image: ImageDetails) {
        if let urlString = image.downloadURL, let url = localFilePathForUrl(urlString) {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "ImageDetailVC") as! ImageDetailViewController
            controller.imagePath = url.path
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    //Mark Delete File method
    
    //Called when swipe to delete is called
    func deleteDownloadedImage(_ image:ImageDetails){
        if let urlString = image.downloadURL, let url = localFilePathForUrl(urlString) {
            print(url)
            print(url.absoluteString)
            do {
                try FileManager.default.removeItem(atPath: url.path)
                tableView.reloadData()
            }
            catch{
                
            }
        }
    }
    
    //Delegate methods from ImageDetailCellDelegate
    
    func pauseClicked(_ cell: ImageDetailCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = imageDetailsArray[indexPath.row]
            pauseDownload(image)
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
        }
    }
    
    func resumeClicked(_ cell: ImageDetailCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = imageDetailsArray[indexPath.row]
            resumeDownload(image)
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
        }
    }
    
    func cancelClicked(_ cell: ImageDetailCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = imageDetailsArray[indexPath.row]
            cancelDownload(image)
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
        }
    }
    
    func downloadClicked(_ cell: ImageDetailCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = imageDetailsArray[indexPath.row]
            startDownload(image)
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
        }
    }
    
    // MARK: Download methods
    
    // Called when the Download button for a track is tapped
    func startDownload(_ image: ImageDetails) {
        if let urlString = image.downloadURL, let url =  URL(string: urlString) {
            let download = DownloadManager(url: urlString)
            download.downloadTask = downloadsSession.downloadTask(with: url)
            download.downloadTask!.resume()
            download.isDownloading = true
            activeDownloads[download.url] = download
        }
    }
    
    // Called when the Pause button for a track is tapped
    func pauseDownload(_ image: ImageDetails) {
        if let urlString = image.downloadURL,
            let download = activeDownloads[urlString] {
            if(download.isDownloading) {
                download.downloadTask?.cancel { data in
                    if data != nil {
                        download.resumeData = data
                    }
                }
                download.isDownloading = false
            }
        }
    }
    
    // Called when the Cancel button for a track is tapped
    func cancelDownload(_ image: ImageDetails) {
        if let urlString = image.downloadURL,
            let download = activeDownloads[urlString] {
            download.downloadTask?.cancel()
            activeDownloads[urlString] = nil
        }
    }
    
    // Called when the Resume button for a track is tapped
    func resumeDownload(_ image: ImageDetails) {
        if let urlString = image.downloadURL,
            let download = activeDownloads[urlString] {
            if let resumeData = download.resumeData {
                download.downloadTask = downloadsSession.downloadTask(withResumeData: resumeData)
                download.downloadTask!.resume()
                download.isDownloading = true
            } else if let url = URL(string: download.url) {
                download.downloadTask = downloadsSession.downloadTask(with: url)
                download.downloadTask!.resume()
                download.isDownloading = true
            }
        }
    }
    
    // MARK: Download helper methods
    
    // This method generates a permanent local file path to save a track to by appending
    // the lastPathComponent of the URL (i.e. the file name and extension of the file)
    // to the path of the app’s Documents directory.
    func localFilePathForUrl(_ previewUrl: String) -> URL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let fullPath = documentsPath.appendingPathComponent((URL(string: previewUrl)?.lastPathComponent)!)
        return URL(fileURLWithPath:fullPath)
    }
    
    // This method checks if the local file exists at the path generated by localFilePathForUrl(_:)
    func localFileExistsForImage(_ image: ImageDetails) -> Bool {
        if let urlString = image.downloadURL, let localUrl = localFilePathForUrl(urlString) {
            var isDir : ObjCBool = false
            return FileManager.default.fileExists(atPath: localUrl.path , isDirectory: &isDir)
            
        }
        return false
    }
    
    func trackIndexForDownloadTask(_ downloadTask: URLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            for (index, image) in imageDetailsArray.enumerated() {
                if url == image.downloadURL! {
                    return index
                }
            }
        }
        return nil
    }
    
    // MARK: - NSURLSessionDelegate
    
    internal func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async(execute: {
                    completionHandler()
                })
            }
        }
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1
        if let originalURL = downloadTask.originalRequest?.url?.absoluteString,
            let destinationURL = localFilePathForUrl(originalURL) {
            
            print(destinationURL)
            
            // 2
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: destinationURL)
            } catch {
                // Non-fatal: file probably doesn't exist
            }
            do {
                try fileManager.copyItem(at: location, to: destinationURL)
            } catch let error as NSError {
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
        }
        
        // 3
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            activeDownloads[url] = nil
            // 4
            if let trackIndex = trackIndexForDownloadTask(downloadTask) {
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadRows(at: [IndexPath(row: trackIndex, section: 0)], with: .none)
                })
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // 1
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString,
            let download = activeDownloads[downloadUrl] {
            // 2
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            // 3
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            // 4
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let trackCell = tableView.cellForRow(at: IndexPath(row: trackIndex, section: 0)) as? ImageDetailCell {
                DispatchQueue.main.async(execute: {
                    trackCell.progressView.progress = download.progress
                    trackCell.progressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
}


