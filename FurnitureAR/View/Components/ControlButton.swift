import SwiftUI

struct ControlButton: View
{
    let image: String
    let action: () -> Void
    
    var body: some View
    {
        Button
        {
            self.action()
        } label:
            {
                Image(systemName: image)
                    .padding(10)
                    .padding(.horizontal)
                    .fontWeight(.semibold)
                    .font(.title2)
            }.buttonStyle(.glass)
    }
}

#Preview
{
    ControlButton(image: "gear", action: {print("Hello")})
}
