import Foundation

protocol MainTableManagerInput: AnyObject {
    func configure(with items: [QuoteViewModel])
}

protocol MainPresenterProtocol: AnyObject {
    func viewDidLoad()
    func subscribeToDefaultQuotes()
    func resubscribeToQuotes()
}

class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewInputProtocol?
    var interactor: MainInteractorInputProtocol?
    var router: MainRouterProtocol?

    private var tickers: [String] = []
    private var quotes: [String: QuoteViewModel] = [:]
    private var minStepCache: [String: Double] = [:]

    var tableManager: MainTableManagerInput?

    func viewDidLoad() {
        view?.showLoader()
        interactor?.getTopSecurities()
    }
    
    func subscribeToDefaultQuotes() {
        interactor?.subscribeToQuotes(tickers: nil)
    }
    
    func resubscribeToQuotes() {
        interactor?.subscribeToQuotes(tickers: tickers)
    }
}

extension MainPresenter: MainInteractorOutputProtocol {
    func receievedQuote(_ quoteModel: QuoteModel) {
        let ticker = quoteModel.symbol
        
        if let step = quoteModel.minStep {
            minStepCache[ticker] = step
        }
        let step = minStepCache[ticker] ?? 0.01
        let decimalPlaces = decimalPlaces(from: Decimal(step))
        
        if let current = quotes[ticker] {
            current.update(from: quoteModel)
        } else {
            let quoteViewModel = QuoteViewModel(model: quoteModel, decimalPlaces: decimalPlaces)
            quotes[ticker] = quoteViewModel
        }
        let sortedQuotes = quotes.values.sorted { $0.ticker < $1.ticker }
        tableManager?.configure(with: sortedQuotes)
        view?.reloadData()
    }
    
    func socketError(error: String) {
        view?.showError(message: error, errorType: .socketError)
    }
    
    func didGetTopSecurities(securities: SecurityViewModel) {
        view?.hideLoader()
        tickers = securities.tickers
        interactor?.subscribeToQuotes(tickers: securities.tickers)
    }
    
    func didNotGetTopSecurities(error: String) {
        view?.hideLoader()
        view?.showError(message: error, errorType: .stockListError)
    }
}

private extension MainPresenter {
    func decimalPlaces(from minStep: Decimal) -> Int {
        let string = "\(minStep)"
        return string.split(separator: ".").last?.count ?? 0
    }
}
