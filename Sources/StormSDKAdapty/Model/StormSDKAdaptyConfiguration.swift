import Adapty

public struct StormSDKAdaptyConfiguration {
    let apiKey: String
    let placementIdentifers: [String]
    let storeKitVersion: StoreKitVersion
    let logLevel: AdaptyLog.Level
    let fallbackName: String?
    
    init(apiKey: String,
         placementIdentifers: [String],
         storeKitVersion: StoreKitVersion = .v1,
         logLevel: AdaptyLog.Level = .verbose,
         fallbackName: String? = nil) {
        self.apiKey = apiKey
        self.placementIdentifers = placementIdentifers
        self.storeKitVersion = storeKitVersion
        self.logLevel = logLevel
        self.fallbackName = fallbackName
    }
}
