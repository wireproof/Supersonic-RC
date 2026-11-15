import SceneKit
import UIKit

/// Loads geometry and texture data decoded from the supplied Director movie.
enum RecoveredScene {
    static func load(_ name: String, excluding: Set<String> = []) throws -> SCNNode {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else { throw NSError(domain: "RecoveredScene", code: 1) }
        let scene = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: Any]
        let textureEntries = scene["textures"] as? [[String: Any]] ?? []
        var textures: [String: UIImage] = [:]
        for entry in textureEntries {
            if let id = entry["id"] as? String, let b64 = entry["base64"] as? String, let bytes = Data(base64Encoded: b64), let image = UIImage(data: bytes) { textures[id] = image }
        }
        print("RECOVERY \(name): decoded \(textures.count)/\(textureEntries.count) texture images")
        var materials: [String: SCNMaterial] = [:]
        for entry in scene["materials"] as? [[String: Any]] ?? [] {
            guard let id = entry["id"] as? String else { continue }
            let m = SCNMaterial(); m.lightingModel = .constant; m.isDoubleSided = true
            if let tex = entry["baseColorTextureId"] as? String, let image = textures[tex] { m.diffuse.contents = image; m.diffuse.wrapS = .repeat; m.diffuse.wrapT = .repeat }
            else if let c = entry["color"] as? [CGFloat], c.count >= 3 { m.diffuse.contents = UIColor(red:c[0], green:c[1], blue:c[2], alpha:c.count > 3 ? c[3] : 1) }
            m.roughness.contents = 0.8; materials[id] = m
        }
        var meshes: [String: SCNGeometry] = [:]
        for entry in scene["meshes"] as? [[String: Any]] ?? [] {
            guard let id = entry["id"] as? String, let positions = entry["positions"] as? [Double], let indices = entry["indices"] as? [UInt32], positions.count % 3 == 0 else { continue }
            let vertices = stride(from: 0, to: positions.count, by: 3).map { SCNVector3(Float(positions[$0]), Float(positions[$0+1]), Float(positions[$0+2])) }
            var sources = [SCNGeometrySource(vertices: vertices)]
            if let normals = entry["normals"] as? [Double], normals.count == positions.count {
                sources.append(SCNGeometrySource(normals: stride(from:0,to:normals.count,by:3).map { SCNVector3(Float(normals[$0]),Float(normals[$0+1]),Float(normals[$0+2])) }))
            }
            if let uvs = entry["uvs"] as? [Double], uvs.count == vertices.count * 2 {
                sources.append(SCNGeometrySource(textureCoordinates: stride(from:0,to:uvs.count,by:2).map { CGPoint(x:CGFloat(uvs[$0]),y:CGFloat(1 - uvs[$0+1])) }))
            }
            var elements: [SCNGeometryElement] = []; var applied: [SCNMaterial] = []
            for group in entry["groups"] as? [[String: Any]] ?? [] {
                guard let start = group["start"] as? Int, let count = group["count"] as? Int, start >= 0, count > 0, (start+count)*3 <= indices.count else { continue }
                let part = Array(indices[(start*3)..<((start+count)*3)])
                elements.append(SCNGeometryElement(indices: part, primitiveType: .triangles))
                applied.append(materials[group["materialId"] as? String ?? ""] ?? SCNMaterial())
            }
            if elements.isEmpty { elements = [SCNGeometryElement(indices:indices, primitiveType:.triangles)]; applied = [materials[entry["materialId"] as? String ?? ""] ?? SCNMaterial()] }
            let geo = SCNGeometry(sources:sources, elements:elements); geo.materials = applied; meshes[id] = geo
        }
        print("RECOVERY \(name): decoded \(meshes.count) meshes and \(materials.count) materials")
        func node(_ dict: [String: Any]) -> SCNNode {
            let n = SCNNode(); n.name = dict["name"] as? String
            if let a = dict["transform"] as? [Float], a.count == 16 {
                n.transform = SCNMatrix4(m11:a[0],m12:a[1],m13:a[2],m14:a[3],m21:a[4],m22:a[5],m23:a[6],m24:a[7],m31:a[8],m32:a[9],m33:a[10],m34:a[11],m41:a[12],m42:a[13],m43:a[14],m44:a[15])
            }
            if let name = n.name, excluding.contains(name.lowercased()) { n.isHidden = true }
            if let ids = dict["meshIds"] as? [String] { for id in ids { if let geometry = meshes[id] { n.addChildNode(SCNNode(geometry:geometry)) } } }
            for child in dict["children"] as? [[String: Any]] ?? [] { n.addChildNode(node(child)) }
            return n
        }
        guard let root = scene["root"] as? [String:Any] else { throw NSError(domain:"RecoveredScene",code:2) }
        return node(root)
    }
}
