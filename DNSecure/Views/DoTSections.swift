//
//  DoTSections.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/23/22.
//

import SwiftUI

private enum FocusedField {
    case address
    case serverName
}

struct DoTSections {
    @Binding var server: Resolver
    @State var configuration: DoTConfiguration
    @FocusState private var focusedField: FocusedField?

    private func commit() {
        self.server.configuration = .dnsOverTLS(self.configuration)
    }
}

extension DoTSections: View {
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
                self.configuration.servers.append("")
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
                Text("Server Name")
                Spacer()
                TextField(
                    "Server Name",
                    text: .init(
                        get: { self.configuration.serverName ?? "" },
                        set: {
                            self.configuration.serverName = $0
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    )
                )
                .focused(self.$focusedField, equals: .serverName)
                .multilineTextAlignment(.trailing)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
        } header: {
            Text("DNS-over-TLS Settings")
        } footer: {
            Text("The TLS name of a DNS-over-TLS server.")
        }
        .onChange(of: self.focusedField) { newValue in
            if newValue == nil {
                self.commit()
            }
        }
        .onDisappear {
            self.commit()
        }
    }
}

struct DoTSections_Previews: PreviewProvider {
    static var previews: some View {
        let configuration = DoTConfiguration(
            servers: [
                "1.1.1.1",
                "1.0.0.1",
                "2606:4700:4700::1111",
                "2606:4700:4700::1001",
            ],
            serverName: "cloudflare-dns.com"
        )
        let resolver = Resolver(name: "1.1.1.1", configuration: .dnsOverTLS(configuration))
        Form {
            DoTSections(server: .constant(resolver), configuration: configuration)
        }
    }
}
