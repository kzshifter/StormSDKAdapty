import Adapty
import AdaptyUI
import Foundation

public protocol StormSDKAdaptyProviding {
    func validateSubscription(for accessLevels: [AccessLevel]) async -> AccessEntry
    func placementEntry(with placementId: String) async -> PlacementEntry?
    func remoteConfig<T>(for placementId: String) async -> T?  where T: Decodable
    
    func purchase(with product: any AdaptyPaywallProduct) async throws -> AdaptyPurchaseResult
    func restore(for accessLevels: AccessLevel) async throws -> AccessEntry
    
    // logging
    func logPaywall(from placementId: String) async
    func logPaywall(with paywall: AdaptyPaywall) async
}

public actor StormSDKAdapty {
    
    private var placementBag: PlacementBag?
    
    private let localizer = JSONLocalizer()
    
    public func start(config: StormSDKAdaptyConfiguration) {
        
        let serverCluster: AdaptyConfiguration.ServerCluster = Locale.current.regionCode == "CN" ? .cn : .default
        
        let configuration = AdaptyConfiguration
            .builder(withAPIKey: config.apiKey)
            .with(storeKitVersion: config.storeKitVersion)
            .with(serverCluster: serverCluster)
        
        Adapty.activate(with: configuration.build())
        AdaptyUI.activate()
        Adapty.logLevel = config.logLevel
        
        // strat fetch and build adapty data
        Task {
            await setFallback(config.fallbackName)
            self.placementBag = await buildPlacementBag(placementIdentifers: config.placementIdentifers)
        }
    }
    
    private func setFallback(_ fallbackName: String?) async {
        guard let fallbackURL = Bundle.main.url(forResource: fallbackName, withExtension: "json") else {
            StormSDKError.logError(key: .fallbackEmpty)
            return
        }

        do {
            try await Adapty.setFallback(fileURL: fallbackURL)
        } catch {
            StormSDKError.logError(key: .fallbackInstallError, error: error)
        }
    }
    
    private func buildPlacementBag(placementIdentifers: [String]) async -> PlacementBag?  {
        do {
            return try await PlacementBag(placementIdentifers, locale: Locale.current.identifier)
        } catch let error {
            StormSDKError.logError(key: .buildPlacementEntry, error: error)
            return nil
        }
    }
}

extension StormSDKAdapty: StormSDKAdaptyProviding {
    
    public func validateSubscription(for accessLevels: [AccessLevel] = [.premium]) async -> AccessEntry {
        for level in accessLevels {
            if let access = (try? await Adapty.getProfile())?.accessLevels[level.rawValue] {
                return AccessEntry(isActive: access.isActive, isRenewable: access.willRenew)
            }
        }
        
        return AccessEntry(isActive: false, isRenewable: false)
    }
    
    public func placementEntry(with placementId: String) async -> PlacementEntry? {
        await placementBag?.entry(for: placementId)
    }
    
    public func remoteConfig<T: Sendable>(for placementId: String) async -> T? where T: Decodable {
        guard let remoteConfigData = await self.placementBag?.entry(for: placementId)?.remoteConfigData else {
            return nil
        }
        return try? localizer.decode(from: remoteConfigData)
    }
    
    public func purchase(with product: any AdaptyPaywallProduct) async throws -> AdaptyPurchaseResult {
        do {
            let result = try await Adapty.makePurchase(product: product)
            if result.isPurchaseSuccess {
                // track here
                
            }
            return result
        } catch let error {
            throw error
        }
    }
    
    public func restore(for accessLevels: AccessLevel = .premium) async throws -> AccessEntry {
        let result = try await Adapty.restorePurchases().accessLevels[accessLevels.rawValue]
        return AccessEntry(isActive: result?.isActive ?? false, isRenewable: result?.willRenew ?? false)
    }
    
    public func logPaywall(from placementId: String) {
        Task.detached(operation: {
            guard let entry = await self.placementBag?.entry(for: placementId) else { return }
            try await Adapty.logShowPaywall(entry.paywall)
        })
    }
    
    public func logPaywall(with paywall: AdaptyPaywall) {
        Task.detached(operation: {
            try await Adapty.logShowPaywall(paywall)
        })
    }
}


extension StormSDKAdapty {
    
    public func validateSubscription(
        for accessLevels: [AccessLevel] = [.premium],
        completion: @escaping (AccessEntry) -> Void
    ) {
        Task {
            let result = await validateSubscription(for: accessLevels)
            await MainActor.run {
                completion(result)
            }
        }
    }
    
    public func placementEntry(
        with placementId: String,
        completion: @escaping (PlacementEntry?) -> Void
    ) {
        Task {
            let result = await placementEntry(with: placementId)
            await MainActor.run {
                completion(result)
            }
        }
    }
    
    public func remoteConfig<T: Sendable>(
        for placementId: String,
        completion: @escaping (T?) -> Void
    ) where T: Decodable {
        Task {
            let result: T? = await remoteConfig(for: placementId)
            await MainActor.run {
                completion(result)
            }
        }
    }
    
    public func purchase(
        with product: any AdaptyPaywallProduct,
        completion: @escaping (Result<AdaptyPurchaseResult, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await purchase(with: product)
                await MainActor.run {
                    completion(.success(result))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func restore(
        for accessLevels: AccessLevel = .premium,
        completion: @escaping (Result<AccessEntry, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await restore(for: accessLevels)
                await MainActor.run {
                    completion(.success(result))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
