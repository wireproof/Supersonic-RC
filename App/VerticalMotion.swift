import Foundation

/// A provisional ramp-launch approximation; original Havok tuning is unknown.
struct VerticalMotion {
    private(set) var height: Float
    private(set) var velocity: Float = 0
    private(set) var grounded = false
    private var previousGround: Float?
    private var rampVelocity: Float = 0

    init(height: Float) { self.height = height }
    mutating func reset(height: Float) { self = VerticalMotion(height: height) }

    mutating func step(dt: Float, ground: Float?) {
        guard dt > 0 else { return }
        let wasGrounded = grounded
        let priorRampVelocity = rampVelocity
        let oldHeight = height
        velocity -= 3.5 * dt
        var nextHeight = height + velocity * dt
        var onGround = false
        if let ground = ground {
            let target = ground + 0.005
            let slopeVelocity = wasGrounded && previousGround != nil ? (ground - previousGround!) / dt : 0
            let crest = wasGrounded && priorRampVelocity > 0.15 && slopeVelocity < priorRampVelocity * 0.5
            if crest && nextHeight <= target {
                velocity = min(priorRampVelocity, 2)
                nextHeight = max(oldHeight, target) + velocity * dt
            } else if nextHeight <= target {
                nextHeight = target
                velocity = 0
                onGround = true
                rampVelocity = max(0, min(slopeVelocity, 2))
            }
            previousGround = ground
        } else {
            previousGround = nil
        }
        if wasGrounded && !onGround && velocity <= 0 && priorRampVelocity > 0.15 {
            velocity = min(priorRampVelocity, 2)
            nextHeight = oldHeight + velocity * dt
        }
        if !onGround { rampVelocity = 0 }
        grounded = onGround
        height = nextHeight
    }
}
