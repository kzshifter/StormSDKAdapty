import Adapty

public struct StormSDKAdaptyConfiguration: Sendable {
    let apiKey: String
    let placementIdentifers: [String]
    let accessLevels: [AccessLevel]
    let storeKitVersion: StoreKitVersion
    let logLevel: AdaptyLog.Level
    let chinaClusterEnable: Bool
    let fallbackName: String?
    let languageCode: String
    
    public init(apiKey: String,
                placementIdentifers: [String],
                accessLevels: [AccessLevel],
                storeKitVersion: StoreKitVersion = .v1,
                logLevel: AdaptyLog.Level = .verbose,
                chinaClusterEnable: Bool = true,
                fallbackName: String? = nil,
                language: String = "en") {
        self.apiKey = apiKey
        self.placementIdentifers = placementIdentifers
        self.accessLevels = accessLevels
        self.storeKitVersion = storeKitVersion
        self.chinaClusterEnable = chinaClusterEnable
        self.logLevel = logLevel
        self.fallbackName = fallbackName
        self.languageCode = language
    }
}
