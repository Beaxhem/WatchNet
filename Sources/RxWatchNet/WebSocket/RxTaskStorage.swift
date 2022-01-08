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

    public var data = PublishRelay<Data>()
    public var message = PublishRelay<URLSessionWebSocketTask.Message>()

    public var send: Observable<Void> {
        Observable.merge(
            dataObservable,
            message.asObservable()
        )
            .flatMapLatest { [weak self] message -> Single<Void> in
                guard let self = self,
                      let task = self.task else {
                          return .never()
                      }

                return self.send(task: task, message: message)
            }
    }

    var dataObservable: Observable<URLSessionWebSocketTask.Message> {
        data
            .map { String(decoding: $0, as: UTF8.self) }
            .map { .string($0) }
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
