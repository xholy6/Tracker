import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let identifier = "colorCell"
    
    var isCellSelected = false {
        didSet {
            isCellSelected ? showBorderLine() : hideBorderLine()
        }
    }
    
    private lazy var colorView: UIView = {
        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 9
        return colorView
    }()
    
    func config(color: UIColor?) {
        colorView.backgroundColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showBorderLine() {
        layer.borderWidth = 3
        layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
    }
    
    private func hideBorderLine() {
        layer.borderWidth = 0
        layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(colorView)
    }
    
    private func activateConstraints() {
        let edge: CGFloat = 5
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: edge),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -edge)
        ])
    }
}
