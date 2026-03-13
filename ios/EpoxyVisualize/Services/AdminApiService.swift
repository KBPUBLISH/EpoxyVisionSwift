import Foundation

/// Shared Admin API — used by both web and Swift apps.
/// Set `baseURL` to your deployed API (e.g. https://your-api.example.com).
/// When nil, falls back to local UserDefaults.
enum AdminApiService {
    /// Configure in Config.adminApiBaseURL or set via setBaseURL(). Use same URL as web app's VITE_ADMIN_API_URL.
    static var baseURL: String? = Config.adminApiBaseURL
        ?? ProcessInfo.processInfo.environment["ADMIN_API_URL"]
        ?? UserDefaults.standard.string(forKey: "epoxy_admin_api_url")

    static func setBaseURL(_ url: String?) {
        UserDefaults.standard.set(url, forKey: "epoxy_admin_api_url")
        Self.baseURL = url
    }

    static var hasApi: Bool {
        guard let base = baseURL, !base.isEmpty else { return false }
        return URL(string: base) != nil
    }

    static func apiURL(_ path: String) -> URL? {
        guard let base = baseURL?.trimmingCharacters(in: CharacterSet(charactersIn: "/")) else { return nil }
        return URL(string: "\(base)/\(path)".replacingOccurrences(of: "//", with: "/"))
    }

    static func fetchAdminSettings() async -> AdminSettings {
        guard let url = apiURL("api/admin-settings") else {
            return .defaultSettings
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(AdminSettings.self, from: data)
            return decoded
        } catch {
            return .defaultSettings
        }
    }

    static func verifyAdminPin(_ pin: String) async -> Bool {
        guard let url = apiURL("api/admin-verify") else {
            return false
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(["pin": pin])
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return false }
            let decoded = try JSONDecoder().decode(VerifyResponse.self, from: data)
            return decoded.valid
        } catch {
            return false
        }
    }

    static func saveAdminSettings(currentPIN: String, newPIN: String? = nil, settings: AdminSettings? = nil) async -> Bool {
        guard let url = apiURL("api/admin-settings") else {
            return false
        }
        var body: [String: Any] = ["currentPIN": currentPIN]
        if let np = newPIN, np.count >= 4 { body["newPIN"] = np }
        if let s = settings {
            body["settings"] = [
                "flakePricePerSqFt": s.flakePricePerSqFt,
                "metallicPricePerSqFt": s.metallicPricePerSqFt,
                "quartzPricePerSqFt": s.quartzPricePerSqFt,
                "solidColorPricePerSqFt": s.solidColorPricePerSqFt,
                "laborRatePerSqFt": s.laborRatePerSqFt,
                "minimumJobPrice": s.minimumJobPrice,
                "materialUpchargePercent": s.materialUpchargePercent
            ]
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = jsonData
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            return (resp as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    private struct VerifyResponse: Decodable {
        let valid: Bool
    }
}
