//
//  Section+CoreDataClass.swift
//  OwlGame
//
//  Created by Никита Главацкий on 07/02/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Section)
public class Section: NSManagedObject, Codable {
    convenience init(){
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Section")!, insertInto: CoreDataManager.instance.managedObjectContext)
    }
    
    enum CodingKeys: String, CodingKey {
        case desc
        case image
        case name
        case number
        case score
        case type
        case tasks
        case sectionId = "section_id"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Section", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.desc = try container.decodeIfPresent(String.self, forKey: .desc)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.score = try container.decodeIfPresent(Int64.self, forKey: .score) ?? 0
        self.number = try container.decodeIfPresent(Int64.self, forKey: .number) ?? 0
        self.type = try container.decodeIfPresent(Int32.self, forKey: .type) ?? 1
        self.sectionId = try container.decodeIfPresent(Int64.self, forKey: .sectionId) ?? 0
        self.tasks = NSSet(array: try container.decode([Task].self, forKey: .tasks))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
    func getAllLevels(forSecrtion section: Section) -> NSFetchedResultsController<NSFetchRequestResult>{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        let filter = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [filter]
        
        let predicate = NSPredicate(format: "%K == %@", "section", section)
        fetchRequest.predicate = predicate
        
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchResultController
        
    }
    func update(withJson json: [String: Any]){
        self.desc = json["desc"] as? String
        self.image = json["image"] as? String
        self.name = json["name"] as? String
        self.number = json["number"] as! Int64
        self.type = json["type"] as! Int32
    }
}
