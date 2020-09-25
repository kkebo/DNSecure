//
//  Resolver.swift
//  CustomDNS
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

extension DoHConfiguration: Codable {}

enum Configuration {
    case dnsOverTLS(DoTConfiguration)
    case dnsOverHTTPS(DoHConfiguration)

    func toDNSSettings() -> NEDNSSettings {
        switch self {
        case let .dnsOverTLS(configuration):
            return configuration.toDNSSettings()
        case let .dnsOverHTTPS(configuration):
            return configuration.toDNSSettings()
        }
    }
}

extension Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case base, dotConfiguration, dohConfiguration
    }

    enum Base: String, Codable {
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
        case let .dnsOverTLS(configuration):
            try container.encode(Self.Base.dnsOverTLS, forKey: .base)
            try container.encode(configuration, forKey: .dotConfiguration)
        case let .dnsOverHTTPS(configuration):
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

struct Resolver {
    var id = UUID()
    var name: String
    var configuration: Configuration
}

extension Resolver: Identifiable {}

extension Resolver: Codable {}

typealias Resolvers = [Resolver]

extension Resolvers {
    func find(by id: UUID) -> Self.Element? {
        self.first { $0.id == id }
    }
}

extension Resolvers: RawRepresentable {
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
