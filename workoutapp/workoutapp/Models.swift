//
//  Models.swift
//  workoutapp
//
//  Created by Zach Smith on 4/15/25.
//

import Foundation

struct Exercise: Codable, Identifiable, Equatable {
    let day: String
    let group: String
    let name: String
    let sets: String
    let reps: String
    let weight: String
    let notes: String
    
    var id: String {
        return "\(day)-\(group)-\(name)"
    }
    
    enum CodingKeys: String, CodingKey {
        case day = "Day"
        case group = "Group"
        case name = "Name"
        case sets = "Sets"
        case reps = "Reps"
        case weight = "Weight"
        case notes = "Notes"
    }
}
