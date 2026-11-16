import Foundation

@main struct TerrainTests {
    static func main() {
        let flat = TerrainSupport.sample(x:0,z:0,y:0,heading:0) { _,_,_,_ in 1 }!
        precondition(flat.contacts == 4 && abs(flat.height-1)<0.0001 && flat.pitch == 0 && flat.roll == 0)
        let ramp = TerrainSupport.sample(x:0,z:0,y:0,heading:0) { _,z,_,_ in -z }!
        precondition(ramp.pitch > 0.7 && abs(ramp.roll)<0.0001)
        let bank = TerrainSupport.sample(x:0,z:0,y:0,heading:0) { x,_,_,_ in x }!
        precondition(bank.roll < -0.7 && abs(bank.pitch)<0.0001)
        let none = TerrainSupport.sample(x:0,z:0,y:0,heading:0) { _,_,_,_ in nil }
        precondition(none == nil)
        print("four-wheel flat, ramp, bank, and missing-ground checks passed")
    }
}
