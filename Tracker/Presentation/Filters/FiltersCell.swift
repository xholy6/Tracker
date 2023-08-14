import UIKit

final class FilterCell: UITableViewCell {

    static let identifier = "FilterCell"

    var isSelectedCell: Bool = true {
        didSet {
            checkMarkImageView.isHidden = self.isSelectedCell
        }
    }

    private lazy var filterName: UILabel = {
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
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray
        return view
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
        contentView.addSubViews(filterName, checkMarkImageView, lineView)
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            filterName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            filterName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            filterName.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),

            checkMarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkMarkImageView.heightAnchor.constraint(equalToConstant: 24),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: 24),

            lineView.leadingAnchor.constraint(equalTo: filterName.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: checkMarkImageView.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    func configCell(filter: String, isSelected: Bool) {
        filterName.text = filter
        checkMarkImageView.isHidden = !isSelected
    }
}
