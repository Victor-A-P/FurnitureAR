import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sceneManager: SceneManager
    
    @State private var selectedControlMode: Int = 0
    @State var isControlVisible: Bool = true
    @State var isGalleryVisible: Bool = false
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer()
                .ignoresSafeArea()
            
            // AR Status Overlay (siempre visible)
            ARStatusView()
                .environmentObject(sceneManager)
            
            // Control Views
            if placementSettings.selectedModel == nil {
                ControlView(
                    selecteControlMode: $selectedControlMode,
                    isControlVisible: $isControlVisible,
                    isGalleryVisible: $isGalleryVisible
                )
            } else {
                PlacementView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PlacementSettings())
        .environmentObject(SceneManager())
}
