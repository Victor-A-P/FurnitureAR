import SwiftUI

struct Separator: View
{
    var body: some View
    {
        Divider()
            .padding(.horizontal,20)
            .padding(.vertical, 10)
    }
}


#Preview {
    Separator()
}
