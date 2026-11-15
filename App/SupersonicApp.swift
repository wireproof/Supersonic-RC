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
    var throttle: Float = 0
    var steer: Float = 0
    var speed: Float = 0
    var heading: Float = 0
    var lastTime: TimeInterval = 0
    var verticalSpeed: Float = 0
    var lastTelemetry: TimeInterval = 0
    var frameCount = 0
    var recoveredWorld: SCNNode?
    let groundIndex = GroundIndex.load()
    let wallIndex = WallIndex.load()
    let wheels: [SCNNode]
    @Published var speedDisplay = 0
    @Published var paused = false

    override init() {
        var wheelNodes: [SCNNode] = []
        for _ in 0..<4 { wheelNodes.append(SCNNode()) }
        wheels = wheelNodes
        super.init()
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
        if let model = try? RecoveredScene.load("car") {
            model.scale = SCNVector3(0.0017,0.0017,0.0017)
            model.eulerAngles.y = .pi
            car.addChildNode(model)
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
    func reset() { car.position = SCNVector3(37.9017,3.3866,56.9619); heading = 0; speed = 0; verticalSpeed = 0; updateCamera() }
    // Vertical contact is provisional; unlike the original four-wheel Havok
    // simulation this single ray only prevents free fall through the surface.
    func groundHeight() -> Float? {
        guard let world = recoveredWorld, !world.isHidden else { return nil }
        let p = car.position
        return groundIndex?.height(x: p.x, z: p.z, below: p.y + 0.25, above: p.y - 5)
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard lastTime > 0 else { lastTime = time; return }
        let dt = Float(min(time-lastTime, 0.04)); lastTime = time
        if paused { return }
        speed += throttle * 3.5 * dt
        speed *= pow(0.965, dt*60)
        speed = max(-1.6, min(4.6,speed))
        heading += steer * min(abs(speed)/1.0,1) * (speed < 0 ? -1 : 1) * 1.5 * dt
        car.eulerAngles.y = heading
        let dx = sin(heading) * speed * dt
        let dz = -cos(heading) * speed * dt
        let step = sqrt(dx * dx + dz * dz)
        if step > 0.00001, let walls = wallIndex {
            let margin: Float = 0.13
            let rayLength = step + margin
            let origin = SIMD3<Float>(car.position.x, car.position.y + 0.06, car.position.z)
            let end = origin + SIMD3<Float>(dx / step * rayLength, 0, dz / step * rayLength)
            if let fraction = walls.firstHit(from: origin, to: end) {
                let allowed = max(0, min(step, fraction * rayLength - margin))
                car.position.x += dx / step * allowed
                car.position.z += dz / step * allowed
                if allowed < step { speed = 0 }
            } else {
                car.position.x += dx; car.position.z += dz
            }
        } else {
            car.position.x += dx; car.position.z += dz
        }
        verticalSpeed -= 3.5 * dt
        car.position.y += verticalSpeed * dt
        let measuredGround = groundHeight()
        if let ground = measuredGround {
            let carBottomOffset: Float = 0.005
            if car.position.y <= ground + carBottomOffset {
                car.position.y = ground + carBottomOffset
                verticalSpeed = 0
            }
        }
        car.position.x = max(-58,min(53,car.position.x)); car.position.z = max(-88,min(84,car.position.z))
        updateCamera()
        frameCount += 1
        if ProcessInfo.processInfo.arguments.contains("--telemetry-test"), time - lastTelemetry >= 1 {
            lastTelemetry = time
            let sample: [String: Any] = ["x": car.position.x, "y": car.position.y, "z": car.position.z,
                                         "ground": measuredGround as Any? ?? NSNull(), "speed": speed,
                                         "verticalSpeed": verticalSpeed, "frames": frameCount]
            if let data = try? JSONSerialization.data(withJSONObject: sample, options: [.sortedKeys]) {
                try? data.write(to: FileManager.default.temporaryDirectory.appendingPathComponent("drive-telemetry.json"), options: .atomic)
            }
        }
        let value = Int(abs(speed)*20)
        DispatchQueue.main.async { [weak self] in self?.speedDisplay = value }
    }
}

struct GameScreen: View {
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
                        HStack(spacing:12) { holdButton("chevron.left") { game.steer = $0 ? -1 : 0 }; holdButton("chevron.right") { game.steer = $0 ? 1 : 0 } }
                        Spacer()
                        HStack(spacing:12) { holdButton("arrow.down") { game.throttle = $0 ? -1 : 0; audio.setAccelerating($0, playing: !game.paused) }; holdButton("arrow.up") { game.throttle = $0 ? 1 : 0; audio.setAccelerating($0, playing: !game.paused) } }
                    }
                }.padding(.horizontal,24).padding(.vertical,14)
                if game.paused { Text("PAUSED").font(.largeTitle.bold()).foregroundStyle(.white).shadow(radius:4) }
            }
        }.preferredColorScheme(.dark).onChange(of:started) { value in game.paused = !value; audio.setPlaying(value) }.onChange(of:game.paused) { paused in audio.setPlaying(started && !paused) }.onAppear { game.paused = !started; if started { audio.setPlaying(true) }; if ProcessInfo.processInfo.arguments.contains("--drive-test") { game.throttle = 1 } }
    }
    func holdButton(_ icon:String, change:@escaping (Bool)->Void) -> some View {
        Image(systemName:icon).font(.title2.bold()).foregroundStyle(.white).frame(width:64,height:64)
            .background(.black.opacity(0.48),in:Circle()).overlay(Circle().stroke(.white.opacity(0.38),lineWidth:1))
            .contentShape(Circle()).gesture(DragGesture(minimumDistance:0).onChanged { _ in change(true) }.onEnded { _ in change(false) })
    }
}
struct ActionButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline.bold()).foregroundStyle(.black).padding(.horizontal,30).padding(.vertical,12)
            .background(Color.orange.opacity(configuration.isPressed ? 0.7 : 1),in:Capsule())
    }
}
