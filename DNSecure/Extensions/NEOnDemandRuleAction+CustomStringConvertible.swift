//
//  NEOnDemandRuleAction+CustomStringConvertible.swift
//  DNSecure
//
//  Created by Kenta Kubo on 12/20/20.
//

import NetworkExtension

extension NEOnDemandRuleAction: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .connect:
            return "Apply settings"
        case .disconnect:
            return "Do not apply settings"
        case .evaluateConnection:
            return "Apply with excluded domains"
        case .ignore:
            return "As is"
        default:
            return "Unknown"
        }
    }
}
