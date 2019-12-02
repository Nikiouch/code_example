//
//  Level+CoreDataClass.swift
//  OwlGame
//
//  Created by Никита Главацкий on 07/02/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Level)
public class Level: NSManagedObject, Codable {
    convenience init(){
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Level")!, insertInto: CoreDataManager.instance.managedObjectContext)
    }
    
    enum CodingKeys: String, CodingKey {
        case desc
        case image
        case name
        case number
        case score
        case videoUrl = "video_url"
        case sections
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Level", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(entity: entity, insertInto: managedObjectContext)
        
        self.desc = try container.decodeIfPresent(String.self, forKey: .desc)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.score = try container.decodeIfPresent(Int64.self, forKey: .score) ?? 0
        self.number = try container.decodeIfPresent(Int64.self, forKey: .number) ?? 0
        self.videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        self.sections = NSSet(array: try container.decode([Section].self, forKey: .sections))
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        
    }
    
    func getSections(level: Level) -> NSFetchedResultsController<NSFetchRequestResult>{
        
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "Section")
        
        let sordDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchResult.sortDescriptors = [sordDescriptor]
        
        let predicate = NSPredicate(format: "%K == %@", "level", level)
        fetchResult.predicate = predicate
        
        let fetchResultController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchResult, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchResultController
    }
    
    func update(withJson json: [String: Any]){
        self.desc = json["desc"] as? String
        self.image = json["image"] as? String
        self.videoUrl = json["video_url"] as? String
    }
    
}


