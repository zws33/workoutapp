//
//  ExerciseEntity+CoreDataProperties.swift
//  workoutapp
//
//  Created by Zach Smith on 6/13/25.
//
//

import Foundation
import CoreData


extension ExerciseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseEntity> {
        return NSFetchRequest<ExerciseEntity>(entityName: "ExerciseEntity")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var sets: Int64
    @NSManaged public var reps: Int64
    @NSManaged public var weight: String?
    @NSManaged public var notes: String?
    @NSManaged public var exerciseGroup: ExerciseGroupEntity?

}

extension ExerciseEntity : Identifiable {

}
