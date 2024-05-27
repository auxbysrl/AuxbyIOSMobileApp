//
//  VC.swift
//  NDSports
//
//  Created by Senocico Stelian on 26.01.2022.
//

import UIKit

extension NSObject {
    /**
     Convenient way to force cast an NSObject type to an UIViewController type.
     
     Force try to convert NSObject type to an UIViewController type.
     The app will crash if the type casting fails. Use this extension only
     for NSObjects inheriting from the UIViewController.
     
     - IMPORTANT: The `className` of the type is the explicit identifier of the UIViewController set in the storyboard.
     */
    class func asVC(storyboardName: String? = nil) -> UIViewController {
        VC.get(id: className, storyboardName: storyboardName)
    }
    
    /// Returns the class name
    class var className: String {
        String(describing: self)
    }
}

/**
 Private helper extension for the NSObject, to convert an NSObject type to an UIViewController type.
 */
private class VC {
    
    /// Readable type alias for the storyboard identifier of the type string
    typealias StoryboardIdentifier = String
    
    /**
     Get a UIViewController by providing its StoryboardIdentifier.
     
     If the storyboardName is not provided, it will be assumed that the storyboard name
     can be retrieved from the id by cutting the VC letters from the end of the identifier.
     
     Example: If the StoryboardIdentifier is `LoginVC`, it will assume that storyboard name is `Login`
     */
    class func get(id: StoryboardIdentifier, storyboardName: String? = nil) -> UIViewController {
        guard let storyboardName = storyboardName ?? id.components(separatedBy: "VC").first else {
            fatalError("The name of the provided UIViewController should be like: LoginVC, HomeVC, etc. Use just VC instead of using LoginViewController or HomeViewController")
        }
        
        if Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") == nil {
            fatalError("The project does not contain any storyboard named \(storyboardName). Check that storyboardName is set correctly.")
        }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        // "identifierToNibNameMap" – is the key for searching IDs - don't change it
        let identifiersDict = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any]
        // check if the storyboard contains the provided StoryboardIdentifier
        
        if let identifiersList = identifiersDict, identifiersList[id] != nil {
            return storyboard.instantiateViewController(withIdentifier: id)
        } else {
            fatalError("The storyboard named \(storyboardName) does not contain a VC with the identifier \(id). Please check if the storyboard identifier is set correctly.")
        }
    }
}
