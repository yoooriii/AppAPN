//
//  AppDelegate.swift
//  AppAPNS
//
//  Created by Yu Lo on 10/13/18.
//  Copyright © 2018 Horns & Hoovs. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

extension UIApplication {
    static var appDelegate: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?

    func registerForAPN() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let options: UNAuthorizationOptions
        if #available(iOS 12.0, *) {
            options = [.badge, .alert, .sound, .provisional, .providesAppNotificationSettings, .criticalAlert]
        } else {
            options = [.badge, .alert, .sound]
        }

        center.requestAuthorization(options:options) { (granted, error) in
            // Enable or disable features based on authorization.
            print("APN requestAuthorization result: granted: \(granted); error:\(String(describing: error))")

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("APN User denied the permissions")
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    /// This method will be called once a token is available, or has been refreshed. Typically it
    /// will be called once per app start, but may be called more often, if token is invalidated or
    /// updated. In this method, you should perform operations such as:
    ///
    /// * Uploading the FCM token to your application server, so targeted notifications can be sent.
    ///
    /// * Subscribing to any topics.
//    - (void)messaging:(FIRMessaging *)messaging
//    didReceiveRegistrationToken:(NSString *)fcmToken
//    NS_SWIFT_NAME(messaging(_:didReceiveRegistrationToken:));

    /// This method is called on iOS 10+ devices to handle data messages received via FCM
    /// direct channel (not via APNS). For iOS 9 and below, the direct channel data message
    /// is handled by the UIApplicationDelegate's -application:didReceiveRemoteNotification: method.
    /// You can enable all direct channel data messages to be delivered in FIRMessagingDelegate
    /// by setting the flag `useMessagingDelegateForDirectMessages` to true.
//    - (void)messaging:(FIRMessaging *)messaging
//    didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage
//    NS_SWIFT_NAME(messaging(_:didReceive:))
//    __IOS_AVAILABLE(10.0);

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }


}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        registerForAPN()

        // // Use Firebase library to configure APIs
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - APNs
    // Getting device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APN didRegisterForRemoteNotificationsWithDeviceToken >> \(deviceTokenString) <<")

        Messaging.messaging().apnsToken = deviceToken
    }

    // In case of error
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APN didFailToRegisterForRemoteNotificationsWithError >> \(error) <<")
    }

    // For receiving push notification
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("APN didReceiveRemoteNotification userInfo >> \(userInfo) <<")


        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        print("APNd willPresent notification >> \(notification) <<")

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)

        let options: UNNotificationPresentationOptions = [.badge, .alert, .sound]
        completionHandler(options)
    }


    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("APNd didReceive response >> \(response) <<")

        completionHandler()
    }


    // The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
    @available(iOS 12.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("APNd openSettingsFor notification >> \(notification?.debugDescription ?? "<nil>") <<")
    }
}
