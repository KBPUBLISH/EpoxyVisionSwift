import SwiftUI
import UIKit

@Observable
@MainActor
class VisualizationService {
    var isGenerating = false
    var generatedImage1: UIImage?
    var generatedImage2: UIImage?
    var errorMessage: String?

    func generateVisualization(originalImage: UIImage, epoxyType: EpoxyType, styleName: String) async {
        isGenerating = true
        generatedImage1 = nil
        generatedImage2 = nil
        errorMessage = nil

        guard let imageData = originalImage.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Failed to process image"
            isGenerating = false
            return
        }

        let base64 = imageData.base64EncodedString()

        if AdminApiService.hasApi {
            await callBackendVisualize(base64: base64, epoxyType: epoxyType, styleName: styleName)
        } else {
            let prompt = buildPrompt(epoxyType: epoxyType, styleName: styleName)
            async let result1 = callRorkAPI(base64: base64, prompt: prompt + " Variation 1: slightly different angle of light reflection.")
            async let result2 = callRorkAPI(base64: base64, prompt: prompt + " Variation 2: slightly different ambient lighting conditions.")
            let (img1, img2) = await (result1, result2)
            if let img1 { generatedImage1 = img1 }
            if let img2 { generatedImage2 = img2 }
        }

        if generatedImage1 == nil && generatedImage2 == nil {
            errorMessage = "Failed to generate visualizations. Please try again."
        }

        isGenerating = false
    }

    private func epoxyTypeApiValue(_ type: EpoxyType) -> String {
        switch type {
        case .flake: return "flake"
        case .metallic: return "metallic"
        case .quartz: return "quartz"
        case .solidColor: return "solid"
        }
    }

    private func callBackendVisualize(base64: String, epoxyType: EpoxyType, styleName: String) async {
        guard let url = AdminApiService.apiURL("api/visualize") else {
            errorMessage = "API URL not configured"
            return
        }
        let photoBase64 = "data:image/jpeg;base64,\(base64)"
        let body: [String: Any] = [
            "photo": photoBase64,
            "epoxyType": epoxyTypeApiValue(epoxyType),
            "colorOrBlend": styleName
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.timeoutInterval = 120

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode != 200 {
                errorMessage = "Server error (\(httpResponse.statusCode))"
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let afterVal = json["after"] else {
                errorMessage = "Invalid response"
                return
            }
            // after can be base64 data URL or signed GCS URL
            if let urlString = afterVal as? String {
                if urlString.hasPrefix("data:image") {
                    let b64 = urlString.components(separatedBy: ",").last ?? ""
                    if let imgData = Data(base64Encoded: b64), let img = UIImage(data: imgData) {
                        generatedImage1 = img
                    }
                } else if let url = URL(string: urlString),
                          let imgData = try? Data(contentsOf: url),
                          let img = UIImage(data: imgData) {
                    generatedImage1 = img
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func buildPrompt(epoxyType: EpoxyType, styleName: String) -> String {
        let base = "Transform this floor photo to show a professionally installed \(epoxyType.rawValue.lowercased()) epoxy floor coating in the '\(styleName)' style."
        switch epoxyType {
        case .flake:
            return base + " Apply a seamless epoxy base coat with decorative vinyl flake chips scattered evenly across the surface. The flakes should look embedded in clear epoxy with a smooth glossy finish. Keep the room walls, furniture and surroundings exactly the same."
        case .metallic:
            return base + " Apply a metallic epoxy coating with a pearlescent swirl pattern that creates depth and movement. The finish should be highly reflective with a glass-like appearance. Keep the room walls, furniture and surroundings exactly the same."
        case .quartz:
            return base + " Apply a quartz epoxy broadcast system with a natural stone-like granular texture. The finish should appear as a uniform quartz aggregate surface with a slight sheen. Keep the room walls, furniture and surroundings exactly the same."
        case .solidColor:
            return base + " Apply a solid color epoxy floor coating with a uniform, smooth, high-gloss finish. The color should be even and consistent across the entire floor. Keep the room walls, furniture and surroundings exactly the same."
        }
    }

    private nonisolated func callRorkAPI(base64: String, prompt: String) async -> UIImage? {
        guard let url = URL(string: "https://toolkit.rork.com/images/edit/") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let body: [String: Any] = [
            "prompt": prompt,
            "images": [["type": "image", "image": base64]],
            "aspectRatio": "4:3"
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let imageObj = json["image"] as? [String: Any],
                  let base64Data = imageObj["base64Data"] as? String,
                  let imageData = Data(base64Encoded: base64Data) else { return nil }
            return UIImage(data: imageData)
        } catch {
            return nil
        }
    }
}
