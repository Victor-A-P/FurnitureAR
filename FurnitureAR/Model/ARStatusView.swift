import SwiftUI
import ARKit

struct ARStatusView: View
{
    
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View {
        VStack {
            
            mappingStatusBar
                .offset(x:-60)
            
            Spacer().frame(height: 10)
            
            if !sceneManager.sessionMessage.isEmpty
            {
                statusBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
           Spacer()
            
            // Mostrar snapshot durante relocalizacion
            if sceneManager.isRelocalizing, let snapshot = sceneManager.snapshotImage {
                snapshotView(snapshot)
                    .transition(.scale.combined(with: .opacity))
            }
            Spacer().frame(height: 50)
            
            // Información de mapeo/tracking (siempre visible en la parte inferior)
           
        }
        .animation(.easeInOut(duration: 0.3), value: sceneManager.sessionMessage)
        .animation(.easeInOut(duration: 0.3), value: sceneManager.isRelocalizing)
    }
    
    // MARK: - Status Banner
    
    private var statusBanner: some View {
        Text(sceneManager.sessionMessage)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.top, 60)
    }
    
    // MARK: - Snapshot View
    
    private func snapshotView(_ image: UIImage) -> some View
    {
        VStack(spacing: 12) {
            Text("Mueve el dispositivo aquí")
                .font(.headline)
                .foregroundStyle(.white)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.bottom, 100)
    }
    
    // MARK: - Mapping Status Bar
    
    private var mappingStatusBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                statusIndicator(
                    title: "Mapeo",
                    value: sceneManager.worldMappingStatus.description,
                    color: mappingColor
                )
                
                Divider()
                    .frame(height: 30)
                
                statusIndicator(
                    title: "Tracking",
                    value: sceneManager.trackingState.description,
                    color: trackingColor
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
        }
        .padding(.bottom, 20)
    }
    
    private func statusIndicator(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
    }
    
    // MARK: - Colors
    
    private var mappingColor: Color {
        switch sceneManager.worldMappingStatus
        {
            case .mapped:
                return .green
            case .extending:
                return .blue
            case .limited:
                return .orange
            case .notAvailable:
                return .red
            @unknown default:
                return .gray
        }
    }
    
    private var trackingColor: Color {
        switch sceneManager.trackingState {
        case .normal:
            return .green
        case .limited:
            return .orange
        case .notAvailable:
            return .red
        @unknown default:
            return .gray
        }
    }
}
