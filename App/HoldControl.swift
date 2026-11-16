import SwiftUI
import UIKit

/// A separate UIKit touch target for each direction, allowing simultaneous holds.
struct HoldControl: UIViewRepresentable {
    let icon: String
    let change: (Bool) -> Void

    func makeUIView(context: Context) -> HoldButton {
        let button = HoldButton()
        button.change = change
        button.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        button.layer.cornerRadius = 32
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.38).cgColor
        button.setImage(UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)), for: .normal)
        button.tintColor = .white
        return button
    }

    func updateUIView(_ button: HoldButton, context: Context) { button.change = change }

    final class HoldButton: UIButton {
        var change: ((Bool) -> Void)?
        override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            change?(true)
            return true
        }
        override func endTracking(_ touch: UITouch?, with event: UIEvent?) { change?(false) }
        override func cancelTracking(with event: UIEvent?) { change?(false) }
    }
}
