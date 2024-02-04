import UIKit

fileprivate enum Constants {
    enum strings {
        static let importanceLabel = "Importance"
        static let segmentControlIndexZero = Importance.low.emoji
        static let segmentControlIndexOne = Importance.normal.emoji
        static let segmentControlIndexTwo = Importance.high.emoji
    }
}

class SegmentContolCell: UITableViewCell {
    static let reuseIdentifier = "SegmentControlCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let segmentControl: UISegmentedControl = {
        let segmentConttol = UISegmentedControl()
        segmentConttol.translatesAutoresizingMaskIntoConstraints = false
        return segmentConttol
    }()
    
    func configure(with item: ToDoItem?) {
        segmentControl.insertSegment(withTitle: Constants.strings.segmentControlIndexZero,
                                     at: 0,
                                     animated: true)
        segmentControl.insertSegment(withTitle: Constants.strings.segmentControlIndexOne,
                                     at: 1,
                                     animated: true)
        segmentControl.insertSegment(withTitle: Constants.strings.segmentControlIndexTwo,
                                     at: 2,
                                     animated: true)
        if let item = item {
            switch item.importance {
            case .high:
                segmentControl.selectedSegmentIndex = 2
            case .low:
                segmentControl.selectedSegmentIndex = 0
            default:
                segmentControl.selectedSegmentIndex = 1
            }
        } else {
            segmentControl.selectedSegmentIndex = 1
        }
        
        label.text = Constants.strings.importanceLabel
    }
    
    private func setupLayout() {
        addSubview(label)
        addSubview(segmentControl)
                
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        segmentControl.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(30)
        }
    }
}
