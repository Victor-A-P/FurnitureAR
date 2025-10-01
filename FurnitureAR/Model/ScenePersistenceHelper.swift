import Foundation
import RealityKit
import ARKit
import CoreLocation

class ScenePersistenceHelper
{
    
    // MARK: - Save Scene
    
    class func saveScene(
        for arView: CustomARView,
        at persistenceURL: URL,
        location: CLLocation?,
        address: String?,
        completion: @escaping (Bool) -> Void
    ) {
        print("Guardando escena en: \(persistenceURL.path)")
        
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Persistencia fallida: No se pudo obtener WorldMap - \(error?.localizedDescription ?? "error desconocido")")
                completion(false)
                return
            }
            
            // Agregar snapshot con ubicación
            guard let snapshotAnchor = SnapshotAnchor(
                capturing: arView.session,
                location: location,
                address: address
            ) else {
                print("Advertencia: No se pudo crear snapshot, guardando sin él")
                saveWorldMap(map, to: persistenceURL, completion: completion)
                return
            }
            
            map.anchors.append(snapshotAnchor)
            saveWorldMap(map, to: persistenceURL, completion: completion)
        }
    }
    
    private class func saveWorldMap(
        _ worldMap: ARWorldMap,
        to url: URL,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: worldMap,
                requiringSecureCoding: true
            )
            try data.write(to: url, options: [.atomic])
            print("Escena guardada exitosamente")
            completion(true)
        } catch {
            print("Error al guardar: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Load Scene
    
    class func loadScene(
        for arView: CustomARView,
        with data: Data,
        completion: @escaping (Bool) -> Void
    ) {
        print("Cargando escena desde sistema de archivos")
        
        do {
            guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: ARWorldMap.self,
                from: data
            ) else {
                print("Carga fallida: No se pudo deserializar ARWorldMap")
                completion(false)
                return
            }
            
            // Remover el snapshot anchor del worldMap
            // (solo lo usamos para visualización, no necesita estar en la escena)
            worldMap.anchors.removeAll { $0 is SnapshotAnchor }
            
            // Configurar sesión con el worldMap
            let configuration = ARWorldTrackingConfiguration()
            configuration.initialWorldMap = worldMap
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.environmentTexturing = .automatic
            
            // Opciones de sesión para relocalizacion
            let options: ARSession.RunOptions = [
                .resetTracking,
                .removeExistingAnchors
            ]
            
            arView.session.run(configuration, options: options)
            
            print("Configuración de relocalizacion aplicada")
            completion(true)
            
        } catch {
            print("Carga fallida: \(error.localizedDescription)")
            completion(false)
        }
    }
}
