//
//  NewItemViewController.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 11.01.2024.
//

import Foundation
import UIKit
import RealmSwift
import CalendarKit

protocol NewItemViewControllerDelegate: AnyObject {
    func deleteButtonTapped(_ vc: NewItemViewController)
}

class NewItemViewController: UIViewController {
    private var newItemView: NewItemView!
    private var toDoItem: ToDoItem?
    
    weak var delegate: NewItemViewControllerDelegate?
    
    init(toDoItem: ToDoItem?) {
        self.toDoItem = toDoItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
//MARK: - Lifeycle
    
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
        navigationItem.title = "New event"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Save", style: .plain, target: self,
                            action: #selector(didTapSaveButton))
        if let _ = toDoItem {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
    }
    
    @objc func didTapSaveButton() {
        let nameCell = newItemView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldCell
        let isAllDayCell = newItemView.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SwitchCell
        let importanceCell = newItemView.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! SegmentContolCell
        let startDateCell = newItemView.tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! DatePickerCell
        let endDateCell = newItemView.tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as! DatePickerCell
        let noteCell = newItemView.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! TextViewCell
       
        var importane = Importance.normal
        switch importanceCell.segmentControl.selectedSegmentIndex {
        case 0:
            importane = .low
        case 2:
            importane = .hight
        default:
            importane = .normal
        }
        
        if let item = toDoItem {
            if startDateCell.datePicker.date > endDateCell.datePicker.date {
                showChangeDateAllert()
            } else {
                dismiss(animated: true) {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            item.name = nameCell.textField.text!
                            item.startDate = startDateCell.datePicker.date.timeIntervalSince1970
                            item.endDate = endDateCell.datePicker.date.timeIntervalSince1970
                            item.note = noteCell.textView.text
                            item.isAllDay = isAllDayCell.allDaySwitch.isOn
                            item.importance = importane
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            if startDateCell.datePicker.date > endDateCell.datePicker.date {
                showChangeDateAllert()
            } else {
                self.toDoItem = ToDoItem(name: nameCell.textField.text!,
                                         startDate: startDateCell.datePicker.date,
                                         endDate: endDateCell.datePicker.date,
                                         exactTime: Date(),
                                         note: noteCell.textView.text, isAllDay: isAllDayCell.allDaySwitch.isOn, importance: importane )
                dismiss(animated: true) {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            realm.add(self.toDoItem!)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func showChangeDateAllert() {
        let alert = UIAlertController(title: "Cannot save Event.", message: "The start date must be before the end date", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    @objc func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    private func setupTableView() {
        newItemView.tableView.delegate = self
        newItemView.tableView.dataSource = self
        newItemView.tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier)
        newItemView.tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        newItemView.tableView.register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.reuseIdentifier)
        newItemView.tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.reuseIdentifier)
        newItemView.tableView.register(SegmentContolCell.self, forCellReuseIdentifier: SegmentContolCell.reuseIdentifier)
        newItemView.tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
        newItemView.tableView.keyboardDismissMode = .onDrag
    }
    
    //MARK: - Notification to not cover note textView by keyBoard
    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBiHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeRegistrationForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
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
        let cell = newItemView.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! TextViewCell
        let cellIntersect = CGRectIntersection(activeRect, cell.frame)
        let cellLeftHeight = cell.frame.height - cellIntersect.height
        newItemView.tableView.setContentOffset(CGPoint(x: 0, y: cellLeftHeight), animated: true)
    }
    
    @objc func keyboardWillBiHidden(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        newItemView?.tableView.contentInset = contentInsets
        newItemView?.tableView.scrollIndicatorInsets = contentInsets
    }
}

//MARK: - UITableViewDataSource

extension NewItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = toDoItem {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Name
            return 1
        case 1:
            // All-day, importance, starts, ends
            return 4
        case 2:
            // Note
            return 1
        case 3:
            // Delete button
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // NAME
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
            cell.textField.placeholder = "New event"
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
            if let item = toDoItem {
                cell.textField.text = item.name
                cell.textField.clearButtonMode = .always
            }
            cell.contentView.isUserInteractionEnabled = false
            cell.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            
            return cell
        }
    
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                // ALL-DAY
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.reuseIdentifier, for: indexPath) as! SwitchCell
                if let item = toDoItem {
                    cell.allDaySwitch.isOn = item.isAllDay
                }
                cell.contentView.isUserInteractionEnabled = false
                
                return cell
            case 1:
                // IMPORTANCE
                let cell = tableView.dequeueReusableCell(withIdentifier: SegmentContolCell.reuseIdentifier, for: indexPath) as! SegmentContolCell
                if let item = toDoItem {
                    switch item.importance {
                    case .hight:
                        cell.segmentControl.selectedSegmentIndex = 2
                    case .low:
                        cell.segmentControl.selectedSegmentIndex = 0
                    default:
                        cell.segmentControl.selectedSegmentIndex = 1
                    }
                } else {
                    cell.segmentControl.selectedSegmentIndex = 1
                }
                
                cell.contentView.isUserInteractionEnabled = false
                    
                return cell
            case 2,3:
                // START DATE
                if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.reuseIdentifier, for: indexPath) as! DatePickerCell
                    cell.textLabel?.text = "Starts"
                    if let item = toDoItem {
                        cell.datePicker.date = item.startDate.date()
                    } else {
                        cell.datePicker.date = Date()
                    }
                    cell.contentView.isUserInteractionEnabled = false
                    
                    return cell
                } else  {
                    // END DATE
                    let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.reuseIdentifier, for: indexPath) as! DatePickerCell
                    cell.textLabel?.text = "Ends"
                    if let item = toDoItem {
                        cell.datePicker.date = item.endDate.date()
                    } else {
                        cell.datePicker.date = Date().addingTimeInterval(60 * 60)
                    }
                    cell.contentView.isUserInteractionEnabled = false
                    
                    return cell
                }
            default:
                return UITableViewCell()
            }
        }
        
        if indexPath.section == 2 {
            // NOTE
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.reuseIdentifier, for: indexPath) as! TextViewCell
            cell.textView.placeholderLabel.text = "Note"
            cell.textView.delegate = self
            if let item = toDoItem,
               let note = item.note,
               !note.isEmpty {
                cell.textView.placeholderLabel.isHidden = true
                cell.textView.text = note
            }
            cell.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
            cell.contentView.isUserInteractionEnabled = false
            
            return cell
        }
        
        if indexPath.section == 3 {
            // DELETE BUTTON
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseIdentifier, for: indexPath) as! ButtonCell
            cell.button.setTitle("Delete", for: .normal)
            cell.button.setTitleColor(.systemRed, for: .normal)
            cell.button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }

    @objc func textFieldDidChange(_ sender: UITextField) {
        if let text = sender.text,
           text != "" {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func didTapDeleteButton() {
        guard let item = toDoItem else { return }
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete this event?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete event", style: .destructive, handler: {  [weak self] (_) in
            self?.delegate?.deleteButtonTapped(self!)
            self?.dismiss(animated: true) {
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.delete(item)
                    }
                } catch {
                    print(error)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = .systemRed
        self.present(alert, animated: true)
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
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
