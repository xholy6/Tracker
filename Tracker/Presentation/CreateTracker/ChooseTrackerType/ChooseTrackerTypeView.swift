import UIKit

protocol ChooseTrackerTypeViewDelegate: AnyObject {
    func showHabitCreaterVC()
    func showIrregularCreaterVC()
}

final class ChooseTrackerTypeView: UIView {
    
    weak var delegate: ChooseTrackerTypeViewDelegate?
    
    //MARK: - UI objects
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Привычка", for: .normal)
        setupButtonStyle(button: button)
        button.addTarget(self, action:#selector(habitButtonTapped) , for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Нерегулярное событие", for: .normal)
        setupButtonStyle(button: button)
        button.addTarget(self, action:#selector(irregularEventButtonTapped) , for: .touchUpInside)
        return button
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private func setupButtonStyle(button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
    }
    
     init(frame: CGRect, delegate: ChooseTrackerTypeViewDelegate) {
         super.init(frame: frame)
         self.delegate = delegate
         setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }
    
    @objc
    private func habitButtonTapped() {
        delegate?.showHabitCreaterVC()
    }
    
    @objc
    private func irregularEventButtonTapped() {
        delegate?.showIrregularCreaterVC()
    }
}
