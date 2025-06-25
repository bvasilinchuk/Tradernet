import UIKit

class MainModuleBuilder {
    static func createModule() -> UIViewController {
        let socketService = QuotesWebSocketService()
        let networkService = NetworkService()
        
        let presenter = MainPresenter()
        let view = MainViewController(presenter: presenter)
        let interactor = MainInteractor(socketService: socketService, networkService: networkService)
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
