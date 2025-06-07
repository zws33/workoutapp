//
//  WorkoutAppDelegate.swift
//  workoutapp
//
//  Created by Zach Smith on 6/3/25.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    FirebaseApp.configure()

    return true
  }
}
