//
//  WebsocketService.swift
//  
//
//  Created by Ilya Senchukov on 05.12.2021.
//

import Foundation

public protocol WebsocketService {
    associatedtype Storage: TaskStorage
    
    func path() -> String

	func setupRequest(_ request: inout URLRequest)

    var taskStorage: Storage { get set }
}

private extension WebsocketService {

    var session: URLSession {
        .init(configuration: .default)
    }

	var request: URLRequest? {
		guard let url = url else { return nil }

		var request = URLRequest(url: url)
		setupRequest(&request)
		return request
	}

    var url: URL? {
        URL(string: path())
    }

    var decoder: JSONDecoder {
        .init()
    }

	func setupRequest(_ request: inout URLRequest) { }

    func receive(task: URLSessionWebSocketTask, receiveHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        guard task.state == .running || task.state == .suspended else {
            return
        }
        task.receive(completionHandler: { res in
            receiveHandler(res)
            receive(task: task, receiveHandler: receiveHandler)
        })
    }

}

public extension WebsocketService {

    @discardableResult
    mutating func connect(receiveHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) -> URLSessionWebSocketTask? {
        guard let request = request else {
			receiveHandler(.failure(NetworkError(error: .badRequest)))
            return nil
        }

        let task = session.webSocketTask(with: request)
		print("✅ [\(Date())] - Connected to \(request.description)")
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
                    guard let task = task,
                        task.state == .running else {
                        return
                    }
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
							let error = NetworkError(error: .badData("Data response from websocket is not supported"))
							onError?(error)
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

public extension WebsocketService {

    func send(message: URLSessionWebSocketTask.Message, completion: @escaping (Error?) -> Void) {
        taskStorage.send(message: message, completion: completion)
    }

    func send<T: Encodable>(object: T) {
        guard let data = try? JSONEncoder().encode(object),
              let message = String(data: data, encoding: .utf8) else {
                  return
              }

        taskStorage.send(message: .string(message), completion: { _ in })
    }

}
