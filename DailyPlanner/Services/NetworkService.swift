//
//  NetworkService.swift
//  DailyPlanner
//
//  Created by Kira on 12.12.2024.
//

import Foundation
import RealmSwift

struct ListOfTasks: Decodable {
    var data: [Task]
}

final class Task: Object, Decodable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var dateStart: Date
    @Persisted var dateFinish: Date
    @Persisted var name: String
    @Persisted var descriptionText: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateStart = "date_start"
        case dateFinish = "date_finish"
        case name
        case description
    }
    
    required convenience init(from decoder: any Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        let dateStartStr = try container.decode(String.self, forKey: .dateStart)
        self.dateStart = Date(timeIntervalSince1970: Double(dateStartStr) ?? 0)
        let dateFinishStr = try container.decode(String.self, forKey: .dateFinish)
        self.dateFinish = Date(timeIntervalSince1970: Double(dateFinishStr) ?? 0)
        self.name = try container.decode(String.self, forKey: .name)
        self.descriptionText = try container.decode(String.self, forKey: .description)
    }
}

final class NetworkService {
    
    private var realm: Realm? = try? Realm()
    
    func parseJSON() {
        guard let path = Bundle.main.path(
            forResource: "Json",
            ofType: "json"
        ) else {
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonData = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(ListOfTasks.self, from: jsonData)
            
            try realm?.write {
                realm?.add(result.data, update: .modified)
            }
        }
        catch {
            print("Error: \(error)")
        }
        return
    }
    
    func getListOfTasks() -> ListOfTasks? {
        guard let realm else {
            return nil
        }
        let result = realm.objects(Task.self)
        let array = Array(result)
        return ListOfTasks(data: array)
    }
    
    func addTask(_ task: Task) {
        guard let realm else {
            return
        }
        do {
            try realm.write {
                realm.add(task, update: .modified)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
