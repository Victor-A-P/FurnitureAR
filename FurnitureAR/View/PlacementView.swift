import SwiftUI

struct PlacementView: View
{
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View
    {
      GlassEffectContainer(spacing: 22)
        {
           VStack
            {
                Spacer()
                HStack
                 {
                     ControlButton(image: "xmark")
                     {
                         print("Cancel Placement Button Pressed")
                         self.placementSettings.selectedModel = nil
                     }
                     .buttonStyle(.plain)
                     .glassEffect(.clear.tint(.red.opacity(0.4)))
                     
                     
                     ControlButton(image: "checkmark")
                     {
                         print("Confirm Placement Button Pressed")
                         self.placementSettings.confirmedModel =  self .placementSettings.selectedModel
                         
                         self.placementSettings.selectedModel = nil
                     }.buttonStyle(.plain)
                     .glassEffect(.clear.tint(.green.opacity(0.5)))
                 }
            }
        }
    }
}

#Preview {
    PlacementView()
}
