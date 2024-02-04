import UIKit

class TextViewWithPlaceholder: UITextView {
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(placeholderLabel)
   
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(7)
            make.left.equalToSuperview().inset(4)
        }
    }
}
