//
//  JavaScriptEvaluator.swift
//  JumboApp
//
//  Created by Nicholas Reeder on 1/22/20.
//  Copyright © 2020 Nicholas Reeder. All rights reserved.
//

/*
 I chose to use delegates here, because it allows for the tableview to be updated as new responses are received. For further development, the app simply needs to be a delegate to theis class, and we can run necessary methods based on delegate calls.*/

protocol EvaluatorDelegate: AnyObject {
    func error(_ error: JumboError)
    func updateObjectWithID(_ message: Message)
    func didStartOperation()
}

import UIKit
import JavaScriptCore
import WebKit

class JavaScriptEvaluator: NSObject {
    weak var delegate: EvaluatorDelegate?
    static let instance = JavaScriptEvaluator()
    private let context = JSContext()
   
    var webview: WKWebView?
    var idString: String?
    var isRunning = false
    var runningOperations = [String]()
    private let messageHandler = "jumbo"
    
    override init() {
        super.init()
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: messageHandler)
        webview = WKWebView(frame: .zero, configuration: config)
        webview?.navigationDelegate = self
    }
    
    func startOperationWithIdString(_ id: String) {
        // Simply send the idString, and the webview will do the rest
        self.idString = id
       
        var path: URL?
        #if DEBUG
        path = Bundle.main.url(forResource: "sample", withExtension: "html")
        let myURLRequest:URLRequest = URLRequest(url: path!)
        webview?.load(myURLRequest)
        #endif
        
        
    }
    

    func getObject(_ object: [String: Any]) {
        var progress = 0.0
        var state = ""
        
        guard let message = object["message"] as? String else {
            self.delegate?.error(JumboError.dataIncorrectFormat)
            return
        }
        guard let idString = object["id"] as? String else {
            self.delegate?.error(JumboError.dataIncorrectFormat)
            return
        }
        if let progressNumber = object["progress"] as? Double {
            progress = progressNumber
        }
        if let progressState = object["state"] as? String {
            state = progressState
        }
      
        let msg = Message(
            id:  idString,
            message: message,
            progress: progress,
            state: state)
        
        DispatchQueue.main.async {
            self.delegate?.updateObjectWithID(msg)
        }
        
    }
    
    
}

extension JavaScriptEvaluator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.error(JumboError.connectionError)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        guard let idString = self.idString else { return }
        webView.evaluateJavaScript("startOperation('\(idString)');", completionHandler: { (data, error) in
                  if let err = error {
                           print(err)
                    self.delegate?.error(JumboError.invalidResponse)
                     } else {
                    self.delegate?.didStartOperation()
                   }
         })
    }
}


extension JavaScriptEvaluator: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // This is listening for the message handler which is passing the json object
        if message.name == messageHandler {
           
                if let jsonString = message.body as? String {
                    if let jsonData = jsonString.data(using: .utf8) {
                        do {
                            if let object = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]
                            {
                                self.getObject(object)
                            } else {
                                self.delegate?.error(JumboError.dataIncorrectFormat)
                            }
                        } catch  {
                            self.delegate?.error(JumboError.dataIncorrectFormat)
                            print(error.localizedDescription)
                        }
                    }
                    
                } else {
                    self.delegate?.error(JumboError.dataIncorrectFormat)
                }
            }
        }
}
extension JavaScriptEvaluator: EvaluatorDelegate {
    func updateObjectWithID(_ message: Message) {}
    func error(_ error: JumboError) {}
    func didStartOperation() {}
}
