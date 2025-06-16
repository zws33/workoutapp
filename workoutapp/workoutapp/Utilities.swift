//
//  Utilities.swift
//  workoutapp
//
//  Created by Zach Smith on 4/16/25.
//


import SwiftUI
import GoogleSignIn

func prettyPrintData(data: Data) -> String {
    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
        return "JSON Response: \(String(decoding: jsonData, as: UTF8.self))"
    } else {
        return "JSON data malformed"
    }
}
