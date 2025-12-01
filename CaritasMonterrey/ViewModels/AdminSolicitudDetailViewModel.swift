
//
//  AdminSolicitudDetailViewModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 18/11/2025.
//

import Combine
import Foundation
import Supabase

@MainActor
class AdminSolicitudDetailViewModel: ObservableObject {
    
    @Published var isUpdating = false
    @Published var errorMessage: String?
    @Published var adminNote: String = ""
    @Published var isShowingNoteSheet = false
    
    private var selectedAction: DonationDBStatus?
    
    let donation: Donation
    
    var onComplete: (() -> Void)?

    init(donation: Donation) {
        self.donation = donation
    }
    
    func prepareUpdate(action: DonationDBStatus) {
        self.selectedAction = action
        self.adminNote = "" // Limpia la nota anterior
        self.isShowingNoteSheet = true
    }
    
    func cancelUpdate() {
        self.isShowingNoteSheet = false
        self.selectedAction = nil
        self.adminNote = ""
    }
    
        func performUpdate() async {
            guard let newStatus = selectedAction else {
                errorMessage = "Error: No se ha seleccionado ninguna acción."
                return
            }
            
            isUpdating = true
            errorMessage = nil
            
            
            struct DonationUpdatePayload: Encodable {
                let status: String
                let admin_note: String?
            }
            
            let noteToSend = adminNote.isEmpty ? nil : adminNote

            // Preparar Payload
            let payload = DonationUpdatePayload(
                status: newStatus.rawValue,
                admin_note: noteToSend
            )
            
            // Enviar payload como encodable
            do {
                try await SupabaseManager.shared.client
                    .from("Donations")
                    .update(payload)
                    .eq("id", value: donation.id)
                    .execute()
                
                isUpdating = false
                isShowingNoteSheet = false
                onComplete?()
                
            } catch {
                errorMessage = error.localizedDescription
                isUpdating = false
            }
        }
}
