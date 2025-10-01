import SwiftUI

struct ItemButton: View
{
        
    let model: Model
    let action: () -> Void
    
    var body: some View
    {
        Button
        {
            self.action()
        } label:
            {
                Image(uiImage: self.model.thumbnail)
                    .resizable()
                    .frame(height: 200)
                    .aspectRatio(1/1, contentMode: .fit)
                    .scaledToFit()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.ultraThinMaterial)
                    )
            }.buttonStyle(.plain)
    }
}
