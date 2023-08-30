//
//  PlugView.swift
//  Tracker
//
//  Created by D on 12.06.2023.
//

import UIKit

final class PlugView: UIStackView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame.size = CGSize(width: 80, height: 80)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .ypMedium12
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(frame: CGRect, titleLabel: String, image: UIImage) {
        super.init(frame: frame)
        setupView()
        imageView.image = image
        label.text = titleLabel
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(title: String, image: UIImage?) {
        label.text = title
        imageView.image = image
    }
    
    private func setupView() {
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fill
        axis = .vertical
        spacing = 8
        
    }
    
    
}
