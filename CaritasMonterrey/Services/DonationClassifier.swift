 
 import Foundation
import CoreML
import Vision
import UIKit

class DonationClassifier {
    
    private let model: VNCoreMLModel?
    
    init() {
        do {
            let config = MLModelConfiguration()
            let coreMLModel = try MyImageClassifier_1(configuration: config).model
            self.model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("Error al cargar el modelo ML (MyIjmageClassifier_1): \(error)")
            self.model = nil
        }
    }
    
    func predict(image: UIImage) async throws -> String? {
        guard let model = model,
              let ciImage = CIImage(image: image) else {
            print("Modelo no cargado o imagen inválida")
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if didResume { return }
                didResume = true
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let results = request.results as? [VNClassificationObservation],
                   let topResult = results.first {
                    print("ML Prediction: \(topResult.identifier) - Confidence: \(topResult.confidence)")
                    continuation.resume(returning: topResult.identifier)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                if !didResume {
                    didResume = true
                    print("Error executing VNImageRequestHandler: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
