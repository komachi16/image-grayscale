//
//  CameraManager.swift
//  image-grayscale
//  
//  Created by komachi16 on 2024/10/06.
//

import AVFoundation
import UIKit

class CameraManager {
    let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?

    func setupSession() {
        setupDeviceInput()
        setupPhotoOutput()
    }

    private func setupDeviceInput() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available.")
            return
        }
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)

            guard let deviceInput else { return }
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        } catch {
            print("Error setting up camera input: \(error)")
        }
    }

   private func setupPhotoOutput() {
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }

    func captureSessionStart() {
        Task.detached { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func takePhoto(delegate: AVCapturePhotoCaptureDelegate) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate)
    }

    func stopCamera() {
        captureSession.stopRunning()
        if let deviceInput = deviceInput {
            captureSession.removeInput(deviceInput)
        }
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
    }
}
