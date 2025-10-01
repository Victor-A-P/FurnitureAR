import SwiftUI

struct BrowseButtons: View
{
    @Binding var isGalleryVisible : Bool
    @State private var showSettingsSheet = false
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View
    {
        GlassEffectContainer(spacing: 22)
        {
            HStack
            {
                //Asest usado mas recientemente
                ControlButton(image: "stopwatch.fill",
                              action:
                                {
                                    print("Recently")
                    
                                } )
                    
                
                
                //Boton para mostrar todos los modelos
                ControlButton(image: "square.grid.2x2.fill",
                              action:
                                {
                                    self.isGalleryVisible.toggle()
                                } )
                .sheet(isPresented: $isGalleryVisible)
                {
                    BrowseView(isGalleryVisible: $isGalleryVisible)
                        .presentationDetents([.height(270), .large])
                }
                
                
                //Boton para ajuste
                ControlButton(image: "slider.horizontal.3",
                              action:
                                {
                                    showSettingsSheet = true
                           
                                } )
                
            }
        }
        .sheet(isPresented: $showSettingsSheet)
        {
            SettingsView()
                .environmentObject(sceneManager)
        }
    }
}

#Preview
{
    BrowseButtons(isGalleryVisible: .constant(true))
}
