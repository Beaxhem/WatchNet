//
//  RestService+Cache.swift
//  
//
//  Created by Ilya Senchukov on 05.11.2021.
//

import Foundation

extension RestService {

    var allowedDiskSize: Int {
        100 * 1024 * 1024
    }

    var cache: URLCache {
        URLCache(memoryCapacity: 0, diskCapacity: allowedDiskSize, diskPath: "responseCache")
    }

}

