//
//  ImageService.swift
//  
//
//  Created by Ilya Senchukov on 06.05.2021.
//

import Foundation
import UIKit

public final class ImageService: RestDataService {

    public var defaultParamenters: [String : String]? = nil

    static let shared = ImageService()

    public var path: String?

    public var method: HTTPMethod = .get

}

public extension ImageService {

    func image(for path: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        self.path = path

        (self as RestDataService).execute { res in
            switch res {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    }

                    completion(.failure(.badData))
            }
        }
    }

}
