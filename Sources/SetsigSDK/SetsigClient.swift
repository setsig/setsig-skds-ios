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
        guard let httpRes = response as? HTTPURLResponse else {
            throw SetsigError.apiError(statusCode: 500, code: "ERR_NETWORK", message: "Invalid HTTP response")
        }

        if !(200...299).contains(httpRes.statusCode) {
            let errorJson = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
            let code = (errorJson["error_code"] as? String) ?? (errorJson["code"] as? String) ?? "ERR_UNKNOWN"
            let message = (errorJson["message"] as? String) ?? String(data: data, encoding: .utf8) ?? "API Error"
            let details = errorJson["details"] as? [String: Any]

            switch code {
            case "ERR_PAYWALL_BLOCKED":
                throw SetsigError.paywallBlocked(
                    paywallURL: details?["paywall_url"] as? String,
                    currentBalance: details?["current_balance"] as? Double,
                    message: message
                )
            case "ERR_CROSS_BORDER_CREDIT_REQUIRED":
                throw SetsigError.crossBorderCreditRequired(message)
            case "ERR_PAYWALL_TIER_REQUIRED":
                throw SetsigError.paywallTierRequired(message)
            case "ERR_ATTESTATION_FAILED":
                throw SetsigError.attestationFailed(message)
            case "ERR_VISUAL_PROOF_REQUIRED":
                throw SetsigError.visualProofRequired(message)
            case "ERR_STALE_VISUAL_PROOF":
                throw SetsigError.staleVisualProof(message)
            case "ERR_INVALID_IMAGE_HASH":
                throw SetsigError.invalidImageHash(message)
            case "ERR_GEOFENCE_OUT_OF_BOUNDS":
                throw SetsigError.geofenceOutOfBounds(message)
            case "ERR_REPLAY_DETECTED":
                throw SetsigError.replayDetected(message)
            default:
                if httpRes.statusCode == 401 || httpRes.statusCode == 403 {
                    throw SetsigError.authenticationFailed(message)
                } else if httpRes.statusCode == 402 {
                    throw SetsigError.insufficientCredits(message)
                } else if httpRes.statusCode == 429 {
                    throw SetsigError.rateLimitExceeded(message)
                }
                throw SetsigError.apiError(statusCode: httpRes.statusCode, code: code, message: message)
            }
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

