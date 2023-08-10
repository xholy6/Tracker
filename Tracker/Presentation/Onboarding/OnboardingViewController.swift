//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by D on 06.08.2023.
//

import UIKit


final class OnboardingViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            backImageView.image = image
        }
    }
    
    var infoText: String? {
        didSet {
            onBoardingInfoLabel.text = infoText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        activateConstraints()
    }
    
    private lazy var backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var onBoardingInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .ypBold32
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private func setupView() {
        view.addSubViews(backImageView,
                    onBoardingInfoLabel)
    }
    
    private func activateConstraints() {
        let labelEdge: CGFloat = 16
        NSLayoutConstraint.activate([
            backImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            onBoardingInfoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            onBoardingInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            onBoardingInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: labelEdge),
            onBoardingInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -labelEdge)
        ])
    }
}
