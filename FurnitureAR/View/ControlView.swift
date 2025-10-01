import SwiftUI

struct ControlView: View
{
    @Environment(\.dismiss) var dismiss
    
    @Binding var selecteControlMode: Int
    @Binding var isControlVisible : Bool
    @Binding var isGalleryVisible : Bool
    
    var body: some View
    {
        VStack
        {
            ControlVisibilityToggleButton(isControlVisible: $isControlVisible)
            
            Spacer()
            
            if isControlVisible
            {
                ControlModelPicker(selectedControlMode: $selecteControlMode)
                ControlButtonBar(isGalleryVisible: $isGalleryVisible,
                                 selectedControlMode: selecteControlMode)
            }
        }
    }
}


#Preview
{
    ControlView(selecteControlMode: .constant(1),
                isControlVisible: .constant(true),
                isGalleryVisible: .constant(false))
}
