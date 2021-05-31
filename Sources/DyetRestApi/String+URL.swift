//
//  String+URL.swift
//  
//
//  Created by Ilya Senchukov on 31.05.2021.
//

import Foundation

public extension String {

    var urlAllowed: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }

}
