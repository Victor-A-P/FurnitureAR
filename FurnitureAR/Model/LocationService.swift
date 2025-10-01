import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject
{
    
    @Published var currentLocation: CLLocation?
    @Published var currentAddress: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isAuthorized: Bool = false
    @Published var isUpdatingLocation: Bool = false
    
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationUpdateTimer: Timer?
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Actualizar cada 10 metros
        authorizationStatus = locationManager.authorizationStatus
        updateAuthorizationStatus()
    }
    
    func requestPermission()
    {
        print("🗺️ Solicitando permisos de ubicación...")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation()
    {
        guard isAuthorized else
        {
            print("⚠️ No autorizado para obtener ubicación")
            requestPermission()
            return
        }
        
        print("🗺️ Iniciando actualización de ubicación...")
               isUpdatingLocation = true
               locationManager.startUpdatingLocation()
               
               // Forzar una actualización de ubicación inmediata
               locationManager.requestLocation()
               
               // Timeout de seguridad
               locationUpdateTimer?.invalidate()
               locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false)
                { [weak self] _ in
                   if self?.currentLocation == nil
                   {
                       print("⏱️ Timeout obteniendo ubicación")
                       self?.isUpdatingLocation = false
                   }
                }
       }
    
    
    
    
    func stopUpdatingLocation()
    {
        print("🗺️ Deteniendo actualización de ubicación")
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
    }
    
    
    func reverseGeocodeLocation(_ location: CLLocation, completion: @escaping (String?) -> Void)
    {
        print("🏠 Obteniendo dirección para: \(location.coordinate)")
        
        geocoder.reverseGeocodeLocation(location)
        { placemarks, error in
            guard error == nil, let placemark = placemarks?.first else {
                print("❌ Error en geocoding: \(error?.localizedDescription ?? "desconocido")")
                completion(nil)
                return
            }
            
            var addressString = ""
            if let street = placemark.thoroughfare {
                addressString += street
            }
            if let number = placemark.subThoroughfare {
                addressString += " \(number)"
            }
            if let city = placemark.locality {
                addressString += ", \(city)"
            }
            if let state = placemark.administrativeArea {
                addressString += ", \(state)"
            }
            if let country = placemark.country {
                addressString += ", \(country)"
            }
            
            print("✅ Dirección obtenida: \(addressString)")
            completion(addressString.isEmpty ? nil : addressString)
        }
    }
    
    
    private func updateAuthorizationStatus()
    {
        isAuthorized = authorizationStatus == .authorizedWhenInUse ||
                      authorizationStatus == .authorizedAlways
        print("🔐 Estado de autorización: \(isAuthorized ? "Autorizado" : "No autorizado")")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate
{
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        updateAuthorizationStatus()
        
        print("🔐 Cambio de autorización: \(authorizationStatus.rawValue)")
        
        if isAuthorized {
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("📍 Ubicación actualizada: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        currentLocation = location
        isUpdatingLocation = false
        locationUpdateTimer?.invalidate()
                
        // Obtener dirección
        reverseGeocodeLocation(location)
        { [weak self] address in
            DispatchQueue.main.async
            {
                self?.currentAddress = address
            }
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("❌ Error obteniendo ubicación: \(error.localizedDescription)")
          isUpdatingLocation = false
          locationUpdateTimer?.invalidate()
    }
}
