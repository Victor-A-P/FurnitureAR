import SwiftUI
import Combine
import RealityKit

enum ModelCategory: CaseIterable
{
    case rest
    case decor
    case table
    case bedroom
    
    var label: String
    {
        get
        {
            switch self
            {
                case .rest: return "RestRoom"
                case .decor: return "Decor"
                case .table: return "Table"
                case .bedroom: return "BedRoom"
            }
        }
    }
    
}

