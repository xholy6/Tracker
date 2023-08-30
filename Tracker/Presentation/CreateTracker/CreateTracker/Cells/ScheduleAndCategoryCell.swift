import UIKit

final class ScheduleAndCategoryCell: UITableViewCell {
        
    static let indentifier = "ScheduleCategory"
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .ypRegular17
        label.textColor = .black
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "rightArrow")?.withRenderingMode(.alwaysOriginal)
        image.contentMode = .right
        return image
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .ypLightGray
        contentView.addSubview(label)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),

            lineView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: arrowImageView.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.5)

        ])
    }
}
