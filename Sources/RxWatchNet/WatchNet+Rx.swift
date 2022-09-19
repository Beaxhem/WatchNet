//
//  WatchNet+Rx.swift
//  WatchNet+Rx
//
//  Created by Ilya Senchukov on 01.08.2021.
//

import UIKit
import WatchNet
import RxSwift
import Foundation

public extension Reactive where Base: RestService {

	func fetch<T: Decodable>(force: Bool = true, decodingTo: T.Type) -> Single<T> {
        Single.create { single in
            let task = base.execute(decodingTo: T.self, force: force) { res in
                switch res {
                    case .success(let obj):
                        single(.success(obj))
                    case .failure(let error):
                        single(.failure(error))
                }
            }

            return Disposables.create {
                task?.cancel()
            }
        }
		.observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

	func fetch(force: Bool = true) -> Single<Data> {
        Single.create { single in
			let task = base.execute(force: force) { res in
                switch res {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        single(.failure(error))
                }
            }

            return Disposables.create {
                task?.cancel()
            }
        }
		.observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

}

public extension Reactive where Base: ImageService {

    func fetch(path: String) -> Single<UIImage> {
        Single.create { single in
            let task = base.image(for: path) { res in
                switch res {
                    case .success(let image):
                        single(.success(image))
                    case .failure(let error):
                        single(.failure(error))
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }

}

public extension Reactive where Base: RestService {

	func fetch<T: Decodable>(force: Bool = true, decodingTo: T.Type, errorHandler: @escaping (Base.ErrorResponse) -> Void) -> Single<T> {
		fetch(force: force, decodingTo: decodingTo)
			.catch { error in
				if let error = error as? Base.ErrorResponse {
					errorHandler(error)
				}
				return .error(error)
			}
	}

	func fetch(force: Bool = true, errorHandler: @escaping (Base.ErrorResponse) -> Void) -> Single<Data> {
		fetch(force: force)
			.catch { error in
				if let error = error as? Base.ErrorResponse {
					errorHandler(error)
				}
				return .error(error)
			}
	}

}

public extension ObservableType {

	func `catch`<T: Error>(error: T.Type, handler: @escaping (T) -> Void) -> Observable<Self.Element> {
		self.catch { e in
			if let error = e as? T {
				handler(error)
				return .error(e)
			}
			return .error(e)
		}
	}

}

public extension ObservableType {

	func `catch`<E: Error, T>(error: E.Type, handler: @escaping (E) -> Void) -> Observable<Self.Element> where Element == Event<T> {
		self.do(onNext: { e in
			if let error = e.error as? E {
				handler(error)
			}
		})
	}

}
