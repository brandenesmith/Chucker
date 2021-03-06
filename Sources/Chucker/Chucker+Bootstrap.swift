//
//  Chucker+Bootstrap.swift
//  
//
//  Created by Branden Smith on 3/31/21.
//

import Foundation

internal extension String {
    enum CommandLineArgs {
        static let useMockData = "--useMockData"
    }
}
public func bootstrap(configFilename: String?, mockDataManifest: String? = nil, mockDataBundle: Bundle? = nil) {
    _ = networkTrafficManager

    if let config = configFilename, let mockDataManifest = mockDataManifest {
        networkTrafficManager.mockDataManager = MockDataManager(
            config: config,
            manifest: mockDataManifest,
            bundle: mockDataBundle ?? .main
        )
    }
}
