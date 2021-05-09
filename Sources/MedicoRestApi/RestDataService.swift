//
//  MedicoRestApi.swift
//
//
//  Created by Ilya Senchukov on 06.05.2021.
//

import Foundation
import UIKit

public protocol RestDataService {

    var path: String? { get set }

    var method: HTTPMethod { get set }

    var defaultParamenters: [String: String]? { get set }

}

private extension RestDataService {

    var base: URLSession {
        URLSession.shared
    }

    func getURL(from path: String, query: String, parameters: [String: String]?) -> URL? {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }

        if let parameters = parameters {
            let parametersString = getParametersString(parameters: parameters)
            
            return URL(string: "\(path)\(query)?\(parametersString)")
        } else if let defaultParamenters = defaultParamenters {
            let parametersString = getParametersString(parameters: defaultParamenters)

            return URL(string: "\(path)\(query)?\(parametersString)")
        }

        return URL(string: "\(path)\(query)")
    }

    func getParametersString(parameters: [String: String]) -> String {
        let parametersString = parameters.map { key, value in
            guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return ""
            }

            return "\(key)=\(value)"
        }.joined(separator: "&")

        return parametersString
    }

    func mapError(by response: URLResponse) -> NetworkError? {
        let res = response as! HTTPURLResponse

        switch res.statusCode {
            case 200..<300:
                return nil
            case 401:
                return .unauthorized
            case 403:
                return .noAccess
            case 404:
                return .notFound
            case 405:
                return .wrongMethod
            case 400..<500:
                return .badRequest
            default:
                return .serverError
        }
    }

}

public extension RestDataService {

    func execute(query: String = "", parameters: [String: String]? = nil, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let start = DispatchTime.now()

        guard let path = path, let url = getURL(from: path, query: query, parameters: parameters) else {
            completion(.failure(.badRequest))
            return
        }

        let task = base.dataTask(with: url) { data, response, error in
            print("Time taken: \((DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000) ms")
            if let response = response, let error = mapError(by: response) {
                completion(.failure(error))
                return
            }

            if let data = data {
                completion(.success(data))
                return
            }

            completion(.failure(.unknownError("I don't know")))
        }

        task.resume()
    }

}

