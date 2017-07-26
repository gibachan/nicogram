//
//  NicoNicoDownloader.swift
//  nico
//
//  Created by gibachan on 2017/07/23.
//

import Foundation

public func download(email: String, password: String, videoId: String, completionHandler: @escaping (URL?) -> Void) {
    let account = NicoNicoAccount(email: email, password: password)
    let downloader = NicoNicoDownloader(account: account)
    downloader.download(videoId: videoId) { (url) in
        completionHandler(url)
    }
}

public class NicoNicoDownloader: NSObject, URLSessionDownloadDelegate {
    var session: NicoNicoSession! = nil
    
    private var videoId: String = ""
    private var downloadedFile: URL?
    private var downloadCompletionHandeler: ((URL?) -> Void) = { url in }
    
    public init(account: NicoNicoAccount) {
        super.init()
        session = NicoNicoSession(account: account, delegate: self)
    }
    
    public func download(videoId: String, completionHandler: @escaping (URL?) -> Void) {
        self.videoId = videoId
        downloadedFile = nil
        downloadCompletionHandeler = completionHandler
        
        // login and donwload
        session.login { loggedIn in
            guard loggedIn == true else {
                print("Failed to log in")
                completionHandler(nil)
                return
            }
            
            self.requestURLOfVideo { videoUrl in
                guard videoUrl != nil else {
                    print("Failed to get url")
                    completionHandler(nil)
                    return
                }
                
                self.watchVideo { watched in
                    guard watched == true else {
                        print("Failed to watch")
                        completionHandler(nil)
                        return
                    }
                    
                    self.download(url: videoUrl!)
                }
            }
        }
    }
    
    private func requestURLOfVideo(completionHandler: @escaping (URL?) -> Void) {
        let urlString = "http://www.nicovideo.jp/api/getflv/\(videoId)"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    completionHandler(nil)
                    return
            }
            
            guard let responseString = String(data: data, encoding: .utf8) else {
                completionHandler(nil)
                return
            }
            
            let regex = try! NSRegularExpression(pattern: "&url=(.*?)&", options: [.caseInsensitive])
            let nsresponseString = NSString(string: responseString)
            let range = NSRange(location: 0, length: nsresponseString.length)
            let match = regex.firstMatch(in: responseString, options: [], range: range)
            if let match = match, match.numberOfRanges == 2 {
                let resultRange = match.rangeAt(1)
                let encodedURL = nsresponseString.substring(with: resultRange)
                if let decodedURL = encodedURL.removingPercentEncoding {
                    if let videoURL = URL(string: decodedURL) {
                        completionHandler(videoURL)
                        return
                    }
                }
            }
            completionHandler(nil)
        }
        task.resume()
    }
    
    private func watchVideo(completionHandler: @escaping ((Bool) -> Void)) {
        let urlString = "http://www.nicovideo.jp/watch/\((videoId))"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let task = session.session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    completionHandler(false)
                    return
            }
            
            completionHandler(true)
        }
        task.resume()
        
    }
    
    private func download(url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.session.downloadTask(with: request)
        task.resume()
    }
    
    // --------------------------------------------------
    // MARK: URLSessionDownloadDelegate
    // --------------------------------------------------
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
                return
        }
        
        guard let contentType = httpResponse.allHeaderFields["Content-Type"] as? String else {
            return
        }
        
        let fileName = videoId + "." + contentType.replacingOccurrences(of: "video/", with: "")
        
        let fileMgr = FileManager.default
        let toURL = URL(fileURLWithPath: fileMgr.currentDirectoryPath + "/" + fileName)
        
        do {
            try fileMgr.moveItem(atPath: location.path, toPath: toURL.path)
            downloadedFile = toURL
        } catch let error {
            print(error.localizedDescription)
            try? fileMgr.removeItem(at: location)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.invalidateAndCancel()
        
        if let error = error {
            print(error.localizedDescription)
            downloadCompletionHandeler(nil)
        } else {
            downloadCompletionHandeler(downloadedFile)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("\u{1B}[1A\u{1B}[KDownloading: \(String(format: "%.2f", progress * 100))%")
    }
}



