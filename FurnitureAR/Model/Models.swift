import SwiftUI
import Combine
import RealityKit


struct Models
{
    var all: [Model] = []
    
    init()
    {
        //RestRoom
        let conjuntoTv = Model(name: "conjuntoTv", category: .rest, scaleCompensation: 2.0/100)
        let muebleTV = Model(name: "muebleTV", category: .rest, scaleCompensation:  3.0/100)
        let mueblesTV = Model(name: "mueblesTV", category: .rest, scaleCompensation: 1.0/100)
        
        self.all += [conjuntoTv,muebleTV,mueblesTV]
        
        //decor
        let cofeeTable = Model(name: "cofeeTable", category: .decor,scaleCompensation: 80.00/100)
        
        self.all += [cofeeTable]
        
        //table
        let sillasMesa = Model(name: "sillasMesa", category: .table,scaleCompensation: 1.0/100)// bien
        
        self.all += [sillasMesa]
        
        
        
        //bed
        let cama = Model(name: "cama", category: .bedroom, scaleCompensation: 0.018/100) // 0.32
        let ropero = Model(name: "ropero", category: .bedroom, scaleCompensation: 200.0/100)
        
        self.all += [cama,ropero]
    }
    
    
    func get(category: ModelCategory) ->[Model]
    {
        return all.filter({$0.category == category})
    }
    
}

