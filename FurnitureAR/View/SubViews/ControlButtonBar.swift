import SwiftUI

struct ControlButtonBar: View
{
    
    @Binding var isGalleryVisible : Bool
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var selectedControlMode: Int
    
    
    
    var body: some View
    {
        HStack(alignment: .center)
        {
            if selectedControlMode == 1
            {
                SceneButtons()
            } else
                {
                    BrowseButtons(isGalleryVisible: $isGalleryVisible)
                }
        }
    }
}

#Preview
{
   ContentView()
}
