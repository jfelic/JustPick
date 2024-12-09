//
//  JustPickApp.swift
//  JustPick
//
//  Created by Julian on 11/26/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    return true

  }
}


@main
struct JustPickApp: App {
    
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Create the FirebaseManager as a StateObject
    @StateObject private var firebaseManager = FirebaseManager()
    @State private var networkManager = NetworkManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(firebaseManager) // use firebaseManager to trickle down state to entire app
                .environment(networkManager)
        }
    }
}
