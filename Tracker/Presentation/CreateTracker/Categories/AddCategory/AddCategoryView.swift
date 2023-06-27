import UIKit

protocol AddCategoryViewDelegate: AnyObject {
    func textFieldDidChanged(text: String) -> Bool
    func confirmNewCategory(with text: String)
    func dismissVC()
}

final class AddCategoryView: UIView {
    
    weak var delegate: AddCategoryViewDelegate?
    
    private struct AddCategoryViewConstants {
        static let textFieldPlaceholder = "Введите название трекера"
        static let doneButtonTitle = "Готово"
    }
    
    private lazy var textField: CustomTextField = {
        let textField = CustomTextField(frame: .zero,
                                        placeholderText:
                                            AddCategoryViewConstants.textFieldPlaceholder)
        textField.addTarget(self, action: #selector(textFieldHasChanged), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.setTitle(AddCategoryViewConstants.doneButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.ypMedium16
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(frame: CGRect, delegate: AddCategoryViewDelegate?) {
        self.delegate = delegate
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubViews(textField, doneButton)
        
    }
    
    private func activateConstraints() {
        let edge: CGFloat = 16
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            textField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            doneButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),

        ])
    }
    
    @objc
    private func textFieldHasChanged() {
        guard let text = textField.text else { return }
        guard let delegate = delegate else { return }
        
        doneButton.isEnabled = delegate.textFieldDidChanged(text: text) ? true : false
        doneButton.backgroundColor = doneButton.isEnabled ? .ypBlack : .ypGray
    }
    
    @objc
    private func doneButtonTapped() {
        guard let text = textField.text else { return }
        delegate?.confirmNewCategory(with: text)
        delegate?.dismissVC()
    }
    
}

extension AddCategoryView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
}
