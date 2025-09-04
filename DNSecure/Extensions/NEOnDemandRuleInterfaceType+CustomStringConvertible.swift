//
//  NEOnDemandRuleInterfaceType+CustomStringConvertible.swift
//  DNSecure
//
//  Created by Kenta Kubo on 12/20/20.
//

import NetworkExtension

extension NEOnDemandRuleInterfaceType: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .any: "Any"
        #if os(macOS)
            case .ethernet: "Ethernet"
        #endif
        case .wiFi: "Wi-Fi"
        #if os(iOS)
            case .cellular: "Cellular"
        #endif
        @unknown case _: "Unknown"
        }
    }
}
