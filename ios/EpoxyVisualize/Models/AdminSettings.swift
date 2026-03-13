import Foundation

struct AdminSettings: Codable, Sendable {
    var flakePricePerSqFt: Double
    var metallicPricePerSqFt: Double
    var quartzPricePerSqFt: Double
    var solidColorPricePerSqFt: Double
    var laborRatePerSqFt: Double
    var minimumJobPrice: Double
    var materialUpchargePercent: Double

    static let defaultSettings = AdminSettings(
        flakePricePerSqFt: 6.50,
        metallicPricePerSqFt: 9.00,
        quartzPricePerSqFt: 7.50,
        solidColorPricePerSqFt: 5.00,
        laborRatePerSqFt: 3.50,
        minimumJobPrice: 1500.0,
        materialUpchargePercent: 15.0
    )

    func pricePerSqFt(for type: EpoxyType) -> Double {
        switch type {
        case .flake: return flakePricePerSqFt
        case .metallic: return metallicPricePerSqFt
        case .quartz: return quartzPricePerSqFt
        case .solidColor: return solidColorPricePerSqFt
        }
    }

    func calculateQuote(sqft: Double, type: EpoxyType) -> QuoteBreakdown {
        let materialCost = sqft * pricePerSqFt(for: type)
        let materialUpcharge = materialCost * (materialUpchargePercent / 100.0)
        let laborCost = sqft * laborRatePerSqFt
        let subtotal = materialCost + materialUpcharge + laborCost
        let total = max(subtotal, minimumJobPrice)
        return QuoteBreakdown(
            squareFootage: sqft,
            epoxyType: type,
            materialCost: materialCost,
            materialUpcharge: materialUpcharge,
            laborCost: laborCost,
            subtotal: subtotal,
            total: total,
            minimumApplied: subtotal < minimumJobPrice
        )
    }
}

nonisolated struct QuoteBreakdown: Sendable {
    let squareFootage: Double
    let epoxyType: EpoxyType
    let materialCost: Double
    let materialUpcharge: Double
    let laborCost: Double
    let subtotal: Double
    let total: Double
    let minimumApplied: Bool
}
