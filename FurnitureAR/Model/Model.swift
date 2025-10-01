import SwiftUI
import Combine
import RealityKit


class Model
{
    var name: String
    var category: ModelCategory
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0)
    {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
    }
    
    func asyncLoadModelEntity()
    {
        let filename = self.name + ".usdz"
        print("\(filename)")
        //self.cancellable = ModelEntity.loadModelAsync(named: filename)
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion:
                    { loadCompletion in
                        switch loadCompletion
                        {
                            case .failure(let error):
                            print("Failed to load \(filename): \(error.localizedDescription)")
                            case .finished:
                                break
                        }
                    }, receiveValue:
                            { modelEntity in
                                self.modelEntity = modelEntity
                                self.modelEntity?.scale *= self.scaleCompensation
                                
                                print("Model entity for \(self.name) loaded")
                            })
    }
}
