protocol MainInteractorProtocol: AnyObject {
    func fetchItems()
    func subscribeToQuotes()
}

protocol MainInteractorOutputProtocol: AnyObject {
    func didFetch(items: [MainEntity])
    func receievedQuote(_ quote: QuoteViewModel)
}

class MainInteractor: MainInteractorProtocol {
    weak var presenter: MainInteractorOutputProtocol?
    let socketService: QuotesWebSocketServiceProtocol

    init(socketService: QuotesWebSocketServiceProtocol) {
        self.socketService = socketService
    }

    func fetchItems() {
        let items = [
            MainEntity(title: "Item 1"),
            MainEntity(title: "Item 2"),
            MainEntity(title: "Item 3")
        ]
        subscribeToQuotes()
        presenter?.didFetch(items: items)
    }

    func subscribeToQuotes() {
        socketService.setMessageHandler { [weak self] quote in
            let viewModel = QuoteViewModel(model: quote)
            print("Received quote: \(quote.symbol)")
            self?.presenter?.receievedQuote(viewModel)
        }

        Task {
            await socketService.connect()
            // await socketService.subscribe(to: ["AAPL.US", "GAZP", "SBER"])
            await socketService.subscribe(to: ["SP500.IDX", "AAPL.US", "RSTI", "GAZP", "MRKZ", "RUAL", "HYDR", "MRKS", "SBER", "FEES", "TGKA", "VTBR", "ANH.US", "VICL.US", "BURG.US", "NBL.US", "YETI.US", "WSFS.US", "NIO.US", "DXC.US", "MIC.US", "HSBC.US", "EXPN.EU", "GSK.EU", "SHP.EU", "MAN.EU", "DB1.EU", "MUV2.EU", "TATE.EU", "KGF.EU", "MGGT.EU", "SGGD.EU"])
        }
    }
    
    func disconnectFromQuotes() {
        socketService.disconnect()
    }
}
