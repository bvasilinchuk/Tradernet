struct SecurityViewModel {
    let tickers: [String]
}

extension SecurityViewModel {
    init(from securities: SecuritiesModel) {
        self.tickers = securities.tickers ?? []
    }
}
