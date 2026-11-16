import Foundation

// Exercise real recovered triangles, without needing an interactive simulator.
@main struct WarehouseRampTests {
    static func main() throws {
        let index = try JSONDecoder().decode(GroundIndex.self, from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))
        let dt: Float = 1 / 60
        let x: Float = 34
        var z: Float = -21
        let initial = index.height(x: x, z: z, below: 6.1, above: 5.5)!
        var motion = VerticalMotion(height: initial + 0.005)
        var supported = 0
        var maxHeight = motion.height
        for _ in 0..<240 {
            let sample = TerrainSupport.sample(x: x, z: z, y: motion.height, heading: 0) { x,z,upper,lower in
                index.height(x: x, z: z, below: upper, above: lower)
            }
            motion.step(dt: dt, ground: sample?.height)
            if motion.grounded { supported += 1 }
            maxHeight = max(maxHeight, motion.height)
            z -= dt
        }
        print("recovered ramp: start=\(initial), end=\(motion.height), max=\(maxHeight), supportedFrames=\(supported), z=\(z)")
        precondition(supported > 180 && maxHeight > initial + 1.4, "car failed to follow the recovered ramp")
    }
}
