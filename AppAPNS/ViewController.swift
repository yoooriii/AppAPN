//
//  ViewController.swift
//  AppAPNS
//
//  Created by Yu Lo on 10/13/18.
//  Copyright © 2018 Horns & Hoovs. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func actRegisterAPNS(_ sender: AnyObject) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
    }
    
    @IBAction func actGetNotificationSettings(_ sender: AnyObject) {
        UNUserNotificationCenter.current().getNotificationSettings() { (settings) in
            
            print("settings: \(settings)")
            
            switch settings.soundSetting {
            case .enabled:
                print("enabled sound setting")
                
            case .disabled:
                print("setting has been disabled")
                
            case .notSupported:
                print("something vital went wrong here")
            }
        }
    }
}

