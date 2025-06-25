//
//  MainRouter.swift
//  Tradernet
//
//  Created by Bogdan Vasilinchuk on 6/25/25.
//


class MainRouter: MainRouterProtocol {
    static func createModule(socketService: QuotesWebSocketServiceProtocol, networkService: NetworkServiceProtocol) -> UIViewController {
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