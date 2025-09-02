//
//  OnDemandRule.swift
//  DNSecure
//
//  Created by Kenta Kubo on 8/31/25.
//

import Foundation
import NetworkExtension

struct OnDemandRule {
    var id = UUID()
    var name: String
    var action: NEOnDemandRuleAction = .connect
    var interfaceType: NEOnDemandRuleInterfaceType = .any
    var ssidMatch: [String] = []
    var dnsSearchDomainMatch: [String] = []
    var dnsServerAddressMatch: [String] = []
    var probeURL: URL?
    var excludedDomains: [String]?
}

extension OnDemandRule: Identifiable {}

extension OnDemandRule: Equatable {}

extension OnDemandRule: Hashable {}

extension OnDemandRule: Codable {}

extension [OnDemandRule] {
    func toNEOnDemandRules() -> [NEOnDemandRule] {
        self.map { rule in
            switch rule.action {
            case .connect:
                let newRule = NEOnDemandRuleConnect()
                newRule.interfaceTypeMatch = rule.interfaceType
                if rule.interfaceType.isSSIDUsed {
                    newRule.ssidMatch = rule.ssidMatch
                }
                newRule.dnsSearchDomainMatch = rule.dnsSearchDomainMatch
                newRule.dnsServerAddressMatch = rule.dnsServerAddressMatch
                newRule.probeURL = rule.probeURL
                return newRule
            case .disconnect:
                let newRule = NEOnDemandRuleDisconnect()
                newRule.interfaceTypeMatch = rule.interfaceType
                if rule.interfaceType.isSSIDUsed {
                    newRule.ssidMatch = rule.ssidMatch
                }
                newRule.dnsSearchDomainMatch = rule.dnsSearchDomainMatch
                newRule.dnsServerAddressMatch = rule.dnsServerAddressMatch
                newRule.probeURL = rule.probeURL
                return newRule
            case .evaluateConnection:
                let newRule = NEOnDemandRuleEvaluateConnection()
                newRule.interfaceTypeMatch = rule.interfaceType
                if rule.interfaceType.isSSIDUsed {
                    newRule.ssidMatch = rule.ssidMatch
                }
                newRule.dnsSearchDomainMatch = rule.dnsSearchDomainMatch
                newRule.dnsServerAddressMatch = rule.dnsServerAddressMatch
                newRule.probeURL = rule.probeURL
                newRule.connectionRules =
                    switch rule.excludedDomains {
                    case let domains? where !domains.isEmpty:
                        [.init(matchDomains: domains, andAction: .neverConnect)]
                    case _: []
                    }
                return newRule
            case .ignore:
                let newRule = NEOnDemandRuleIgnore()
                newRule.interfaceTypeMatch = rule.interfaceType
                if rule.interfaceType.isSSIDUsed {
                    newRule.ssidMatch = rule.ssidMatch
                }
                newRule.dnsSearchDomainMatch = rule.dnsSearchDomainMatch
                newRule.dnsServerAddressMatch = rule.dnsServerAddressMatch
                newRule.probeURL = rule.probeURL
                return newRule
            @unknown case _:
                preconditionFailure("Unexpected NEOnDemandRuleAction")
            }
        }
    }
}
