class QuoteViewModel {
    let ticker: String
    let name: String
    let exchange: String
    let lastPrice: String
    let changeValue: String
    let changePercent: Double
    let isPositiveChange: Bool
    var percentChangeType: PercentChangeType = .noChange
    let model: QuoteModel
    
    var changePercentString: String {
        return String(format: "%+.2f%%", changePercent)
    }

    init(model: QuoteModel, decimalPlaces: Int = 2) {
        self.model = model
        self.ticker = model.symbol
        self.name = model.name ?? ""
        self.exchange = model.exchange ?? ""

        if let price = model.lastPrice {
            self.lastPrice = String(format: "%.\(decimalPlaces)f", price)
        } else {
            self.lastPrice = "-"
        }

        if let chg = model.change {
            self.changeValue = String(format: "%+.\(decimalPlaces)f", chg)
        } else {
            self.changeValue = ""
        }

        if let pcp = model.percentChange {
            self.changePercent = pcp
            self.isPositiveChange = pcp >= 0
        } else {
            self.changePercent = 0
            self.isPositiveChange = true
        }
    }
}

extension QuoteViewModel {
    func merging(with newModel: QuoteModel, decimalPlaces: Int) -> QuoteViewModel {
        return QuoteViewModel(model: QuoteModel(
            symbol: newModel.symbol,
            name: name,
            exchange: exchange,
            lastPrice: newModel.lastPrice ?? model.lastPrice,
            change: newModel.change ?? model.change,
            percentChange: newModel.percentChange ?? model.percentChange,
            bid: newModel.bid ?? model.bid,
            ask: newModel.ask ?? model.ask,
            volume: newModel.volume ?? model.volume
        ), decimalPlaces: decimalPlaces)
    }
}