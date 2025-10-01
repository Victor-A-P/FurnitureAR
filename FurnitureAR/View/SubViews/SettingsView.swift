import SwiftUI
import MapKit

struct SettingsView: View
{
    
    @EnvironmentObject var sceneManager: SceneManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteAlert = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        NavigationView {
            List {
                // Sección de escena guardada
                Section("Escena Guardada") {
                    if sceneManager.scenePersistenceData != nil {
                        savedSceneInfo
                    } else {
                        Text("No hay escena guardada")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Sección de ubicación
                if let location = sceneManager.savedLocation {
                    Section("Ubicación de la Escena") {
                        locationInfo(location: location)
                    }
                }
                
                // Sección de snapshot
                if let snapshot = sceneManager.snapshotImage {
                    Section("Vista Previa") {
                        snapshotPreview(snapshot)
                    }
                }
                
                // Sección de acciones
                if sceneManager.scenePersistenceData != nil {
                    Section {
                        deleteButton
                    }
                }
                
                // Información de la app
                Section("Información") {
                    appInfo
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            updateMapRegion()
        }
        .alert("Eliminar Escena", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                sceneManager.clearPersistedScene()
            }
        } message: {
            Text("¿Estás seguro de que deseas eliminar la escena guardada? Esta acción no se puede deshacer.")
        }
    }
    
    // MARK: - Saved Scene Info
    
    private var savedSceneInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Escena disponible")
                    .fontWeight(.medium)
            }
            
            if let fileSize = getFileSize() {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(.blue)
                    Text("Tamaño: \(fileSize)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let address = sceneManager.savedAddress {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                    Text(address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Location Info
    
    private func locationInfo(location: CLLocation) -> some View {
        VStack(spacing: 16) {
            // Coordenadas
            VStack(alignment: .leading, spacing: 8) {
                Label("Coordenadas", systemImage: "location.fill")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Latitud")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.6f", location.coordinate.latitude))
                            .font(.subheadline)
                            .monospaced()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Longitud")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.6f", location.coordinate.longitude))
                            .font(.subheadline)
                            .monospaced()
                    }
                }
            }
            
            // Mapa
            Map(coordinateRegion: .constant(mapRegion), annotationItems: [MapLocation(coordinate: location.coordinate)]) { item in
                MapMarker(coordinate: item.coordinate, tint: .red)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            
            // Botón de abrir en Mapas
            Button {
                openInMaps(location: location)
            } label: {
                Label("Abrir en Mapas", systemImage: "map.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Snapshot Preview
    
    private func snapshotPreview(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            
            Text("Vista capturada al guardar la escena")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Delete Button
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            Label("Eliminar Escena Guardada", systemImage: "trash.fill")
        }
    }
    
    // MARK: - App Info
    
    private var appInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoRow(icon: "app.fill", title: "Versión", value: "1.0.0")
            infoRow(icon: "cube.fill", title: "Motor", value: "RealityKit + ARKit")
            infoRow(icon: "iphone", title: "iOS", value: "18.0+")
        }
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helper Functions
    
    private func getFileSize() -> String? {
        guard let data = sceneManager.scenePersistenceData else { return nil }
        let bytes = Double(data.count)
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func updateMapRegion() {
        if let location = sceneManager.savedLocation {
            mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func openInMaps(location: CLLocation) {
        let coordinate = location.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = "Escena AR Guardada"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        ])
    }
}

// MARK: - MapLocation Helper

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview
{
    SettingsView()
        .environmentObject(SceneManager())
}
