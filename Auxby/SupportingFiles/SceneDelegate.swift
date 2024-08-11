//
//  SceneDelegate.swift
//  Auxby
//
//  Created by Andrei Traciu on 11.10.2022.
//

import UIKit
import BranchSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
   

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        if let userActivity = connectionOptions.userActivities.first {
              BranchScene.shared().scene(scene, continue: userActivity)
            } else if !connectionOptions.urlContexts.isEmpty {
              BranchScene.shared().scene(scene, openURLContexts: connectionOptions.urlContexts)
            }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        UpdateService.shared.stopTimer()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
      scene.userActivity = NSUserActivity(activityType: userActivityType)
      scene.delegate = self
    }
     
     func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
           BranchScene.shared().scene(scene, continue: userActivity)
     }
     
     func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
           BranchScene.shared().scene(scene, openURLContexts: URLContexts)
     }
}

