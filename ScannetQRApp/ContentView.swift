//
//  ContentView.swift
//  ScannetQRApp
//
//  Created by Kristi on 31.05.2023.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    
    // Ошибка
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showAlert: Bool = false
    
    @Environment(\.openURL) private var openURL
      @StateObject private var qrDelegate = QRScannerDelegate()
    
    // Сканирование
    @State private var scannedCode: String = ""
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = geometry.size
                
                CameraView(frameSize: size, session: $session)
                
                ZStack {
                    ForEach(0...4, id: \.self) { index in
                        let rotation = Double(index) * 90
                        RoundedRectangle(cornerRadius: 2, style: .circular)
                            .trim(from: 0.61, to: 0.64)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .rotationEffect(.init(degrees: rotation))
                    }
                }
                .frame(width: 250, height: 250)
                .position(x: size.width/2, y: size.height/2)
                
            }
            
            VStack {
                Text("Пожалуйста наведите камеру на QR код")
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 80)
                Text("Сканирование начнется автоматически")
                    .font(.callout)
                    .padding()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .onAppear(perform: {
                   checkCameraPermission()
                   startScanning()
               })
        .alert(errorMessage, isPresented: $showError) {
            
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingString = UIApplication.openSettingsURLString
                    if let settingURL = URL(string: settingString) {
                        openURL(settingURL)
                    }
                }
            }
        }
        
         .onChange(of: qrDelegate.scannedCode) { newValue in
         if let code = newValue {
         scannedCode = code
         session.stopRunning()
         showAlert = true // Добавьте новое состояние showAlert
         }
         }
        
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Code Scanned"),
                message: Text(scannedCode), // Отображение отсканированного кода в качестве сообщения
                dismissButton: .default(Text("OK")) {
                    scannedCode = "" // Сброс отсканированного кода
                    DispatchQueue.global(qos: .background).async {
                        session.startRunning()// Запуск процесса сканирования снова
                   
                    }
                }
            )
        }
    }
    
    // Проверка разрешения камеры
    
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                setupCamera()
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    cameraPermission = .denied
                    presentError("Пожалуйста предоставьте доступ к камере для сканирования кода")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Пожалуйста предоставьте доступ к камере для сканирования кода")
            default: break
            }
        }
    }
    
    // Настройка камеры
    func setupCamera() {
        do {
            // Поиск задней камеры
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
                presentError("UNKNOWN DEVICE ERROR")
                return
            }
            // Вход камеры
            let input = try AVCaptureDeviceInput(device: device)
            // Для дополнительной безопасности
            // Проверяем можно ли добавить ввод и вывод в сессию
            
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("UNKNOWN INPUT/OUTPUT ERROR")
                return
            }
            
            // Добавление ввода и вывода в сеанс камеры
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            // Настройка конфигурации вывода для чтения QR-кода
            qrOutput.metadataObjectTypes = [.qr]
            
            // Добавление делегата для получения полученного QR-кода с камеры
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            
            // Сессия должна быть запущена в фоновом режиме
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
        } catch {
            presentError(error.localizedDescription)
        }
    }
    
    func presentError (_ message: String) {
        errorMessage = message
        showError.toggle()
    }
    
    func startScanning() {
        
        if cameraPermission == .approved { // Check if camera permission is approved
            DispatchQueue.global(qos: .background).async {
                session.startRunning() // Start the scanning process
               
            }
        } else {
            // Camera permission is not approved, present an error message
            presentError("Пожалуйста предоставьте доступ к камере для сканирования кода")
        }
    }
}

