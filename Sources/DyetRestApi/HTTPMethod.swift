//
//  HTTPMethod.swift
//  
//
//  Created by Ilya Senchukov on 06.05.2021.
//

import Foundation

public enum HTTPMethod: String {

    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"

    @available(*, deprecated, message: "Use .rawValue instead")
    var string: String {
        self.rawValue.uppercased()
    }

}
