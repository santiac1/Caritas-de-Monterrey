import Foundation
import SwiftUI
import Supabase
import Combine
import PhotosUI

@MainActor
final class DonationSheetViewModel: ObservableObject {
    enum DonationType: String, CaseIterable, Identifiable {
        case monetaria = "Monetaria"
        case ropa = "Ropa"
        case alimentos = "Alimentos"
        case utiles = "Útiles escolares"

        var id: String { rawValue }
    }

    // MARK: - Publicación de propiedades observables
    
    @Published var donationName: String = ""
    @Published var selectedType: DonationType = .monetaria
    @Published var amount: String = ""
    @Published var notes: String = ""
    @Published var preferPickupAtBazaar: Bool = true {
        didSet {
            if preferPickupAtBazaar && selectedBazaar == nil {
                selectedBazaar = bazaars.first
            }
        }
    }
    @Published var bazaars: [Location] = []
    @Published var selectedBazaar: Location?
    @Published var helpNeeded: Bool = false
    @Published var shippingWeight: String = ""
    @Published private(set) var isSubmitting = false
    @Published var submitOK = false
    @Published var errorMessage: String?

    // MARK: - Imagen
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var selectedImages: [Image] = []
    @Published var selectedImageDatas: [Data] = []

    // MARK: - Usuario
    var currentUserId: UUID?

    // MARK: - Cliente Supabase
    private let client = SupabaseManager.shared.client
    private var hasLoadedBazaars = false

    // MARK: - Validaciones (MODIFICADO)
    var isValid: Bool {
        
        // --- REQUERIMIENTOS OBLIGATORIOS ---
        
        // 1. Nombre obligatorio
        if donationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        // 2. Foto(s) obligatoria(s) (NUEVO REQUERIMIENTO)
        if selectedImages.isEmpty {
            return false
        }

        // 3. Tipo de donación (ya está cubierto, siempre hay un valor)
        
        // 4. Ubicación de entrega (ya está cubierto)
        //    Si prefiere entregar en bazar, debe seleccionar uno.
        //    Si prefiere recolección (preferPickupAtBazaar = false), es válido.
        if preferPickupAtBazaar && selectedBazaar == nil {
            return false
        }
        
        // --- Validaciones condicionales ---
        
        // Si es monetaria, el monto debe ser válido
        if selectedType == .monetaria {
            guard let value = Double(amount.replacingOccurrences(of: ",", with: ".")), value > 0 else { return false }
        }
        
        // Si necesita ayuda, debe especificar el peso/tamaño
        if helpNeeded && shippingWeight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }

        // --- Validación de usuario ---
        return currentUserId != nil
    }

    // MARK: - Cargar bazares
    func loadBazaars() async {
        guard !hasLoadedBazaars else { return }
        hasLoadedBazaars = true
        errorMessage = nil

        do {
            let response: [Location] = try await client
                .from("Locations")
                .select()
                .order("name")
                .execute()
                .value
            bazaars = response
            if selectedBazaar == nil {
                selectedBazaar = response.first
            }
        } catch {
            errorMessage = error.localizedDescription
            hasLoadedBazaars = false
        }
    }

    // MARK: - Cargar imágenes seleccionadas
    func loadImages() async {
        var newImages: [Image] = []
        var newData: [Data] = []
        
        for item in selectedPhotoItems {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    newImages.append(Image(uiImage: uiImage))
                    newData.append(data)
                }
            } catch {
                print("Error al cargar imagen: \(error.localizedDescription)")
            }
        }
        
        selectedImages = newImages
        selectedImageDatas = newData
    }
    
    /// Elimina una imagen de los tres arrays para mantener la sincronización
    func removeImage(at index: Int) {
        guard selectedImages.indices.contains(index),
              selectedImageDatas.indices.contains(index),
              selectedPhotoItems.indices.contains(index) else {
            return
        }
        
        selectedImages.remove(at: index)
        selectedImageDatas.remove(at: index)
        selectedPhotoItems.remove(at: index)
    }

    // MARK: - Enviar donación (MODIFICADO)
    func submit() async {
        guard isValid, let userId = currentUserId else {
            // --- Mensaje de error actualizado ---
            errorMessage = "Por favor, completa todos los campos obligatorios: Nombre, Foto(s) y Ubicación de entrega."
            return
        }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let status = helpNeeded ? "solicitud_ayuda" : "en_proceso"

        let donation = NewDonation(
            user_id: userId,
            name: donationName,
            type: selectedType.rawValue,
            status: status,
            help_needed: helpNeeded,
            shipping_weight: helpNeeded ? shippingWeight : nil,
            notes: notes.isEmpty ? nil : notes,
            amount: selectedType == .monetaria ? Double(amount.replacingOccurrences(of: ",", with: ".")) : nil,
            prefer_pickup_at_bazaar: preferPickupAtBazaar,
            location_id: preferPickupAtBazaar ? selectedBazaar?.id : nil
        )

        do {
            try await client
                .from("Donations")
                .insert(donation)
                .execute()

            // Subir TODAS las imágenes a Supabase Storage
            if !selectedImageDatas.isEmpty {
                for data in selectedImageDatas {
                    try await uploadImageToSupabase(data: data, userId: userId)
                }
            }

            submitOK = true
        } catch {
            errorMessage = error.localizedDescription
            submitOK = false
        }
    }

    // MARK: - Subida opcional de imagen
    private func uploadImageToSupabase(data: Data, userId: UUID) async throws {
        let fileName = "donation_\(userId.uuidString)_\(UUID().uuidString).jpg"
        do {
            try await client.storage
                .from("donations") // nombre del bucket
                .upload(path: fileName, file: data)
            print("✅ Imagen subida correctamente a Supabase Storage: \(fileName)")
        } catch {
            print("⚠️ Error al subir imagen: \(error.localizedDescription)")
        }
    }
}

// MARK: - Modelo de inserción
private struct NewDonation: Encodable {
    let user_id: UUID
    let name: String
    let type: String
    let status: String
    let help_needed: Bool
    let shipping_weight: String?
    let notes: String?
    let amount: Double?
    let prefer_pickup_at_bazaar: Bool
    let location_id: Int?
}
