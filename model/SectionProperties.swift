//
//  Section+CoreDataProperties.swift
//  OwlGame
//
//  Created by Никита Главацкий on 17/02/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//
//

import Foundation
import CoreData


extension Section {

    enum SectionType: Int32 {
        case remember, letters, words, sentences
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section> {
        return NSFetchRequest<Section>(entityName: "Section")
    }

    @NSManaged public var desc: String?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var number: Int64
    @NSManaged public var score: Int64
    @NSManaged public var type: Int32
    @NSManaged public var sectionId: Int64
    @NSManaged public var level: Level?
    @NSManaged public var tasks: NSSet?

    var sectionType: SectionType{
        get{
            return SectionType(rawValue: self.type)!
        }
        set{
            self.type = newValue.rawValue
        }
    }
}

// MARK: Generated accessors for tasks
extension Section {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
