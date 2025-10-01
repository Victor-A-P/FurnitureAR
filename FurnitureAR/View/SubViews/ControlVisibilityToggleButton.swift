import SwiftUI

struct ControlVisibilityToggleButton: View
{
    @Binding var isControlVisible: Bool
    
    
    var body: some View
    {
        HStack
        {
            Spacer()
            
            ControlButton(image: isControlVisible ? "square.3.layers.3d.slash": "square.2.layers.3d.fill",
                          action:
                            {
                                self.isControlVisible.toggle()
                                print("Visibility Toggled")
                            } )
        }
        .padding(.trailing, 10)
    }
}

#Preview
{
    ZStack
    {
        Color.black
            .ignoresSafeArea()
        
        ControlVisibilityToggleButton(isControlVisible: .constant(true))
    }
}
