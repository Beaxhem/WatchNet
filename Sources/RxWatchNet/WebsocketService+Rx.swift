//
//  WebsocketsService+Rx.swift
//  
//
//  Created by Ilya Senchukov on 05.12.2021.
//

import Foundation
import WatchNet
import RxSwift

extension WebsocketService: ReactiveCompatible { }

public extension Reactive where Base: WebsocketService {

    func receive(onData: ((Data) -> ())?,
                 onString: ((String) -> ())?,
                 onError: ((Error) -> ())?) -> Disposable {

        let observable = Observable<Void>.create { observer in
            let task = self.base.connect { res in
                switch res {
                    case .success(let message):
                        switch message {
                            case .data(let data):
                                onData?(data)
                            case .string(let string):
                                onString?(string)
                            @unknown default:
                                fatalError("Not implemented")
                        }
                        observer.on(.next(()))
                    case .failure(let error):
                        observer.on(.error(error))
                        onError?(error)
                }
            }

            return Disposables.create {
                task?.cancel()
            }
        }

        return observable.subscribe()
    }

}

public extension Reactive where Base: WebsocketObjectService {

    func receive<T: Decodable>(decodingTo: T.Type) -> Observable<T> {
        Observable.create { observer in
            let task = base.connect(decodingTo: T.self) { object in
                observer.onNext(object)
            } onError: { error in
                observer.onError(error)
            }

            return Disposables.create {
                task?.cancel()
            }
        }
    }

}
