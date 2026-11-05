import Foundation

public final class SetsigClient: @unchecked Sendable {
    public let config: SetsigConfig
    private let session: URLSession

    public init(config: SetsigConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    public convenience init(apiKey: String, baseURL: URL = URL(string: "https://api.setsig.com")!) {
        self.init(config: SetsigConfig(apiKey: apiKey, baseURL: baseURL))
    }

    /// Verifies physical presence using dynamic TOTP token and device GPS coordinates.
    public func verifyPresence(request: VerifySessionRequest) async throws -> VerifySessionResponse {
        let endpoint = config.baseURL.appendingPathComponent("v1/sessions/verify")
        var urlReq = URLRequest(url: endpoint)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        urlReq.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: urlReq)
        guard let httpRes = response as? HTTPURLResponse, (200...299).contains(httpRes.statusCode) else {
            throw NSError(domain: "SetsigError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [
                NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "Verification rejected"
            ])
        }

        let decoder = JSONDecoder()
        if let envelope = try? decoder.decode([String: VerifySessionResponse].self, from: data), let parsed = envelope["data"] {
            return parsed
        }
        return try decoder.decode(VerifySessionResponse.self, from: data)
    }

    /// Fetches a dynamic self-refreshing QR payload for kiosk or terminal displays.
    public func generateKioskToken(venueID: String, ttlSeconds: Int = 60) async throws -> KioskTokenResponse {
        let endpoint = config.baseURL.appendingPathComponent("v1/tokens/generate")
        var urlReq = URLRequest(url: endpoint)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "venue_id": venueID,
            "ttl_seconds": ttlSeconds
        ]
        urlReq.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await session.data(for: urlReq)
        let decoder = JSONDecoder()
        if let envelope = try? decoder.decode([String: KioskTokenResponse].self, from: data), let parsed = envelope["data"] {
            return parsed
        }
        return try decoder.decode(KioskTokenResponse.self, from: data)
    }

    /// Acquires a presigned URL to upload a visual proof photo directly to the cloud.
    public func acquireVisualProofUploadURL(venueID: String) async throws -> VerifyIntentResponse {
        let endpoint = config.baseURL.appendingPathComponent("v1/sessions/verify-intent")
        var urlReq = URLRequest(url: endpoint)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        let body = ["venue_id": venueID]
        urlReq.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await session.data(for: urlReq)
        let decoder = JSONDecoder()
        if let envelope = try? decoder.decode([String: VerifyIntentResponse].self, from: data), let parsed = envelope["data"] {
            return parsed
        }
        return try decoder.decode(VerifyIntentResponse.self, from: data)
    }
}

