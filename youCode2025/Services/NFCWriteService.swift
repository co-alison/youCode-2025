//
//  NFCWriteService.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import CoreNFC
import os

class NFCWriteService: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    var readerSession: NFCNDEFReaderSession?
//    var ndefMessage: NFCNDEFMessage?
    private var writeData: GearItem?
    
    func writeTag(data: GearItem) {
        writeData = data
        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        readerSession?.alertMessage = "Hold your iPhone near a writable NFC tag to update."
        readerSession?.begin()
    }
    
    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        // In the tag removal procedure, you connect to the tag and query for
        // its availability. You restart RF polling when the tag becomes
        // unavailable; otherwisFg.
        self.readerSession?.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                
                os_log("Restart polling")
                
                self.readerSession?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                self.tagRemovalDetect(tag)
            })
        }
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC session become active======")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // If necessary, you may handle the error. Note session is no longer valid.
        // You must create a new session to restart RF polling.
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Do not add code in this function. This method isn't called
        // when you provide `reader(_:didDetect:)`.
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tags found. Please present only 1 tag."
            self.tagRemovalDetect(tags.first!)
            return
        }
        
        // You connect to the desired tag.
        let tag = tags.first!
        session.connect(to: tag) { (error: Error?) in
            if error != nil {
                session.restartPolling()
                return
            }
            
            // You then query the NDEF status of tag.
            tag.queryNDEFStatus() { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Fail to determine NDEF status.  Please try again.")
                    return
                }
                
                if status == .readOnly {
                    session.invalidate(errorMessage: "Tag is not writable.")
                } else if status == .readWrite {
//                    if self.ndefMessage!.length > capacity {
//                        session.invalidate(errorMessage: "Tag capacity is too small.  Minimum size requirement is \(self.ndefMessage!.length) bytes.")
//                        return
//                    }
                    
                    // When a tag is read-writable and has sufficient capacity,
                    // write an NDEF message to it.
//                    tag.writeNDEF(self.writeData!) { (error: Error?) in
//                        if error != nil {
//                            session.invalidate(errorMessage: "Update tag failed. Please try again. \(error)") // TODO: this is getting hit
//                            print("Error: ", error)
//                        } else {
//                            session.alertMessage = "Update success!"
//                            session.invalidate()
//                        }
//                    }
                    
                    if let data = self.writeData?.toJSONString(), let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: data, locale: Locale(identifier: "en")) {
                        let message = NFCNDEFMessage(records: [payload])
                        tag.writeNDEF(message) { (error) in
                            DispatchQueue.main.async {
                                if let error = error {
                                    self.readerSession?.alertMessage = "Error writing: \(error.localizedDescription)"
                                } else {
                                    self.readerSession?.alertMessage = "Data successfully written to tag."
                                }
                                
                            }
                        }
                        
                    }
                } else {
                    session.invalidate(errorMessage: "Tag is not NDEF formatted.")
                }
            }
        }
    }
}
