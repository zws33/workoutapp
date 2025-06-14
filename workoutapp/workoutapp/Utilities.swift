//
//  Utilities.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//


import SwiftUI
import GoogleSignIn

func prettyPrintData(data: Data) {
    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
        AppLogger.debug("JSON Response: \(String(decoding: jsonData, as: UTF8.self))", category: .networking)
    } else {
        AppLogger.warning("JSON data malformed", category: .networking)
    }
}