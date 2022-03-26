//
//  RestService.swift
//  
//
//  Created by Ilya Senchukov on 26.10.2021.
//

import Foundation

public protocol RestService {
    func method() -> HTTPMethod

    func path() -> String

    func parameters() -> [String: String]?

    func body() -> Data?

    func cacheable() -> Bool

    func setupRequest(_ request: inout URLRequest)
}

public extension RestService {

    func parameters() -> [String: String]? {
        nil
    }

    func body() -> Data? {
        nil
    }

    func setupRequest(_ request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

}

extension RestService {

    private func session(force: Bool) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = cacheable() && !force ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    var reachability: Reachability? {
        try? .init()
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

        if let body = body() {
            request.httpBody = body
        }

        request.addValue("application/json", forHTTPHeaderField: "Accept")

        setupRequest(&request)

        return request
    }

}

public extension RestService {

    @discardableResult
    func execute(force: Bool = true,
                 completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> URLSessionDataTask? {
        guard let request = request else {
            log(.failure(NetworkError.badRequest), startTime: .now())
            completion(.failure(.badRequest))
            return nil
        }

        let session = session(force: force)

        let start = DispatchTime.now()
        let task = session.dataTask(with: request) { data, response, error in

            guard let response = response,
                  error == nil else {
                      log(.failure(NetworkError.notFound), startTime: start)
                      completion(.failure(.notFound))
                      return
            }

            if let errorFromStatusCode = mapError(by: response) {
                log(.failure(errorFromStatusCode), startTime: start)
                completion(.failure(errorFromStatusCode))
                return
            }

            guard let data = data else {
                log(.failure(NetworkError.badData), startTime: start)
                completion(.failure(.badData))
                return
            }

            log(.success(response), startTime: start)
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
                        log(.failure(.badData))
                        completion(.failure(.badData))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }

        return task
    }

}
