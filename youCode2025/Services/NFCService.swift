//
//  NFCService.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//
import Foundation
import CoreNFC

class NFCService: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    private var nfcSession: NFCNDEFReaderSession?
    private var isWriteMode: Bool = false
    private var messageToWrite: NFCNDEFMessage?

    @Published var scannedText: String = ""
    @Published var statusMessage: String = ""
    @Published var complete: Bool = false

    func startReading() {
        isWriteMode = false
        complete = false
        scannedText = ""
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to read."
        nfcSession?.begin()
    }

    func startWriting(with tagId: String) {
        isWriteMode = true
        complete = false
        let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: tagId, locale: Locale(identifier: "en"))!
        messageToWrite = NFCNDEFMessage(records: [payload])
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to write."
        nfcSession?.begin()
    }

    // MARK: - NFCNDEFReaderSessionDelegate

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.statusMessage = "Session ended: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }

            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: "Query failed: \(error.localizedDescription)")
                    return
                }

                if self.isWriteMode {
                    guard let message = self.messageToWrite else {
                        session.invalidate(errorMessage: "No message to write.")
                        return
                    }

                    if status == .readWrite {
                        if let record = message.records.first {
                            let payload = record.payload
                            print("Writing payload bytes: \(payload.map { String(format: "%02x", $0) }.joined())")
                        }
                        tag.writeNDEF(message) { error in
                            if let error = error {
                                session.invalidate(errorMessage: "Failed to add gear: \(error.localizedDescription)")
                            } else {
                                session.alertMessage = "Gear Added!!"
                                print(message)
                                session.invalidate()
                                self.complete = true
                                DispatchQueue.main.async {
                                    self.statusMessage = "Gear Added!"
                                }
                            }
                        }
                    } else {
                        session.invalidate(errorMessage: "Tag is not writable.")
                    }
                } else {
                    tag.readNDEF { message, error in
                        if let error = error {
                            session.invalidate(errorMessage: "Read failed: \(error.localizedDescription)")
                            return
                        }

                        if let message = message {
                            let text = message.records.compactMap { record -> String? in
                                let payload = record.payload
                                guard let statusByte = payload.first else { return nil }

                                let isUTF16 = (statusByte & 0x80) != 0
                                let langCodeLength = Int(statusByte & 0x3F)
                                let textData = payload.dropFirst(1 + langCodeLength)

                                let encoding: String.Encoding = isUTF16 ? .utf16 : .utf8
                                let decoded = String(data: textData, encoding: encoding)
                                return decoded
                            }.joined(separator: "\n")

                            DispatchQueue.main.async {
                                self.scannedText = text
                                print("Scanned text: \(self.scannedText)")
                                session.alertMessage = "Tag scanned!"
                                self.complete = true
                                self.statusMessage = "Tag scanned!"
                            }
                        }

                        session.invalidate()
                    }
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Optional: Used if you want passive detection rather than tag connect
    }
}
