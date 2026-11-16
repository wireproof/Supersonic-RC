import Foundation

@main struct InputTests {
    static func main() {
        let m = InputMixer()
        m.setController(steer: 0.5, throttle: 0.7)
        precondition(m.snapshot().steer == 0.5 && m.snapshot().throttle == 0.7)
        m.setKeyboard(.left,down:true); m.setTouch(.forward,down:true)
        precondition(m.snapshot().steer == -1 && m.snapshot().throttle == 1)
        m.setKeyboard(.right,down:true)
        precondition(m.snapshot().steer == 0)
        m.setTouch(.forward,down:false); m.clearKeyboard()
        precondition(m.snapshot().steer == 0.5 && m.snapshot().throttle == 0.7)
        m.setController(steer:0,throttle:0)
        precondition(m.snapshot().steer == 0 && m.snapshot().throttle == 0)
        print("input mixing, opposing keys, release and disconnect checks passed")
    }
}
