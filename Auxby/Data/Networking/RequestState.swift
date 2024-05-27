//
//  RequestState.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Foundation
import UIKit

/// A generic state to easily manage the request state
enum RequestState<Type> {
    case idle
    case loading
    case failed(Error)
    case succeed(Type)

    /// Returns true if the current state has failed or loaded
    var completed: Bool {
        var done = false
        if case .failed = self { done = true }
        if case .succeed = self { done = true }
        return done
    }

    /// Returns true if the current state is loading
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    /// Returns true if the current state is loaded
    var succeeded: Bool {
        if case .succeed = self { return true }
        return false
    }

    /// Returns true if the current state is idle
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
    
    func setStateActivityIndicator(_ indicator: inout ActivityIndicator?, vc: UIViewController = topVC()) {
        if isLoading && indicator == nil {
            indicator = ActivityIndicator(vc: vc)
        } else {
            indicator?.hide()
            indicator = nil
        }
    }
}
