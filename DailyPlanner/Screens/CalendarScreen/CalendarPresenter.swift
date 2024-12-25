//
//  CalendarPresenter.swift
//  DailyPlanner
//
//  Created by Kira on 23.12.2024.
//

import FSCalendar
import UIKit

protocol CalendarPresenterProtocol: AnyObject {
    func reloadTableView()
}

final class CalendarPresenter {
    
     var hours = [Int]()
     var selectedDate: Date?
    private var result: ListOfTasks?
    private weak var viewController: CalendarPresenterProtocol?
    private var networkService: NetworkService?
    
    init(viewController: CalendarPresenterProtocol) {
        self.viewController = viewController
        initTime()
        networkService = NetworkService()
        networkService?.parseJSON()
        result = networkService?.getListOfTasks()
    }
    
    func tasksForDateAndTime(date: Date, hour: Int) -> [Task] {
        guard let tasks = result?.data else { return [] }
        var daysTasks = [Task]()
        for task in tasks {
            if dayIsSame(task.dateStart, date, hour: hour) {
                daysTasks.append(task)
            }
            if dayIsSame(task.dateFinish, date, hour: hour) {
                daysTasks.append(task)
            }
        }
        return daysTasks
    }
    
    func dayIsSame(_ date1: Date, _ date2: Date, hour: Int) -> Bool {
        if(Calendar.current.isDate(date1, inSameDayAs: date2)) {
            let taskHour = hourFromDate(date: date1)
            if taskHour == hour {
                return true
            }
        }
        return false
    }
    
    func setEvents(_ cell: DailyCall, _ events: [Task]) {
       
        hideAll(cell)
        switch events.count
        {
        case 1:
            setEvent1(cell, events[0])
        case 2:
            setEvent1(cell, events[0])
            setEvent2(cell, events[1])
        case 3:
            setEvent1(cell, events[0])
            setEvent2(cell, events[1])
            setEvent3(cell, events[2])
            
        case let count where count > 3:
            setEvent1(cell, events[0])
            setEvent2(cell, events[1])
            setMoreEvents(cell, events.count - 2)
        default:
            break
        }
    }
    
    func setMoreEvents(_ cell: DailyCall, _ count: Int) {
        cell.event3.isHidden = false
        cell.event3.text = String(count) + " More Events"
    }
    
    func setEvent1(_ cell: DailyCall, _ event: Task) {
        cell.event1.isHidden = false
        cell.event1.text = event.name
    }
    
    func setEvent2(_ cell: DailyCall, _ event: Task) {
        cell.event2.isHidden = false
        cell.event2.text = event.name
    }
    
    func setEvent3(_ cell: DailyCall, _ event: Task) {
        cell.event3.isHidden = false
        cell.event3.text = event.name
    }
    
    func hideAll(_ cell: DailyCall) {
        cell.event1.isHidden = true
        cell.event2.isHidden = true
        cell.event3.isHidden = true
    }
    
    func hourFromDate(date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour], from: date)
        return components.hour ?? 0
    }
    
    func setResult(_ result: ListOfTasks) {
        self.result = result
    }
    
    func addTask(_ task: Task) {
        networkService?.addTask(task)
        result = networkService?.getListOfTasks()
        viewController?.reloadTableView()
    }
    
    func initTime() {
        for hour in 0...23 {
            hours.append(hour)
        }
    }
}

