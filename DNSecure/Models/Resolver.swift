//
//  Resolver.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/25/20.
//

import Foundation
import NetworkExtension

struct DoTConfiguration {
    var servers: [String] = []
    var serverName: String? = nil

    func toDNSSettings() -> NEDNSOverTLSSettings {
        let settings = NEDNSOverTLSSettings(servers: self.servers)
        settings.serverName = self.serverName
        return settings
    }
}

extension DoTConfiguration: Equatable {}

extension DoTConfiguration: Hashable {}

extension DoTConfiguration: Codable {}

struct DoHConfiguration {
    var servers: [String] = []
    var serverURL: URL? = nil

    func toDNSSettings() -> NEDNSOverHTTPSSettings {
        let settings = NEDNSOverHTTPSSettings(servers: self.servers)
        settings.serverURL = self.serverURL
        return settings
    }
}

extension DoHConfiguration: Equatable {}

extension DoHConfiguration: Hashable {}

extension DoHConfiguration: Codable {}

enum Configuration {
    case dnsOverTLS(DoTConfiguration)
    case dnsOverHTTPS(DoHConfiguration)

    func toDNSSettings() -> NEDNSSettings {
        switch self {
        case .dnsOverTLS(let configuration):
            return configuration.toDNSSettings()
        case .dnsOverHTTPS(let configuration):
            return configuration.toDNSSettings()
        }
    }
}

extension Configuration: Equatable {}

extension Configuration: Hashable {}

extension Configuration: Codable {
    private enum CodingKeys: String, CodingKey {
        case base, dotConfiguration, dohConfiguration
    }

    private enum Base: String, Codable {
        case dnsOverTLS, dnsOverHTTPS
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys.self)
        let base = try container.decode(Self.Base.self, forKey: .base)

        switch base {
        case .dnsOverTLS:
            let configuration = try container.decode(DoTConfiguration.self, forKey: .dotConfiguration)
            self = .dnsOverTLS(configuration)
        case .dnsOverHTTPS:
            let configuration = try container.decode(DoHConfiguration.self, forKey: .dohConfiguration)
            self = .dnsOverHTTPS(configuration)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys.self)

        switch self {
        case .dnsOverTLS(let configuration):
            try container.encode(Self.Base.dnsOverTLS, forKey: .base)
            try container.encode(configuration, forKey: .dotConfiguration)
        case .dnsOverHTTPS(let configuration):
            try container.encode(Self.Base.dnsOverHTTPS, forKey: .base)
            try container.encode(configuration, forKey: .dohConfiguration)
        }
    }
}

extension Configuration: CustomStringConvertible {
    var description: String {
        switch self {
        case .dnsOverTLS: return "DNS-over-TLS"
        case .dnsOverHTTPS: return "DNS-over-HTTPS"
        }
    }
}

struct OnDemandRule {
    var id = UUID()
    var name: String
    var action: NEOnDemandRuleAction = .ignore
    var interfaceType: NEOnDemandRuleInterfaceType = .any
    var ssidMatch: [String] = []
    var dnsSearchDomainMatch: [String] = []
    var dnsServerAddressMatch: [String] = []
    var probeURL: URL?
}

extension OnDemandRule: Identifiable {}

extension OnDemandRule: Equatable {}

extension OnDemandRule: Hashable {}

extension OnDemandRule: Codable {}

extension Array where Self.Element == OnDemandRule {
    func toNEOnDemandRules() -> [NEOnDemandRule] {
        self.lazy
            .map { rule in
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
                default:
                    preconditionFailure("Unexpected NEOnDemandRuleAction")
                }
            }
    }
}

struct Resolver {
    var id = UUID()
    var name: String
    var configuration: Configuration
    var onDemandRules: [OnDemandRule] = []
}

extension Resolver: Identifiable {}

extension Resolver: Equatable {}

extension Resolver: Hashable {}

extension Resolver: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, configuration, onDemandRules
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.configuration = try container.decode(Configuration.self, forKey: .configuration)
        self.onDemandRules =
            try container.decodeIfPresent(
                [OnDemandRule].self,
                forKey: .onDemandRules
            ) ?? []
    }
}

typealias Resolvers = [Resolver]

extension Resolvers {
    func find(by id: UUID) -> Self.Element? {
        self.first { $0.id == id }
    }
}

extension Resolvers: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
