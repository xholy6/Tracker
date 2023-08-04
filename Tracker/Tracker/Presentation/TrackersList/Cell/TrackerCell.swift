import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func checkTracker(id: String?, completed: Bool)
}

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = "trackerCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var completedTracker = false {
        didSet {
            if completedTracker {
                daysCount += 1
            } else {
                daysCount -= 1
            }
        }
    }
    
    private var trackerId: String?
    private var daysCount: Int = 0
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var dayCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = .ypMedium12
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .ypMedium16
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameTrackerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .ypMedium12
        label.textColor = .white
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        let image = getButtonImage(completedTracker)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypColor3
        button.addTarget(self, action: #selector(completeTrackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emojiAndNameView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayCountAndButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(tracker: Tracker, completedDaysCount: Int?, completed: Bool) {
        emojiLabel.text = tracker.emoji
        nameTrackerLabel.text = tracker.name
        emojiAndNameView.backgroundColor = tracker.color
        completeButton.backgroundColor = getBackgroundButtonColor(color: tracker.color)
        trackerId = tracker.id
        completedTracker = completed
        
        let image = getButtonImage(completedTracker)
        completeButton.setImage(image, for: .normal)
        let backgroundColor = getBackgroundButtonColor(color: completeButton.backgroundColor)
        completeButton.backgroundColor = backgroundColor
        
        guard let completedDaysCount else { return }
        daysCount = completedDaysCount
        setDaysLabel()
    }
    
    func enabledCheckTrackerButton(enabled: Bool) {
        completeButton.isEnabled = enabled ? false : true
    }
    
    private func getButtonImage(_ check: Bool) -> UIImage? {
        let doneImage = UIImage(named: "Done")?.withRenderingMode(.alwaysTemplate)
        let plusImage = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        return check ? doneImage : plusImage
    }
    
    private func getBackgroundButtonColor(color: UIColor?) -> UIColor? {
        completedTracker ? color?.withAlphaComponent(0.3) : color?.withAlphaComponent(1)
    }
    
    private func setDaysLabel() {
        let stringDay = String.getDayAddition(int: daysCount)
        dayCountLabel.text = "\(daysCount) \(stringDay)"
    }
    
    @objc
    private func completeTrackerButtonTapped() {
        completedTracker = !completedTracker
        let image = getButtonImage(completedTracker)
        completeButton.setImage(image, for: .normal)
        let backgroundColor = getBackgroundButtonColor(color: completeButton.backgroundColor)
        completeButton.backgroundColor = backgroundColor
        setDaysLabel()
        delegate?.checkTracker(id: self.trackerId, completed: completedTracker)
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(emojiAndNameView)
        stackView.addArrangedSubview(dayCountAndButtonView)
        
        emojiAndNameView.addSubViews(emojiLabel, nameTrackerLabel)
        dayCountAndButtonView.addSubViews(dayCountLabel, completeButton)
    }
    
    private func activateConstraints() {
        emojiLabel.layer.cornerRadius = 12
        let offset: CGFloat = 12
        completeButton.layer.cornerRadius = 17
        completeButton.clipsToBounds = true
    
        emojiAndNameView.heightAnchor.constraint(equalTo: dayCountAndButtonView.heightAnchor, multiplier: 2).isActive = true

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            
            emojiLabel.topAnchor.constraint(equalTo: emojiAndNameView.topAnchor, constant: offset),
            emojiLabel.leftAnchor.constraint(equalTo: emojiAndNameView.leftAnchor, constant: offset),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant:  24),
            
            nameTrackerLabel.bottomAnchor.constraint(equalTo: emojiAndNameView.bottomAnchor, constant: -offset),
            nameTrackerLabel.leftAnchor.constraint(equalTo: emojiAndNameView.leftAnchor, constant: offset),
            nameTrackerLabel.rightAnchor.constraint(equalTo: emojiAndNameView.rightAnchor, constant: -offset),
            
            dayCountLabel.centerYAnchor.constraint(equalTo: dayCountAndButtonView.centerYAnchor),
            dayCountLabel.leftAnchor.constraint(equalTo: nameTrackerLabel.leftAnchor),
            dayCountLabel.rightAnchor.constraint(equalTo: completeButton.leftAnchor),
            
            completeButton.rightAnchor.constraint(equalTo: dayCountAndButtonView.rightAnchor, constant: -offset),
            completeButton.topAnchor.constraint(equalTo: dayCountAndButtonView.topAnchor, constant: 8),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 34),
        ])
    }
}
