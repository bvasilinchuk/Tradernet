class QuoteViewModel {
    let ticker: String
    let name: String
    let exchange: String
    var lastPrice: Double
    var changeValue: Double
    var changePercent: Double
    var percentChangeType: PercentChangeType = .noChange
    let decimalPlaces: Int
    
    init(model: QuoteModel, decimalPlaces: Int = 2) {
        ticker = model.symbol
        name = model.name ?? ""
        exchange = model.exchange ?? ""
        lastPrice = model.lastPrice ?? 0
        changeValue = model.change ?? 0
        changePercent = model.percentChange ?? 0
        self.decimalPlaces = decimalPlaces
    }
    
    var lastPriceString: String {
        String(format: "%.\(decimalPlaces)f", lastPrice)
    }
    
    var changeValueString: String {
        String(format: "%+.\(decimalPlaces)f", changeValue)
    }
    
    var changePercentString: String {
        String(format: "%+.2f%%", changePercent)
    }
    
    var isPositivePercentChange: Bool {
        changePercent >= 0
    }
}

extension QuoteViewModel {
    func update(from model: QuoteModel) {
        if let price = model.lastPrice {
            if price > lastPrice {
                percentChangeType = .positive
            } else if price < lastPrice {
                percentChangeType = .negative
            } else {
                percentChangeType = .noChange
            }
            lastPrice = price
        } else {
            percentChangeType = .noChange
        }
        
        if let chg = model.change {
            changeValue = chg
        }
        
        if let pcp = model.percentChange {
            changePercent = pcp
        }
    }
}
