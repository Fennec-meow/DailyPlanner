//
//  CalendarViewController.swift
//  DailyPlanner
//
//  Created by Kira on 08.12.2024.
//

import FSCalendar
import UIKit

final class CalendarViewController: UIViewController, FSCalendarDelegate, CalendarViewControllerDelegate {
    var presenter: CalendarPresenter?
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CalendarPresenter(viewController: self)
        calendar.delegate = self
        self.presenter?.selectedDate = calendar.today
    }
    
    func addTask(_ task: Task) {
        presenter?.addTask(task)
    }
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil) 
        
        guard let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TaskViewController") as? TaskViewController else { return }
        
        nextViewController.calendarDelegate = self
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard let presenter else { return }
        presenter.selectedDate = date
        tableView.reloadData()
    }
    
    func formatHour(hour: Int) -> String {
        return String(format: "%02d:%02d", hour, 0)
    }
}

extension CalendarViewController: CalendarPresenterProtocol {
    
    func reloadTableView() {
        tableView.reloadData()
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.hours.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let presenter,
              let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DailyCall else { return UITableViewCell() }
        
        let hour = presenter.hours[indexPath.row]
        cell.time.text = formatHour(hour: hour)
        
        guard let selectedDate = presenter.selectedDate else { return cell }
        
        let tasks = presenter.tasksForDateAndTime(date: selectedDate, hour: hour)
        presenter.setEvents(cell, tasks)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DailyCall else { return }
        
        let hour = presenter.hours[indexPath.row]
        cell.time.text = formatHour(hour: hour)
        
        guard let selectedDate = presenter.selectedDate else { return }
        let tasks = presenter.tasksForDateAndTime(date: selectedDate, hour: hour)
        
        if let firstEvent = tasks.first {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TaskViewController") as! TaskViewController
            nextViewController.calendarDelegate = self
            nextViewController.task = firstEvent
            self.present(nextViewController, animated:true, completion:nil)
            
        } else {
            
            print("Нет событий для выбранного времени.")
        }
    }
}





