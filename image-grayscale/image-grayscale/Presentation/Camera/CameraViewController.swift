//
//  CameraViewController.swift
//  image-grayscale
//
//  Created by komachi16 on 2024/09/29.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    private let captureSession = AVCaptureSession()

    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput = AVCapturePhotoOutput()

    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetCamera()
    }

    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            print("Error setting up camera input: \(error)")
            return
        }

        guard let deviceInput = deviceInput else { return }

        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        } else {
            return
        }

        photoOutput = AVCapturePhotoOutput()

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }

        captureSession.startRunning()
    }

    private func resetCamera() {
        captureSession.stopRunning()
        if let deviceInput = deviceInput {
            captureSession.removeInput(deviceInput)
        }
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
}
