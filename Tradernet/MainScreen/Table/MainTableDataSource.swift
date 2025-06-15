//
//  MainTableViewDataSource.swift
//  Tradernet
//
//  Created by Bogdan Vasilinchuk on 6/14/25.
//


import UIKit

final class MainTableViewDataSource: NSObject, UITableViewDataSource {
    weak var presenter: MainPresenterProtocol?
    private var items: [QuoteViewModel] = []

    init(presenter: MainPresenterProtocol?) {
        self.presenter = presenter
    }

    func setItems(_ items: [QuoteViewModel]) {
        self.items = items
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as? QuoteTableViewCell ?? QuoteTableViewCell(style: .default, reuseIdentifier: "QuoteCell")
        cell.configure(with: model)
        return cell
    }
}
