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

    private let cameraManager = CameraManager()
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
        cameraManager.setupSession()
        setupPreviewLayer()

        cameraManager.captureSessionStart()
    }

    private func setupPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        view.bringSubviewToFront(shutterButton)
        view.bringSubviewToFront(countdownLabel)
        view.bringSubviewToFront(loadingView)
    }

    private func resetCamera() {
        cameraManager.stopCamera()
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }

    private func takePhoto() {
        cameraManager.takePhoto(delegate: self)
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

        let fixedImage = ImageUtil.fixImageOrientation(image)
        let monochromeImage = ImageUtil.applyMonochromeFilter(to: fixedImage)

        saveImageToCameraRoll(monochromeImage)

        Task { @MainActor in
            loadingView.stopAnimating()
            let resultVC = ResultViewController()
            resultVC.capturedImage = monochromeImage
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}
