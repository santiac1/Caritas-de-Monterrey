//
//  APIClient.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation
import Combine

protocol APIClientProtocol {
    func fetch<T: Decodable>(endpoint: String) -> AnyPublisher<T, Error>
}

final class APIClient: APIClientProtocol {
    private let baseURL = URL(string: "https://api.caritasmonterrey.org")!

    func fetch<T: Decodable>(endpoint: String) -> AnyPublisher<T, Error> {
        let url = baseURL.appendingPathComponent(endpoint)
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
