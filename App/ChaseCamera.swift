import Foundation

/// Approximate the original camera's eased follow position (0.1 per update).
struct ChaseCamera {
    private(set) var position: SIMD3<Float> = .zero

    static func target(car: SIMD3<Float>, heading: Float) -> SIMD3<Float> {
        car + SIMD3<Float>(-sin(heading) * 0.75, 0.45, cos(heading) * 0.75)
    }

    mutating func snap(car: SIMD3<Float>, heading: Float) {
        position = Self.target(car: car, heading: heading)
    }

    mutating func follow(car: SIMD3<Float>, heading: Float, dt: Float) {
        guard dt > 0 else { return }
        let blend = 1 - pow(0.9, min(dt, 0.1) * 60)
        position += (Self.target(car: car, heading: heading) - position) * blend
    }
}
