//
//  NEOnDemandRuleInterfaceType+ssidIsUsed.swift
//  DNSecure
//
//  Created by Kenta Kubo on 12/20/20.
//

import NetworkExtension

extension NEOnDemandRuleInterfaceType {
    var ssidIsUsed: Bool {
        switch self {
        case .any, .wiFi:
            return true
        default:
            return false
        }
    }
}
