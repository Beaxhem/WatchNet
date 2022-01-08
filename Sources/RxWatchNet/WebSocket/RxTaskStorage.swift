//
//  RxTaskStorage.swift
//  
//
//  Created by Ilya Senchukov on 08.01.2022.
//

import Foundation
import WatchNet
import RxSwift
import RxCocoa

public class RxTaskStorage: TaskStorage {

    public var task: URLSessionWebSocketTask?

    public var message = BehaviorRelay<URLSessionWebSocketTask.Message?>(value: nil)

    public var send: Observable<Void> {
        message
            .compactMap { $0 }
            .flatMapLatest { [weak self] message -> Single<Void> in
                guard let self = self,
                      let task = self.task else {
                          return .never()
                      }

                return self.send(task: task, message: message)
            }
    }

    public init() { }

    func send(task: URLSessionWebSocketTask, message: URLSessionWebSocketTask.Message) -> Single<Void> {
        Single.create { single in
            task.send(message) { error in
                guard let error = error else {
                    single(.success(()))
                    return
                }
                single(.failure(error))
            }

            return Disposables.create {
                task.cancel(with: .goingAway, reason: nil)
            }
        }
    }

    func accept(message messageToSend: URLSessionWebSocketTask.Message) {
        message.accept(messageToSend)
    }

}
