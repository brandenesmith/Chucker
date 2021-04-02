//
//  Chucker+Bootstrap.swift
//  
//
//  Created by Branden Smith on 3/31/21.
//

import Foundation

public func bootstrap(mockDataManifest: String? = nil, mockDataBundle: Bundle? = nil) {
    _ = networkTrafficManager

    if let mockDataManifest = mockDataManifest {
        networkTrafficManager.mockDataManager = MockDataManager(manifest: mockDataManifest, bundle: mockDataBundle ?? .main)
    }
}
