//
//  CameraViewController.swift
//  image-grayscale
//
//  Created by komachi16 on 2024/09/29.
//

import UIKit
import AVFoundation
import SnapKit

class CameraViewController: UIViewController {

    private let captureSession = AVCaptureSession()

    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput = AVCapturePhotoOutput()

    private var previewLayer: AVCaptureVideoPreviewLayer?

    private lazy var shutterButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(shutterButtonTapped(_:)), for: .touchUpInside)
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        button.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        return button
    }()

    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = .systemFont(ofSize: 30)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetCamera()
    }

    private func setupLayout() {
        view.addSubview(shutterButton)
        view.addSubview(countdownLabel)

        shutterButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-40)
            $0.width.height.equalTo(72)
        }

        countdownLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(64)
        }
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

    private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc
    private func shutterButtonTapped(_ sender: UIButton) {
        countdownLabel.isHidden = false
        startCountdown()
    }

    private func startCountdown() {
        var countdown = 3
        countdownLabel.text = "\(countdown)"

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            countdown -= 1
            self?.countdownLabel.text = "\(countdown)"
            if countdown == 0 {
                self?.countdownLabel.isHidden = true
                timer.invalidate()
                self?.takePhoto()
            }
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        // TODO: モノクロ変換機能を追加

        // TODO: 結果画面に遷移
    }
}
