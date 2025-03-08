//
//  NEOnDemandRuleInterfaceType+CaseIterable.swift
//  DNSecure
//
//  Created by Kenta Kubo on 12/20/20.
//

import NetworkExtension

extension NEOnDemandRuleInterfaceType: @retroactive CaseIterable {
    public static var allCases: [Self] {
        #if os(macOS)
            return [.any, .ethernet, .wiFi]
        #else
            return [.any, .wiFi, .cellular]
        #endif
    }
}
