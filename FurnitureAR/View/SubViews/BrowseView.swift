import SwiftUI

struct BrowseView: View
{
    @Binding var isGalleryVisible : Bool
    
    var body: some View
    {
        NavigationView
        {
            ScrollView(showsIndicators: false)
            {
                ModelsByCategoryGrid(isGalleryVisible: $isGalleryVisible)
            }
            .toolbar
            {
                GalleryToolbar(isGalleryVisible: $isGalleryVisible)
            }
        }
    }
}

#Preview {
    BrowseView(isGalleryVisible: .constant(false))
}



// MARK: - Toolbar Config
struct GalleryToolbar: ToolbarContent
{
    @Binding var isGalleryVisible: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal)
        {
            Text("Gallery")
                .font(.largeTitle.bold())
        }
        
        
        ToolbarItem(placement: .topBarTrailing)
        {
            Button(role: .close)
            {
                isGalleryVisible = false
            } label:
            {
                Image(systemName: "xmark")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .glassEffect(.clear.tint(.red.opacity(0.4)))
                    )
            }
        }.sharedBackgroundVisibility(.hidden)
        
    }
}

/*
@ToolbarContentBuilder
private var galleryToolbar: some ToolbarContent
{
   
    
    ToolbarItem(placement: .principal)
    {
        Text("Gallery")
            .font(Font.largeTitle.bold())
    }
    
    
    ToolbarItem(placement: .topBarTrailing)
    {
        Button(role: .close)
        {
            isGalleryVisible //<- aqui problema
        } label:
        {
            Image(systemName: "xmark")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(10)
                .background(
                    Circle()
                        .glassEffect(.clear.tint(.red.opacity(0.4)))
                )
        }
    }.sharedBackgroundVisibility(.hidden)
}
*/
