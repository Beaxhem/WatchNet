//
//  RestService+Logger.swift
//  
//
//  Created by Ilya Senchukov on 05.11.2021.
//

import Foundation

public extension RestService {

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

        let method = method().rawValue

        let icon = getIconIf(success: success)
        let date = Date()
        let _message = message != nil ? message! + separator : ""

        print("\(icon) [\(date)] - \(method) \(path()) \(_message)")

        #endif
    }

}

private extension RestService {

    func getIconIf(success: Bool) -> String {
        success ? "✅" : "🔴"
    }

    func getTimeTaken(startTime: DispatchTime?) -> String {
        guard let startTime = startTime else { return "" }

        return "\((DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000) ms "
    }

}

