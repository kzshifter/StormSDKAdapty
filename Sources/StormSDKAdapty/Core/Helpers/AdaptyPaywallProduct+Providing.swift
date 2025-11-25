import Foundation
import Adapty

fileprivate enum Period {
    case week, month, year, day
    
    func description(isAdaptiveName: Bool, periodValue: Int) -> String {
        switch self {
        case .week:
            return isAdaptiveName ? "weekly" : "week"
        case .month:
            return isAdaptiveName ? "monthly" : "month"
        case .year:
            return isAdaptiveName ? "yearly" : "year"
        case .day:
            if periodValue % 7 == 0 {
                return isAdaptiveName ? "weekly" : "week"
            } else {
                return isAdaptiveName ? "day" : "day"
            }
        }
    }
}

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}

extension AdaptyPaywallProduct {
    
    public func replacingPlaceholders(
         in text: String,
         multiplicatorValue: Double = 1.0,
         additionalPlaceholders: [String: String] = [:]
     ) -> String {
         
         var result = text
         
         let defaultPlaceholders: [String: String] = [
             "%subscriptionPrice%": descriptionPrice(multiplicatorValue: multiplicatorValue),
             "%subscriptionPeriod%": descriptionPeriod()
         ]
         
         let placeholders = defaultPlaceholders.merging(additionalPlaceholders) { _, new in new }
         
         for (key, value) in placeholders {
             result = result.replacingOccurrences(of: key, with: value)
         }
         
         return result
     }
    
    public func descriptionPrice(multiplicatorValue: Double = 1.0) -> String {
        self.sk1Product != nil ?
        String(format: "\(self.priceLocale.currencySymbol ?? "")%.2f", (self.sk1Product?.price.doubleValue ?? 0) * multiplicatorValue) :
        String(format: "\(self.priceLocale.currencySymbol ?? "")%.2f", (self.sk2Product?.price.doubleValue ?? 0) * multiplicatorValue)
    }
    
    public func descriptionPeriod(isAdaptiveName: Bool = false) -> String {
        self.sk1Product != nil ?
        self.sk1Period(for: self, isAdaptiveName: isAdaptiveName) :
        self.sk2Period(for: self, isAdaptiveName: isAdaptiveName)
    }
    
    private func sk1Period(for product: AdaptyPaywallProduct, isAdaptiveName: Bool = false) -> String {
        guard let period = product.sk1Product?.subscriptionPeriod else {
            return ""
        }
        let periodValue = period.numberOfUnits
        return switch period.unit {
        case .day: Period.day.description(isAdaptiveName: isAdaptiveName, periodValue: periodValue)
        case .week: Period.week.description(isAdaptiveName: isAdaptiveName, periodValue: periodValue)
        case .month: Period.month.description(isAdaptiveName: isAdaptiveName, periodValue: periodValue)
        case .year: Period.year.description(isAdaptiveName: isAdaptiveName, periodValue: periodValue)
        @unknown default: Period.day.description(isAdaptiveName: isAdaptiveName, periodValue: periodValue)
        }
    }
    
    private func sk2Period(for product: AdaptyPaywallProduct, isAdaptiveName: Bool = false) -> String {
        guard let subscription = product.sk2Product?.subscription else {
            return ""
        }
        
        let period = subscription.subscriptionPeriod
        return switch period.unit {
        case .day: Period.day.description(isAdaptiveName: isAdaptiveName, periodValue: period.value)
        case .week: Period.week.description(isAdaptiveName: isAdaptiveName, periodValue: period.value)
        case .month: Period.month.description(isAdaptiveName: isAdaptiveName, periodValue: period.value)
        case .year: Period.year.description(isAdaptiveName: isAdaptiveName, periodValue: period.value)
        @unknown default: Period.day.description(isAdaptiveName: isAdaptiveName, periodValue: period.value)
        }
    }
}
