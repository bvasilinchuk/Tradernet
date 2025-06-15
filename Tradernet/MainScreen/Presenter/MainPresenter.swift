protocol MainTableManagerInput: AnyObject {
    func configure(with items: [QuoteViewModel])
}

protocol MainPresenterProtocol: AnyObject {
    var itemsCount: Int { get }
    func viewDidLoad()
    func titleForRow(at index: Int) -> String
    var tableManager: MainTableManagerInput? { get set }
}

class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    var interactor: MainInteractorProtocol?
    var router: MainRouterProtocol?

    private var items: [MainEntity] = []
    private var quotes: [String: QuoteViewModel] = [:]

    var tableManager: MainTableManagerInput?

    var itemsCount: Int {
        return items.count
    }

    func viewDidLoad() {
        interactor?.fetchItems()
    }

    func titleForRow(at index: Int) -> String {
        return items[index].title
    }
}

extension MainPresenter: MainInteractorOutputProtocol {
    func receievedQuote(_ quote: QuoteViewModel) {
        let current = quotes[quote.ticker]
        let updated = current?.merging(with: quote.model) ?? quote
        if let current = current {
            if updated.changePercent > current.changePercent {
                updated.percentChangeType = .positive
            } else if updated.changePercent < current.changePercent {
                updated.percentChangeType = .negative
            }
        }
        quotes[quote.ticker] = updated

        let sortedQuotes = quotes.values.sorted { $0.ticker < $1.ticker }
        tableManager?.configure(with: sortedQuotes)
        view?.reloadData()
    }
    
    func didFetch(items: [MainEntity]) {
        self.items = items
        view?.reloadData()
    }
}
