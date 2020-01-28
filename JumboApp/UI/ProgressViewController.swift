//
//  ViewController.swift
//  JumboApp
//
//  Created by Nicholas Reeder on 1/22/20.
//  Copyright © 2020 Nicholas Reeder. All rights reserved.
//


import UIKit
import WebKit

class ProgressViewController: UIViewController {
    
    var numberOfOperations = [SectionData]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var testButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        center.addObserver(forName: .didComplete, object: nil, queue: .main) { (notif) in
            if let userInfo = notif.userInfo {
                guard let isComplete = userInfo["isComplete"] as? Bool else {return}
                self.updateTestButton(isEnabled: isComplete)
                return
            }
            
        }
        
        JavaScriptEvaluator.instance.delegate = self
        tableView.tableFooterView = UITableViewHeaderFooterView(frame: .zero)
        #if !DEBUG
        
        // This urlString would be where you would download the html file to run script on
        DownloadManager.instance.downloadJavascriptFileWithUrl(urlString: "http://www.apple.com") { (err) in
            if err == nil {
                DownloadManager.instance.downloadHtmlFile(urlString: "http://someurl") { (error) in
                    if !error {
                        DispatchQueue.main.async {
                            self.testTapped(self)
                        }
                    } else {
                        showErrorToUser(error: error)
                    }
                }
            } else {
                showErrorToUser(error: err)
            }
        }
        #endif
       
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: BUTTON
    @IBAction func testTapped(_ sender: Any) {
        
        JavaScriptEvaluator.instance.startOperationWithIdString(NSUUID().uuidString)
        testButton.title = "Running..."
        updateTestButton(isEnabled: false)
    }
    @objc func updateTestButton(isEnabled: Bool) {
        testButton.isEnabled = isEnabled
        if isEnabled {
            testButton.title = "Test"
        }
    }
    
    func showErrorToUser(error: JumboError) {
        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .default) { (action) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        ac.addAction(ok)
        self.present(ac, animated: true, completion: nil)
    }
    
}

extension ProgressViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfOperations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}

extension ProgressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ProgressTableViewCell else {
            return UITableViewCell(frame: .zero)
        }
        let objects = numberOfOperations[indexPath.section].objects
        if let last = objects.last {
            //print(last)
            cell.updateCell(last)
        }
        return cell
    }
}

extension ProgressViewController: EvaluatorDelegate {
    func updateObjectWithID(_ message: Message) {
        //print("message: \(message)")
        var sectionData: SectionData
        if numberOfOperations.isEmpty {
            sectionData = SectionData.init(id: message.id, objects: [message])
            numberOfOperations.insert(sectionData, at: 0)
        } else {
            evaluateMessage(m: message)
        }
        tableView.reloadData()
    }
    
    // MARK: SECTION DATA HELPER
    func evaluateMessage(m: Message) {
        var contains = numberOfOperations.first(where: {$0.id == m.id})
        let index = numberOfOperations.firstIndex(where:{$0.id == m.id})
        contains?.objects.append(m)
        if contains == nil {
            numberOfOperations.insert(SectionData.init(id: m.id, objects: [m]), at: 0)
            
        } else {
            numberOfOperations[index ?? 0].objects = contains!.objects
            
        }
        
    }
    
    func didStartOperation() {
        print("didStartOperation")
    }
    
    func error(_ error: JumboError) {
        showErrorToUser(error: error)
    }
    
}

