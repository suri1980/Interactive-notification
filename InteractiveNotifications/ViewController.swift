//
//  ViewController.swift
//  InteractiveNotifications
//
//  Created by Thota, Surendra Babu on 10/7/17.
//  Copyright © 2017 Thota, Surendra Babu. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    struct Notification {
        
        struct Category {
            static let categoryAction = "categoryAction"
        }
        
        struct Action {
            static let activateCard = "activateCard"
            static let cardNotReceived = "cardNotReceived"
        }
        
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {


        super.viewDidLoad()
        
        configureUserNotificationsCenter()
    }
    
    // MARK: - Private Methods
    
    private func configureUserNotificationsCenter() {
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
        // Define Actions
        let actionActivateCard = UNTextInputNotificationAction(identifier: Notification.Action.activateCard, title: "Activate card", options: [.foreground], textInputButtonTitle: "Enter Expiry Date", textInputPlaceholder: "mm/yy")
        let actionCardNotReceived = UNNotificationAction(identifier: Notification.Action.cardNotReceived, title: "I didn't get my card", options: [.authenticationRequired])
        
        // Define Category
        let actionCategory = UNNotificationCategory(identifier: Notification.Category.categoryAction, actions: [actionActivateCard, actionCardNotReceived], intentIdentifiers: [], options: [])
        
        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([actionCategory])
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        // Request Notification Settings
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    // Schedule Local Notification
                    self.scheduleLocalNotification()
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            }
        }

    }
    private func scheduleLocalNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.body = "Its been 15 days since your card was mailed to you. Activate it now"
        
        // Set Category Identifier
        notificationContent.categoryIdentifier = Notification.Category.categoryAction
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
     //   let request = response.notification.request
        
        switch response.actionIdentifier {
        case Notification.Action.activateCard:
            let textResponse = response as! UNTextInputNotificationResponse
            //let newContent = request.content.mutableCopy() as! UNMutableNotificationContent
            print(textResponse.userText)
            print("Activating card")
        case Notification.Action.cardNotReceived:
            print("Card not received")
        default:
            print("Other Action")
        }
        
        completionHandler()
    }
}
