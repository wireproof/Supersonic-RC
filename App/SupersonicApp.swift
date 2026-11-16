import SwiftUI
import SceneKit
import QuartzCore
import simd

@main struct SupersonicApp: App {
    var body: some Scene { WindowGroup { GameScreen().persistentSystemOverlays(.hidden) } }
}

final class DriveScene: NSObject, ObservableObject, SCNSceneRendererDelegate {
    let scene = SCNScene()
    let car = SCNNode()
    let camera = SCNNode()
    let inputs = InputMixer()
    lazy var externalInput = ExternalInput(mixer: inputs)
    let bodyTilt = SCNNode()
    var throttle: Float = 0
    var steer: Float = 0
    var speed: Float = 0
    var driveDynamics = DriveDynamics()
    var heading: Float = 0
    var lastTime: TimeInterval = 0
    var verticalMotion = VerticalMotion(height: 3.3866)
    var lastTelemetry: TimeInterval = 0
    var frameCount = 0
    var wallContacts = 0
    var cyclePhase = 0
    var reverseStartZ: Float = 0
    var reverseDistance: Float = 0
    var testMaxHeight: Float = -.greatestFiniteMagnitude
    var testGroundedFrames = 0
    var recoveredWorld: SCNNode?
    let groundIndex = GroundIndex.load()
    let wallIndex = WallIndex.load()
    var wheelNodes: [SCNNode] = []
    @Published var speedDisplay = 0
    @Published var accelerating = false
    @Published var paused = false

    override init() {
        super.init()
        _ = externalInput
        scene.background.contents = UIColor(red: 0.32, green: 0.53, blue: 0.68, alpha: 1)
        let ambient = SCNLight(); ambient.type = .ambient; ambient.intensity = 220
        let an = SCNNode(); an.light = ambient; scene.rootNode.addChildNode(an)
        let sun = SCNLight(); sun.type = .directional; sun.intensity = 700; sun.castsShadow = true; sun.shadowSampleCount = 8
        let sn = SCNNode(); sn.light = sun; sn.eulerAngles = SCNVector3(-0.85, 0.55, 0); scene.rootNode.addChildNode(sn)
        // The original movie uses Z-up and centimetre-like units. The decoded root
        // carries the Z-up to Y-up conversion; the outer node scales the whole scene.
        if let world = try? RecoveredScene.load("world", excluding:["car", "arrow"]) {
            world.scale = SCNVector3(0.01,0.01,0.01); world.isHidden = ProcessInfo.processInfo.arguments.contains("--car-preview"); scene.rootNode.addChildNode(world); recoveredWorld = world
        }
        scene.rootNode.addChildNode(car)
        car.position = SCNVector3(37.9017, 3.3866, 56.9619)
        if ProcessInfo.processInfo.arguments.contains("--warehouse-ramp-test") {
            car.position = SCNVector3(34, 5.9082674, -21)
            verticalMotion.reset(height: car.position.y)
        }
        car.addChildNode(bodyTilt)
        if let model = try? RecoveredScene.load("car") {
            model.scale = SCNVector3(0.0017,0.0017,0.0017)
            model.eulerAngles.y = .pi
            bodyTilt.addChildNode(model)
            wheelNodes = (1...4).compactMap { model.childNode(withName: "Wheel\($0)", recursively: true) }
            print("RECOVERED-CAR: loaded child count = \(model.childNodes.count)")
        }
        camera.camera = SCNCamera(); camera.camera?.zNear = 0.02; camera.camera?.zFar = 300; camera.camera?.fieldOfView = 62
        scene.rootNode.addChildNode(camera); updateCamera()
    }
    func box(_ name:String, size:(CGFloat,CGFloat,CGFloat), position:(Float,Float,Float), color:UIColor, parent:SCNNode) {
        let b = SCNBox(width:size.0,height:size.1,length:size.2,chamferRadius:0.04); b.firstMaterial?.diffuse.contents = color
        let n = SCNNode(geometry:b); n.name = name; n.position = SCNVector3(position.0,position.1,position.2); parent.addChildNode(n)
    }
    func updateCamera() {
        camera.position = SCNVector3(car.position.x - sin(heading)*0.75, car.position.y + 0.45, car.position.z + cos(heading)*0.75)
        camera.look(at: SCNVector3(car.position.x,car.position.y + 0.06,car.position.z))
    }
    func reset() { car.position = SCNVector3(37.9017,3.3866,56.9619); heading = 0; speed = 0; driveDynamics.reset(); verticalMotion.reset(height: 3.3866); bodyTilt.eulerAngles = SCNVector3Zero; updateCamera() }
    // The four sample positions come from the original wheel offsets. This is
    // a visual/support approximation, not the original Havok suspension.
    func terrainSupport() -> TerrainSupport.Result? {
        guard let world = recoveredWorld, !world.isHidden, let index = groundIndex else { return nil }
        let p = car.position
        return TerrainSupport.sample(x: p.x, z: p.z, y: p.y, heading: heading) { x,z,upper,lower in
            index.height(x:x, z:z, below:upper, above:lower)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard lastTime > 0 else { lastTime = time; return }
        let dt = Float(min(time-lastTime, 0.04)); lastTime = time
        if paused { return }
        if !ProcessInfo.processInfo.arguments.contains("--drive-test") && !ProcessInfo.processInfo.arguments.contains("--drive-cycle-test") && !ProcessInfo.processInfo.arguments.contains("--warehouse-ramp-test") {
            let current = inputs.snapshot()
            steer = current.steer; throttle = current.throttle
        }
        if ProcessInfo.processInfo.arguments.contains("--drive-cycle-test") {
            if cyclePhase == 0 { throttle = 1 }
            else if cyclePhase == 1 {
                throttle = -1
                reverseDistance = abs(car.position.z - reverseStartZ)
                if reverseDistance >= 0.75 { cyclePhase = 2; throttle = 0 }
            } else { throttle = 0 }
        }
        if ProcessInfo.processInfo.arguments.contains("--warehouse-ramp-test") { throttle = 1 }
        driveDynamics.step(dt: dt, throttle: throttle, steer: steer)
        speed = driveDynamics.speed
        heading += driveDynamics.headingRate * dt
        car.eulerAngles.y = heading
        let dx = sin(heading) * speed * dt
        let dz = -cos(heading) * speed * dt
        let step = sqrt(dx * dx + dz * dz)
        if step > 0.00001, let walls = wallIndex {
            let margin: Float = 0.13
            let rayLength = step + margin
            let origin = SIMD3<Float>(car.position.x, car.position.y + 0.06, car.position.z)
            let end = origin + SIMD3<Float>(dx / step * rayLength, 0, dz / step * rayLength)
            if let fraction = walls.firstHit(from: origin, to: end, halfWidth: 0.095) {
                let allowed = max(0, min(step, fraction * rayLength - margin))
                car.position.x += dx / step * allowed
                car.position.z += dz / step * allowed
                if allowed < step {
                    speed = 0
                    driveDynamics.stop()
                    wallContacts += 1
                    if ProcessInfo.processInfo.arguments.contains("--drive-cycle-test"), cyclePhase == 0 {
                        cyclePhase = 1; reverseStartZ = car.position.z
                    }
                }
            } else {
                car.position.x += dx; car.position.z += dz
            }
        } else {
            car.position.x += dx; car.position.z += dz
        }
        // The recovered car keeps separate wheel nodes; roll them by the
        // distance travelled. Radius remains provisional until original comparison.
        for wheel in wheelNodes { wheel.eulerAngles.x -= speed * dt / 0.05 }
        let support = terrainSupport()
        let measuredGround = support?.height
        verticalMotion.step(dt: dt, ground: measuredGround)
        car.position.y = verticalMotion.height
        testMaxHeight = max(testMaxHeight, car.position.y)
        if verticalMotion.grounded { testGroundedFrames += 1 }
        if let support = support, verticalMotion.grounded {
            let blend = min(1, dt * 8)
            bodyTilt.eulerAngles.x += (support.pitch - bodyTilt.eulerAngles.x) * blend
            bodyTilt.eulerAngles.z += (support.roll - bodyTilt.eulerAngles.z) * blend
        }
        car.position.x = max(-58,min(53,car.position.x)); car.position.z = max(-88,min(84,car.position.z))
        updateCamera()
        frameCount += 1
        if ProcessInfo.processInfo.arguments.contains("--telemetry-test"), time - lastTelemetry >= 1 {
            lastTelemetry = time
            let sample: [String: Any] = ["x": car.position.x, "y": car.position.y, "z": car.position.z,
                                         "ground": measuredGround as Any? ?? NSNull(), "speed": speed,
                                         "verticalSpeed": verticalMotion.velocity, "grounded": verticalMotion.grounded, "contacts": support?.contacts ?? 0,
                                         "pitch": bodyTilt.eulerAngles.x, "roll": bodyTilt.eulerAngles.z, "frames": frameCount,
                                         "wallContacts": wallContacts, "cyclePhase": cyclePhase, "reverseDistance": reverseDistance, "wheelNodes": wheelNodes.count,
                                         "maxHeight": testMaxHeight, "groundedFrames": testGroundedFrames]
            if let data = try? JSONSerialization.data(withJSONObject: sample, options: [.sortedKeys]) {
                try? data.write(to: FileManager.default.temporaryDirectory.appendingPathComponent("drive-telemetry.json"), options: .atomic)
            }
        }
        let value = Int(abs(speed)*20)
        let engineOn = abs(throttle) > 0.05
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.speedDisplay != value { self.speedDisplay = value }
            if self.accelerating != engineOn { self.accelerating = engineOn }
        }
    }
}

struct GameScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var game = DriveScene()
    @State private var audio = GameAudio()
    @State private var started = ProcessInfo.processInfo.arguments.contains("--autostart")
    var body: some View {
        ZStack {
            SceneView(scene:game.scene, pointOfView:game.camera, options:[.autoenablesDefaultLighting, .rendersContinuously], delegate:game)
                .ignoresSafeArea()
            if !started {
                Color.black.opacity(0.72).ignoresSafeArea()
                VStack(spacing:10) {
                    Image("Title").resizable().scaledToFit().frame(maxHeight:190).clipShape(RoundedRectangle(cornerRadius:12))
                    Text("FREE DRIVE · EARLY PROTOTYPE").font(.caption.bold()).tracking(2).foregroundStyle(.orange)
                    Button("START DRIVING") { started = true }.buttonStyle(ActionButton())
                    Text("Original world and handling are still being recovered.").font(.caption).foregroundStyle(.white.opacity(0.8))
                }.padding()
            } else {
                VStack {
                    HStack(alignment:.top) {
                        VStack(alignment:.leading,spacing:2) { Text("FREE DRIVE").font(.headline.bold()); Text("PROTOTYPE").font(.caption2.bold()).foregroundStyle(.orange) }
                        Spacer()
                        Text("\(game.speedDisplay)  SPEED").font(.system(.headline,design:.monospaced).bold())
                        Button("RESET") { game.reset() }.font(.caption.bold()).padding(10).background(.black.opacity(0.5),in:Capsule())
                        Button(game.paused ? "PLAY" : "PAUSE") { game.paused.toggle() }.font(.caption.bold()).padding(10).background(.black.opacity(0.5),in:Capsule())
                    }.foregroundStyle(.white)
                    Spacer()
                    HStack(alignment:.bottom) {
                        HStack(spacing:12) { holdButton("chevron.left") { game.inputs.setTouch(.left, down: $0) }; holdButton("chevron.right") { game.inputs.setTouch(.right, down: $0) } }
                        Spacer()
                        HStack(spacing:12) { holdButton("arrow.down") { game.inputs.setTouch(.reverse, down: $0) }; holdButton("arrow.up") { game.inputs.setTouch(.forward, down: $0) } }
                    }
                }.padding(.horizontal,24).padding(.vertical,14)
                if game.paused { Text("PAUSED").font(.largeTitle.bold()).foregroundStyle(.white).shadow(radius:4) }
            }
        }.preferredColorScheme(.dark).onChange(of:scenePhase) { phase in if phase != .active { game.inputs.clearTouch(); game.inputs.clearKeyboard(); game.inputs.setController(steer:0, throttle:0); if started { game.paused = true }; audio.setPlaying(false) } }.onChange(of:started) { value in game.paused = !value; audio.setPlaying(value) }.onChange(of:game.paused) { paused in audio.setPlaying(started && !paused); audio.setAccelerating(game.accelerating, playing: started && !paused) }.onChange(of:game.accelerating) { active in audio.setAccelerating(active, playing: started && !game.paused) }.onAppear { game.paused = !started; if started { audio.setPlaying(true) }; if ProcessInfo.processInfo.arguments.contains("--drive-test") { game.throttle = 1 } }
    }
    func holdButton(_ icon:String, change:@escaping (Bool)->Void) -> some View {
        HoldControl(icon: icon, change: change).frame(width:64,height:64)
    }
}
struct ActionButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline.bold()).foregroundStyle(.black).padding(.horizontal,30).padding(.vertical,12)
            .background(Color.orange.opacity(configuration.isPressed ? 0.7 : 1),in:Capsule())
    }
}
