import Foundation
import simd

/// Approximate horizontal collision against near-vertical recovered triangles.
/// This does not reproduce the original Havok collision response.
struct WallIndex: Decodable {
    let cell: Float
    let triangles: [[Float]]
    let bins: [String: [Int]]

    static func load() -> WallIndex? {
        guard let url = Bundle.main.url(forResource: "walls", withExtension: "json"), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(WallIndex.self, from: data)
    }

    func firstHit(from origin: SIMD3<Float>, to end: SIMD3<Float>) -> Float? {
        let direction = end - origin
        let x0 = Int(floor(min(origin.x,end.x)/cell)), x1 = Int(floor(max(origin.x,end.x)/cell))
        let z0 = Int(floor(min(origin.z,end.z)/cell)), z1 = Int(floor(max(origin.z,end.z)/cell))
        var candidates = Set<Int>()
        for x in x0...x1 { for z in z0...z1 { candidates.formUnion(bins["\(x),\(z)"] ?? []) } }
        var nearest: Float?
        for i in candidates where i >= 0 && i < triangles.count {
            let p = triangles[i]; if p.count != 9 { continue }
            let a = SIMD3<Float>(p[0],p[1],p[2]), b = SIMD3<Float>(p[3],p[4],p[5]), c = SIMD3<Float>(p[6],p[7],p[8])
            let e1 = b-a, e2 = c-a, h = simd_cross(direction,e2), det = simd_dot(e1,h)
            if abs(det) < 0.0000001 { continue }
            let inv = 1/det, relative = origin-a
            let u = inv * simd_dot(relative,h); if u < 0 || u > 1 { continue }
            let q = simd_cross(relative,e1), v = inv * simd_dot(direction,q)
            if v < 0 || u+v > 1 { continue }
            let t = inv * simd_dot(e2,q)
            if t >= 0 && t <= 1 && (nearest == nil || t < nearest!) { nearest = t }
        }
        return nearest
    }
}
