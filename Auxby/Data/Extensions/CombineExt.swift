//
//  CombineExt.swift
//  NDSports
//
//  Created by Senocico Stelian on 25.01.2022.
//

import Combine
import UIKit

/*
 Combine framework extensions
 */

extension Published.Publisher {
    /// https://stackoverflow.com/a/67058492/7306653
    var didSet: AnyPublisher<Value, Never> {
        receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}

extension Publisher {
    /// Instead of using the `sink` operator along with its two closures, use convertToSingleResult
    /// to have as output a single closure of type Result (which embeds the success and failure cases)
    func convertToSingleResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }

    /// A conversion operator that emits LoadingState values, rather than using the built-in Result type
    func convertToLoadingState() -> AnyPublisher<RequestState<Output>, Never> {
        map(RequestState.succeed)
            .catch { Just(.failed($0)) }
            .eraseToAnyPublisher()
    }
}

extension UITextField {

    // https://cocoacasts.com/combine-fundamentals-observing-a-text-field-with-combine
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .map { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }
}

extension UITextView {

    // https://cocoacasts.com/combine-fundamentals-observing-a-text-field-with-combine
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(
            for: UITextView.textDidChangeNotification,
            object: self
        )
        .map { ($0.object as? UITextView)?.text }
        .eraseToAnyPublisher()
    }
}
