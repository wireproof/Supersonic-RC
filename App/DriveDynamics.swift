import Foundation

/// Arcade tuning informed by the original Lingo's drive/brake/reverse ratios.
/// Absolute units and tire forces still require comparison with the original.
struct DriveDynamics {
    private(set) var speed: Float = 0
    private(set) var steering: Float = 0

    mutating func reset() { speed = 0; steering = 0 }
    mutating func stop() { speed = 0 }

    mutating func step(dt: Float, throttle: Float, steer: Float) {
        guard dt > 0 else { return }
        let input = max(-1, min(1, throttle))
        let targetSteer = max(-1, min(1, steer))
        let change = 10 * dt
        steering += max(-change, min(change, targetSteer - steering))
        // Original script uses 6300 forward, 10000 braking, 4000 reverse.
        let acceleration: Float
        if input < 0 && speed > 0.02 { acceleration = 5.0 * (10000.0 / 6300.0) }
        else if input < 0 { acceleration = 5.0 * (4000.0 / 6300.0) }
        else { acceleration = 5.0 }
        speed += input * acceleration * dt
        // The prior drag limited sustained throttle to about 1.6 units/s,
        // far below the configured 4.6 cap. This is provisional arcade tuning.
        speed *= pow(0.985, dt * 60)
        speed = max(-1.6, min(4.6, speed))
    }

    var headingRate: Float {
        steering * min(abs(speed), 1) * (speed < 0 ? -1 : 1) * 1.5
    }
}
