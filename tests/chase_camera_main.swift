import Foundation

@main struct CameraTests {
    static func main() {
        var camera = ChaseCamera()
        let car = SIMD3<Float>(0, 0, 0)
        camera.snap(car: car, heading: 0)
        precondition(abs(camera.position.z - 0.75) < 0.0001)
        camera.follow(car: car, heading: .pi / 2, dt: 1 / 60)
        precondition(camera.position.z > 0.6 && camera.position.x < -0.07)
        for _ in 0..<120 { camera.follow(car: car, heading: .pi / 2, dt: 1 / 60) }
        precondition(abs(camera.position.x + 0.75) < 0.001 && abs(camera.position.z) < 0.001)
        camera.snap(car: SIMD3<Float>(10, 2, 4), heading: 0)
        precondition(abs(camera.position.x - 10) < 0.001 && abs(camera.position.z - 4.75) < 0.001)
        print("camera snap, turn lag, follow and reset checks passed")
    }
}
