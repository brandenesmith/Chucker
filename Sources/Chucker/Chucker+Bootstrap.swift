//
//  Chucker+Bootstrap.swift
//  
//
//  Created by Branden Smith on 3/31/21.
//

import Foundation

enum DefaultsKey {
    static let useMockData = "chuckerMockDataEnabled"
}

public func bootstrap(configFilename: String?, mockDataManifest: String? = nil, mockDataBundle: Bundle? = nil, userDefaults: UserDefaults) {
    _ = networkTrafficManager

    if let config = configFilename, let mockDataManifest = mockDataManifest {
        networkTrafficManager.mockDataManager = MockDataManager(
            config: config,
            manifest: mockDataManifest,
            bundle: mockDataBundle ?? .main,
            userDefaults: userDefaults
        )
    }
}
