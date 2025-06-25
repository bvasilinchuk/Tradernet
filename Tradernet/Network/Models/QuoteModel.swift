struct QuoteModel {
    let symbol: String
    let name: String?
    let exchange: String?
    let lastPrice: Double?
    let change: Double?
    let percentChange: Double?
    let bid: Double?
    let ask: Double?
    let volume: Double?
    let minStep: Double?

    init?(from dict: [String: Any]) {
        guard let symbol = dict["c"] as? String else { return nil }
        self.symbol = symbol

        self.name = dict["name"] as? String
        self.exchange = dict["ltr"] as? String

        self.lastPrice = dict["ltp"] as? Double
        self.change = dict["chg"] as? Double
        self.percentChange = dict["pcp"] as? Double
        self.bid = dict["bbp"] as? Double
        self.ask = dict["bap"] as? Double
        self.volume = dict["vol"] as? Double
        self.minStep = dict["min_step"] as? Double
    }

    init(
        symbol: String,
        name: String? = nil,
        exchange: String? = nil,
        lastPrice: Double? = nil,
        change: Double? = nil,
        percentChange: Double? = nil,
        bid: Double? = nil,
        ask: Double? = nil,
        volume: Double? = nil,
        minStep: Double? = nil
    ) {
        self.symbol = symbol
        self.name = name
        self.exchange = exchange
        self.lastPrice = lastPrice
        self.change = change
        self.percentChange = percentChange
        self.bid = bid
        self.ask = ask
        self.volume = volume
        self.minStep = minStep
    }
}