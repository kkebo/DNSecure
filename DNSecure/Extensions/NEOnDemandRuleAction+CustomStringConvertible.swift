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
        case .connect: "Apply settings"
        case .disconnect: "Do not apply settings"
        case .evaluateConnection: "Apply with excluded domains"
        case .ignore: "As is"
        @unknown case _: "Unknown"
        }
    }
}
