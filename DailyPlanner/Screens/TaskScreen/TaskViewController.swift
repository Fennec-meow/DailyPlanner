//
//  TaskViewController.swift
//  DailyPlanner
//
//  Created by Kira on 22.12.2024.
//

import UIKit

protocol CalendarViewControllerDelegate: AnyObject {
    func addTask(_ task: Task)
}

class TaskViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateStart: UIDatePicker!
    @IBOutlet weak var dateFinish: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
     weak var calendarDelegate: CalendarViewControllerDelegate?
    private var presenter: CalendarPresenter?
     var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let task {
            nameTextField.text = task.name
            descriptionTextField.text = task.descriptionText
            dateStart.date = task.dateStart
            dateFinish.date = task.dateFinish
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let task = Task()
        task.name = nameTextField.text ?? ""
        task.descriptionText = descriptionTextField.text ?? ""
        task.dateStart = dateStart.date
        task.dateFinish = dateFinish.date
        calendarDelegate?.addTask(task)
        dismiss(animated: true)
    }
}
