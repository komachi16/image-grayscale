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
    struct Const {
        static let circleViewHeight = CGFloat(96)
    }

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

    private let countDownCircleView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .white
        view.alpha = 0.2
        view.layer.cornerRadius = Const.circleViewHeight / 2
        view.clipsToBounds = true
        return view
    }()

    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        return label
    }()

    private let loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.large
        return indicator
    }()

    private var isCountingDown: Bool {
        !countDownCircleView.isHidden
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

        view.addSubview(countDownCircleView)
        countDownCircleView.addSubview(countdownLabel)

        view.addSubview(loadingView)

        shutterButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-40)
            $0.width.height.equalTo(72)
        }

        countDownCircleView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(Const.circleViewHeight)
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
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait

        view.layer.addSublayer(previewLayer)

        view.bringSubviewToFront(shutterButton)
        view.bringSubviewToFront(countDownCircleView)
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
        countDownCircleView.isHidden = false
        startCountdown()
    }

    private func startCountdown() {
        var countdown = 3
        countdownLabel.text = "\(countdown)"

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            countdown -= 1
            self?.countdownLabel.text = "\(countdown)"
            if countdown == 0 {
                self?.countDownCircleView.isHidden = true
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
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        loadingView.startAnimating()
        cameraManager.captureSession.stopRunning()
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else { return }

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
