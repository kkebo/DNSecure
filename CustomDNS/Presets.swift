//
//  Presets.swift
//  CustomDNS
//
//  Created by Kenta Kubo on 9/25/20.
//

import Foundation

enum Presets {
    static let servers: Resolvers = [
        .init(
            name: "Google Public DNS",
            configuration: .dnsOverTLS(
                DoTConfiguration(
                    servers: [
                        "8.8.8.8",
                        "8.8.4.4",
                        "2001:4860:4860::8888",
                        "2001:4860:4860::8844",
                    ],
                    serverName: "dns.google"
                )
            )
        ),
        .init(
            name: "Google Public DNS",
            configuration: .dnsOverHTTPS(
                DoHConfiguration(
                    servers: [
                        "8.8.8.8",
                        "8.8.4.4",
                        "2001:4860:4860::8888",
                        "2001:4860:4860::8844",
                    ],
                    serverURL: URL(string: "https://dns.google/dns-query")
                )
            )
        ),
        .init(
            name: "1.1.1.1",
            configuration: .dnsOverTLS(
                DoTConfiguration(
                    servers: [
                        "1.1.1.1",
                        "1.0.0.1",
                        "2606:4700:4700::64",
                        "2606:4700:4700::6400",
                    ],
                    serverName: "cloudflare-dns.com"
                )
            )
        ),
        .init(
            name: "1.1.1.1",
            configuration: .dnsOverHTTPS(
                DoHConfiguration(
                    servers: [
                        "1.1.1.1",
                        "1.0.0.1",
                        "2606:4700:4700::64",
                        "2606:4700:4700::6400",
                    ],
                    serverURL: URL(string: "https://cloudflare-dns.com/dns-query")
                )
            )
        ),
    ]
}
