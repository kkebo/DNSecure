//
//  NEOnDemandRuleInterfaceType+isSSIDUsed.swift
//  DNSecure
//
//  Created by Kenta Kubo on 12/20/20.
//

import NetworkExtension

extension NEOnDemandRuleInterfaceType {
    var isSSIDUsed: Bool {
        switch self {
        case .any, .wiFi: true
        case _: false
        }
    }
}
