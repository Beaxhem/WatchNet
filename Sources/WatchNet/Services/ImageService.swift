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

#if os(macOS)
public typealias UIImage = NSImage
#endif

public class ImageService: RestService {

    public static let shared = ImageService()

    private var _path: String?

    public func path() -> String {
        if let path = _path {
            return path
        }
        fatalError("Path is not set")
    }

    public func method() -> HTTPMethod {
        .get
    }

    public func cacheable() -> Bool {
        true
    }

}


public extension ImageService {

    @discardableResult
    func image(for path: String, force: Bool = false, completion: @escaping (Result<UIImage, NetworkError>) -> Void) -> URLSessionDataTask? {
        self._path = path

        let task = execute(force: force) { res in
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

        return task
    }

}
