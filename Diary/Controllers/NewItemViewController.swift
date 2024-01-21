
import UIKit
import RealmSwift
import CalendarKit

fileprivate enum UIConstants {
    enum strings {
        static let title = "New event"
        static let saveButton = "Save"
        static let cancelButton = "Cancel"
        static let saveAlertTitle = "Cannot save Event"
        static let saveAlertMessage = "The start date must be before the end date"
        static let deleteAlertTitle = ""
        static let deleteAlertMessage = "Are you sure you want to delete this event?"
        static let deleteAlertActionTitle = "Delete event"
        static let cancelAlertActionTiitle = "Cancel"
        static let textFieldPlaceholder = "New event"
        static let startsLabel = "Starts"
        static let endsLabel = "Ends"
        static let textViewPlaceholder = "Note"
        static let deleteButton = "Delete"
    }
    
    enum layout {
        static let textFieldMinimumHeight: CGFloat = 44
        static let textViewMinimumHeight: CGFloat = 200
        static let kbWillBeHiddenContentInsets = UIEdgeInsets.zero
    }
    enum indexPaths {
        static let nameCell = IndexPath(row: 0, section: 0)
        static let allDayCell = IndexPath(row: 0, section: 1)
        static let importanceCell = IndexPath(row: 1, section: 1)
        static let startCell = IndexPath(row: 2, section: 1)
        static let endCell = IndexPath(row: 3, section: 1)
        static let noteCell = IndexPath(row: 0, section: 2)
        static let deleteCell = IndexPath(row: 0, section: 3)
    }
    enum dates {
        static let oneHour: TimeInterval = 3600
    }
}

protocol NewItemViewControllerDelegate: AnyObject {
    func deleteButtonTapped(_ vc: NewItemViewController)
}

class NewItemViewController: UIViewController {
    
   private enum Section: String, CaseIterable {
        case name, settings, note, delete
        
        static func getSections(toDoItem: ToDoItem?) -> [Section] {
            var sections = self.allCases
            if let _ = toDoItem {
                return sections
            } else {
                sections.removeLast()
                return sections
            }
        }
        enum Settings: CaseIterable {
            case allDay, importance, starts, ends
        }
    }
    
    private var newItemView: NewItemView!
    private var toDoItem: ToDoItem?
    private lazy var sections = {
        Section.getSections(toDoItem: toDoItem)
    }()
    weak var delegate: NewItemViewControllerDelegate?
    
    init(toDoItem: ToDoItem?) {
        self.toDoItem = toDoItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
//MARK: - Lifecycle
    
    override func loadView() {
        newItemView = NewItemView()
        self.view = newItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeRegistrationForKeyboardNotification()
    }

    private func setupNavBar() {
        navigationItem.title = UIConstants.strings.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.strings.saveButton,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapSaveButton))
        if let _ = toDoItem {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: UIConstants.strings.cancelButton,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancelButton))
    }
    
    @objc private func didTapSaveButton() {
        let nameCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.nameCell) as! TextFieldCell
        let allDayCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.allDayCell) as! SwitchCell
        let importanceCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.importanceCell) as! SegmentContolCell
        let startCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.startCell) as! DatePickerCell
        let endCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.endCell) as! DatePickerCell
        let noteCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.noteCell) as! TextViewCell
        
        let name = nameCell.textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var importance = Importance.normal
        switch importanceCell.segmentControl.selectedSegmentIndex {
        case 0:
            importance = .low
        case 2:
            importance = .high
        default:
            importance = .normal
        }
        let note = noteCell.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if startCell.datePicker.date > endCell.datePicker.date {
            presentConfirmAlert(title: UIConstants.strings.saveAlertTitle,
                          message: UIConstants.strings.saveAlertMessage)
        } else if let item = toDoItem {
            dismiss(animated: true) {
                let item = ToDoItem(id: item.id,
                                    name: name,
                                    startDate: startCell.datePicker.date,
                                    endDate: endCell.datePicker.date,
                                    note: note,
                                    isAllDay: allDayCell.allDaySwitch.isOn,
                                    importance: importance)
                RealmManager.shared.save(item: item)
            }
        } else {
            self.toDoItem = ToDoItem(name: name,
                                     startDate: startCell.datePicker.date,
                                     endDate: endCell.datePicker.date,
                                     note: note,
                                     isAllDay: allDayCell.allDaySwitch.isOn,
                                     importance: importance )
            dismiss(animated: true) {
                RealmManager.shared.save(item: self.toDoItem!)
            }
        }
    }
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    private func setupTableView() {
        newItemView.tableView.delegate = self
        newItemView.tableView.dataSource = self
        newItemView.tableView.keyboardDismissMode = .onDrag
    }
    
    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeRegistrationForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc private func keyboardWasShown(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0,
                                         left: 0,
                                         bottom: keyboardSize.height,
                                         right: 0)
        newItemView.tableView.contentInset = contentInsets
        newItemView.tableView.scrollIndicatorInsets = contentInsets
        
        // Find visible rect add offset tableview content to the cell left height
        var activeRect = self.newItemView.tableView.frame
        activeRect.size.height -= keyboardFrame.height
        let cell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.noteCell) as! TextViewCell
        let cellIntersect = CGRectIntersection(activeRect, cell.frame)
        let cellLeftHeight = cell.frame.height - cellIntersect.height
        newItemView.tableView.setContentOffset(CGPoint(x: 0, y: cellLeftHeight), animated: true)
    }
    
    @objc private func keyboardWillBeHidden(_ notification: NSNotification) {
        newItemView.tableView.contentInset = UIConstants.layout.kbWillBeHiddenContentInsets
        newItemView.tableView.scrollIndicatorInsets = UIConstants.layout.kbWillBeHiddenContentInsets
    }
}

//MARK: - UITableViewDataSource

extension NewItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    private func numberOfRows(for section: Section) -> Int {
        switch section {
        case .name: return 1
        case .settings: return Section.Settings.allCases.count
        case .note: return 1
        case .delete: return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows(for: sections[section])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch sections[indexPath.section] {
        case .name:
            let nameCell = TextFieldCell()
            nameCell.textField.placeholder = UIConstants.strings.textFieldPlaceholder
            nameCell.textField.delegate = self
            nameCell.textField.addTarget(self,
                                         action: #selector(textFieldDidChange(_:)),
                                         for: .editingChanged)
            if let item = toDoItem {
                nameCell.textField.text = item.name
                nameCell.textField.clearButtonMode = .always
            }
            nameCell.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.layout.textFieldMinimumHeight).isActive = true
            cell = nameCell
        case .settings:
            let settings = Section.Settings.allCases
            switch settings[indexPath.row] {
            case .allDay:
                let allDayCell = SwitchCell()
                if let item = toDoItem {
                    allDayCell.allDaySwitch.isOn = item.isAllDay
                }
                allDayCell.allDaySwitch.addTarget(self,
                                                  action: #selector(switchValueChanged(_:)),
                                                  for: .valueChanged)
                cell = allDayCell
            case .importance:
                let importanceCell = SegmentContolCell()
                if let item = toDoItem {
                    switch item.importance {
                    case .high:
                        importanceCell.segmentControl.selectedSegmentIndex = 2
                    case .low:
                        importanceCell.segmentControl.selectedSegmentIndex = 0
                    default:
                        importanceCell.segmentControl.selectedSegmentIndex = 1
                    }
                } else {
                    importanceCell.segmentControl.selectedSegmentIndex = 1
                }
                cell = importanceCell
            case .starts:
                let startCell = DatePickerCell()
                startCell.textLabel?.text = UIConstants.strings.startsLabel
                if let item = toDoItem {
                    startCell.datePicker.date = item.startDate.date()
                    if item.isAllDay {
                        startCell.datePicker.datePickerMode = .date
                    }
                } else {
                    startCell.datePicker.date = Date()
                }
                cell = startCell
            case .ends:
                let endCell = DatePickerCell()
                endCell.textLabel?.text = UIConstants.strings.endsLabel
                if let item = toDoItem {
                    endCell.datePicker.date = item.endDate.date()
                    if item.isAllDay {
                        endCell.datePicker.datePickerMode = .date
                    }
                } else {
                    endCell.datePicker.date = Date().addingTimeInterval(UIConstants.dates.oneHour)
                }
                cell = endCell
            }
        case .note:
            let noteCell = TextViewCell()
            noteCell.textView.placeholderLabel.text = UIConstants.strings.textViewPlaceholder
            noteCell.textView.delegate = self
            if let item = toDoItem,
               let note = item.note,
               !note.isEmpty {
                noteCell.textView.placeholderLabel.isHidden = true
                noteCell.textView.text = note
            }
            noteCell.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.layout.textViewMinimumHeight).isActive = true
            cell = noteCell
        case .delete:
            let deleteCell = ButtonCell()
            deleteCell.button.setTitle(UIConstants.strings.deleteButton, for: .normal)
            deleteCell.button.setTitleColor(.systemRed, for: .normal)
            deleteCell.button.addTarget(self,
                                        action: #selector(didTapDeleteButton),
                                        for: .touchUpInside)
            cell = deleteCell
        }
        if !(cell is ButtonCell) {
            cell.contentView.isUserInteractionEnabled = false
        }
        return cell
    }

    @objc private func textFieldDidChange(_ sender: UITextField) {
        if let text = sender.text,
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let startCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.startCell) as! DatePickerCell
        let finishCell = newItemView.tableView.cellForRow(at: UIConstants.indexPaths.endCell) as! DatePickerCell
        
        if sender.isOn {
            startCell.datePicker.datePickerMode = .date
            finishCell.datePicker.datePickerMode = .date
        } else {
            startCell.datePicker.datePickerMode = .dateAndTime
            finishCell.datePicker.datePickerMode = .dateAndTime
        }
    }
    
    @objc private func didTapDeleteButton() {
        guard let item = toDoItem else { return }
        
        let deleteAction = UIAlertAction(title: UIConstants.strings.deleteAlertActionTitle,
                                         style: .destructive,
                                         handler: {  [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.deleteButtonTapped(self!)
            strongSelf.dismiss(animated: true) {
                RealmManager.shared.delete(item: item)
            }
        })
        let cancelAction = UIAlertAction(title: UIConstants.strings.cancelAlertActionTiitle,
                                         style: .cancel)
        presentActionSheetAlert(title: UIConstants.strings.deleteAlertTitle,
                                message: UIConstants.strings.deleteAlertMessage,
                                actions: [deleteAction, cancelAction])
    }
}

//MARK: - UITableViewDelegate

extension NewItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

//MARK: - UITextFieldDelegate

extension NewItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UITextViewDelegate

extension NewItemViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        let myTextView = textView as! TextViewWithPlaceholder
        myTextView.placeholderLabel.isHidden = !myTextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let myTextView = textView as! TextViewWithPlaceholder
        
        if myTextView.text.isEmpty {
            myTextView.placeholderLabel.isHidden = false
        } else {
            myTextView.placeholderLabel.isHidden = true
        }
    }
}