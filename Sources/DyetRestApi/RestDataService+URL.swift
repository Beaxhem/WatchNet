//
//  RestDataService+URL.swift
//  
//
//  Created by Ilya Senchukov on 29.05.2021.
//

import Foundation

extension RestDataService {

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

}
