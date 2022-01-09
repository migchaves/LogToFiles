//
//  MainViewController.swift
//  LogToFiles
//
//  Created by Miguel on 09/01/2022.
//

import UIKit
import MessageUI

class MainViewController: UIViewController {
    
    @IBOutlet weak var messageTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func handleLogMessage() {
        
        guard let text = self.messageTextField.text, text != "" else {
            self.showAlert("Please insert the text to log")
            return
        }
        
        // Save the string to the logs
        print(text, to: &Log.log)
        
        self.showAlert("Information saved")
    }
    
    @IBAction func handleSendLogs() {
        
        do {
            let documentDirectory = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true)[0]
            
            let temp = try FileManager.default.contentsOfDirectory(atPath: documentDirectory)
            let logs = temp.filter { $0.hasPrefix("log_") }
            
            if logs.count == 0 {
                self.showAlert("No logs to send!")
                return
            }
            
            if MFMailComposeViewController.canSendMail() {
                
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                mailComposer.setSubject("Sending logs")
                mailComposer.setMessageBody("Sending app logs in attachement", isHTML: false)
                
                for item in logs {
                    let url = URL(fileURLWithPath: documentDirectory + "/" + item)
                    let fileData = try Data(contentsOf: url)
                    
                    mailComposer.addAttachmentData(
                        fileData,
                        mimeType: "text/txt",
                        fileName: (item as NSString).lastPathComponent)
                }
                
                self.present(mailComposer, animated: true, completion: nil)
                
            } else {
                
                var dataToSave = [Data]()
                
                for item in logs {
                    let url = URL(fileURLWithPath: documentDirectory + "/" + item)
                    let fileData = try Data(contentsOf: url)
                    
                    dataToSave.append(fileData)
                }
                
                let activityController = UIActivityViewController(
                    activityItems: dataToSave,
                    applicationActivities: nil)
                
                activityController.completionWithItemsHandler = { [weak self] (type,completed,items,error) in
                    
                    guard let self = self else {
                        return
                    }
                    
                    self.showAlert("Logs sent")
                }
                
                self.present(activityController, animated: true, completion: nil)
            }
            
        } catch let error {
            self.showAlert("Failed to remove video with error: \(error)")
        }
    }
    
    @IBAction func handleDeleteLogs() {
        
        do {
            let documentDirectory = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true)[0]
            
            let temp = try FileManager.default.contentsOfDirectory(atPath: documentDirectory)
            let logs = temp.filter { $0.hasPrefix("log_") }
            
            for item in logs {
                let url = URL(fileURLWithPath: documentDirectory + "/" + item)
                try FileManager.default.removeItem(at: url)
                print("Remove log file: \(url.lastPathComponent)")
            }
            
        } catch let error {
            self.showAlert("Failed to remove log with error: \(error)")
            return
        }
        
        self.showAlert("Logs removed")
    }
    
    // MARK: - Aux
    
    private func showAlert(_ message: String) {
        
        let alert = UIAlertController(
            title: "Log App",
            message: message,
            preferredStyle: .alert)
        
        let close = UIAlertAction(
            title: "Close",
            style: .default,
            handler: nil)
        
        alert.addAction(close)
        
        self.present(
            alert,
            animated: true,
            completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension MainViewController : MFMailComposeViewControllerDelegate{
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?) {
            
            controller.dismiss(animated: true)
            
            if result == .sent {
                self.showAlert("Logs sent")
            } else {
                self.showAlert("Logs not sent")
            }
        }
}
