//
//  AlertController.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/4/23.
//
import UIKit
import Foundation

class CustomAlertController {
//    let title: String?
//    let message: String?
//    var style: UIAlertController.Style = .alert
//    init(title: String, message: ) {
//
//    }
    class func presentAlertStyle(title: String, message: String, style: UIAlertController.Style = .alert) -> UIAlertController {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        return alertVC
    }
    
}
