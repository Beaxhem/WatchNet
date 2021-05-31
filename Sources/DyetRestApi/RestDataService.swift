//
//  RestDataService.swift
//
//
//  Created by Ilya Senchukov on 06.05.2021.
//

import Foundation

public protocol RestDataService {

    var path: String? { get set }

    var method: HTTPMethod { get set }

    var defaultParamenters: [String: String]? { get set }

    var cacheable: Bool { get set }

}

extension RestDataService {

    var base: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = cache
        return URLSession(configuration: configuration)
    }

}

public extension RestDataService {

    func execute(
        query: String = "",
        parameters: [String: String]? = nil,
        force: Bool = true,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    )   {

        guard let request = getRequest(query: query, parameters: parameters) else {

            completion(.failure(.badRequest))
            return
        }

        resumeTask(request: request, force: force, completion: completion)

    }

    func executeWithBody<T: Encodable>(
        _ body: T,
        query: String = "",
        parameters: [String: String]? = nil,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {

        guard var request = getPostRequest(query: query, parameters: parameters) else {
            completion(.failure(.badRequest))
            return
        }

        guard let data = try? JSONEncoder().encode(body) else {
            completion(.failure(.badData))
            return
        }

        request.httpBody = data

        resumeTask(request: request, completion: completion)

    }
}

private extension RestDataService {

    func resumeTask(
        request: URLRequest,
        force: Bool = false,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {

        let start = DispatchTime.now()

        if !force, let cachedResponse = cache.cachedResponse(for: request) {
            completion(.success(cachedResponse.data))
            log(success: true, message: "from cache")
            return
        }

        let task = base.dataTask(with: request) { data, response, error in

            guard error == nil, let response = response else {
                completion(.failure(.notFound))
                return
            }

            log(response: response, startTime: start)

            if let errorFromStatusCode = mapError(by: response) {
                completion(.failure(errorFromStatusCode))
                return
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            if cacheable {
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)
            }

            completion(.success(data))

        }

        task.resume()

    }

}

