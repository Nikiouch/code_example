//
//  Level+CoreDataProperties.swift
//  OwlGame
//
//  Created by Никита Главацкий on 17/02/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//
//

import Foundation
import CoreData


extension Level {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Level> {
        return NSFetchRequest<Level>(entityName: "Level")
    }

    @NSManaged public var desc: String?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var number: Int64
    @NSManaged public var score: Int64
    @NSManaged public var videoUrl: String?
    @NSManaged public var sections: NSSet?

}



// MARK: Generated accessors for sections
extension Level {

    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: Section)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: Section)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)

}
