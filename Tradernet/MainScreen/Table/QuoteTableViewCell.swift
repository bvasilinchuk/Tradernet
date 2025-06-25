import UIKit
import SnapKit
import Kingfisher

final class QuoteTableViewCell: UITableViewCell {

    // MARK: - UI Elements

    private let logoImageView = UIImageView()
    private let tickerLabel = UILabel()
    private let exchangeAndNameLabel = UILabel()
    private let lastPriceLabel = UILabel()
    private let changeValueLabel = UILabel()
    private let changePercentLabel = UILabel()
    
    // MARK: - Appearance

    let positiveColor = UIColor(red: 115/255, green: 191/255, blue: 65/255, alpha: 1)
    let negativeColor = UIColor(red: 249/255, green: 47/255, blue: 87/255, alpha: 1)

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
        lastPriceLabel.text = model.lastPriceString
        changeValueLabel.text = model.changeValueString
        changePercentLabel.text = model.changePercentString

        let isPositive = model.isPositivePercentChange
        let changeColor = isPositive ? positiveColor : negativeColor
        changePercentLabel.textColor = changeColor
        changeValueLabel.textColor = changeColor
        switch model.percentChangeType {
        case .positive:
            changePercentLabel.backgroundColor = positiveColor
            changePercentLabel.textColor = .white
        case .negative:
            changePercentLabel.backgroundColor = negativeColor
            changePercentLabel.textColor = .white
        case .noChange:
            changePercentLabel.backgroundColor = .clear
        }
        
        logoImageView.image = nil
        logoImageView.isHidden = true
        let url = URL(string: "https://tradernet.com/logos/get-logo-by-ticker?ticker=\(model.ticker.lowercased())")
        logoImageView.kf.setImage(with: url, completionHandler: { result in
            switch result {
            case let .success(image):
                if image.image.size.width < 2 {
                    self.logoImageView.isHidden = true
                } else {
                    self.logoImageView.isHidden = false
                }
            case .failure:
                self.logoImageView.isHidden = true
            }
        })
    }

    // MARK: - Layout

    private func setupUI() {
        setupStyles()
        setupLayout()
    }
    
    private func setupStyles() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        logoImageView.layer.cornerRadius = 4

        tickerLabel.font = .systemFont(ofSize: 18)
        exchangeAndNameLabel.font = .systemFont(ofSize: 12)
        exchangeAndNameLabel.textColor = .gray

        lastPriceLabel.font = .systemFont(ofSize: 14)
        changeValueLabel.font = .systemFont(ofSize: 12)
        changePercentLabel.font = .systemFont(ofSize: 18)
        changePercentLabel.textAlignment = .center
        changePercentLabel.layer.cornerRadius = 4
        changePercentLabel.layer.masksToBounds = true
    }
    
    private func setupLayout() {
        let leftStack = UIStackView(arrangedSubviews: [logoImageView, tickerLabel])
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .center

        let topRow = UIStackView(arrangedSubviews: [leftStack, changePercentLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .equalSpacing

        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }

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
