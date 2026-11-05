# SetsigSDK for iOS

Official Swift Package for [setsig.com](https://setsig.com) — Physical Presence & Verification Infrastructure (PaaS/IaaS).

Supports **iOS 15.0+**, **macOS 12.0+**, **Apple App Attest**, CoreLocation, and SwiftUI.

---

## 📦 Installation via Swift Package Manager

In Xcode:
1. Go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/setsig/setsig-ios.git
   ```
3. Select **Up to Next Major Version** starting from `1.0.0`.

Or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/setsig/setsig-ios.git", from: "1.0.0")
]
```

---

## 🚀 Usage

### 1. Initialize the Client

```swift
import SetsigSDK

let client = SetsigClient(
    apiKey: "pk_live_your_public_api_key",
    baseURL: URL(string: "https://api.setsig.com")!
)
```

### 2. Verify Presence with Telemetry

```swift
let request = VerifySessionRequest(
    venueID: "ven_workshop_01",
    tokenID: scannedTokenID,
    clientToken: "clt_\(UUID().uuidString)",
    coordinates: Coordinates(
        latitude: location.coordinate.latitude,
        longitude: location.coordinate.longitude,
        accuracy: location.horizontalAccuracy
    )
)

do {
    let result = try await client.verifyPresence(request: request)
    if result.status == "verified" {
        print("Presence Verified! Distance: \(result.distanceMeters)m")
    }
} catch {
    print("Verification Error: \(error.localizedDescription)")
}
```

### 3. Display Kiosk Dynamic QR in SwiftUI

```swift
import SwiftUI
import SetsigSDK

struct KioskScreen: View {
    let client = SetsigClient(apiKey: "pk_live_kiosk_key")

    var body: some View {
        SetsigKioskView(
            client: client,
            venueID: "ven_turnstile_01",
            refreshIntervalSeconds: 60
        )
    }
}
```

---

## 📄 License

Apache-2.0 © setsig.com & AVCI Ventures

