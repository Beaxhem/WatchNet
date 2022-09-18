//
//  RestService+Logger.swift
//  
//
//  Created by Ilya Senchukov on 05.11.2021.
//

import Foundation

public extension RestService {

    func log(_ result: Result<URLResponse, NetworkError>, startTime: DispatchTime? = nil) {
        var message: String
        let method = method().rawValue
        let url = url?.absoluteString ?? path()

        switch result {
            case .success(let response):
                let statusCode = (response as! HTTPURLResponse).statusCode
                message = "✅ [\(Date())] - \(method) \(url) \(statusCode) \(timeFrom(startTime: startTime))"
            case .failure(let error):
                message = "🔴 [\(Date())] - \(method) \(url) \(error.string) \(timeFrom(startTime: startTime))"
				if let data = error.responseData,
				   let dataString = String(data: data, encoding: .utf8) {
					message += "\n\(dataString)"
				}
        }

        log(message: message)
    }

}

private extension RestService {

	func log(message: String) {
#if DEBUG
		print(message)
#endif
	}

    func timeFrom(startTime: DispatchTime?) -> String {
        guard let startTime = startTime else { return "" }

        return "\((DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000) ms "
    }

}

