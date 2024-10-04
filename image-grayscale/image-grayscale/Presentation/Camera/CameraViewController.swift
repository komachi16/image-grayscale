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
    private var photoOutput: AVCapturePhotoOutput?
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

    private let loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var isCountingDown: Bool {
        !countdownLabel.isHidden
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetCamera()
        setupCamera()
    }

    private func setupLayout() {
        view.addSubview(shutterButton)
        view.addSubview(countdownLabel)
        view.addSubview(loadingView)

        shutterButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-40)
            $0.width.height.equalTo(72)
        }

        countdownLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(64)
        }

        loadingView.center = view.center
    }

    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available.")
            return
        }
        setupDeviceInput(device: captureDevice)
        setupPhotoOutput()
        setupPreviewLayer()

        Task.detached { [weak self] in
            await self?.captureSession.startRunning()
        }
    }

    private func setupDeviceInput(device: AVCaptureDevice) {
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)

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

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill

        guard let previewLayer else { return }
        view.layer.addSublayer(previewLayer)

        view.bringSubviewToFront(shutterButton)
        view.bringSubviewToFront(countdownLabel)
        view.bringSubviewToFront(loadingView)
    }

    private func resetCamera() {
        captureSession.stopRunning()
        if let deviceInput = deviceInput {
            captureSession.removeInput(deviceInput)
        }
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }

    private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    @objc
    private func shutterButtonTapped(_ sender: UIButton) {
        guard !isCountingDown else { return }
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

    private func applyMonochromeFilter(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image),
              let filter = CIFilter(name: "CIColorMonochrome")
        else {
            return UIImage()
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIColor(red: 0.0, green: 0.0, blue: 0.0), forKey: kCIInputColorKey)
        filter.setValue(1.0, forKey: kCIInputIntensityKey)

        let context = CIContext()
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }

    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? image
    }

    private func saveImageToCameraRoll(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else { return }

        loadingView.startAnimating()

        let fixedImage = fixImageOrientation(image)
        let monochromeImage = applyMonochromeFilter(to: fixedImage)

        saveImageToCameraRoll(monochromeImage)

        Task { @MainActor in
            loadingView.stopAnimating()
            let resultVC = ResultViewController()
            resultVC.capturedImage = monochromeImage
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}
