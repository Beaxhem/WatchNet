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
	case urlError(URLError)

    var string: String {
        switch self {
            case .notFound:
                return "Not found"
            case .unauthorized:
                return "Unauthorized"
            case .badRequest:
                return "Bad request"
            case .noAccess:
                return "No access"
            case .wrongMethod:
                return "Wrong method"
            case .serverError:
                return "Internal error"
            case .badData:
                return "Bad data"
            case .unknownError(let error):
                return error
			case .urlError(let error):
				return error.localizedDescription
        }
    }

}

extension RestService {

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
