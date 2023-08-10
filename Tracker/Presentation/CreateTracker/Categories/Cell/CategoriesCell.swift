import UIKit

final class CategoriesCell: UITableViewCell {
    
    static let identifier = "categoriesCell"
    
    var isSelectedCell: Bool = true {
        didSet {
            let r = self.isSelectedCell
            checkMarkImageView.isHidden = r
        }
    }
    
    private lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.ypRegular17
        return label
    }()
    
    private lazy var checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "checkMark")
        imageView.backgroundColor = .ypLightGray
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func shouldShowCheckMark() -> Bool {
//
//    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .ypLightGray
        contentView.addSubViews(categoryNameLabel, checkMarkImageView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryNameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            checkMarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkMarkImageView.heightAnchor.constraint(equalToConstant: 24),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    func configCell(categoryName: String) {
        categoryNameLabel.text = categoryName
    }
}
