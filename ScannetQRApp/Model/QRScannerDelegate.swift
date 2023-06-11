//
//  QRScannerDelegate.swift
//  ScannetQRApp
//
//  Created by Kristi on 31.05.2023.
//


import SwiftUI
import AVKit

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let code = readableObject.stringValue else { return }
            print(code)
            DispatchQueue.main.async { // Switch to the main queue
                self.scannedCode = code // Update the scannedCode property
            }
           
        }
    }
}

