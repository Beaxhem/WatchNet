//
//  ImageService.swift
//  
//
//  Created by Ilya Senchukov on 06.05.2021.
//



import Foundation
#if !os(macOS)
import UIKit
#else
import Cocoa
#endif

public class ImageService: RestDataService {

    static let shared = ImageService()

    public var defaultParamenters: [String : String]? = nil

    public var path: String?

    public var method: HTTPMethod = .get

    public var cacheable = true

}



#if !os(macOS)
public extension ImageService {

    func image(for path: String, force: Bool = false, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        self.path = path

        (self as RestDataService).execute(force: force) { res in
            switch res {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                        return
                    }

                    completion(.failure(.badData))

            }

        }

    }

}

#else

public extension ImageService {

    func image(for path: String, force: Bool = false, completion: @escaping (Result<NSImage, NetworkError>) -> Void) {
        self.path = path

        (self as RestDataService).execute(force: force) { res in
            switch res {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    if let image = NSImage(data: data) {
                        completion(.success(image))
                        return
                    }

                    completion(.failure(.badData))

            }

        }

    }

}

#endif


