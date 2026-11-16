import Foundation
import simd

@main struct WallSweepTests {
    static func main() {
        // A narrow vertical obstacle crosses only the right-hand sweep ray.
        let wall = WallIndex(cell: 2, triangles: [
            [0.08, -1, 0, 0.12, -1, 0, 0.10, 1, 0]
        ], bins: ["0,0": [0], "0,-1": [0]])
        let start = SIMD3<Float>(0, 0, -0.5), end = SIMD3<Float>(0, 0, 0.5)
        precondition(wall.firstHit(from: start, to: end) == nil)
        let hit = wall.firstHit(from: start, to: end, halfWidth: 0.095)
        precondition(hit != nil && abs(hit! - 0.5) < 0.001)
        precondition(wall.firstHit(from: start, to: start, halfWidth: 0.095) == nil)
        print("wall center clearance, side contact, and stationary checks passed")
    }
}
