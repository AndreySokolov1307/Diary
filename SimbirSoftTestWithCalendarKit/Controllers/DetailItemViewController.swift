//
//  DetailItemViewController.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 13.01.2024.
//

import Foundation
import UIKit
import RealmSwift

protocol DetailItemViewControllerDelegate: AnyObject {
    func deleteItem(_ toDoItem: ToDoItem)
}

class DetailItemViewController: UIViewController {
    var detailItemView: DetailItemView!
    
    var notificationToken: NotificationToken?
    
    var toDoItem: ToDoItem
    
    weak var delegate: DetailItemViewControllerDelegate?
    
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
        detailItemView.tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.reuseIdentifier)
        detailItemView.tableView.register(TwoLabelsCell.self, forCellReuseIdentifier: TwoLabelsCell.reuseIdentifier)
        detailItemView.tableView.register(SegmentContolCell.self, forCellReuseIdentifier: SegmentContolCell.reuseIdentifier)
    }
    
    private func setupNavController() {
        navigationItem.title = "Event details"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Edit", style: .plain, target: self,
                            action: #selector(didTapEditButton))
        navigationController?.setToolbarHidden(false, animated: true)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteItem = UIBarButtonItem(title: "Delete event", style: .plain, target: self, action: #selector(didTapDeleteButton))
        deleteItem.tintColor = .systemRed
        setToolbarItems([space, deleteItem, space], animated: true)
    }
    
    @objc func didTapDeleteButton() {
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete this event?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete event", style: .destructive, handler: {  [weak self] (_) in
            self?.notificationToken?.invalidate()
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(self!.toDoItem)
                }
            } catch {
                print(error)
            }
            self?.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func subscribeToNotifications() {
        do {
            let realm = try Realm()
            notificationToken = realm.observe { [weak self] (_,_)  in
                guard let tableView = self?.detailItemView.tableView else { return }
                tableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
    @objc func didTapEditButton() {
        let controller = NewItemViewController(toDoItem: toDoItem)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension DetailItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let note = toDoItem.note,
           !note.isEmpty {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.reuseIdentifier) as! LabelCell
            cell.label.text = toDoItem.name
            cell.label.textColor = .black
            cell.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            cell.label.numberOfLines = 0
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
            
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.reuseIdentifier) as! LabelCell
            cell.label.textColor = .systemGray
            cell.label.font = UIFont.systemFont(ofSize: 15)
            cell.label.numberOfLines = 0
            cell.label.attributedText = configureFormattedAttributedText(isAllDay: toDoItem.isAllDay)
            
            return cell
        }
        
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SegmentContolCell.reuseIdentifier) as! SegmentContolCell
            switch toDoItem.importance {
            case .hight:
                cell.segmentControl.selectedSegmentIndex = 2
            case .low:
                cell.segmentControl.selectedSegmentIndex = 0
            default:
                cell.segmentControl.selectedSegmentIndex = 1
            }
            
            return cell
        }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TwoLabelsCell.reuseIdentifier) as! TwoLabelsCell
            cell.toplabel.text = "Notes"
            cell.toplabel.font = UIFont.systemFont(ofSize: 17)
            cell.toplabel.textColor = .black
            cell.bottomlabel.text = toDoItem.note
            cell.bottomlabel.font = UIFont.systemFont(ofSize: 17)
            cell.bottomlabel.textColor = .systemGray
            cell.bottomlabel.adjustsFontSizeToFitWidth = false
            cell.bottomlabel.numberOfLines = 0

            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    private func configureFormattedAttributedText(isAllDay: Bool) -> NSMutableAttributedString {
        let dateFormatter = DateFormatter()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 4
        var startString = ""
        var endString = ""
        var finalString = ""
        var attributedString = NSMutableAttributedString()
        let startDayComponents = Calendar.current.dateComponents([.day], from: toDoItem.startDate.date())
        let endDayComponents = Calendar.current.dateComponents([.day], from: toDoItem.endDate.date())

        if isAllDay {
            if startDayComponents.day == endDayComponents.day {
                dateFormatter.dateFormat = CustomDateFormat.allDayFull
                finalString = "\(dateFormatter.string(from: toDoItem.startDate.date()))\nAll day"
                attributedString = NSMutableAttributedString(string: finalString, attributes: [.paragraphStyle: paragraphStyle])
                // Wednesday, Jan 10, 2024
                // All day
                return attributedString
            } else {
                dateFormatter.dateFormat = CustomDateFormat.allDayShort
                let start = dateFormatter.string(from: toDoItem.startDate.date())
                let end = dateFormatter.string(from: toDoItem.endDate.date())
                finalString = "All day from \(start)\nto \(end)"
                attributedString = NSMutableAttributedString(string: finalString, attributes: [.paragraphStyle: paragraphStyle])
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
                attributedString = NSMutableAttributedString(string: finalString, attributes: [.paragraphStyle: paragraphStyle])
                // Wednesday, Jan 10, 2024
                // from 4:05 PM to 5:05 PM
                return attributedString
            } else {
                dateFormatter.dateFormat = CustomDateFormat.regular
                startString = dateFormatter.string(from: toDoItem.startDate.date())
                endString = dateFormatter.string(from: toDoItem.endDate.date())
                finalString = "from \(startString)\nto \(endString)"
                attributedString = NSMutableAttributedString(string: finalString, attributes: [.paragraphStyle: paragraphStyle])
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
        return 44
    }
}

extension DetailItemViewController: NewItemViewControllerDelegate {
    func deleteButtonTapped(_ vc: NewItemViewController) {
        notificationToken?.invalidate()
        navigationController?.popViewController(animated: false)
    }
}
