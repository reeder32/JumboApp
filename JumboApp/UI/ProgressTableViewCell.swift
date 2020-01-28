//
//  ProgressTableViewCell.swift
//  JumboApp
//
//  Created by Nicholas Reeder on 1/22/20.
//  Copyright © 2020 Nicholas Reeder. All rights reserved.
//

class MessageCache: Any {
    var messages = [String]()
    static let instance = MessageCache()
   
}
import UIKit



class ProgressTableViewCell: UITableViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell(_ m: Message) {
        
            if m.message == "progress" {
                messageLabel.isHidden = true
                progressBar.isHidden = false
                activityIndicator.startAnimating()
                progressBar.setProgress(Float(m.progress / 100), animated: true)
            } else {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                messageLabel.isHidden = false
                progressBar.isHidden = true
                // This is just a helper that stores what id's have been operated on, so we don't reload a cell that has already been completed
                if MessageCache.instance.messages.isEmpty {
                    MessageCache.instance.messages.append(m.id)
                    isComplete()
                }
                //print(MessageCache.instance.messages)
                if !MessageCache.instance.messages.contains(m.id) {
                    MessageCache.instance.messages.append(m.id)
                    isComplete()
                }
                
               
            }
        
    }
    
  
    
    func isComplete() {
            self.progressBar.progress = 0
            NotificationCenter.default.post(name: .didComplete, object: nil, userInfo: ["isComplete": true])
        
    }
    
}
