//
//  RestDataService+Cache.swift
//  
//
//  Created by Ilya Senchukov on 31.05.2021.
//

import Foundation

extension RestDataService {

    private var allowedDiskSize: Int {
        100 * 1024 * 1024
    }

    var cache: URLCache {
        URLCache(memoryCapacity: 0, diskCapacity: allowedDiskSize, diskPath: "responseCache")
    }
    
}
