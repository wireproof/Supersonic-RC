import SwiftUI
import SceneKit
import QuartzCore

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
    let wheels: [SCNNode]
    @Published var speedDisplay = 0
    @Published var paused = false

    override init() {
        var wheelNodes: [SCNNode] = []
        for _ in 0..<4 { wheelNodes.append(SCNNode()) }
        wheels = wheelNodes
        super.init()
        scene.background.contents = UIColor(red: 0.32, green: 0.53, blue: 0.68, alpha: 1)
        let ambient = SCNLight(); ambient.type = .ambient; ambient.intensity = 500
        let an = SCNNode(); an.light = ambient; scene.rootNode.addChildNode(an)
        let sun = SCNLight(); sun.type = .directional; sun.intensity = 1600; sun.castsShadow = true; sun.shadowSampleCount = 8
        let sn = SCNNode(); sn.light = sun; sn.eulerAngles = SCNVector3(-0.85, 0.55, 0); scene.rootNode.addChildNode(sn)
        let floor = SCNFloor(); floor.firstMaterial?.diffuse.contents = UIColor(red: 0.23, green: 0.25, blue: 0.25, alpha: 1); floor.firstMaterial?.roughness.contents = 0.92
        scene.rootNode.addChildNode(SCNNode(geometry: floor))
        let gridColor = UIColor(white: 0.35, alpha: 1)
        for i in -10...10 {
            box("grid", size: (0.025, 0.008, 80), position: (Float(i)*4, 0.01, 0), color: gridColor, parent: scene.rootNode)
            box("grid", size: (80, 0.008, 0.025), position: (0, 0.01, Float(i)*4), color: gridColor, parent: scene.rootNode)
        }
        for i in -4...4 {
            box("barrier", size: (8, 0.55, 0.45), position: (Float(i)*8, 0.28, -37), color: i % 2 == 0 ? .systemOrange : .white, parent: scene.rootNode)
            box("barrier", size: (8, 0.55, 0.45), position: (Float(i)*8, 0.28, 37), color: i % 2 == 0 ? .systemOrange : .white, parent: scene.rootNode)
        }
        for (x,z) in [(-11.0,-10.0),(10.0,-18.0),(15.0,9.0),(-15.0,12.0)] {
            let ramp = SCNNode(geometry: SCNBox(width: 7, height: 0.5, length: 6, chamferRadius: 0.08))
            ramp.geometry?.firstMaterial?.diffuse.contents = UIColor.systemOrange
            ramp.position = SCNVector3(x,0.7,z); ramp.eulerAngles.x = -0.18; scene.rootNode.addChildNode(ramp)
        }
        scene.rootNode.addChildNode(car); car.position = SCNVector3(0,0.5,10)
        box("chassis", size:(2.1,0.55,3.6), position:(0,0.25,0), color:.darkGray, parent:car)
        box("body", size:(1.45,0.48,2.35), position:(0,0.7,-0.25), color:.black, parent:car)
        box("stripe", size:(0.34,0.03,2.2), position:(0,0.96,-0.25), color:.systemRed, parent:car)
        box("bumper", size:(2.3,0.17,0.18), position:(0,0.38,-1.9), color:.lightGray, parent:car)
        box("spoiler", size:(2.5,0.15,0.5), position:(0,1.15,1.65), color:.systemRed, parent:car)
        for (i,coord) in [(-1.2,-1.15),(1.2,-1.15),(-1.2,1.15),(1.2,1.15)].enumerated() {
            let wheel = wheels[i]; wheel.geometry = SCNCylinder(radius: 0.68, height: 0.52)
            wheel.geometry?.firstMaterial?.diffuse.contents = UIColor(white:0.08,alpha:1)
            wheel.eulerAngles.z = .pi/2; wheel.position = SCNVector3(coord.0,0.05,coord.1); car.addChildNode(wheel)
            let hub = SCNNode(geometry: SCNCylinder(radius:0.28,height:0.54)); hub.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray; wheel.addChildNode(hub)
        }
        camera.camera = SCNCamera(); camera.camera?.zFar = 300; camera.camera?.fieldOfView = 62
        scene.rootNode.addChildNode(camera); updateCamera()
    }
    func box(_ name:String, size:(CGFloat,CGFloat,CGFloat), position:(Float,Float,Float), color:UIColor, parent:SCNNode) {
        let b = SCNBox(width:size.0,height:size.1,length:size.2,chamferRadius:0.04); b.firstMaterial?.diffuse.contents = color
        let n = SCNNode(geometry:b); n.name = name; n.position = SCNVector3(position.0,position.1,position.2); parent.addChildNode(n)
    }
    func updateCamera() {
        camera.position = SCNVector3(car.position.x - sin(heading)*9, 5.2, car.position.z + cos(heading)*9)
        camera.look(at: SCNVector3(car.position.x,1,car.position.z))
    }
    func reset() { car.position = SCNVector3(0,0.5,10); heading = 0; speed = 0; updateCamera() }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard lastTime > 0 else { lastTime = time; return }
        let dt = Float(min(time-lastTime, 0.04)); lastTime = time
        if paused { return }
        speed += throttle * 17 * dt
        speed *= pow(0.965, dt*60)
        speed = max(-8, min(23,speed))
        heading += steer * min(abs(speed)/5,1) * (speed < 0 ? -1 : 1) * 1.5 * dt
        car.eulerAngles.y = heading
        car.position.x += sin(heading)*speed*dt
        car.position.z -= cos(heading)*speed*dt
        car.position.x = max(-37,min(37,car.position.x)); car.position.z = max(-36,min(36,car.position.z))
        updateCamera()
        let value = Int(abs(speed)*4)
        DispatchQueue.main.async { [weak self] in self?.speedDisplay = value }
    }
}

struct GameScreen: View {
    @StateObject private var game = DriveScene()
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
                        HStack(spacing:12) { holdButton("arrow.down") { game.throttle = $0 ? -1 : 0 }; holdButton("arrow.up") { game.throttle = $0 ? 1 : 0 } }
                    }
                }.padding(.horizontal,24).padding(.vertical,14)
                if game.paused { Text("PAUSED").font(.largeTitle.bold()).foregroundStyle(.white).shadow(radius:4) }
            }
        }.preferredColorScheme(.dark).onChange(of:started) { value in game.paused = !value }.onAppear { game.paused = !started; if ProcessInfo.processInfo.arguments.contains("--drive-test") { game.throttle = 1 } }
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
