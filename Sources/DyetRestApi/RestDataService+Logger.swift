//
//  RestDataService+Logger.swift
//  
//
//  Created by Ilya Senchukov on 28.05.2021.
//

import Foundation

public extension RestDataService {

    func log(response: URLResponse, startTime: DispatchTime? = nil) {
        #if DEBUG

        let success = mapError(by: response) == nil

        let timeTaken = getTimeTaken(startTime: startTime)
        let statusCode = (response as! HTTPURLResponse).statusCode
        let message = "\(statusCode) \(timeTaken)"

        log(success: success, message: message, separator: " ")

        #endif
    }

    func log(success: Bool, message: String? = nil, separator: String = ", ") {
        #if DEBUG

        let icon = getIconIf(success: success)
        let date = Date()
        let method = method.string
        let path = path ?? "empty_path"
        var _message = ""
        if let message = message {
            _message = separator + message
        }

        print(
            "\(icon) [\(date)] - \(method) \(path)\(_message)"
        )

        #endif
    }

}

private extension RestDataService {

    func getIconIf(success: Bool) -> String {
        success ? "✅" : "🔴"
    }

    func getTimeTaken(startTime: DispatchTime?) -> String {

        guard let startTime = startTime else {
            return ""
        }

        return "\((DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000) ms "
    }

}
