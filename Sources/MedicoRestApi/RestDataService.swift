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

    func getRequest(path: String, query: String = "", parameters: [String: String]? = nil) -> URLRequest? {
        guard let url = getURL(path: path, query: query, parameters: parameters) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.string

        return request
    }

    func getURL(path: String, query: String = "", parameters: [String: String]?) -> URL? {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }

        let parametersString = getParametersString(parameters: parameters ?? defaultParamenters)

        return URL(string: [path, query, parametersString].joined())
    }

    func getParametersString(parameters: [String: String]?) -> String {
        guard let parameters = parameters else {
            return ""
        }

        let parametersString = parameters.map { key, value in
            guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return ""
            }

            return "\(key)=\(value)"
        }.joined(separator: "&")

        return "?\(parametersString)"
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

        guard let path = path, let reqeust = getRequest(path: path, query: query, parameters: parameters) else {
            completion(.failure(.badRequest))
            return
        }

        let task = base.dataTask(with: reqeust) { data, response, error in
            print("Time taken: \((DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000) ms")

            if error != nil {
                completion(.failure(.notFound))
                return
            }

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

