import Foundation

enum DriveButton: Hashable { case left, right, forward, reverse }

/// Thread-safe input state shared by the render loop and input callbacks.
final class InputMixer {
    private let lock = NSLock()
    private var touch: Set<DriveButton> = []
    private var keyboard: Set<DriveButton> = []
    private var padSteer: Float = 0
    private var padThrottle: Float = 0

    func setTouch(_ button: DriveButton, down: Bool) {
        lock.lock(); defer { lock.unlock() }
        if down { touch.insert(button) } else { touch.remove(button) }
    }
    func setKeyboard(_ button: DriveButton, down: Bool) {
        lock.lock(); defer { lock.unlock() }
        if down { keyboard.insert(button) } else { keyboard.remove(button) }
    }
    func clearTouch() { lock.lock(); touch.removeAll(); lock.unlock() }
    func clearKeyboard() { lock.lock(); keyboard.removeAll(); lock.unlock() }
    func setController(steer: Float, throttle: Float) {
        lock.lock(); padSteer = max(-1,min(1,steer)); padThrottle = max(-1,min(1,throttle)); lock.unlock()
    }
    func snapshot() -> (steer: Float, throttle: Float) {
        lock.lock(); defer { lock.unlock() }
        func direction(_ s: Set<DriveButton>, _ positive: DriveButton, _ negative: DriveButton) -> Float {
            (s.contains(positive) ? 1 : 0) - (s.contains(negative) ? 1 : 0)
        }
        let touchSteer = direction(touch,.right,.left), keySteer = direction(keyboard,.right,.left)
        let touchThrottle = direction(touch,.forward,.reverse), keyThrottle = direction(keyboard,.forward,.reverse)
        let hasTouchSteer = touch.contains(.left) || touch.contains(.right)
        let hasTouchThrottle = touch.contains(.forward) || touch.contains(.reverse)
        let hasKeySteer = keyboard.contains(.left) || keyboard.contains(.right)
        let hasKeyThrottle = keyboard.contains(.forward) || keyboard.contains(.reverse)
        return (hasTouchSteer ? touchSteer : (hasKeySteer ? keySteer : padSteer),
                hasTouchThrottle ? touchThrottle : (hasKeyThrottle ? keyThrottle : padThrottle))
    }
}
