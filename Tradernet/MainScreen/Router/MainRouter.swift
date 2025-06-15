import UIKit

protocol MainRouterProtocol: AnyObject {
    static func createModule(socketService: QuotesWebSocketServiceProtocol) -> UIViewController
}

class MainRouter: MainRouterProtocol {
    static func createModule(socketService: QuotesWebSocketServiceProtocol) -> UIViewController {
        let presenter = MainPresenter()
        let view = MainViewController(presenter: presenter)
        let interactor = MainInteractor(socketService: socketService)
        let router = MainRouter()
        let tableManager = MainTableViewManager(tableView: view.tableView, presenter: presenter)
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        presenter.tableManager = tableManager

        return view
    }
}
