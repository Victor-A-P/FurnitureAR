import SwiftUI
import RealityKit
import Combine

class PlacementSettings: ObservableObject
{
///Variable que es asignada cuando el usuario selecciona un modelo de BrowseView
    @Published var selectedModel: Model?
    {
        willSet(newValue)
        {
            print("Setting selectedModel to \(String(describing: newValue?.name) )")
        }
    }
    
/// Variable que obtiene su valor de la variable `selectedModel` una vez que el usuario confirma al seleccionar el boton checkmar en `PlacementView`
    @Published var confirmedModel: Model?
    {
        willSet(newValue)
        {
            guard let model = newValue
            else
            {
                return
            }
            
            print("Setting confirmedModel to \(model.name)")
        }
    }
    
    // Esta propiedad conserva el objeto cancelable para nuestras Eventos en la escena; actualiza 'subscriber'
    var sceneObserver: Cancellable?
    
}
