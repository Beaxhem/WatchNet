//
//  HTTPMethod.swift
//  
//
//  Created by Ilya Senchukov on 06.05.2021.
//

import Foundation

public enum HTTPMethod: String {

    case get
    case post
    case delete
    case put
    case patch

    var string: String {
        self.rawValue.uppercased()
    }

}
