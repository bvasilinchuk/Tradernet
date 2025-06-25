import Foundation

protocol QuotesWebSocketServiceProtocol {
    func connect() async
    func subscribe(to symbols: [String]) async
    func disconnect()
    func setMessageHandler(_ handler: @escaping (QuoteModel) -> Void)
    func setErrorHandler(_ handler: @escaping (Error) -> Void)
}

final class QuotesWebSocketService: QuotesWebSocketServiceProtocol {
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private var messageHandler: ((QuoteModel) -> Void)?
    private var errorHandler: ((Error) -> Void)?

    private let socketURL: URL = {
        guard let url = URL(string: "wss://wss.tradernet.com") else {
            fatalError("Invalid WebSocket URL")
        }
        return url
    }()

    private var isConnected: Bool {
        webSocketTask?.state == .running
    }

    private var pingTask: Task<Void, Never>?

    func setMessageHandler(_ handler: @escaping (QuoteModel) -> Void) {
        self.messageHandler = handler
    }

    func setErrorHandler(_ handler: @escaping (Error) -> Void) {
        self.errorHandler = handler
    }

    func connect() async {
        guard webSocketTask == nil else { return }

        webSocketTask = session.webSocketTask(with: socketURL)
        webSocketTask?.resume()

        Task { await receiveMessages() }
        pingTask = Task { await pingLoop() }
    }

    func subscribe(to symbols: [String]) async {
        guard let message = makeSubscriptionMessage(for: symbols) else { return }
        await send(message)
    }

    func disconnect() {
        pingTask?.cancel()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }

    private func send(_ text: String) async {
        guard isConnected else { return }
        do {
            try await webSocketTask?.send(.string(text))
        } catch {
            errorHandler?(error)
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
                webSocketTask = nil
                errorHandler?(error)
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            print("Cannot convert text to Data")
            return
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: data),
            let array = json as? [Any],
            array.count >= 2,
            let event = array[0] as? String,
            event == "q",
            let quoteData = array[1] as? [String: Any]
        else {
            print("Unexpected message format")
            return
        }

        guard let quote = QuoteModel(from: quoteData) else {
            print("Failed to parse QuoteModel")
            return
        }

        messageHandler?(quote)
    }

    private func makeSubscriptionMessage(for symbols: [String]) -> String? {
        let payload: [Any] = ["quotes", symbols]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return json
    }

    private func pingLoop() async {
        while isConnected {
            webSocketTask?.sendPing(pongReceiveHandler: { _ in })
            try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
        }
    }
}

enum PercentChangeType {
    case positive
    case negative
    case noChange
}
