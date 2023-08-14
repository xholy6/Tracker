//
//  StatisticsCell.swift
//  Tracker
//
//  Created by D on 14.08.2023.
//

import UIKit

final class StatisticsCell: UITableViewCell {

    static let reuseIdentifer = "cellstat"

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .ypBold34
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .ypMedium12
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupview()
        activateConstraints()
        backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setGradientBorder()
    }

    func configCell(text: String, count: String) {
        titleLabel.text = text
        countLabel.text = count
    }

    private func setupview() {
        contentView.addSubview(containerView)

        containerView.addSubview(countLabel)
        containerView.addSubview(titleLabel)
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90)
        ])

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            countLabel.heightAnchor.constraint(equalToConstant: 41)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func setGradientBorder() {
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true

        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: containerView.frame.size)
        gradient.colors = [UIColor.ypColor1?.cgColor, UIColor.ypColor9?.cgColor, UIColor.ypColor3!.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let shape = CAShapeLayer()
        shape.lineWidth = 3
        shape.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor

        gradient.mask = shape

        containerView.layer.addSublayer(gradient)
    }
}
