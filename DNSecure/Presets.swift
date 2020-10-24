//
//  Presets.swift
//  DNSecure
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
        .init(
            name: "Quad9",
            configuration: .dnsOverTLS(
                DoTConfiguration(
                    servers: [
                        "9.9.9.9",
                        "149.112.112.112",
                        "2620:fe::fe",
                        "2620:fe::fe:9",
                    ],
                    serverName: "dns.quad9.net"
                )
            )
        ),
        .init(
            name: "Quad9",
            configuration: .dnsOverHTTPS(
                DoHConfiguration(
                    servers: [
                        "9.9.9.9",
                        "149.112.112.112",
                        "2620:fe::fe",
                        "2620:fe::fe:9",
                    ],
                    serverURL: URL(string: "https://dns.quad9.net/dns-query")
                )
            )
        ),
    ]
}
