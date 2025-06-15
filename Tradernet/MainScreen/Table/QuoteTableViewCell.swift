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
        //Поправить
        changePercentLabel.text = String(format: "%+.2f%%", model.changePercent)

        let isPositive = model.isPositiveChange
        let changeColor = isPositive ? UIColor.systemGreen : UIColor.systemRed
        changePercentLabel.textColor = changeColor
        changeValueLabel.textColor = changeColor
        switch model.percentChangeType {
        case .positive:
            changePercentLabel.backgroundColor = .green
            changePercentLabel.textColor = .white
        case .negative:
            changePercentLabel.backgroundColor = .red
            changePercentLabel.textColor = .white
        case .noChange:
            changePercentLabel.backgroundColor = .clear
        }
    }

    // MARK: - Layout

    private func setupUI() {
        selectionStyle = .none

        tickerLabel.font = .boldSystemFont(ofSize: 16)
        exchangeAndNameLabel.font = .systemFont(ofSize: 12)
        exchangeAndNameLabel.textColor = .gray

        lastPriceLabel.font = .systemFont(ofSize: 14)
        changeValueLabel.font = .systemFont(ofSize: 12)
        changePercentLabel.font = .systemFont(ofSize: 16)
        changePercentLabel.textAlignment = .center
        changePercentLabel.layer.cornerRadius = 4
        changePercentLabel.layer.masksToBounds = true

        let topRow = UIStackView(arrangedSubviews: [tickerLabel, changePercentLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .equalSpacing

        let priceStack = UIStackView(arrangedSubviews: [lastPriceLabel, changeValueLabel])
        priceStack.axis = .horizontal
        priceStack.spacing = 4

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        exchangeAndNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        exchangeAndNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        exchangeAndNameLabel.lineBreakMode = .byTruncatingTail

        priceStack.setContentHuggingPriority(.required, for: .horizontal)
        priceStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        let bottomRow = UIStackView(arrangedSubviews: [exchangeAndNameLabel, spacer, priceStack])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .fill
        bottomRow.spacing = 8

        contentView.addSubview(topRow)
        contentView.addSubview(bottomRow)

        topRow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(16)
        }

        bottomRow.snp.makeConstraints { make in
            make.top.equalTo(topRow.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }
}
