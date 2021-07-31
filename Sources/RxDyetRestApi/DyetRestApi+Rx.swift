//
//  DyetRestApi+Rx.swift
//  DyetRestApi+Rx
//
//  Created by Ilya Senchukov on 01.08.2021.
//

import DyetRestApi
import RxSwift

public extension RestJSONService {

    func executeObservable(query: String = "", parameters: [String: String]? = nil) -> Observable<Output> {
        
        Observable.create { observer in
            (self as RestDataService).execute(query: query, parameters: parameters) { res in
                switch res {
                    case .failure(let error):
                        observer.on(.error(error))
                    case .success(let data):
                        if let result = decode(data: data) {
                            observer.on(.next(result))
                            observer.on(.completed)
                        }

                        observer.on(.error(NetworkError.badData))
                }
            }

            return Disposables.create()
        }

    }

}
