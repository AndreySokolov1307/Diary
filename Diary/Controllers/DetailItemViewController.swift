
import UIKit
import RealmSwift
import CalendarKit

fileprivate enum UIConstants {
    enum strings {
        static let title = "Event details"
        static let editButton = "Edit"
        static let cancelButton = "Cancel"
        static let deleteButton = "Delete event"
        static let deleteAlertTitle = ""
        static let deleteAlertMessage = "Are you sure you want to delete this event?"
        static let deleteAlertActionTitle = "Delete event"
        static let cancelAlertActionTiitle = "Cancel"
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

class DetailItemViewController: UIViewController {
    
    private enum Row: String, CaseIterable {
         case name, date, importance, note
         
         static func getRows(toDoItem: ToDoItem) -> [Row] {
             var rows = self.allCases
             if let _ = toDoItem.note {
                 return rows
             } else {
                 rows.removeLast()
                 return rows
             }
         }
     }
    
    private var detailItemView: DetailItemView!
    private var notificationToken: NotificationToken?
    private var toDoItem: ToDoItem
    private lazy var rows = {
        Row.getRows(toDoItem: toDoItem)
    }()
    
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
        subscribeToNotifications()
    }
    
    private func setupTableView() {
        detailItemView.tableView.delegate = self
        detailItemView.tableView.dataSource = self
    }
    
    private func setupNavController() {
        navigationItem.title = UIConstants.strings.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.strings.editButton,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapEditButton))
        navigationController?.setToolbarHidden(false, animated: true)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let deleteItem = UIBarButtonItem(title: UIConstants.strings.deleteButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapDeleteButton))
        deleteItem.tintColor = .systemRed
        setToolbarItems([space, deleteItem, space], animated: true)
    }
    
    @objc func didTapDeleteButton() {
        let deleteAction = UIAlertAction(title: UIConstants.strings.deleteAlertActionTitle,
                                         style: .destructive,
                                         handler: {  [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.notificationToken?.invalidate()
            RealmManager.shared.delete(item: strongSelf.toDoItem)
            strongSelf.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: UIConstants.strings.cancelAlertActionTiitle,
                                         style: .cancel)
        presentActionSheetAlert(title: UIConstants.strings.deleteAlertTitle,
                                message: UIConstants.strings.deleteAlertMessage,
                                actions: [deleteAction, cancelAction])
    }
    
    private func subscribeToNotifications() {
        notificationToken = RealmManager.shared.realm.observe { [weak self] (_,_)  in
            guard let tableView = self?.detailItemView.tableView else { return }
            tableView.reloadData()
        }
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
        return Row.getRows(toDoItem: self.toDoItem).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch rows[indexPath.row] {
        case .name:
            let nameCell = LabelCell()
            nameCell.label.text = toDoItem.name
            nameCell.label.textColor = UIConstants.colors.nameLabelColor
            nameCell.label.font = UIConstants.fonts.nameLabelFont
            nameCell.separatorInset = UIConstants.layout.nameCellSeparatorInset
            cell = nameCell
        case .date:
            let dateCell = LabelCell()
            dateCell.label.textColor = UIConstants.colors.dateLabelColor
            dateCell.label.font = UIConstants.fonts.dateLabelFont
            dateCell.label.attributedText = configureFormattedAttributedText(isAllDay: toDoItem.isAllDay)
            
            cell = dateCell
        case .importance:
            let importanceCell = SegmentContolCell()
            switch toDoItem.importance {
            case .high:
                importanceCell.segmentControl.selectedSegmentIndex = 2
            case .low:
                importanceCell.segmentControl.selectedSegmentIndex = 0
            default:
                importanceCell.segmentControl.selectedSegmentIndex = 1
            }
            cell = importanceCell
        case .note:
            let noteCell = TwoLabelsCell()
            noteCell.toplabel.text = UIConstants.strings.noteTopLabel
            noteCell.toplabel.font = UIConstants.fonts.noteTopLabelFont
            noteCell.toplabel.textColor = UIConstants.colors.noteTopLabelColor
            noteCell.bottomlabel.text = toDoItem.note
            noteCell.bottomlabel.font = UIConstants.fonts.noteBottomLabelFont
            noteCell.bottomlabel.textColor = UIConstants.colors.noteBottomLabelColor
            noteCell.bottomlabel.adjustsFontSizeToFitWidth = false
            cell = noteCell
        }
        return cell
    }
        
    private func configureFormattedAttributedText(isAllDay: Bool) -> NSMutableAttributedString {
        let dateFormatter = DateFormatter()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = UIConstants.layout.paragraphSpacing
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
                // to 5:05 PM Thu, Jan 11, 20245
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
        return UIConstants.layout.estimatedHeightForRow
    }
}

extension DetailItemViewController: NewItemViewControllerDelegate {
    func deleteButtonTapped(_ vc: NewItemViewController) {
        notificationToken?.invalidate()
        navigationController?.popViewController(animated: false)
    }
}
