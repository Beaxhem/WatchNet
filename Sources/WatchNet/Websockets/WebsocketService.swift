//
//  WebsocketService.swift
//  
//
//  Created by Ilya Senchukov on 05.12.2021.
//

import Foundation

public protocol TaskStorage {
    var task: URLSessionWebSocketTask? { get set }
}

public extension TaskStorage {

    func send(message: URLSessionWebSocketTask.Message, completion: @escaping (Error?) -> Void) {
        task?.send(message, completionHandler: completion)
    }

    mutating func setTask(task: URLSessionWebSocketTask?) {
        self.task = task
    }
}

public protocol WebsocketService {
    associatedtype Storage: TaskStorage
    func path() -> String

    var taskStorage: Storage { get set }
}

private extension WebsocketService {

    var session: URLSession {
        .init(configuration: .default)
    }

    var url: URL? {
        URL(string: path())
    }

    var decoder: JSONDecoder {
        .init()
    }

    func receive(task: URLSessionWebSocketTask, receiveHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        task.receive(completionHandler: { res in
            receiveHandler(res)
            receive(task: task, receiveHandler: receiveHandler)
        })
    }

}

public extension WebsocketService {

    @discardableResult
    mutating func connect(receiveHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) -> URLSessionWebSocketTask? {
        guard let url = url else {
            receiveHandler(.failure(NetworkError.badRequest))
            return nil
        }

        let task = session.webSocketTask(with: url)
        receive(task: task, receiveHandler: receiveHandler)
        task.resume()

        taskStorage.setTask(task: task)

        return task
    }

}

public extension WebsocketService {

    func ping(task: URLSessionWebSocketTask?) {
        task?.sendPing { error in
            if let error = error {
                print("Error when sending PING \(error)")
            } else {
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    ping(task: task)
                }
            }
        }
    }

    @discardableResult
    mutating func connect<T: Decodable>(
        decodingTo: T.Type,
        onDecode: @escaping (T) -> Void,
        onError: ((Error) -> Void)?
    ) -> URLSessionWebSocketTask? {
        let task = connect { [self] res in
            switch res {
                case .success(let message):
                    switch message {
                        case .data(_):
                            onError?(NetworkError.badData)
                        case .string(let string):
                            let data = Data(string.utf8)
                            do {
                                onDecode(try decoder.decode(T.self, from: data))
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

        ping(task: task)
        
        return task
    }

}

