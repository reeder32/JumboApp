//
//  DownloadManager.swift
//  JumboApp
//
//  Created by Nicholas Reeder on 1/27/20.
//  Copyright © 2020 Nicholas Reeder. All rights reserved.
//

/*
    Okay. So Here is what I was thinking...The app upon start would download the javascript file from a url, and then save it to the file system.
    When it successfully saves, the next call would be to download the html file with a url, and then save that file, and insert the <script>some_script<\script> into the
    html, save to the file system, and then open the html file with a webview using JavascriptEvaluator
 
 */
import UIKit
import WebKit

class DownloadManager: NSObject {

    static let instance = DownloadManager()
    
    func downloadJavascriptFileWithUrl(urlString: String, completion: @escaping(_ error: Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        let downloadTask = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let localURL = localURL, error == nil {
               
                    if let code = (response as? HTTPURLResponse)?.statusCode {
                        print("Successfully downloaded file: \(code)")
                    }
                    do {
                        let localFileLocation = self.getDocumentsDirectory().appendingPathComponent("script.js")
                        try FileManager.default.copyItem(at: localURL, to: localFileLocation)
                        completion(nil)
                    }
                    catch {
                        if let err = error as? JumboError {
                            completion(err)
                        print("Error creating a file in local directory")
                        }
                    }
                
            } else {
                print(error?.localizedDescription ?? "error getting localURL")
            }
        }
        downloadTask.resume()
    }
    
    func downloadHtmlFile(urlString: String, completion: @escaping(_ error: Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL {
               
                var script =  Bundle.main.path(forResource: "script", ofType: "js", inDirectory: nil, forLocalization: nil)
                if var string = try? String(contentsOf: localURL, encoding: .utf8).components(separatedBy: "\n") {
                    guard let index = string.firstIndex(where: {$0.contains("<head>")}) else {
                        completion(error)
                        return
                        
                    }
                    string[index].append(script ?? "")
                    let html = string.joined()
                    //script.append(contentsOf: string)
                    do {
                        let localFileLocation = self.getDocumentsDirectory().appendingPathComponent("index.html")
                        try html.write(to: localFileLocation, atomically: true, encoding: .utf8)
                        completion(nil)
                    }
                    catch {
                        if let err = error as? JumboError {
                            completion(err)
                        }
                        print("Error creating a file in local directory")
                    }
                } else {
                    
                }
            }
        }

        task.resume()
    }
    
   func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
    }
}
