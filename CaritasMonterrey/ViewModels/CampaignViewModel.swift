import Foundation
import Supabase
import Combine

@MainActor
final class CampaignViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    // MARK: - Load Campaigns
    func loadCampaigns(activeOnly: Bool = false) async {
        isLoading = true
        errorMessage = nil
        
        do {
            var query = client.from("campaigns").select()
            
            if activeOnly {
                query = query.eq("is_active", value: true)
            }
            
            let response: [Campaign] = try await query
                .order("start_date", ascending: false)
                .execute()
                .value
            
            self.campaigns = response
        } catch {
            errorMessage = "Error al cargar campañas: \(error.localizedDescription)"
            print("❌ Error loading campaigns: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Create Campaign
    func createCampaign(_ payload: CampaignPayload) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await client
                .from("campaigns")
                .insert(payload)
                .execute()
            
            await loadCampaigns()
        } catch {
            errorMessage = "Error al crear campaña: \(error.localizedDescription)"
            print("❌ Error creating campaign: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Update Campaign
    func updateCampaign(_ id: Int, with payload: CampaignPayload) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await client
                .from("campaigns")
                .update(payload)
                .eq("id", value: id)
                .execute()
            
            await loadCampaigns()
        } catch {
            errorMessage = "Error al actualizar campaña: \(error.localizedDescription)"
            print("❌ Error updating campaign: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Campaign
    func deleteCampaign(_ id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await client
                .from("campaigns")
                .delete()
                .eq("id", value: id)
                .execute()
            
            await loadCampaigns()
        } catch {
            errorMessage = "Error al eliminar campaña: \(error.localizedDescription)"
            print("❌ Error deleting campaign: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Upload Image
    // MARK: - Upload Image
    func uploadCampaignImage(data: Data) async throws -> String {
        let fileName = "campaign_\(UUID().uuidString).jpg"
        let storage = client.storage.from("campaign_images")
        
        // Retry logic: 3 attempts
        var lastError: Error?
        for attempt in 1...3 {
            do {
                try await storage.upload(
                    fileName,
                    data: data,
                    options: FileOptions(contentType: "image/jpeg")
                )
                
                let urlResponse = try storage.getPublicURL(path: fileName)
                print("✅ Imagen de campaña subida (intento \(attempt)): \(urlResponse.absoluteString)")
                return urlResponse.absoluteString
                
            } catch {
                print("⚠️ Error al subir imagen (intento \(attempt)): \(error.localizedDescription)")
                lastError = error
                
                // Wait before retrying (exponential backoff: 1s, 2s)
                if attempt < 3 {
                    try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                }
            }
        }
        
        throw lastError ?? URLError(.unknown)
    }
}
