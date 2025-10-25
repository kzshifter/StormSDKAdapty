import Foundation

enum StormSDKError: String {
    case fallbackEmpty = "Fallback file is empty"
    case fallbackInstallError = "Fallback does't install"
    case buildPlacementEntry = "When the placement entry is being built, any errors should be caught."
    
    static func logError(key: StormSDKError, error: (any Error)? = nil) {
        if let error = error {
            NSLog("StormSDKError: \(key.rawValue) with error: \(error.localizedDescription)")
        } else {
            NSLog("StormSDKError: \(key.rawValue)")
        }
    }
}
