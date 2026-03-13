import Foundation

struct EpoxyProject: Identifiable, Codable, Sendable {
    let id: String
    let createdAt: Date
    var epoxyType: EpoxyType
    var styleName: String
    var originalImageData: Data?
    var generatedImageData1: Data?
    var generatedImageData2: Data?
    var squareFootage: Double?
    var quoteTotal: Double?

    init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        epoxyType: EpoxyType,
        styleName: String,
        originalImageData: Data? = nil,
        generatedImageData1: Data? = nil,
        generatedImageData2: Data? = nil,
        squareFootage: Double? = nil,
        quoteTotal: Double? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.epoxyType = epoxyType
        self.styleName = styleName
        self.originalImageData = originalImageData
        self.generatedImageData1 = generatedImageData1
        self.generatedImageData2 = generatedImageData2
        self.squareFootage = squareFootage
        self.quoteTotal = quoteTotal
    }
}
