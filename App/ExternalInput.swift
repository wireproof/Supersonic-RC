import Foundation
import GameController

/// Connects physical keyboards and extended gamepads to the shared input state.
final class ExternalInput {
    private let mixer: InputMixer
    private var observers: [NSObjectProtocol] = []

    init(mixer: InputMixer) {
        self.mixer = mixer
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { [weak self] _ in self?.connectController() })
        observers.append(center.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            self?.mixer.setController(steer: 0, throttle: 0); self?.connectController()
        })
        observers.append(center.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: .main) { [weak self] _ in self?.connectKeyboard() })
        observers.append(center.addObserver(forName: .GCKeyboardDidDisconnect, object: nil, queue: .main) { [weak self] _ in self?.mixer.clearKeyboard() })
        connectController()
        connectKeyboard()
    }

    deinit { for observer in observers { NotificationCenter.default.removeObserver(observer) } }

    private func connectController() {
        guard let pad = GCController.controllers().compactMap({ $0.extendedGamepad }).first else { return }
        pad.valueChangedHandler = { [weak self] pad, _ in
            let stick = pad.leftThumbstick.xAxis.value
            let steer = abs(stick) > 0.15 ? stick : pad.dpad.xAxis.value
            let forward = max(pad.rightTrigger.value, pad.buttonA.value)
            let reverse = max(pad.leftTrigger.value, pad.buttonB.value)
            self?.mixer.setController(steer: steer, throttle: forward - reverse)
        }
    }

    private func connectKeyboard() {
        guard let keys = GCKeyboard.coalesced?.keyboardInput else { return }
        keys.keyChangedHandler = { [weak self] keys, _, _, _ in
            func down(_ code: GCKeyCode) -> Bool { keys.button(forKeyCode: code)?.isPressed ?? false }
            self?.mixer.setKeyboard(.left, down: down(.leftArrow) || down(.keyA))
            self?.mixer.setKeyboard(.right, down: down(.rightArrow) || down(.keyD))
            self?.mixer.setKeyboard(.forward, down: down(.upArrow) || down(.keyW))
            self?.mixer.setKeyboard(.reverse, down: down(.downArrow) || down(.keyS))
        }
    }
}
