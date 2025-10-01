import ARKit
import RealityKit
import FocusEntity

class CustomARView: ARView
{
    
    var focusEntity: FocusEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
        
        configure()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        // Habilitar características avanzadas para mejor persistencia
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        session.run(config)
    }
    
    /// Reinicia la sesión AR con configuración por defecto
    func resetSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}
