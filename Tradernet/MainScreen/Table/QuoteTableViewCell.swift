//
//  QuoteTableViewCell.swift
//  Tradernet
//
//  Created by Bogdan Vasilinchuk on 6/14/25.
//


import UIKit
import SnapKit

final class QuoteTableViewCell: UITableViewCell {

    // MARK: - UI Elements

    private let tickerLabel = UILabel()
    private let exchangeAndNameLabel = UILabel()
    private let lastPriceLabel = UILabel()
    private let changeValueLabel = UILabel()
    private let changePercentLabel = UILabel()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with model: QuoteViewModel) {
        tickerLabel.text = model.ticker
        exchangeAndNameLabel.text = "\(model.exchange) | \(model.name)"
        lastPriceLabel.text = model.lastPrice
        changeValueLabel.text = model.changeValue
        changePercentLabel.text = model.changePercent

        let isPositive = model.isPositiveChange
        let changeColor = isPositive ? UIColor.systemGreen : UIColor.systemRed
        changePercentLabel.textColor = changeColor
        changeValueLabel.textColor = changeColor
    }

    // MARK: - Layout

    private func setupUI() {
        selectionStyle = .none

        tickerLabel.font = .boldSystemFont(ofSize: 16)
        exchangeAndNameLabel.font = .systemFont(ofSize: 12)
        exchangeAndNameLabel.textColor = .gray

        lastPriceLabel.font = .systemFont(ofSize: 14)
        changeValueLabel.font = .systemFont(ofSize: 12)
        changePercentLabel.font = .systemFont(ofSize: 14)
        changePercentLabel.textAlignment = .right

        contentView.addSubview(tickerLabel)
        contentView.addSubview(exchangeAndNameLabel)
        contentView.addSubview(lastPriceLabel)
        contentView.addSubview(changeValueLabel)
        contentView.addSubview(changePercentLabel)

        tickerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
        }

        exchangeAndNameLabel.snp.makeConstraints { make in
            make.top.equalTo(tickerLabel.snp.bottom).offset(2)
            make.leading.equalTo(tickerLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }

        changePercentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }

        changeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(changePercentLabel.snp.bottom).offset(2)
            make.right.equalTo(changePercentLabel)
        }

        lastPriceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(changePercentLabel.snp.left).offset(-12)
        }
    }
}
