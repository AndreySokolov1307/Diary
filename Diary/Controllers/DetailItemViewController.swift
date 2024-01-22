import UIKit
import CalendarKit

fileprivate enum Constants {
    enum strings {
        static let title = "Event details"
        static let editButton = "Edit"
        static let cancelButton = "Cancel"
        static let deleteButton = "Delete event"
        static let deleteAlertTitle = ""
        static let deleteAlertMessage = "Are you sure you want to delete this event?"
        static let deleteAlertActionTitle = "Delete event"
        static let cancelAlertActionTiitle = "Cancel"
        static let segmentControlIndexZero = Importance.low.emoji
        static let segmentControlIndexOne = Importance.normal.emoji
        static let segmentControlIndexTwo = Importance.high.emoji
        static let importanceLabel = "Importance"
        static let noteTopLabel = "Notes"
    }
    enum layout {
        static let nameCellSeparatorInset = UIEdgeInsets(top: 0,
                                                         left: .greatestFiniteMagnitude,
                                                         bottom: 0,
                                                         right: 0)
        static let paragraphSpacing: CGFloat = 4
        static let estimatedHeightForRow: CGFloat = 44
    }
    enum fonts {
        static let nameLabelFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        static let dateLabelFont = UIFont.systemFont(ofSize: 15)
        static let noteTopLabelFont = UIFont.systemFont(ofSize: 17)
        static let noteBottomLabelFont = UIFont.systemFont(ofSize: 17)
    }
    enum colors {
        static let nameLabelColor: UIColor = .black
        static let dateLabelColor: UIColor = .systemGray
        static let noteTopLabelColor: UIColor = .black
        static let noteBottomLabelColor: UIColor = .systemGray
    }
}

protocol ItemView {
    func reloadData()
}

class DetailItemViewController: UIViewController {

    private enum Row: String, CaseIterable {
        case name, date, importance, note
        
        static func getRows(toDoItem: ToDoItem) -> [Row] {
            var rows = self.allCases
            if let note = toDoItem.note,
               !note.isEmpty {
                return rows
            } else {
                rows.removeLast()
                return rows
            }
        }
    }
    
    private var detailItemView: DetailItemView!
    private var toDoItem: ToDoItem
    private var rows: [Row] {
        Row.getRows(toDoItem: toDoItem)
    }
    
    init(toDoItem: ToDoItem) {
        self.toDoItem = toDoItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        detailItemView = DetailItemView()
        self.view = detailItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavController()
        ToDoService.shared.itemView = self
        ToDoService.shared.subscribeToItemNotifications()
    }
    
    private func setupTableView() {
        detailItemView.tableView.delegate = self
        detailItemView.tableView.dataSource = self
    }
    
    private func setupNavController() {
        navigationItem.title = Constants.strings.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Constants.strings.editButton,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapEditButton))
        navigationController?.setToolbarHidden(false, animated: true)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let deleteItem = UIBarButtonItem(title: Constants.strings.deleteButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapDeleteButton))
        deleteItem.tintColor = .systemRed
        setToolbarItems([space, deleteItem, space], animated: true)
    }
    
    @objc func didTapDeleteButton() {
        let deleteAction = UIAlertAction(title: Constants.strings.deleteAlertActionTitle,
                                         style: .destructive,
                                         handler: {  [weak self] (_) in
            guard let strongSelf = self else { return }
            ToDoService.shared.delete(item: strongSelf.toDoItem)
            strongSelf.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: Constants.strings.cancelAlertActionTiitle,
                                         style: .cancel)
        presentActionSheetAlert(title: Constants.strings.deleteAlertTitle,
                                message: Constants.strings.deleteAlertMessage,
                                actions: [deleteAction, cancelAction])
    }
    
    @objc private func didTapEditButton() {
        let controller = NewItemViewController(toDoItem: toDoItem)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension DetailItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch rows[indexPath.row] {
        case .name:
            let nameCell = LabelCell()
            nameCell.label.text = toDoItem.name
            nameCell.label.textColor = Constants.colors.nameLabelColor
            nameCell.label.font = Constants.fonts.nameLabelFont
            nameCell.separatorInset = Constants.layout.nameCellSeparatorInset
            cell = nameCell
        case .date:
            let dateCell = LabelCell()
            dateCell.label.textColor = Constants.colors.dateLabelColor
            dateCell.label.font = Constants.fonts.dateLabelFont
            dateCell.label.attributedText = configureFormattedAttributedText(isAllDay: toDoItem.isAllDay)
            
            cell = dateCell
        case .importance:
            let importanceCell = SegmentContolCell()
            setupSegmentControl(importanceCell.segmentControl)
            importanceCell.label.text = Constants.strings.importanceLabel
            cell = importanceCell
        case .note:
            let noteCell = TwoLabelsCell()
            noteCell.toplabel.text = Constants.strings.noteTopLabel
            noteCell.toplabel.font = Constants.fonts.noteTopLabelFont
            noteCell.toplabel.textColor = Constants.colors.noteTopLabelColor
            noteCell.bottomlabel.text = toDoItem.note
            noteCell.bottomlabel.font = Constants.fonts.noteBottomLabelFont
            noteCell.bottomlabel.textColor = Constants.colors.noteBottomLabelColor
            noteCell.bottomlabel.adjustsFontSizeToFitWidth = false
            cell = noteCell
        }
        return cell
    }
    
    private func setupSegmentControl(_ segmentControl: UISegmentedControl) {
        segmentControl.insertSegment(withTitle: Constants.strings.segmentControlIndexZero ,
                                     at: 0,
                                     animated: true)
        segmentControl.insertSegment(withTitle: Constants.strings.segmentControlIndexOne,
                                     at: 1,
                                     animated: true)
        segmentControl.insertSegment(withTitle: Constants.strings.segmentControlIndexTwo,
                                     at: 2,
                                     animated: true)
        switch toDoItem.importance {
        case .high:
            segmentControl.selectedSegmentIndex = 2
        case .low:
            segmentControl.selectedSegmentIndex = 0
        default:
            segmentControl.selectedSegmentIndex = 1
        }
    }

        
    private func configureFormattedAttributedText(isAllDay: Bool) -> NSMutableAttributedString {
        let dateFormatter = DateFormatter()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = Constants.layout.paragraphSpacing
        var startString = ""
        var endString = ""
        var finalString = ""
        var attributedString = NSMutableAttributedString()
        let startDayComponents = Calendar.current.dateComponents([.day],
                                                                 from: toDoItem.startDate.date())
        let endDayComponents = Calendar.current.dateComponents([.day],
                                                               from: toDoItem.endDate.date())

        if isAllDay {
            if startDayComponents.day == endDayComponents.day {
                dateFormatter.dateFormat = CustomDateFormat.allDayFull
                finalString = "\(dateFormatter.string(from: toDoItem.startDate.date()))\nAll day"
                attributedString = NSMutableAttributedString(string: finalString,
                                                             attributes: [.paragraphStyle: paragraphStyle])
                // Wednesday, Jan 10, 2024
                // All day
                return attributedString
            } else {
                dateFormatter.dateFormat = CustomDateFormat.allDayShort
                let start = dateFormatter.string(from: toDoItem.startDate.date())
                let end = dateFormatter.string(from: toDoItem.endDate.date())
                finalString = "All day from \(start)\nto \(end)"
                attributedString = NSMutableAttributedString(string: finalString,
                                                             attributes: [.paragraphStyle: paragraphStyle])
                // All day from Wed, Jan 10, 2024
                // to Thu, Jan 11, 2024
                return attributedString
            }
        } else {
            if startDayComponents.day == endDayComponents.day {
                dateFormatter.dateFormat = CustomDateFormat.allDayFull
                startString = dateFormatter.string(from: toDoItem.startDate.date())
                finalString = startString
                dateFormatter.dateFormat = CustomDateFormat.hour
                startString = dateFormatter.string(from: toDoItem.startDate.date())
                endString = dateFormatter.string(from: toDoItem.endDate.date())
                finalString += "\nfrom \(startString) to \(endString)"
                attributedString = NSMutableAttributedString(string: finalString,
                                                             attributes: [.paragraphStyle: paragraphStyle])
                // Wednesday, Jan 10, 2024
                // from 4:05 PM to 5:05 PM
                return attributedString
            } else {
                dateFormatter.dateFormat = CustomDateFormat.regular
                startString = dateFormatter.string(from: toDoItem.startDate.date())
                endString = dateFormatter.string(from: toDoItem.endDate.date())
                finalString = "from \(startString)\nto \(endString)"
                attributedString = NSMutableAttributedString(string: finalString,
                                                             attributes: [.paragraphStyle: paragraphStyle])
                // from 4:05 PM Wed, Jan 10, 2024
                // to 5:05 PM Thu, Jan 11, 2024
                return attributedString
            }
        }
    }
}

//MARK: - UITableViewDelegate

extension DetailItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.layout.estimatedHeightForRow
    }
}

//MARK: - NewItemViewControllerDelegate

extension DetailItemViewController: NewItemViewControllerDelegate {
    func deleteButtonTapped(_ vc: NewItemViewController) {
        ToDoService.shared.invalidateItemToken()
        navigationController?.popViewController(animated: false)
    }
}

//MARK: - ItemView

extension DetailItemViewController: ItemView {
    func reloadData() {
        self.detailItemView.tableView.reloadData()
    }
}
