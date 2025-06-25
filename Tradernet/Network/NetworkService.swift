import Foundation

protocol NetworkServiceProtocol {
    func getTopSecurities(completion: @escaping (Result<SecuritiesModel, Error>) -> Void)
}

enum Endpoint: String {
    case topSecurities = "https://tradernet.com/tradernet-api/quotes-get-top-securities"

    var url: URL? {
        return URL(string: self.rawValue)
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getTopSecurities(completion: @escaping (Result<SecuritiesModel, Error>) -> Void) {
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

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "NetworkService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(self.parseAPIError(from: data, fallbackCode: httpResponse.statusCode)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(SecuritiesModel.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(self.parseAPIError(from: data, fallbackCode: -2)))
                }
            }
        }.resume()
    }
    
    private func parseAPIError(from data: Data, fallbackCode: Int) -> Error {
        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            return NSError(domain: "NetworkService", code: apiError.code, userInfo: [NSLocalizedDescriptionKey: apiError.errMsg])
        } else {
            return NSError(domain: "NetworkService", code: fallbackCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(fallbackCode)"])
        }
    }
}
