import SwiftUI

struct HorizontalGrid: View
{
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var isGalleryVisible : Bool
    
    private let gridItemLayout = [GridItem(.fixed(200) ) ]
    
    var title: String
    var items: [Model]
    
   
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Separator()
            
            Text(title)
                .font(.title2)
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false)
            {
                LazyHGrid(rows: gridItemLayout, spacing: 30)
                {
                    //0 ..< items.count)
                    ForEach(items.indices, id: \.self)
                    {index in
                        let model = items[index]
                        
                        ItemButton(model: model)
                        {
                            model.asyncLoadModelEntity()
                            self.placementSettings.selectedModel = model
                            print("\(model.name)")
                            isGalleryVisible = false
                        }

                    }
                }
                .padding(.horizontal,22)
                .padding(.vertical, 10)
            }
            
        }
    }
}

