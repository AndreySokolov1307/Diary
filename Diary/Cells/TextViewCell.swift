import UIKit

fileprivate enum Constants {
    enum strings {
        static let textViewPlaceholder = "Note"
    }
    
    enum layout {
        static let textViewMinimumHeight: CGFloat = 200
    }
}

class TextViewCell: UITableViewCell {
    static let reuseIdentifier = "TextViewCell"
    
    let textView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(forViewController vc: UIViewController, with item: ToDoItem?) {
        textView.placeholderLabel.text = Constants.strings.textViewPlaceholder
        textView.delegate = (vc.self as! any UITextViewDelegate)
        if let item = item,
           let note = item.note,
           !note.isEmpty {
            textView.placeholderLabel.isHidden = true
            textView.text = note
        }
        textView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Constants.layout.textViewMinimumHeight)
        }
    }
    
    private func setupLayout() {
        addSubview(textView)

        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
