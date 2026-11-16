import Foundation

/// Approximate four-wheel terrain sampling. This is not the original Havok solver.
struct TerrainSupport {
    struct Result {
        let height: Float
        let pitch: Float
        let roll: Float
        let contacts: Int
    }

    /// Wheel offsets are derived from the original Lingo positions, scaled by 0.01.
    static func sample(x: Float, z: Float, y: Float, heading: Float,
                       heightAt: (Float, Float, Float, Float) -> Float?) -> Result? {
        let halfWidth: Float = 0.095
        let halfLength: Float = 0.17
        let points: [(Float, Float)] = [(-halfWidth,halfLength),(halfWidth,halfLength),(-halfWidth,-halfLength),(halfWidth,-halfLength)]
        let c = cos(heading), s = sin(heading)
        let heights = points.map { lateral, forward -> Float? in
            let px = x + c*lateral + s*forward
            let pz = z + s*lateral - c*forward
            return heightAt(px,pz,y + 0.25,y - 0.35)
        }
        let available = heights.compactMap { $0 }
        guard available.count >= 2 else { return nil }
        let average = available.reduce(0,+) / Float(available.count)
        func pairMean(_ a: Int, _ b: Int) -> Float? {
            let values = [heights[a],heights[b]].compactMap { $0 }
            return values.isEmpty ? nil : values.reduce(0,+) / Float(values.count)
        }
        let front = pairMean(0,1), rear = pairMean(2,3)
        let left = pairMean(0,2), right = pairMean(1,3)
        let pitch = front != nil && rear != nil ? atan2(front! - rear!, 2*halfLength) : 0
        let roll = left != nil && right != nil ? atan2(left! - right!, 2*halfWidth) : 0
        return Result(height: average, pitch: pitch, roll: roll, contacts: available.count)
    }
}
