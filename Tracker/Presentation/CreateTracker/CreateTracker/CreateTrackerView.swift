import UIKit

protocol CreateTrackerViewDelegate: AnyObject {
    func cancelCreation()
    func textFieldDidChanged(text: String) -> Bool
    func sendTrackerName(trackerName: String?)
}

final class CreateTrackerView: UIView {
    
    weak var delegate: CreateTrackerViewDelegate?
    
    private struct CreateTrackerViewConstants {
        static let errorLabelText = "Ограничение 38 символов"
        static let textFieldPlaceholder = "Введите название трекера"
    }
    
    //MARK: - Private properties
    private var trackerType: TrackerType
    private var contentSize: CGSize {
        CGSize(width: frame.width, height: 930)
    }
    
    private var topViewConstraint: NSLayoutConstraint!
    
    
    //MARK: - UI Objects
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.contentSize = contentSize
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame.size = contentSize
        return contentView
    }()
    
    private lazy var nameTrackerTextField: CustomTextField = {
        let textField = CustomTextField(frame: .zero,
                                        placeholderText: CreateTrackerViewConstants.textFieldPlaceholder)
        textField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.ypRegular17
        label.textColor = .red
        label.text = CreateTrackerViewConstants.errorLabelText
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var categoryAndScheduleTableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.register(ScheduleAndCategoryCell.self,
                           forCellReuseIdentifier: ScheduleAndCategoryCell.indentifier)
        tableview.layer.cornerRadius = 16
        tableview.backgroundColor = .ypLightGray
        return tableview
    }()
    
    private lazy var emojiAndColorsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.register(EmojiCollectionViewCell.self,
                                forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.register(HeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderReusableView.headerIdentifier)
        collectionView.register(ColorCollectionViewCell.self,
                                forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.ypMedium16
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed?.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.ypMedium16
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypGray
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    
    //MARK: - Initializer
    
    init(frame: CGRect,
         delegate: CreateTrackerViewDelegate?,
         trackerType: TrackerType ) {
        self.delegate = delegate
        self.trackerType = trackerType
        super.init(frame: frame)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private functions
    private func setupView() {
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubViews(nameTrackerTextField,
                                errorLabel,
                                stackView,
                                buttonStackView)
        
        stackView.addArrangedSubview(categoryAndScheduleTableView)
        stackView.addArrangedSubview(emojiAndColorsCollectionView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func activateConstraints() {
        var tableViewHeight: CGFloat = 75
        
        switch trackerType {
        case .habit:
            tableViewHeight *= 2
        case .irregularEvent:
            break
        }
        
        let edge: CGFloat = 16
        let buttonHeight: CGFloat = 60
        
        topViewConstraint = stackView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            
            topViewConstraint,
            
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            nameTrackerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.leadingAnchor.constraint(equalTo: nameTrackerTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: nameTrackerTextField.trailingAnchor),
            errorLabel.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 8),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            stackView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -10),
            
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            buttonStackView.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            categoryAndScheduleTableView.heightAnchor.constraint(equalToConstant: tableViewHeight)
        ])
    }
    
    //MARK: - Objc methods
    @objc
    private func handleTextFieldChange() {
        guard let text = nameTrackerTextField.text else { return }
        guard let delegate = delegate else { return }
        if delegate.textFieldDidChanged(text: text) {
            errorLabel.alpha = 0
            topViewConstraint.constant = 24
            layoutIfNeeded()
        } else {
            nameTrackerTextField.text = String(text.prefix(38))
            errorLabel.alpha = 1
            topViewConstraint.constant = 40
            layoutIfNeeded()
        }
        
        if nameTrackerTextField.text?.isEmpty == false {
            createButton.backgroundColor = .ypBlack
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .ypGray
            createButton.isEnabled = false
        }
    }
    
    @objc
    private func cancelButtonTapped() {
        delegate?.cancelCreation()
    }
    
    @objc
    private func createButtonTapped() {
        delegate?.sendTrackerName(trackerName: nameTrackerTextField.text)
        
    }
    //MARK: - Internal Method
    func refreshTableView() {
        categoryAndScheduleTableView.reloadData()
    }
}

extension CreateTrackerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - TableViewDataSource && TableViewDelegate
extension CreateTrackerView {
    func setupTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        categoryAndScheduleTableView.delegate = delegate
        categoryAndScheduleTableView.dataSource = dataSource
    }
}

extension CreateTrackerView {
    func setupCollectionView(delegate: UICollectionViewDelegateFlowLayout, dataSource: UICollectionViewDataSource) {
        emojiAndColorsCollectionView.delegate = delegate
        emojiAndColorsCollectionView.dataSource = dataSource
    }
}
