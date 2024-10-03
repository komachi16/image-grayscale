//
//  ResultViewController.swift
//  image-grayscale
//  
//  Created by komachi16 on 2024/10/03.
//

import Foundation
import SnapKit
import UIKit

class ResultViewController: UIViewController {
    var capturedImage: UIImage?

    private let resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let bottomView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var finishButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(finishButtonTapped(_:)), for: .touchUpInside)
        button.setTitle("終了", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = CGFloat(8.0)
        button.clipsToBounds = true
        button.backgroundColor = .systemTeal
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        resultImageView.image = capturedImage
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(resultImageView)
        view.addSubview(bottomView)
        bottomView.addSubview(finishButton)

        resultImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        bottomView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        finishButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(72)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }

    @objc
    func finishButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
