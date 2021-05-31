//
//  RestDataService.swift
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

    var cacheable: Bool { get set }

}

extension RestDataService {
    
    private var allowedDiskSize: Int {
        100 * 1024 * 1024
    }

    private var cache: URLCache {
        URLCache(memoryCapacity: 0, diskCapacity: allowedDiskSize, diskPath: "responseCache")
    }

    var base: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = cache
        return URLSession(configuration: configuration)
    }

}

public extension RestDataService {

    @discardableResult
    func execute(query: String = "", parameters: [String: String]? = nil, force: Bool = true, completion: @escaping (Result<Data, NetworkError>) -> Void) -> URLSessionDataTask {

        let start = DispatchTime.now()

        guard let path = path, let request = getRequest(path: path, query: query, parameters: parameters) else {

            completion(.failure(.badRequest))
            return
        }

        if !force, let cachedResponse = cache.cachedResponse(for: request) {
            completion(.success(cachedResponse.data))
            return
        }

        let task = base.dataTask(with: request) { data, response, error in

            guard error == nil, let response = response else {
                completion(.failure(.notFound))
                return
            }

            log(response: response, startTime: start)

            if let error = mapError(by: response) {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                return
            }

            if cacheable {
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)
            }

            completion(.success(data))

        }

        task.resume()

        return task
    }

}

