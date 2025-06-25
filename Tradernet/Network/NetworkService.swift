import Foundation

protocol NetworkServiceProtocol {
    func getTopSecurities(completion: @escaping (Result<[Security], Error>) -> Void)
}

enum Endpoint: String {
    case topSecurities = "https://tradernet.com/tradernet-api/quotes-get-top-securities"

    var url: URL? {
        return URL(string: self.rawValue)
    }
}

struct Security: Decodable {
    let symbol: String
    let name: String?
    let price: Double?
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getTopSecurities(completion: @escaping (Result<[Security], Error>) -> Void) {
        guard let url = Endpoint.topSecurities.url else {
            completion(.failure(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "type": "stocks",
            "exchange": "russia",
            "gainers": 0,
            "limit": 30
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "NetworkService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode([Security].self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
