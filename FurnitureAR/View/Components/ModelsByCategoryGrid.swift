import SwiftUI

struct ModelsByCategoryGrid: View
{
    @Binding var isGalleryVisible : Bool
    
    let models = Models()
    
    var body: some View
    {
        VStack
        {
            ForEach(ModelCategory.allCases, id: \.self)
            {categoria in
                let modelsByCategory = models.get(category: categoria)
                
                if !modelsByCategory.isEmpty
                {
                    HorizontalGrid(isGalleryVisible: $isGalleryVisible,
                                   title: categoria.label,
                                   items: modelsByCategory)
                }
            }
        }
    }
}


#Preview
{
    ModelsByCategoryGrid(isGalleryVisible: .constant(false))
}
