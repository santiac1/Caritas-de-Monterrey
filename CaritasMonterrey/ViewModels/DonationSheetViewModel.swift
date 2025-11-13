import Foundation
import SwiftUI
import Supabase
import Combine
import PhotosUI

@MainActor
final class DonationSheetViewModel: ObservableObject {

    // MARK: - Tipo dinámico (opción para el picker)
    struct TypeOption: Identifiable, Hashable {
        let id = UUID()
        let slug: String          // lo que se guarda en BD
        let displayName: String   // lo que ve el usuario
        let systemImage: String   // para icons en el picker
    }
    
    // --- NUEVA PROPIEDAD ---
    // Almacena el bazar preseleccionado hasta que se cargan los demás
    private var preselectedBazaar: Location?

    // MARK: - Props observables (UI)
    @Published var donationName: String = ""
    @Published var notes: String = ""
    @Published var amount: String = ""            // ya no se usa (no hay monetaria)
    @Published var helpNeeded: Bool = false
    @Published var shippingWeight: String = ""

    // Entrega
    @Published var preferPickupAtBazaar: Bool = true {
        didSet {
            if preferPickupAtBazaar, selectedBazaar == nil {
                selectedBazaar = bazaars.first
            }
            recomputeAvailableTypes()
        }
    }
    @Published var bazaars: [Location] = []
    @Published var selectedBazaar: Location? {
        didSet { recomputeAvailableTypes() }
    }

    // ... (el resto de tus propiedades @Published no cambian) ...
    @Published private(set) var availableTypes: [TypeOption] = []
    @Published var selectedType: TypeOption? = nil
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var selectedImages: [Image] = []
    @Published var selectedImageDatas: [Data] = []
    @Published private(set) var isSubmitting = false
    @Published var submitOK = false
    @Published var errorMessage: String?
    var currentUserId: UUID?

    // Infra
    private let client = SupabaseManager.shared.client
    private var hasLoadedBazaars = false
    
    // --- INIT POR DEFECTO (SIN CAMBIOS) ---
    init() { }
    
    // --- ¡NUEVO INIT! ---
    /// Permite crear el VM con un bazar preseleccionado desde el mapa.
    convenience init(preselectedBazaar: Location) {
        self.init()
        self.preselectedBazaar = preselectedBazaar
        self.preferPickupAtBazaar = true
        self.selectedBazaar = preselectedBazaar
    }

    // MARK: - Validaciones
    var isValid: Bool {
        // ... (tu lógica de 'isValid' no cambia) ...
        guard !donationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !selectedImages.isEmpty else { return false }
        guard selectedType != nil else { return false }
        if preferPickupAtBazaar && selectedBazaar == nil { return false }
        if helpNeeded && shippingWeight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        return currentUserId != nil
    }

    // MARK: - Cargar bazares (MODIFICADO)
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
            
            // --- LÓGICA DE SELECCIÓN MODIFICADA ---
            // Si venimos del mapa, mantenemos la preselección.
            // Si no, seleccionamos el primero de la lista.
            if let preselected = self.preselectedBazaar {
                // Asegurarnos que el objeto 'preselected' es el de la lista
                self.selectedBazaar = bazaars.first { $0.id == preselected.id } ?? preselected
                self.preferPickupAtBazaar = true
                self.preselectedBazaar = nil // Consumimos la preselección
            } else if selectedBazaar == nil {
                selectedBazaar = response.first
            }
            
            recomputeAvailableTypes()
            
        } catch {
            errorMessage = error.localizedDescription
            hasLoadedBazaars = false
        }
    }

    // MARK: - Imágenes
    // ... (tu función 'loadImages' sin cambios) ...
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

    // ... (tu función 'removeImage' sin cambios) ...
    func removeImage(at index: Int) {
        guard selectedImages.indices.contains(index),
              selectedImageDatas.indices.contains(index),
              selectedPhotoItems.indices.contains(index) else { return }

        selectedImages.remove(at: index)
        selectedImageDatas.remove(at: index)
        selectedPhotoItems.remove(at: index)
    }

    // MARK: - Mapeo de Location -> tipos
    // ... (tu función 'recomputeAvailableTypes' sin cambios) ...
    private func recomputeAvailableTypes() {
        var options: [TypeOption] = []
        func add(_ cond: Bool, slug: String, name: String, icon: String) {
            if cond {
                options.append(.init(slug: slug, displayName: name, systemImage: icon))
            }
        }
        if preferPickupAtBazaar, let l = selectedBazaar {
            add(l.food,       slug: "alimentos",           name: "Alimentos",           icon: "cart.fill")
            add(l.clothes,    slug: "ropa",                name: "Ropa",                icon: "tshirt.fill")
            add(l.equipment,  slug: "equipo",              name: "Equipo",              icon: "wrench.and.screwdriver")
            add(l.furniture,  slug: "muebles",             name: "Muebles",             icon: "sofa.fill")
            add(l.appliances, slug: "electrodomesticos",   name: "Electrodomésticos",   icon: "powerplug")
            add(l.cleaning,   slug: "limpieza",            name: "Limpieza",            icon: "sparkles")
            add(l.medicine,   slug: "medicinas",           name: "Medicinas",           icon: "cross.case.fill")
        } else {
            let anyFood       = bazaars.contains(where: { $0.food })
            let anyClothes    = bazaars.contains(where: { $0.clothes })
            let anyEquipment  = bazaars.contains(where: { $0.equipment })
            let anyFurniture  = bazaars.contains(where: { $0.furniture })
            let anyAppliances = bazaars.contains(where: { $0.appliances })
            let anyCleaning   = bazaars.contains(where: { $0.cleaning })
            let anyMedicine   = bazaars.contains(where: { $0.medicine })
            add(anyFood,       slug: "alimentos",           name: "Alimentos",           icon: "cart.fill")
            add(anyClothes,    slug: "ropa",                name: "Ropa",                icon: "tshirt.fill")
            add(anyEquipment,  slug: "equipo",              name: "Equipo",              icon: "wrench.and.screwdriver")
            add(anyFurniture,  slug: "muebles",             name: "Muebles",             icon: "sofa.fill")
            add(anyAppliances, slug: "electrodomesticos",   name: "Electrodomésticos",   icon: "powerplug")
            add(anyCleaning,   slug: "limpieza",            name: "Limpieza",            icon: "sparkles")
            add(anyMedicine,   slug: "medicinas",           name: "Medicinas",           icon: "cross.case.fill")
        }
        availableTypes = options
        if let sel = selectedType, !availableTypes.contains(sel) {
            selectedType = availableTypes.first
        } else if selectedType == nil {
            selectedType = availableTypes.first
        }
    }

    // MARK: - Helpers
    private func initialDBStatus() -> String { "in_process" }

    // MARK: - Payload
    // ... (tu struct 'NewDonation' sin cambios) ...
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
        let image_urls: [String]?
    }

    // MARK: - Submit
    // ... (tu función 'submit' sin cambios) ...
    func submit() async {
        guard isValid, let userId = currentUserId, let sel = selectedType else {
            errorMessage = "Completa: Nombre, Foto(s), Tipo y Ubicación."
            return
        }
        isSubmitting = true
        errorMessage = nil
        submitOK = false
        defer { isSubmitting = false }
        do {
            var uploadedImageUrls: [String] = []
            if !selectedImageDatas.isEmpty {
                for data in selectedImageDatas {
                    let url = try await uploadImage(data: data, userId: userId)
                    uploadedImageUrls.append(url)
                }
            }
            let payload = NewDonation(
                user_id: userId,
                name: donationName.trimmingCharacters(in: .whitespacesAndNewlines),
                type: sel.slug,
                status: initialDBStatus(),
                help_needed: helpNeeded,
                shipping_weight: helpNeeded ? shippingWeight : nil,
                notes: notes.isEmpty ? nil : notes,
                amount: nil,
                prefer_pickup_at_bazaar: preferPickupAtBazaar,
                location_id: preferPickupAtBazaar ? selectedBazaar?.id : nil,
                image_urls: uploadedImageUrls.isEmpty ? nil : uploadedImageUrls
            )
            _ = try await client
                .from("Donations")
                .insert(payload)
                .execute()
            submitOK = true
          
        } catch {
            errorMessage = error.localizedDescription
            submitOK = false
        }
    }

    // MARK: - Storage
    // ... (tu función 'uploadImage' sin cambios) ...
    private func uploadImage(data: Data, userId: UUID) async throws -> String {
        let fileName = "donation_\(userId.uuidString)_\(UUID().uuidString).jpg"
        let storage = client.storage.from("donations")
        do {
            try await storage
                .upload(path: fileName, file: data)
            let urlResponse = try await storage.getPublicURL(path: fileName)
            print("✅ Imagen subida: \(urlResponse.absoluteString)")
            return urlResponse.absoluteString
        } catch {
            print("⚠️ Error al subir imagen: \(error.localizedDescription)")
            throw error
        }
    }
}
