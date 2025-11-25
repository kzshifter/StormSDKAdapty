import Foundation
import Adapty

actor PlacementBag {
    private(set) var placementIdentifiers: [String] = []
    private(set) var entries: [PlacementEntry] = []
    
    init(_ identifiers: [String], locale: String) async throws {
        self.placementIdentifiers = identifiers
        
        for id in identifiers {
            let paywall = try await Adapty.getPaywall(placementId: id, locale: locale)
            let products = try await Adapty.getPaywallProducts(paywall: paywall)
            
            // get remoteConfig data
            let remoteConfigData = paywall.remoteConfig?.jsonString.data(using: .utf8)
            
            let isViewPaywallType: AdaptyPaywallViewType =
            if paywall.hasViewConfiguration {
                .builder
            } else {
                .local((paywall.remoteConfig?.dictionary?["identifier"] as? String) ??
                       paywall.name.components(separatedBy: "-").first?.lowercased() ?? "")
            }
            
            let placementObject = PlacementEntry(placementId: id,
                                                 identifier: isViewPaywallType,
                                                 paywall: paywall,
                                                 products: products,
                                                 remoteConfigData: remoteConfigData)
            entries.append(placementObject)
        }
    }
    
    nonisolated
    public func entry(for placementId: String) -> PlacementEntry? {
        self.first(where: { $0.placementId == placementId })
    }
}

extension PlacementBag: @preconcurrency Sequence {
    func makeIterator() -> PlacementBagIterator<PlacementEntry> {
        PlacementBagIterator(store: entries)
    }
}

struct PlacementBagIterator<Element>: IteratorProtocol {
    var store: [PlacementEntry] = []
    
    mutating func next() -> PlacementEntry? {
        let str = store.removeFirst()
        guard !store.isEmpty else { return nil }
        
        return str
    }
}
