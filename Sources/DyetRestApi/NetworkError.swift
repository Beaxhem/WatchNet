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
