import Foundation

@main struct DynamicsTests {
    static func main() {
        var forward = DriveDynamics()
        for _ in 0..<60 { forward.step(dt: 1.0/60, throttle: 1, steer: 1) }
        precondition(forward.speed > 3 && forward.steering == 1 && forward.headingRate > 0)
        var left = forward
        for _ in 0..<20 { left.step(dt: 1.0/60, throttle: 1, steer: -1) }
        precondition(left.headingRate < 0)
        var coast = forward, braking = forward
        coast.step(dt: 0.05, throttle: 0, steer: 0)
        braking.step(dt: 0.05, throttle: -1, steer: 0)
        precondition(braking.speed < coast.speed && braking.steering < 1)
        var reverse = DriveDynamics()
        for _ in 0..<60 { reverse.step(dt: 1.0/60, throttle: -1, steer: 0) }
        precondition(reverse.speed < -0.5 && abs(reverse.speed) < forward.speed)
        for _ in 0..<20 { reverse.step(dt: 1.0/60, throttle: -1, steer: 1) }
        precondition(reverse.headingRate < 0)
        reverse.stop(); precondition(reverse.speed == 0)
        reverse.reset(); precondition(reverse.steering == 0)
        print("acceleration, braking, reverse, steering and reset checks passed")
    }
}
