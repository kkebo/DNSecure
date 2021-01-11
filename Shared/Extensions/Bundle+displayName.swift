//
//  BundleExtensions.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/25/20.
//

import Foundation

extension Bundle {
    var displayName: String? {
        self.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? self.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
