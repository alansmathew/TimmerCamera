//
//  ViewController.swift
//  Timer camera
//
//  Created by Alan S Mathew on 10/06/19.
//  Copyright © 2019 Alan S Mathew. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var backCamera : AVCaptureDevice?
    var frontCamera : AVCaptureDevice?
    var currentCamera : AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var cameraPerviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPerviewLayer()
        startRunningCaptureSession()
        // Do any additional setup after loading the view.
    }
    
    func setupCaptureSession(){
        captureSession.sessionPreset=AVCaptureSession.Preset.photo
    }
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    func setupInputOutput(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])],completionHandler: nil)
            
        }catch {
            print(error)
        }
    }
    func setupPerviewLayer(){
        cameraPerviewLayer =  AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPerviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPerviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPerviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPerviewLayer!,at :0)
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
}

