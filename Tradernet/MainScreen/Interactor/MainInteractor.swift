protocol MainInteractorInputProtocol: AnyObject {
    func getTopSecurities()
    func subscribeToQuotes(tickers: [String]?)
}

protocol MainInteractorOutputProtocol: AnyObject {
    func didGetTopSecurities(securities: SecurityViewModel)
    func didNotGetTopSecurities(error: String)
    func receievedQuote(_ quote: QuoteModel)
    func socketError(error: String)
}

class MainInteractor: MainInteractorInputProtocol {
    weak var presenter: MainInteractorOutputProtocol?
    let socketService: QuotesWebSocketServiceProtocol
    let networkService: NetworkServiceProtocol
    let defaultListOfStocks: [String] = ["SP500.IDX", "AAPL.US", "RSTI", "GAZP", "MRKZ", "RUAL", "HYDR", "MRKS", "SBER", "FEES", "TGKA", "VTBR", "ANH.US", "VICL.US", "BURG.US", "NBL.US", "YETI.US", "WSFS.US", "NIO.US", "DXC.US", "MIC.US", "HSBC.US", "EXPN.EU", "GSK.EU", "SHP.EU", "MAN.EU", "DB1.EU", "MUV2.EU", "TATE.EU", "KGF.EU", "MGGT.EU", "SGGD.EU"]

    init(socketService: QuotesWebSocketServiceProtocol, networkService: NetworkServiceProtocol) {
        self.socketService = socketService
        self.networkService = networkService
    }

    func getTopSecurities() {
        networkService.getTopSecurities { [weak self] result in
            switch result {
            case .success(let securities):
                let securities = SecurityViewModel(from: securities)
                self?.presenter?.didGetTopSecurities(securities: securities)
            case .failure(let error):
                print("Failed to fetch securities: \(error)")
                self?.presenter?.didNotGetTopSecurities(error: error.localizedDescription)
            }
        }
    }

    func subscribeToQuotes(tickers: [String]?) {
        socketService.setMessageHandler { [weak self] quote in
            self?.presenter?.receievedQuote(quote)
        }
        socketService.setErrorHandler { [weak self] error in
            print("WebSocket error: \(error.localizedDescription)")
            self?.presenter?.socketError(error: error.localizedDescription)
        }
        Task {
            await socketService.connect()
            if let tickers {
                await socketService.subscribe(to: tickers)
            } else {
                await socketService.subscribe(to: defaultListOfStocks)
            }
        }
    }
    
    func disconnectFromQuotes() {
        socketService.disconnect()
    }
}
