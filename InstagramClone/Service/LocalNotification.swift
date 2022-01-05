//
//  LocalNotification.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/1/5.
//
import UIKit
import Foundation

class LocalNotification {
    static func sendLocalNotification(email: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Post"
        content.body = "\(email) just shared a new post!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
