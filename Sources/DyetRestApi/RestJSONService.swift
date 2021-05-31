//
//  RestJSONService.swift
//  
//
//  Created by Ilya Senchukov on 06.05.2021.
//

import Foundation

public protocol RestJSONService: RestDataService {

    associatedtype Output: Decodable

}

public extension RestJSONService {

    func execute(query: String = "", parameters: [String: String]? = nil, completion: @escaping (Result<Output, NetworkError>) -> Void) {
        
        (self as RestDataService).execute(query: query, parameters: parameters) { res in
            switch res {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    if let result = decode(data: data) {
                        return completion(.success(result))
                    }

                    return completion(.failure(.badData))
            }
        }
    }

}

private extension RestJSONService {

    func decode(data: Data) -> Output? {
        do {
            return try JSONDecoder().decode(Output.self, from: data)
        } catch {
            return nil
        }

    }

}
