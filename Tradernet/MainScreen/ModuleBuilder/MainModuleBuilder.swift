import UIKit

class MainModuleBuilder {
    static func createModule() -> UIViewController {
        let socketService = QuotesWebSocketService()
        let networkService = NetworkService()
        
        let interactor = MainInteractor(socketService: socketService, networkService: networkService)
        let router = MainRouter()
        let presenter = MainPresenter(interactor: interactor, router: router)
        let view = MainViewController(presenter: presenter)
        let tableManager = MainTableViewManager(tableView: view.tableView, presenter: presenter)
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        presenter.tableManager = tableManager

        return view
    }
}
