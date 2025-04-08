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
        case .any:
            return "Any"
        #if os(macOS)
            case .ethernet:
                return "Ethernet"
        #endif
        case .wiFi:
            return "Wi-Fi"
        #if os(iOS)
            case .cellular:
                return "Cellular"
        #endif
        default:
            return "Unknown"
        }
    }
}
