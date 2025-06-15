import Foundation

protocol QuotesWebSocketServiceProtocol {
    func connect() async
    func subscribe(to symbols: [String]) async
    func disconnect()
    func setMessageHandler(_ handler: @escaping (QuoteModel) -> Void)
}

final class QuotesWebSocketService: QuotesWebSocketServiceProtocol {
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private var isConnected = false
    private var messageHandler: ((QuoteModel) -> Void)?

    private let socketURL = URL(string: "wss://wss.tradernet.com")!

    func setMessageHandler(_ handler: @escaping (QuoteModel) -> Void) {
        self.messageHandler = handler
    }

    func connect() async {
        guard webSocketTask == nil else { return }

        webSocketTask = session.webSocketTask(with: socketURL)
        webSocketTask?.resume()
        isConnected = true

        Task { await receiveMessages() }
        Task { await pingLoop() }
    }

    func subscribe(to symbols: [String]) async {
        let subscription: [Any] = ["quotes", symbols]
        guard let data = try? JSONSerialization.data(withJSONObject: subscription, options: []) else { return }
        guard let jsonString = String(data: data, encoding: .utf8) else { return }

        await send(jsonString)
    }

    func disconnect() {
        isConnected = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }

    private func send(_ text: String) async {
        guard isConnected else { return }
        do {
            try await webSocketTask?.send(.string(text))
        } catch {
            print("WebSocket send error: \(error)")
        }
    }

    private func receiveMessages() async {
        guard let task = webSocketTask else { return }

        while isConnected {
            do {
                let message = try await task.receive()
                switch message {
                case .string(let text):
                    handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        handleMessage(text)
                    }
                @unknown default:
                    break
                }
            } catch {
                print("WebSocket receive error: \(error)")
                isConnected = false
            }
        }
    }

    private func handleMessage(_ text: String) {
        print("Received raw message: \(text)")

        guard let data = text.data(using: .utf8) else {
            print("Cannot convert text to Data")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])

            guard let array = json as? [Any],
                  array.count >= 2,
                  let event = array[0] as? String,
                  event == "q",
                  let quoteData = array[1] as? [String: Any] else {
                print("Unexpected message format")
                return
            }

            if let quote = QuoteModel(from: quoteData) {
                messageHandler?(quote)
            } else {
                print("Failed to parse QuoteModel")
            }

        } catch {
            print("JSON parsing error: \(error)")
        }
    }

    private func pingLoop() async {
        while isConnected {
            webSocketTask?.sendPing(pongReceiveHandler: { _ in })
            try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
        }
    }
}

struct QuoteModel {
    let symbol: String
    let name: String?
    let exchange: String?
    let lastPrice: Double?
    let change: Double?
    let percentChange: Double?
    let bid: Double?
    let ask: Double?
    let volume: Double?

    init?(from dict: [String: Any]) {
        guard let symbol = dict["c"] as? String else { return nil }
        self.symbol = symbol

        self.name = dict["name"] as? String // ← зависит от API (может быть nil)
        self.exchange = dict["ltr"] as? String

        self.lastPrice = dict["ltp"] as? Double
        self.change = dict["chg"] as? Double
        self.percentChange = dict["pcp"] as? Double
        self.bid = dict["bbp"] as? Double
        self.ask = dict["bap"] as? Double
        self.volume = dict["vol"] as? Double
    }

    init(
        symbol: String,
        name: String? = nil,
        exchange: String? = nil,
        lastPrice: Double? = nil,
        change: Double? = nil,
        percentChange: Double? = nil,
        bid: Double? = nil,
        ask: Double? = nil,
        volume: Double? = nil
    ) {
        self.symbol = symbol
        self.name = name
        self.exchange = exchange
        self.lastPrice = lastPrice
        self.change = change
        self.percentChange = percentChange
        self.bid = bid
        self.ask = ask
        self.volume = volume
    }
}

class QuoteViewModel {
    let ticker: String
    let name: String
    let exchange: String
    let lastPrice: String
    let changeValue: String
    let changePercent: Double
    let isPositiveChange: Bool
    var percentChangeType: PercentChangeType = .noChange
    let model: QuoteModel

    init(model: QuoteModel) {
        self.model = model
        self.ticker = model.symbol
        self.name = model.name ?? ""
        self.exchange = model.exchange ?? ""

        if let price = model.lastPrice {
            self.lastPrice = String(format: "%.2f", price)
        } else {
            self.lastPrice = "-"
        }

        if let chg = model.change {
            self.changeValue = String(format: "%+.5f", chg)
        } else {
            self.changeValue = ""
        }

        if let pcp = model.percentChange {
            self.changePercent = pcp
            self.isPositiveChange = pcp >= 0
        } else {
            self.changePercent = 0
            self.isPositiveChange = true
        }
    }
}

extension QuoteViewModel {
    func merging(with newModel: QuoteModel) -> QuoteViewModel {
        return QuoteViewModel(model: QuoteModel(
            symbol: newModel.symbol,
            name: name,
            exchange: exchange,
            lastPrice: newModel.lastPrice ?? model.lastPrice,
            change: newModel.change ?? model.change,
            percentChange: newModel.percentChange ?? model.percentChange,
            bid: newModel.bid ?? model.bid,
            ask: newModel.ask ?? model.ask,
            volume: newModel.volume ?? model.volume
        ))
    }
}

enum PercentChangeType {
    case positive
    case negative
    case noChange
}
