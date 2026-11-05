import Foundation

public enum SetsigError: Error, LocalizedError, Sendable {
    case authenticationFailed(String)
    case insufficientCredits(String)
    case paywallBlocked(paywallURL: String?, currentBalance: Double?, message: String)
    case crossBorderCreditRequired(String)
    case paywallTierRequired(String)
    case attestationFailed(String)
    case visualProofRequired(String)
    case staleVisualProof(String)
    case invalidImageHash(String)
    case geofenceOutOfBounds(String)
    case replayDetected(String)
    case rateLimitExceeded(String)
    case apiError(statusCode: Int, code: String, message: String)

    public var errorDescription: String? {
        switch self {
        case .paywallBlocked(let url, let bal, let msg):
            return "Setsig Paywall Blocked: \(msg) (Balance: \(bal ?? 0), Top up: \(url ?? ""))"
        case .insufficientCredits(let msg):
            return "Setsig Insufficient Credits: \(msg)"
        case .crossBorderCreditRequired(let msg):
            return "Setsig Cross Border Credit Required: \(msg)"
        case .paywallTierRequired(let msg):
            return "Setsig Tier Upgrade Required: \(msg)"
        case .attestationFailed(let msg):
            return "Setsig Attestation Failed: \(msg)"
        case .visualProofRequired(let msg):
            return "Setsig Visual Proof Required: \(msg)"
        case .staleVisualProof(let msg):
            return "Setsig Stale Visual Proof: \(msg)"
        case .invalidImageHash(let msg):
            return "Setsig Invalid Image Hash: \(msg)"
        case .geofenceOutOfBounds(let msg):
            return "Setsig Geofence Out Of Bounds: \(msg)"
        case .replayDetected(let msg):
            return "Setsig Replay Detected: \(msg)"
        case .rateLimitExceeded(let msg):
            return "Setsig Rate Limit Exceeded: \(msg)"
        case .authenticationFailed(let msg):
            return "Setsig Authentication Failed: \(msg)"
        case .apiError(let code, let errCode, let msg):
            return "Setsig API Error (HTTP \(code) - \(errCode)): \(msg)"
        }
    }
}

