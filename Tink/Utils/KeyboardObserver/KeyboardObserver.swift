//
//  KeyboardObserver.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 24/2/25.
//

import Foundation
import SwiftUI
import Combine

/// Observes keyboard appearance and updates the keyboard height accordingly.
/// This class listens for system notifications when the keyboard appears or disappears
/// and updates the `keyboardHeight` property.
///
/// - Uses `@Published` to notify SwiftUI views when the keyboard height changes.
/// - Uses `NotificationCenter` to listen for keyboard show/hide events.
/// - Stores subscriptions in `cancellables` to manage memory efficiently.
class KeyboardObserver: ObservableObject {
    
    /// The current height of the keyboard. Updated when the keyboard appears or disappears.
    @Published var keyboardHeight: CGFloat = 0
    
    /// Stores Combine subscriptions to prevent memory leaks.
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the observer and starts listening for keyboard events.
    init() {
        // Observe when the keyboard appears and update its height.
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return keyboardFrame.height
                }
                return 0
            }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)
        
        // Observe when the keyboard hides and reset the height to 0.
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)
    }
}
