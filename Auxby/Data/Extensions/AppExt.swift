//
//  AppExt.swift
//  NDSports
//
//  Created by Senocico Stelian on 19.01.2022.
//

import UIKit

/// Check if the current device is an iOS simulator
var isSimulator: Bool {
    #if targetEnvironment(simulator)
        return true
    #else
        return false
    #endif
}

/// Check if the current running environment is MacOs
var isRunningOnMac: Bool {
    ProcessInfo.processInfo.isiOSAppOnMac
}

/// Check if the device is iPad type
var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac }
/// Check if device is iPhone iPhoneX
var isPhoneX: Bool { UIScreen.main.bounds.height >= 812 && !isPad }
/// Check if current device has notch
var deviceHasNotch: Bool { UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0 }

/**
 Override print function; disable print logs on production environment
 https://stackoverflow.com/questions/52665263/it-is-possible-to-access-the-console-logs-for-an-ios-app-from-appstore
 */
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    DispatchQueue.global(qos: .background).async {
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
        // if !isSimulator && !isRunningOnMac { TestFairy.log(output) }
    }
    #endif
}

/**
 Get the top most view controller from the base view controller; default param is UIWindow's rootViewController
 - Returns: The top most UIViewController that always should exist (but can be nil)
 */
func topVC(_ base: UIViewController? = UIApplication.shared.keyWindowPresentedController) -> UIViewController {
    if let nav = base as? UINavigationController { return topVC(nav.visibleViewController) }
    if let tab = base as? UITabBarController, let selected = tab.selectedViewController { return topVC(selected)}
    if let presented = base?.presentedViewController { return topVC(presented) }
    guard let vc = base else { fatalError("The app doesn't have a active view controller") }
    return vc
}

/// Run a sequence of code after a delay time
/// - Parameters:
///   - sec: Secods to delay
///   - completion: completion block
func delay(_ sec: Double, _ completion: @escaping (() -> Void)) {
    DispatchQueue.main.asyncAfter(deadline: .now()+sec) {
        completion()
    }
}

/// Run a sequence of code in the UI Main Thread
/// - Parameter completion: completion block
func runOnMainThread( _ completion: @escaping (() -> Void)) {
    DispatchQueue.main.async {
        completion()
    }
}
