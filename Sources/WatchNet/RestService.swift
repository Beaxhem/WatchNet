//
//  RestService.swift
//  
//
//  Created by Ilya Senchukov on 26.10.2021.
//

import Foundation

public protocol RestService {

	associatedtype ErrorResponse: NetworkErrorDerivable

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

public extension RestService {

	mutating func binding(_ binder: (Self) -> Void) -> Self {
		binder(self)
		return self
	}

}

extension RestService {

    private func session(force: Bool) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = cacheable() && !force ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
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

    public var request: URLRequest? {
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
				 completion: @escaping (Result<Data, ErrorResponse>) -> Void
    ) -> URLSessionDataTask? {
		func complete(_ result: Result<Data, NetworkError>) {
			switch result {
				case .failure(let error):
					completion(.failure(.init(error:error)))
				case .success(let data):
					completion(.success(data))
			}
		}
        guard let request = request else {
			let error = NetworkError(error: .badRequest)
			log(.failure(error), startTime: .now())
			complete(.failure(error))
            return nil
        }

        let session = session(force: force)

        let start = DispatchTime.now()
        let task = session.dataTask(with: request) { data, response, error in
			func completeWith(error: NetworkError.Error) {
				let error = NetworkError(error: error, responseData: data)
				log(.failure(error), startTime: start)
				URLCache.shared.removeCachedResponse(for: request)
				complete(.failure(error))
			}

			if let error = error as? URLError {
				completeWith(error: .urlError(error))
				return
			}

            guard let response = response,
                  error == nil else {
				completeWith(error: .notFound)
				return
            }

            if let errorFromStatusCode = mapError(by: response) {
				completeWith(error: errorFromStatusCode)
                return
            }

            guard let data = data else {
				completeWith(error: .badData("No data in the response"))
                return
            }

            log(.success(response), startTime: start)
            completion(.success(data))
        }

        task.resume()

        return task
    }

    @discardableResult
    func execute<T: Decodable>(decodingTo: T.Type, force: Bool = true, completion: @escaping (Result<T, ErrorResponse>) -> Void) -> URLSessionDataTask? {
		func completeWith(error: NetworkError.Error) {
			let error = NetworkError(error: error)
			log(.failure(error))
			completion(.failure(.init(error: error)))
		}
        let task = execute(force: force) { res in
            switch res {
                case .success(let data):
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(object))
                    } catch {
						completeWith(error: .badData(error.localizedDescription))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }

        return task
    }

	func fetch<T: Decodable>(decodingTo: T.Type, force: Bool = true) async throws -> T {
		func completeWith(error: NetworkError.Error) -> NetworkError {
			let error = NetworkError(error: error)
			log(.failure(error))
			return error
		}

		guard let request else {
			throw completeWith(error: .badRequest)
		}

		do {
			let (data, res) = try await session(force: force).data(for: request)
			let object = try JSONDecoder().decode(T.self, from: data)
			log(.success(res))
			return object
		} catch {
			print("NETWORK ERROR:", error)
			throw error
		}
	}

}
