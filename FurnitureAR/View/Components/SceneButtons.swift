import SwiftUI
import Combine
import CoreLocation

struct SceneButtons: View
{
    
    @EnvironmentObject var sceneManager: SceneManager
    @StateObject private var locationService = LocationService()
    
    @State private var showSaveAlert = false
    @State private var showLoadAlert = false
    @State private var isWaitingForLocation = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View
    {
        GlassEffectContainer(spacing: 22)
        {
            HStack(alignment: .center, spacing: 16)
            {
                
                // Botón Guardar
                ControlButton(image: "icloud.and.arrow.up")
                {
                    handleSaveButton()
                }
                .disabled(!sceneManager.isPersistenceAvailable || isWaitingForLocation)
                .opacity(sceneManager.isPersistenceAvailable && !isWaitingForLocation ? 1.0 : 0.5)
                .overlay(
                    Group {
                            if isWaitingForLocation
                            {
                                ProgressView()
                                    .tint(.white)
                            }
                        } )
                
                // Botón Cargar
                ControlButton(image: "icloud.and.arrow.down")
                {
                    showLoadAlert = true
                }
                .disabled(sceneManager.scenePersistenceData == nil)
                .opacity(sceneManager.scenePersistenceData != nil ? 1.0 : 0.5)
                
               
                
                // Botón Eliminar
                ControlButton(image: "trash.fill")
                {
                    sceneManager.clearPersistedScene()
                }
                .disabled(sceneManager.scenePersistenceData == nil)
                .opacity(sceneManager.scenePersistenceData != nil ? 1.0 : 0.5)
            }
        }
        .onAppear
        {
            // Iniciar servicio de ubicación
            if locationService.authorizationStatus == .notDetermined
            {
               locationService.requestPermission()
            } else if locationService.isAuthorized
                {
                   locationService.startUpdatingLocation()
                }
        }
        
        .alert("Guardar Escena", isPresented: $showSaveAlert)
        {
            Button("Guardar sin ubicación")
            {
                saveWithoutLocation()
            }
            
            Button("Permitir ubicación")
            {
                locationService.requestPermission()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                {
                    if locationService.isAuthorized
                    {
                        locationService.startUpdatingLocation()
                    }
                }
            }
            
            Button("Cancelar", role: .cancel) {}

        } message:
            {
                Text("Para guardar la ubicación de tu escena, necesitamos acceso a tu ubicación. ¿Deseas permitirlo?")
            }
        
        .alert("Cargar Escena", isPresented: $showLoadAlert)
        {
            Button("Cargar")
            {
                sceneManager.loadPersistedScene()
            }
            
            Button("Cancelar", role: .cancel) {}
            
        } message:
            {
                if let address = sceneManager.savedAddress
                {
                    Text("Se cargará la escena guardada en:\n\(address)")
                } else
                    {
                        Text("¿Deseas cargar la escena guardada?")
                    }
            }
        
    }
}

 #Preview
{
     SceneButtons()
         .environmentObject(SceneManager())
}



// MARK: - Save Functions
extension SceneButtons
{
    private func handleSaveButton()
    {
            // Caso 1: Sin autorización - preguntar
       if !locationService.isAuthorized
       {
            showSaveAlert = true
            return
        }
            
            // Caso 2: Autorizado pero sin ubicación - esperar
       if locationService.currentLocation == nil
       {
            isWaitingForLocation = true
            print("Esperando ubicación...")
            
            // Timeout de 8 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 8)
           {
               if isWaitingForLocation
               {
                    print("Timeout esperando ubicación - guardando sin ubicación")
                    saveWithoutLocation()
                    isWaitingForLocation = false
                }
            }
                
            // Observar cambios en currentLocation usando Combine
            locationService.$currentLocation
                .compactMap { $0 } // Solo valores no-nil
                .first() // Tomar el primer valor válido
                .sink { location in
                    if isWaitingForLocation
                    {
                        print("Ubicación obtenida: \(location.coordinate)")
                        
                        // Esperar 1.5 segundos más para el geocoding de la dirección
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                        {
                            if isWaitingForLocation
                            {
                                isWaitingForLocation = false
                                saveWithLocation()
                            }
                        }
                    }
                }
               .store(in: &cancellables)
                
                return
       }
            
        // Caso 3: Ya hay ubicación - guardar inmediatamente
        saveWithLocation()
    }
       
       

    private func saveWithLocation()
    {
        print("Guardando con ubicación: \(String(describing: locationService.currentLocation?.coordinate))")
        print("Dirección: \(String(describing: locationService.currentAddress))")
        
        sceneManager.saveCurrentScene(
            location: locationService.currentLocation,
            address: locationService.currentAddress
        )
    }



    private func saveWithoutLocation()
    {
        print("Guardando sin ubicación")
        sceneManager.saveCurrentScene(location: nil, address: nil)
    }
    
}
