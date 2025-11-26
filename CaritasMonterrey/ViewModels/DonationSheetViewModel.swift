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
    
    // Almacena el bazar preseleccionado hasta que se cargan los demás
    private var preselectedBazaar: Location?

    // MARK: - Props observables (UI)
    @Published var donationName: String = ""
    @Published var notes: String = ""
    @Published var amount: String = ""            // ya no se usa (no hay monetaria)
    @Published var helpNeeded: Bool = false
    @Published var shippingWeight: String = ""
    @Published var pickupAddress: String = ""

    // Entrega
    @Published var preferPickupAtBazaar: Bool = true {
        didSet {
            // Si activa la opción y no hay bazar seleccionado, autoselecciona el primero DISPONIBLE
            if preferPickupAtBazaar, selectedBazaar == nil {
                selectedBazaar = bazaars.first
            }
            recomputeAvailableTypes()
        }
    }
    
    // Lista filtrada de bazares (Solo activos)
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
    
    // --- INIT POR DEFECTO ---
    init() { }

    // --- INIT CON PRESELECCIÓN ---
    convenience init(preselectedBazaar: Location) {
        self.init()
        // Solo permitimos la preselección si el bazar está activo
        if preselectedBazaar.isActive {
            self.preselectedBazaar = preselectedBazaar
            self.preferPickupAtBazaar = true
            self.selectedBazaar = preselectedBazaar
        }
    }

    func prefillPickupAddress(_ address: String?) {
        guard pickupAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let address,
              !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        pickupAddress = address
    }

    // MARK: - Validaciones
    var isValid: Bool {
        guard !donationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !selectedImages.isEmpty else { return false }
        guard selectedType != nil else { return false }
        if preferPickupAtBazaar && selectedBazaar == nil { return false }
        if helpNeeded && shippingWeight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if helpNeeded && pickupAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        return currentUserId != nil
    }

    // MARK: - Cargar bazares (CORREGIDO)
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

            // ✅ Filtramos solo los activos
            let activeBazaars = response.filter { $0.isActive }
            bazaars = activeBazaars
            
            // --- LÓGICA DE SELECCIÓN ---
            if let preselected = self.preselectedBazaar {
                // Verificamos que el preseleccionado siga existiendo en la lista de activos
                if let found = bazaars.first(where: { $0.id == preselected.id }) {
                    self.selectedBazaar = found
                    self.preferPickupAtBazaar = true
                } else {
                    // Si el preseleccionado ahora está cerrado (inactivo), seleccionamos el primero disponible
                    self.selectedBazaar = bazaars.first
                }
                self.preselectedBazaar = nil
                
            } else if selectedBazaar == nil {
                selectedBazaar = bazaars.first
            }
            
            recomputeAvailableTypes()
            
        } catch {
            errorMessage = error.localizedDescription
            hasLoadedBazaars = false
        }
    }

    // MARK: - Imágenes
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

    func removeImage(at index: Int) {
        guard selectedImages.indices.contains(index),
              selectedImageDatas.indices.contains(index),
              selectedPhotoItems.indices.contains(index) else { return }

        selectedImages.remove(at: index)
        selectedImageDatas.remove(at: index)
        selectedPhotoItems.remove(at: index)
    }

    // MARK: - Mapeo de Location -> tipos
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
            // Si es recolección a domicilio, mostramos lo que acepta CUALQUIER bazar activo
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
        
        // Validar selección actual
        if let sel = selectedType, !availableTypes.contains(sel) {
            selectedType = availableTypes.first
        } else if selectedType == nil {
            selectedType = availableTypes.first
        }
    }

    // MARK: - Helpers
    private func initialDBStatus() -> String { "in_process" }

    // MARK: - Payload
    private struct NewDonation: Encodable {
        let user_id: UUID
        let name: String
        let type: String
        let status: String
        let help_needed: Bool
        let shipping_weight: String?
        let pickup_address: String?
        let notes: String?
        let amount: Double?
        let prefer_pickup_at_bazaar: Bool
        let location_id: Int?
        let image_urls: [String]?
    }

    // MARK: - Submit
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
                pickup_address: helpNeeded ? pickupAddress.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
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
    private func uploadImage(data: Data, userId: UUID) async throws -> String {
        let fileName = "donation_\(userId.uuidString)_\(UUID().uuidString).jpg"
        let storage = client.storage.from("donations")
        do {
            // CORRECCIÓN 1: Usamos la nueva firma 'upload(_:data:options:)'
            // El nombre del archivo va sin etiqueta, y 'file:' ahora es 'data:'.
            try await storage.upload(
                fileName,
                data: data,
                options: FileOptions(contentType: "image/jpeg")
            )
            
            // CORRECCIÓN 2: 'getPublicURL' necesita 'try' (sin await) porque puede lanzar errores de validación
            let urlResponse = try storage.getPublicURL(path: fileName)
            
            print("✅ Imagen subida: \(urlResponse.absoluteString)")
            return urlResponse.absoluteString
        } catch {
            print("⚠️ Error al subir imagen: \(error.localizedDescription)")
            throw error
        }
    }
}
