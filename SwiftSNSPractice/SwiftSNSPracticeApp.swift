//
//  SwiftSNSPracticeApp.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI
import Firebase


@main
struct SwiftSNSPracticeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
           AuthView()
        }
    }
    
    class AppDelegate:NSObject,UIApplicationDelegate{
            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
                FirebaseApp.configure()
                return true
            }
        }
}
