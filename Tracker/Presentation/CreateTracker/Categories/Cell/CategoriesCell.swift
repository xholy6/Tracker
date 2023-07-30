import UIKit

final class CategoriesCell: UITableViewCell {
    
    static let identifier = "categoriesCell"
    
    private lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.ypRegular17
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .ypLightGray
        contentView.addSubview(categoryNameLabel)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryNameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
        ])
    }
    
    func configCell(categoryName: String) {
        categoryNameLabel.text = categoryName
    }
}
