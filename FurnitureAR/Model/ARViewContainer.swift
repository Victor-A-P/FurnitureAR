import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable
{
    
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sceneManager: SceneManager
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero)
        
        // Asignar arView al scene manager
        sceneManager.arView = arView
        
        // Configurar delegado de sesión AR
        arView.session.delegate = context.coordinator
        
        // Subscriber para actualizar escena
        placementSettings.sceneObserver = arView.scene.subscribe(
            to: SceneEvents.Update.self
        ) { _ in
            self.updateScene(for: arView)
        }
        
        // Cargar escena automáticamente si existe
        if let data = sceneManager.scenePersistenceData {
            ScenePersistenceHelper.loadScene(for: arView, with: data) { success in
                DispatchQueue.main.async {
                    if success {
                        sceneManager.syncAnchorEntitiesFromScene()
                    } else {
                        print("Carga automática fallida")
                    }
                }
            }
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Scene Update
    
    private func updateScene(for arView: CustomARView) {
        // Actualizar focus entity
        arView.focusEntity?.isEnabled = placementSettings.selectedModel != nil
        
        // Colocar modelo confirmado
        if let confirmedModel = placementSettings.confirmedModel,
           let modelEntity = confirmedModel.modelEntity {
            place(modelEntity, in: arView)
            placementSettings.confirmedModel = nil
        }
    }
    
    private func place(_ modelEntity: ModelEntity, in arView: ARView) {
        let cloneEntity = modelEntity.clone(recursive: true)
        
        cloneEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: cloneEntity)
        
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(cloneEntity)
        
        arView.scene.addAnchor(anchorEntity)
        sceneManager.anchorEntities.append(anchorEntity)
        
        print("Modelo añadido a la escena")
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            DispatchQueue.main.async {
                self.parent.sceneManager.updateARSessionInfo(frame: frame)
            }
            
            // Detectar cuando relocalizacion es exitosa
            if self.parent.sceneManager.isRelocalizing &&
               frame.camera.trackingState == .normal &&
               (frame.worldMappingStatus == .mapped || frame.worldMappingStatus == .extending) {
                DispatchQueue.main.async {
                    self.parent.sceneManager.handleRelocationSuccess()
                }
            }
        }
        
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            print("Tracking state: \(camera.trackingState)")
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            DispatchQueue.main.async {
                self.parent.sceneManager.sessionMessage = "Sesión interrumpida"
            }
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            DispatchQueue.main.async {
                self.parent.sceneManager.sessionMessage = "Sesión reanudada"
            }
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            guard let arError = error as? ARError else {
                DispatchQueue.main.async {
                    self.parent.sceneManager.sessionMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            let errorMessage: String
            switch arError.code {
            case .cameraUnauthorized:
                errorMessage = "Acceso a cámara denegado"
            case .worldTrackingFailed:
                errorMessage = "Tracking falló - reinicia la sesión"
            default:
                errorMessage = arError.localizedDescription
            }
            
            DispatchQueue.main.async {
                self.parent.sceneManager.sessionMessage = errorMessage
            }
        }
    }
}
