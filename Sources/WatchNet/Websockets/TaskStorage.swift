//
//  TaskStorage.swift
//  
//
//  Created by Ilya Senchukov on 08.01.2022.
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
