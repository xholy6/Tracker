import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let identifier = "emojiCell"
    
    var isCellSelected = false {
        didSet {
            isCellSelected ? highlightSelectedCell() : dehighlightSelectedCell()
        }
    }
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .ypBold32
        return label
    }()
    
    func config(emoji: String?) {
        emojiLabel.text = emoji
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func highlightSelectedCell() {
        contentView.backgroundColor = .ypLightGray
    }
    
    private func dehighlightSelectedCell() {
        contentView.backgroundColor = .clear
    }
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(emojiLabel)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}
