import UIKit

fileprivate enum Constants {
    enum strings {
        static let deleteButton = "Delete"
    }
    enum layout {
        static let buttonMinimumHeight: CGFloat = 44
    }
}

class ButtonCell: UITableViewCell {
    static let reuseIdentifier = "ButtonCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func configure(forViewController vc: UIViewController, with item: ToDoItem?) {
        guard let newItemVC = vc as? NewItemViewController else { return }
        button.setTitle(Constants.strings.deleteButton, for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(newItemVC.self,
                         action: #selector(newItemVC.didTapDeleteButton),
                         for: .touchUpInside)
    }
    
    private func setupLayout() {
        contentView.addSubview(button)
       
        button.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
            make.height.greaterThanOrEqualTo(Constants.layout.buttonMinimumHeight)
        }
    }
}
