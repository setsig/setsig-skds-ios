import Foundation
import DeviceCheck
import CryptoKit

public actor AppAttestService {
    public static let shared = AppAttestService()

    private let service = DCAppAttestService.shared

    public init() {}

    public var isSupported: Bool {
        service.isSupported
    }

    /// Generates or retrieves hardware key and creates an Apple App Attest token bound to client challenge.
    public func generateAttestation(clientToken: String, challenge: String) async throws -> String {
        guard service.isSupported else {
            return "ios_unsupported_simulated_token"
        }

        // Generate cryptographic key on Secure Enclave
        let keyId = try await service.generateKey()

        // Create SHA-256 client data hash
        let clientData = "\(clientToken):\(challenge)".data(using: .utf8)!
        let clientDataHash = Data(SHA256.hash(data: clientData))

        // Request Apple App Attestation statement
        let attestation = try await service.attestKey(keyId, clientDataHash: clientDataHash)
        return attestation.base64EncodedString()
    }
}

