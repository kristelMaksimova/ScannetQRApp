//
//  CameraView.swift
//  ScannetQRApp
//
//  Created by Kristi on 31.05.2023.
//

import SwiftUI
import AVKit

struct CameraView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    var frameSize: CGSize
    
    // Сессия камеры
    @Binding var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: CGRect(origin: .zero, size: frameSize))
        
        let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.frame = .init(origin: .zero, size: frameSize)
        cameraLayer.videoGravity = .resizeAspectFill
       // cameraLayer.masksToBounds = true
        view.layer.addSublayer(cameraLayer)
        
        return view
    }
}


