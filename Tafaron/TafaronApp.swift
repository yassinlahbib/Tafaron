//
//  TafaronApp.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI
import Firebase
import FirebaseCore //Authentication

@main
struct TafaronApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // Appelle du AppDelegate ci-dessous
    
    var body: some Scene {
        WindowGroup {
            RootView()
            
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Firebase configuré !")
    return true
  }
}
