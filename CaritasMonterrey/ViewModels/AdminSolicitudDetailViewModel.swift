
//
//  AdminSolicitudDetailViewModel.swift
//  CaritasMonterrey
//
//  Created by OpenAI on 2024.
//

import Combine
import Foundation
import Supabase

// Usamos @MainActor para asegurarnos de que todos los cambios
// a propiedades @Published ocurran en el hilo principal.
@MainActor
class AdminSolicitudDetailViewModel: ObservableObject {
    
    // Propiedades de estado de la UI
    @Published var isUpdating = false
    @Published var errorMessage: String?
    
    // --- Nuevas propiedades para la nota del admin ---
    @Published var adminNote: String = ""
    @Published var isShowingNoteSheet = false
    
    // Propiedad para saber qué acción se está ejecutando
    private var selectedAction: DonationDBStatus?
    
    // --- Dependencias ---
    let donation: Donation
    
    // --- Callback ---
    // La Vista usará esto para saber cuándo cerrarse (dismiss).
    var onComplete: (() -> Void)?

    init(donation: Donation) {
        self.donation = donation
    }
    
    /// 1. Prepara la actualización y muestra la hoja para la nota.
    func prepareUpdate(action: DonationDBStatus) {
        self.selectedAction = action
        self.adminNote = "" // Limpia la nota anterior
        self.isShowingNoteSheet = true
    }
    
    /// 2. El usuario cancela desde la hoja modal.
    func cancelUpdate() {
        self.isShowingNoteSheet = false
        self.selectedAction = nil
        self.adminNote = ""
    }
    
    /// 3. Ejecuta la actualización en Supabase (llamado desde la hoja modal).
        func performUpdate() async {
            guard let newStatus = selectedAction else {
                errorMessage = "Error: No se ha seleccionado ninguna acción."
                return
            }
            
            isUpdating = true
            errorMessage = nil
            
            // --- LA CORRECCIÓN ESTÁ AQUÍ ---
            
            // 1. Definimos un struct 'Encodable' que Supabase SÍ entiende.
            //    Esto nos da seguridad de tipos y resuelve el error.
            struct DonationUpdatePayload: Encodable {
                let status: String
                let admin_note: String? // La nota es opcional (puede ser nil)
            }
            
            // 2. Preparamos la nota: si está vacía, enviamos 'nil'.
            let noteToSend = adminNote.isEmpty ? nil : adminNote

            // 3. Creamos nuestra carga de datos (payload)
            let payload = DonationUpdatePayload(
                status: newStatus.rawValue,
                admin_note: noteToSend
            )
            
            // 4. Enviamos el 'payload' en lugar del diccionario
            do {
                try await SupabaseManager.shared.client
                    .from("Donations")
                    .update(payload) // <-- ¡Ahora es un struct Encodable!
                    .eq("id", value: donation.id)
                    .execute()
                
                // Éxito
                isUpdating = false
                isShowingNoteSheet = false
                onComplete?() // Llama al callback para que la vista se cierre
                
            } catch {
                // Error
                errorMessage = error.localizedDescription
                isUpdating = false // Mantenemos la hoja abierta para mostrar el error
            }
        }
}
