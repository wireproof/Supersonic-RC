import Foundation

/// Spatial index built from the recovered warehouse mesh. It models support
/// surfaces only; it does not implement the original game's Havok collisions.
struct GroundIndex: Decodable {
    let cell: Float
    let triangles: [[Float]]
    let bins: [String: [Int]]

    static func load() -> GroundIndex? {
        guard let url = Bundle.main.url(forResource: "ground", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(GroundIndex.self, from: data)
    }

    func height(x: Float, z: Float, below upper: Float, above lower: Float) -> Float? {
        let key = "\(Int(floor(x / cell))),\(Int(floor(z / cell)))"
        guard let candidates = bins[key] else { return nil }
        var best: Float?
        for index in candidates where index >= 0 && index < triangles.count {
            let p = triangles[index]
            guard p.count == 9 else { continue }
            let det = (p[5] - p[8]) * (p[0] - p[6]) + (p[6] - p[3]) * (p[2] - p[8])
            if abs(det) < 0.0000001 { continue }
            let u = ((p[5] - p[8]) * (x - p[6]) + (p[6] - p[3]) * (z - p[8])) / det
            let v = ((p[8] - p[2]) * (x - p[6]) + (p[0] - p[6]) * (z - p[8])) / det
            let w = 1 - u - v
            if min(u, v, w) < -0.00001 { continue }
            let y = u * p[1] + v * p[4] + w * p[7]
            if y <= upper && y >= lower && (best == nil || y > best!) { best = y }
        }
        return best
    }
}
