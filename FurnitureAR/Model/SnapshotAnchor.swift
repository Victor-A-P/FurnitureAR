import ARKit
import CoreLocation

/// Anclaje personalizado para guardar snapshot e información de ubicación
class SnapshotAnchor: ARAnchor, @unchecked Sendable {
    
    let imageData: Data
    let location: CLLocation?
    let address: String?
    
    // Inicializador para capturar desde ARView
    convenience init?(capturing session: ARSession, location: CLLocation? = nil, address: String? = nil) {
        guard let frame = session.currentFrame else { return nil }
        
        let image = CIImage(cvPixelBuffer: frame.capturedImage)
        let orientation = CGImagePropertyOrientation(cameraOrientation: UIDevice.current.orientation)
        
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let data = context.jpegRepresentation(
            of: image.oriented(orientation),
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.7]
        ) else { return nil }
        
        self.init(imageData: data, transform: frame.camera.transform, location: location, address: address)
    }
    
    // Inicializador principal
    init(imageData: Data, transform: simd_float4x4, location: CLLocation?, address: String?) {
        self.imageData = imageData
        self.location = location
        self.address = address
        super.init(name: "snapshot", transform: transform)
    }
    
    // Requerido para copiar anclajes
    required init(anchor: ARAnchor) {
        if let snapshotAnchor = anchor as? SnapshotAnchor {
            self.imageData = snapshotAnchor.imageData
            self.location = snapshotAnchor.location
            self.address = snapshotAnchor.address
        } else {
            self.imageData = Data()
            self.location = nil
            self.address = nil
        }
        super.init(anchor: anchor)
    }
    
    // MARK: - NSSecureCoding
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let snapshot = aDecoder.decodeObject(of: NSData.self, forKey: "snapshot") as? Data else {
            return nil
        }
        self.imageData = snapshot
        
        // Decodificar ubicación si existe
        if let locationData = aDecoder.decodeObject(of: NSData.self, forKey: "location") as? Data {
            self.location = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: locationData)
        } else {
            self.location = nil
        }
        
        self.address = aDecoder.decodeObject(of: NSString.self, forKey: "address") as? String
        
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageData, forKey: "snapshot")
        
        // Codificar ubicación si existe
        if let location = location,
           let locationData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true) {
            aCoder.encode(locationData, forKey: "location")
        }
        
        if let address = address {
            aCoder.encode(address as NSString, forKey: "address")
        }
    }
}

// MARK: - CGImagePropertyOrientation Extension

extension CGImagePropertyOrientation {
    init(cameraOrientation: UIDeviceOrientation) {
        switch cameraOrientation {
        case .portrait:
            self = .right
        case .portraitUpsideDown:
            self = .left
        case .landscapeLeft:
            self = .up
        case .landscapeRight:
            self = .down
        default:
            self = .right
        }
    }
}
