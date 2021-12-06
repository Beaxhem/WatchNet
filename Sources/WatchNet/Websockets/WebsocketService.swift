//
//  WebsocketService.swift
//  
//
//  Created by Ilya Senchukov on 05.12.2021.
//

import Foundation

open class WebsocketService {

    public var session: URLSession {
        URLSession.shared
    }

    public init() { }

    open func path() -> String {
        assertionFailure("Not implemented path() method")
        return ""
    }
    
}

private extension WebsocketService {

    var url: URL? {
        URL(string: path())
    }

}

public extension WebsocketService {

    @discardableResult
    func connect(receiveHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) -> URLSessionWebSocketTask? {
        guard let url = url else {
            receiveHandler(.failure(NetworkError.badRequest))
            return nil
        }

        let task = session.webSocketTask(with: url)

        task.receive(completionHandler: receiveHandler)
        task.resume()

        return task
    }

}

open class WebsocketObjectService: WebsocketService {

    private lazy var decoder = JSONDecoder()

    @discardableResult
    public func connect<T: Decodable>(
        decodingTo: T.Type,
        onDecode: @escaping (T) -> Void,
        onError: ((Error) -> Void)?
    ) -> URLSessionWebSocketTask? {
        super.connect { [weak self] res in
            guard let self = self else { return }

            switch res {
                case .success(let message):
                    switch message {
                        case .data(_):
                            onError?(NetworkError.badData)
                        case .string(let string):
                            let data = Data(string.utf8)
                            do {
                                onDecode(try self.decoder.decode(T.self, from: data))
                            } catch {
                                onError?(error)
                            }
                        @unknown default:
                            fatalError("Not implemented")
                    }
                case .failure(let error):
                    onError?(error)
            }
        }
        
    }

}

