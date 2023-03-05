//
//  DoHSections.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/23/22.
//

import SwiftUI

private enum FocusedField {
    case address
    case serverURL
}

struct DoHSections {
    @Binding var server: Resolver
    @State var configuration: DoHConfiguration
    @FocusState private var focusedField: FocusedField?

    private func commit() {
        self.server.configuration = .dnsOverHTTPS(self.configuration)
    }
}

extension DoHSections: View {
    var body: some View {
        Section {
            ForEach(0..<self.configuration.servers.count, id: \.self) { i in
                TextField(
                    "IP address",
                    text: .init(
                        get: { self.configuration.servers[i] },
                        set: {
                            self.configuration.servers[i] = $0
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    )
                )
                .focused(self.$focusedField, equals: .address)
                .textContentType(.URL)
                .keyboardType(.numbersAndPunctuation)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
            .onDelete {
                self.configuration.servers.remove(atOffsets: $0)
                self.commit()
            }
            .onMove {
                self.configuration.servers.move(fromOffsets: $0, toOffset: $1)
                self.commit()
            }
            Button("Add New Server") {
                configuration.servers.append("")
                self.commit()
            }
        } header: {
            EditButton()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .overlay(alignment: .leading) {
                    Text("Servers")
                }
        } footer: {
            Text("The DNS server IP addresses.")
        }
        Section {
            HStack {
                Text("Server URL")
                Spacer()
                TextField(
                    "Server URL",
                    text: .init(
                        get: {
                            configuration.serverURL?.absoluteString ?? ""
                        },
                        set: {
                            configuration.serverURL = URL(
                                string: $0.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
                        }
                    )
                )
                .focused(self.$focusedField, equals: .serverURL)
                .multilineTextAlignment(.trailing)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
        } header: {
            Text("DNS-over-HTTPS Settings")
        } footer: {
            Text("The URL of a DNS-over-HTTPS server.")
        }
        .onChange(of: self.focusedField) { newValue in
            if newValue == nil {
                self.commit()
            }
        }
        .onChange(of: self.server) { server in
            switch server.configuration {
            case .dnsOverTLS:
                preconditionFailure("unreachable")
            case .dnsOverHTTPS(let configuration):
                self.configuration = configuration
            }
        }
        .onDisappear {
            self.commit()
        }
    }
}

struct DoHSections_Previews: PreviewProvider {
    static var previews: some View {
        let configuration = DoHConfiguration(
            servers: [
                "1.1.1.1",
                "1.0.0.1",
                "2606:4700:4700::1111",
                "2606:4700:4700::1001",
            ],
            serverURL: URL(string: "https://cloudflare-dns.com/dns-query")
        )
        let resolver = Resolver(name: "1.1.1.1", configuration: .dnsOverHTTPS(configuration))
        Form {
            DoHSections(server: .constant(resolver), configuration: configuration)
        }
    }
}
