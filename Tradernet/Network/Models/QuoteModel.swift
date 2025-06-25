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
}
