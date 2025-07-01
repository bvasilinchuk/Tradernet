import Foundation

protocol NetworkServiceProtocol {
    func getTopSecurities(completion: @escaping (Result<SecuritiesModel, Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getTopSecurities(completion: @escaping (Result<SecuritiesModel, Error>) -> Void) {
        let parameters: [String: Any] = [
            "cmd": "getTopSecurities",
            "params": [
                "type": "stocks",
                "exchange": "russia",
                "gainers": 0,
                "limit": 30
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8),
              let encodedQuery = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://tradernet.com/api/?q=\(encodedQuery)") else {
            completion(.failure(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or parameters"])))
            return
        }

        session.dataTask(with: url) { data, response, error in
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
