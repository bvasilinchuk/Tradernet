//
//  MainTableViewManager.swift
//  Tradernet
//
//  Created by Bogdan Vasilinchuk on 6/14/25.
//

import UIKit

final class MainTableViewManager: NSObject, MainTableManagerInput {
    private let dataSource: MainTableViewDataSource
    private unowned let tableView: UITableView

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

    func reload() {
        tableView.reloadData()
    }
}
