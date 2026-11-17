import Combine
import Foundation
import SwiftUI

@propertyWrapper
internal struct Preference<Value>: DynamicProperty {

    @ObservedObject private var preferencesObserver: PublisherObservableObject
    private let keyPath: ReferenceWritableKeyPath<Preferences, Value>
    private let preferences: Preferences

    internal init(_ keyPath: ReferenceWritableKeyPath<Preferences, Value>, preferences: Preferences = .standard) {
        self.keyPath = keyPath
        self.preferences = preferences
        let publisher = preferences
            .preferencesChangedSubject
            .filter { $0 == keyPath }
            .map { _ in () }
            .eraseToAnyPublisher()
        self.preferencesObserver = .init(publisher: publisher)
    }

    internal var wrappedValue: Value {
        get { preferences[keyPath: keyPath] }
        nonmutating set { preferences[keyPath: keyPath] = newValue }
    }

    internal var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

internal final class PublisherObservableObject: ObservableObject {
    internal var subscriber: AnyCancellable?

    internal init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
}
