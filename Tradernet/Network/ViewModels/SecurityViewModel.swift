struct QuoteViewModel {
    let ticker: String
    let displayName: String
    let formattedPrice: String
}

extension QuoteViewModel {
    init(from security: Security) {
        self.ticker = security.symbol
        self.displayName = security.name ?? "Unknown"
        self.formattedPrice = security.price.map { String(format: "%.2f ₽", $0) } ?? "-"
    }
}
