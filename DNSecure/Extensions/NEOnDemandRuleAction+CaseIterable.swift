//
//  NEOnDemandRuleAction+CaseIterable.swift
//  DNSecure
//
//  Created by Kenta Kubo on 12/20/20.
//

import NetworkExtension

extension NEOnDemandRuleAction: @retroactive CaseIterable {
    public static var allCases: [Self] {
        [.connect, .disconnect, .evaluateConnection, .ignore]
    }
}
