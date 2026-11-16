import Foundation

@main struct VerticalTests {
    static func main() {
        var flat = VerticalMotion(height: 0.005)
        for _ in 0..<100 { flat.step(dt:0.02, ground:0) }
        precondition(flat.grounded && abs(flat.height-0.005)<0.0001 && flat.velocity == 0)
        var ramp = VerticalMotion(height:0.005)
        ramp.step(dt:0.02,ground:0)
        for i in 1...10 { ramp.step(dt:0.02,ground:Float(i)*0.01) }
        precondition(ramp.grounded)
        let crestHeight = ramp.height
        ramp.step(dt:0.02,ground:0.10)
        precondition(!ramp.grounded && ramp.velocity > 0 && ramp.height > crestHeight)
        var fall = VerticalMotion(height:1)
        for _ in 0..<100 { fall.step(dt:0.02,ground:0) }
        precondition(fall.grounded && abs(fall.height-0.005)<0.0001)
        print("flat, ramp crest launch, and landing checks passed")
    }
}
