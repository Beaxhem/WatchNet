//
//  NetworkError.swift
//  
//
//  Created by Ilya Senchukov on 06.05.2021.
//

import Foundation

public enum NetworkError: Error {
    
    case notFound
    case unauthorized
    case badRequest
    case noAccess
    case wrongMethod
    case serverError
    case badData
    case unknownError(String)

}

extension RestDataService {

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
