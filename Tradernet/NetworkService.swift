//
//  QuotesAPIServiceProtocol.swift
//  Tradernet
//
//  Created by Bogdan Vasilinchuk on 6/22/25.
//


import Foundation

protocol QuotesAPIServiceProtocol {
    func getTopSecurities(completion: @escaping (Result<[Security], Error>) -> Void)
}

struct Security: Decodable {
    let symbol: String
    let name: String?
    let price: Double?
}

final class QuotesAPIService: QuotesAPIServiceProtocol {
    private let session: URLSession
    private let baseURL = URL(string: "https://tradernet.com/tradernet-api/quotes-get-top-securities")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getTopSecurities(completion: @escaping (Result<[Security], Error>) -> Void) {
        var request = URLRequest(url: baseURL)
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

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "NoData", code: 0))) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Security].self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }

        task.resume()
    }
}