import SwiftUI
import RealityKit
import ARKit
import Combine
import CoreLocation

class SceneManager: ObservableObject
{
    
    // MARK: - Published Properties
    
    @Published var isPersistenceAvailable: Bool = false
    @Published var anchorEntities: [AnchorEntity] = []
    @Published var scenePersistenceData: Data?
    @Published var snapshotImage: UIImage?
    @Published var savedLocation: CLLocation?
    @Published var savedAddress: String?
    
    // Estados de AR
    @Published var worldMappingStatus: ARFrame.WorldMappingStatus = .notAvailable
    @Published var trackingState: ARCamera.TrackingState = .notAvailable
    @Published var isRelocalizing: Bool = false
    @Published var sessionMessage: String = ""
    
    // MARK: - Properties
    
    var shouldSaveSceneToFileSystem: Bool = false
    var shouldLoadSceneFromFileSystem: Bool = false
    
    weak var arView: CustomARView?
    
    lazy var persistenceUrl: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("arf.persistence")
        } catch {
            fatalError("Unable to get persistenceURL: \(error.localizedDescription)")
        }
    }()
    
    // MARK: - Initialization
    
    init() {
        refreshPersistenceDataFromDisk()
    }
    
    // MARK: - API para UI
    
    func saveCurrentScene(location: CLLocation?, address: String?) {
        guard let arView else {
            print("Persistencia fallida: arView no está asignado")
            return
        }
        
        ScenePersistenceHelper.saveScene(
            for: arView,
            at: persistenceUrl,
            location: location,
            address: address
        ) { [weak self] success in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.refreshPersistenceDataFromDisk()
                    self.syncAnchorEntitiesFromScene()
                    self.sessionMessage = "Escena guardada exitosamente"
                } else {
                    self.sessionMessage = "Error al guardar la escena"
                }
            }
        }
    }
    
    func loadPersistedScene() {
        guard let arView else {
            print("Carga fallida: arView no está asignado")
            return
        }
        guard let data = scenePersistenceData else {
            print("Carga fallida: no hay datos de persistencia")
            return
        }
        
        isRelocalizing = true
        sessionMessage = "Mueve tu dispositivo a la ubicación del snapshot"
        
        ScenePersistenceHelper.loadScene(for: arView, with: data) { [weak self] success in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.syncAnchorEntitiesFromScene()
                    self.sessionMessage = "Relocalizando escena..."
                } else {
                    self.sessionMessage = "Error al cargar la escena"
                    self.isRelocalizing = false
                }
            }
        }
    }
    
    func clearPersistedScene() {
        do {
            if FileManager.default.fileExists(atPath: persistenceUrl.path) {
                try FileManager.default.removeItem(at: persistenceUrl)
            }
            scenePersistenceData = nil
            snapshotImage = nil
            savedLocation = nil
            savedAddress = nil
            sessionMessage = "Escena eliminada"
        } catch {
            print("Error borrando persistencia: \(error.localizedDescription)")
            sessionMessage = "Error al eliminar escena"
        }
    }
    
    // MARK: - Utilidades
    
    func refreshPersistenceDataFromDisk() {
        guard let data = try? Data(contentsOf: persistenceUrl) else {
            scenePersistenceData = nil
            snapshotImage = nil
            savedLocation = nil
            savedAddress = nil
            return
        }
        
        scenePersistenceData = data
        
        // Extraer snapshot e información de ubicación
        if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: ARWorldMap.self,
            from: data
        ) {
            if let snapshotAnchor = worldMap.anchors.compactMap({ $0 as? SnapshotAnchor }).first {
                snapshotImage = UIImage(data: snapshotAnchor.imageData)
                savedLocation = snapshotAnchor.location
                savedAddress = snapshotAnchor.address
            }
        }
    }
    
    func syncAnchorEntitiesFromScene() {
        guard let arView else { return }
        let anchors = arView.scene.anchors
        self.anchorEntities = anchors.compactMap { $0 as? AnchorEntity }
    }
    
    func updateARSessionInfo(frame: ARFrame) {
        worldMappingStatus = frame.worldMappingStatus
        trackingState = frame.camera.trackingState
        
        // Actualizar disponibilidad de persistencia
        switch worldMappingStatus {
        case .mapped, .extending:
            isPersistenceAvailable = !anchorEntities.isEmpty
        default:
            isPersistenceAvailable = false
        }
        
        // Actualizar mensaje de sesión
        updateSessionMessage(for: frame)
    }
    
    private func updateSessionMessage(for frame: ARFrame) {
        let hasData = scenePersistenceData != nil
        let hasAnchors = frame.anchors.contains(where: { !($0 is SnapshotAnchor) })
        
        switch (trackingState, worldMappingStatus) {
        case (.normal, .mapped), (.normal, .extending):
            if hasAnchors {
                sessionMessage = "Toca 'Guardar' para guardar la experiencia"
            } else {
                sessionMessage = "Toca la pantalla para colocar un objeto"
            }
            
        case (.normal, _) where hasData && !isRelocalizing:
            sessionMessage = "Muévete para mapear o toca 'Cargar' para cargar"
            
        case (.normal, _) where !hasData:
            sessionMessage = "Muévete para mapear el entorno"
            
        case (.limited(.relocalizing), _) where isRelocalizing:
            sessionMessage = "Mueve el dispositivo a la ubicación del snapshot"
            
        case (.limited(.initializing), _):
            sessionMessage = "Inicializando sesión AR..."
            
        case (.limited(.excessiveMotion), _):
            sessionMessage = "Mueve el dispositivo más lentamente"
            
        case (.limited(.insufficientFeatures), _):
            sessionMessage = "Apunta a un área con más detalles"
            
        case (.notAvailable, _):
            sessionMessage = "Tracking no disponible"
            
        default:
            sessionMessage = "Estado: \(trackingState.description)"
        }
    }
    
    func handleRelocationSuccess() {
        isRelocalizing = false
        sessionMessage = "Relocalizacion completada"
    }
}

// MARK: - Extensions para descripciones

extension ARFrame.WorldMappingStatus {
    var description: String {
        switch self {
        case .notAvailable: return "No Disponible"
        case .limited: return "Limitado"
        case .extending: return "Extendiendo"
        case .mapped: return "Mapeado"
        @unknown default: return "Desconocido"
        }
    }
}

extension ARCamera.TrackingState {
    var description: String {
        switch self {
        case .normal: return "Normal"
        case .notAvailable: return "No Disponible"
        case .limited(.initializing): return "Inicializando"
        case .limited(.excessiveMotion): return "Movimiento Excesivo"
        case .limited(.insufficientFeatures): return "Características Insuficientes"
        case .limited(.relocalizing): return "Relocalizando"
        case .limited: return "Limitado"
        @unknown default: return "Desconocido"
        }
    }
}
