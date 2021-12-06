//
//  RestService.swift
//  
//
//  Created by Ilya Senchukov on 26.10.2021.
//

import Foundation

public struct AnyEncodable: Encodable { }

open class RestService {

    open func method() -> HTTPMethod { .get }

    open func path() -> String { fatalError("path() -> HTTPMethod? not implemented") }

    open func parameters() -> [String: String]? { nil }

    open func body() -> AnyEncodable? { nil }

    open func cacheable() -> Bool { fatalError("cacheable() -> Bool not implemented") }

    public init() { }

}

extension RestService {

    private var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = cache
        return URLSession(configuration: configuration)
    }

    var url: URL? {
        return URL(string: path() + parametersString)
    }

    var parametersString: String {
        guard let parameters = parameters() else { return "" }

        let parametersString = parameters.compactMap { key, value in
                guard let key = key.queryAllowed,
                      let value = value.queryAllowed else {
                          return nil
                      }
                return "\(key)=\(value)"
            }
            .joined(separator: "&")

        return "?\(parametersString)"
    }

    var request: URLRequest? {
        guard let url = url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method().rawValue

        if let body = body(),
           let data = try? JSONEncoder().encode(body) {
            request.httpBody = data
        }

        return request
    }

}

public extension RestService {

    @discardableResult
    func execute(force: Bool = true,
                 completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> URLSessionDataTask? {

        guard let request = request else {
            completion(.failure(.badRequest))
            return nil
        }

        let start = DispatchTime.now()

        if cacheable(), !force , let cachedResponse = cache.cachedResponse(for: request) {
            completion(.success(cachedResponse.data))
            log(success: true, message: "from cache")
            return nil
        }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            guard let response = response,
                  error == nil else {
                      self.log(success: false, message: "Not found")
                      completion(.failure(.notFound))
                      return
            }

            self.log(response: response, startTime: start)

            if let errorFromStatusCode = self.mapError(by: response) {
                completion(.failure(errorFromStatusCode))
                return
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            if self.cacheable() {
                let cachedData = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedData, for: request)
            }

            completion(.success(data))
        }

        task.resume()

        return task
    }

    @discardableResult
    func execute<T: Decodable>(decodingTo: T.Type, force: Bool = true, completion: @escaping (Result<T, NetworkError>) -> Void) -> URLSessionDataTask? {
        let task = execute(force: force) { res in
            switch res {
                case .success(let data):
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(.badData))
                    }
                case .failure(let error):
                    completion(.failure(error))

            }
        }

        return task
    }

    

}

