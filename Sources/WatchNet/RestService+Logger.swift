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
        }

        log(message: message)
    }

    private func log(message: String) {
        #if DEBUG
        print(message)
        #endif
    }

    func log(response: URLResponse, startTime: DispatchTime? = nil) {
        #if DEBUG
        let success = mapError(by: response) == nil
        let message = messageFrom(response: response)
        log(success: success, message: message, separator: " ")

        #endif
    }

    func log(success: Bool, message: String? = nil, separator: String = ", ") {
        #if DEBUG

        let method = method().rawValue

        let icon = getIconIf(success: success)
        let date = Date()
        let _message = message != nil ? message! + separator : ""
        let url = url?.absoluteString ?? path()

        print("\(icon) [\(date)] - \(method) \(url) \(_message)")

        #endif
    }

}

private extension RestService {

    func messageFrom(response: URLResponse, startTime: DispatchTime? = nil) -> String {
        let statusCode = (response as! HTTPURLResponse).statusCode
        return "\(statusCode) \(timeFrom(startTime: startTime))"
    }

    func getIconIf(success: Bool) -> String {
        success ? "✅" : "🔴"
    }

    func timeFrom(startTime: DispatchTime?) -> String {
        guard let startTime = startTime else { return "" }

        return "\((DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000) ms "
    }

}

