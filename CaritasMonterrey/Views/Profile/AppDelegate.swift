//
//  AppDelegate.swift
//  CaritasMonterrey
//
//  Created by José de Jesùs Jiménez Martínez on 14/11/25.
//


import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

    }
}

