import UIKit

final class MainTableViewManager: NSObject, MainTableManagerInput {
    private let dataSource: MainTableViewDataSource
private weak var tableView: UITableView?

    init(tableView: UITableView, presenter: MainPresenterProtocol?) {
        self.tableView = tableView
        self.dataSource = MainTableViewDataSource(presenter: presenter)
        super.init()
        tableView.dataSource = dataSource
        tableView.register(QuoteTableViewCell.self, forCellReuseIdentifier: "QuoteCell")
    }

    func configure(with items: [QuoteViewModel]) {
        dataSource.setItems(items)
    }
}
