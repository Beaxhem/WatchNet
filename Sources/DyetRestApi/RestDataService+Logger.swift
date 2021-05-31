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

        let icon = getIcon(by: response)
        let date = Date()
        let timeTaken = getTimeTaken(startTime: startTime)
        let method = method.string
        let path = path ?? ""
        let statusCode = (response as! HTTPURLResponse).statusCode

        print(
            "\(icon) [\(date)] \(timeTaken)- \(method) \(path) \(statusCode)"
        )

        #endif
    }

}

private extension RestDataService {

    func getIcon(by response: URLResponse) -> String {
        mapError(by: response) == nil ? "✅" : "🔴"
    }

    func getTimeTaken(startTime: DispatchTime?) -> String {

        guard let startTime = startTime else {
            return ""
        }

        return "\((DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000) ms "
    }

}
