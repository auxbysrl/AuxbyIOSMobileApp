//
//  AppDelegate.swift
//  Auxby
//
//  Created by Andrei Traciu on 11.10.2022.
//

import UIKit
import GoogleSignIn
import L10n_swift
import Firebase
import Reachability
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import BranchSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate{
    var reachability: Reachability?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        if let language = Offline.decode(key: .language, type: String.self) {
            L10n.shared.language = language
        } else {
            L10n.shared.language = "ro"
            Offline.encode(L10n.shared.language, key: .language)
        }
        whenAppUninstalled()
        
        BranchScene.shared().initSession(launchOptions: launchOptions, registerDeepLinkHandler: { (params, error, scene) in
            if let offerId = params!["$offerId"] as? Int {
                let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
                offerDetailsVC.vm = PreviewOrDetailsVM(id: offerId )
                topVC().pushVC(offerDetailsVC)
            } else if let userId = params!["$userId"] as? String {
                if let _ = Offline.currentUser {
                    
                } else {
                    Offline.encode(Int(userId), key: .referralId)
                    topVC().pushVC(LoginVC.asVC())
                }
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
        do {
            reachability = try Reachability()
            try reachability?.startNotifier()
        } catch {
            print("Nu am putut începe monitorizarea conectivității.")
        }
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
            } else {
                // Show the app's signed-in state.
            }
        }
        return true
    }
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
  
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        bgTask = application.beginBackgroundTask(withName: "My Background Task") {
            application.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func whenAppUninstalled() {
        if UserDefaults.standard.bool(forKey: "hasRunBefore") == false {
            UserDefaults.standard.set(true, forKey: "hasRunBefore")
            Keychain.deleteAll()
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        if let reachability = notification.object as? Reachability {
            if reachability.connection != .unavailable {
                if let _ = Offline.decode(key: .isNoInternetPresented, type: Bool.self) {
                    topVC().popVC()
                }
            } else {
                topVC().pushVC(NoInternetVC.asVC())
            }
        }
    }
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("aici de ce nu intrii?????")
        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(url)
        if !handled {
            return false
        }
        return true
    }
}
