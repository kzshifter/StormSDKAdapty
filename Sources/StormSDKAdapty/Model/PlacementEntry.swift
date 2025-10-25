import Adapty
import Foundation

public struct PlacementEntry: Sendable {
    let placementId: String
    let identifier: AdaptyPaywallViewType
    let paywall: AdaptyPaywall
    let products: [AdaptyPaywallProduct]
    let remoteConfigData: Data?
}

public enum AdaptyPaywallViewType: Sendable, Hashable {
    case builder
    case local(String)
}
