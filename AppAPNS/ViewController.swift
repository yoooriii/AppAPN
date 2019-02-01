//
//  ViewController.swift
//  AppAPNS
//
//  Created by Yu Lo on 10/13/18.
//  Copyright © 2018 Horns & Hoovs. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func actRegisterAPNS(_ sender: AnyObject) {
        UIApplication.appDelegate.registerForAPN()
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

    @IBAction func takeFBToken(_ sender: AnyObject) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                //self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
            }
        }
    }
}

