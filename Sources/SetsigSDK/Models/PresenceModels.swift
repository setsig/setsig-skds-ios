import Foundation

public struct SetsigConfig: Sendable {
    public let apiKey: String
    public let baseURL: URL

    public init(apiKey: String, baseURL: URL = URL(string: "https://api.setsig.com")!) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
}

public struct Coordinates: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    public let altitude: Double?

    public init(latitude: Double, longitude: Double, accuracy: Double, altitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.altitude = altitude
    }
}

public struct VisualProofPayload: Codable, Sendable {
    public let imageHashSHA256: String
    public let storageKey: String
    public let capturedAt: String
    public let livenessScore: Double?

    enum CodingKeys: String, CodingKey {
        case imageHashSHA256 = "image_hash_sha256"
        case storageKey = "storage_key"
        case capturedAt = "captured_at"
        case livenessScore = "liveness_score"
    }

    public init(imageHashSHA256: String, storageKey: String, capturedAt: String = ISO8601DateFormatter().string(from: Date()), livenessScore: Double? = nil) {
        self.imageHashSHA256 = imageHashSHA256
        self.storageKey = storageKey
        self.capturedAt = capturedAt
        self.livenessScore = livenessScore
    }
}

public struct VerifySessionRequest: Codable, Sendable {
    public let venueID: String
    public let tokenID: String
    public let clientToken: String
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    public let altitude: Double?
    public let attestationToken: String?
    public let visualProof: VisualProofPayload?

    enum CodingKeys: String, CodingKey {
        case venueID = "venue_id"
        case tokenID = "token_id"
        case clientToken = "client_token"
        case latitude, longitude, accuracy, altitude
        case attestationToken = "attestation_token"
        case visualProof = "visual_proof"
    }

    public init(
        venueID: String,
        tokenID: String,
        clientToken: String,
        coordinates: Coordinates,
        attestationToken: String? = nil,
        visualProof: VisualProofPayload? = nil
    ) {
        self.venueID = venueID
        self.tokenID = tokenID
        self.clientToken = clientToken
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
        self.accuracy = coordinates.accuracy
        self.altitude = coordinates.altitude
        self.attestationToken = attestationToken
        self.visualProof = visualProof
    }
}

public struct VerifySessionResponse: Codable, Sendable {
    public let sessionID: String
    public let status: String // "verified" | "rejected"
    public let distanceMeters: Double
    public let verifiedAt: String
    public let proofSignature: String?

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case status
        case distanceMeters = "distance_meters"
        case verifiedAt = "verified_at"
        case proofSignature = "proof_signature"
    }
}

public struct KioskTokenResponse: Codable, Sendable {
    public let tokenID: String
    public let qrPayload: String
    public let expiresAt: String
    public let ttlRemaining: Int

    enum CodingKeys: String, CodingKey {
        case tokenID = "token_id"
        case qrPayload = "qr_payload"
        case expiresAt = "expires_at"
        case ttlRemaining = "ttl_remaining"
    }
}

public struct VerifyIntentResponse: Codable, Sendable {
    public let uploadURL: String
    public let storageKey: String
    public let expiresInSeconds: Int

    enum CodingKeys: String, CodingKey {
        case uploadURL = "upload_url"
        case storageKey = "storage_key"
        case expiresInSeconds = "expires_in_seconds"
    }
}

