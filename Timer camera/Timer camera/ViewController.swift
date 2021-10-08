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
    let settings = AVCapturePhotoSettings()
    
    var photoOutput = AVCapturePhotoOutput()
    var cameraPerviewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet weak var capturedImage: UIImageView!
    var images = [UIImage]()
    var items = [GalleryItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPerviewLayer()
        startRunningCaptureSession()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        var captureNumber = 0
    
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            captureNumber += 1
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 160,
                kCVPixelBufferHeightKey as String: 160
            ]
            settings.previewPhotoFormat = previewFormat
            photoOutput.capturePhoto(with: settings, delegate: self)
            if captureNumber == 3 {
                timer.invalidate()
            }
        }
        //        performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
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
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera! )
            captureSession.addInput(captureDeviceInput)
            if (captureSession.canAddOutput(photoOutput)) {
                captureSession.addOutput(photoOutput)
            }
            photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])],completionHandler: nil)
        }catch{
            print("error")
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
    @IBAction func showGallery(_ sender: Any) {
        items.removeAll()
        var galleryItem: GalleryItem!
        for item in images {
            galleryItem = GalleryItem.image{ $0(item) }
            items.append(galleryItem)
        }
        let galleryViewController = GalleryViewController(startIndex: 0, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: galleryConfiguration())
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        galleryViewController.landedPageAtIndexCompletion = { index in
            
        }
        
        self.presentImageGallery(galleryViewController)
    }
    
}
extension ViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            if let dataImage = photo.fileDataRepresentation() {
                let dataProvider = CGDataProvider(data: dataImage as CFData)
                let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
                self.capturedImage.image = image
                self.images.append(image)
                print(self.images.count)
            } else {
                print("some error here")
            }
        }
    }
}
extension ViewController: GalleryItemsDelegate {
    
    func removeGalleryItem(at index: Int) {
        print("remove item at \(index)")
        items.remove(at: index)
    }
}
