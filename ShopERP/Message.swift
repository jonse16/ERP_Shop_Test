//
//  MessageAlert.swift
//  ShopERP
//
//  Created by 洛可 on 2017/7/20.
//  Copyright © 2017年 roko. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Message{
    
    private static var message:Message?
    
    static func sharedInstance() -> Message{
        if message == nil {
            message = Message()
        }
        return message!
    }
    
    func popAlert(title:String, message:String, uiViewController:UIViewController){
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        uiViewController.present(alert, animated: true, completion: nil)
    }
    
    func sendNotification(title: String!, subtitle:String!, body: String!, categoryIdentifier: String?, userInfo: [String:String]?){
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = 1
        content.sound = UNNotificationSound.default()
        if categoryIdentifier != nil{
           content.categoryIdentifier = categoryIdentifier!
        }
        
        if userInfo != nil{
            content.userInfo = userInfo!
        }
        
        let now = Date()
        let df =  DateFormatter()
        df.dateFormat = "HH:mm:ss:SSS"
        let nowString = df.string(from: now)
        
        
//        let imageURL = Bundle.main.url(forResource: "pic", withExtension: "jpg")
//        let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
//        content.attachments = [attachment]
//        content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
        let request = UNNotificationRequest(identifier: nowString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
