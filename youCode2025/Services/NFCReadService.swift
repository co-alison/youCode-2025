//
//  NFCReadService.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import Foundation
import CoreNFC
import os

class NFCReadService: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var message: String = ""
    private var readerSession: NFCTagReaderSession?
//    private var writeData: NFCData?
    
    func scanTag() {
//        guard NFCNDEFReaderSession.readingAvailable else {
//            let alertController = UIAlertController(
//                title: "Scanning Not Supported",
//                message: "This device doesn't support tag scanning.",
//                preferredStyle: .alert
//            )
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
//            return
//        }
        
        readerSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self, queue: nil)
        readerSession?.alertMessage = "Hold your iPhone near an NFC fish tag."
        readerSession?.begin()
    }
    
    // MARK: - NFCTagReaderSessionDelegate
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // If necessary, you may perform additional operations on session start.
        // At this point RF polling is enabled.
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        // If necessary, you may handle the error. Note session is no longer valid.
        // You must create a new session to restart RF polling.
    }
    
    // MARK: - Private helper functions
    func tagRemovalDetect(_ tag: NFCTag) {
        self.readerSession?.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                
                os_log("Restart polling.")
                
                self.readerSession?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                self.tagRemovalDetect(tag)
            })
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tags was found. Please present only 1 tag."
            self.tagRemovalDetect(tags.first!)
            return
        }
        
        var ndefTag: NFCNDEFTag
        
        switch tags.first! {
        case let .iso7816(tag):
            ndefTag = tag
        case let .feliCa(tag):
            ndefTag = tag
        case let .iso15693(tag):
            ndefTag = tag
        case let .miFare(tag):
            ndefTag = tag
        @unknown default:
            session.invalidate(errorMessage: "Tag not valid.")
            return
        }
        
        session.connect(to: tags.first!) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }
            
            ndefTag.queryNDEFStatus() { (status: NFCNDEFStatus, _, error: Error?) in
                if status == .notSupported {
                    session.invalidate(errorMessage: "Tag not valid.")
                    return
                }
                ndefTag.readNDEF() { (message: NFCNDEFMessage?, error: Error?) in
                    if error != nil || message == nil {
                        session.invalidate(errorMessage: "Read error. Please try again. \(String(describing: error))")
                        print("Error: ", error as Any)
                        return
                    } else if (message != nil) {
                        os_log("Tag updated")
//                        session.alertMessage = "Tag read success."
                        session.invalidate()
                        return
                    }
                    
//                    if self.updateWithNDEFMessage(message!) {
//                        
//                    }
                    
                    session.invalidate(errorMessage: "Tag not valid.")
                }
            }
        }
    }
}

