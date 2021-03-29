//
//  URLSessionTask+Swizzle.swift
//  
//
//  Created by Branden Smith on 3/29/21.
//

import Foundation

extension URLSessionTask {
    private typealias CombinedResume = @convention(c) (AnyObject, Selector) -> Void

    static func swizzleResume() {
        method_exchangeImplementations(
            class_getInstanceMethod(URLSessionDataTask.self, #selector(URLSessionTask.resume))!,
            class_getInstanceMethod(URLSessionDataTask.self, #selector(URLSessionTask.swizzledResume))!
        )
    }

    @objc func swizzledResume() {
        unsafeBitCast(
            class_getMethodImplementation(Self.self, #selector(URLSessionTask.swizzledResume)),
            to: CombinedResume.self
        )(self, #selector(URLSessionTask.resume))
    }
}
