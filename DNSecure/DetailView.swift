//
//  DetailView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/25/20.
//

import SwiftUI

struct DetailView {
    @Binding var server: Resolver
    @Binding var isOn: Bool
}

extension DetailView: View {
    var body: some View {
        Form {
            Section {
                Toggle("Use This Server", isOn: self.$isOn)
            }
            Section {
                HStack {
                    Text("Name")
                    TextField("Name", text: self.$server.name)
                        .multilineTextAlignment(.trailing)
                }
            }
            switch self.server.configuration {
            case var .dnsOverTLS(configuration):
                Section(
                    header: EditButton()
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .overlay(Text("Servers"), alignment: .leading),
                    footer: Text("The DNS server IP addresses.")
                ) {
                    ForEach(0..<configuration.servers.count, id: \.self) { i in
                        TextField(
                            "IP address",
                            text: .init(
                                get: { configuration.servers[i] },
                                set: { configuration.servers[i] = $0 }
                            ),
                            onCommit: {
                                self.server.configuration = .dnsOverTLS(configuration)
                            }
                        )
                        .textContentType(.URL)
                        .keyboardType(.numbersAndPunctuation)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .onDelete {
                        configuration.servers.remove(atOffsets: $0)
                        self.server.configuration = .dnsOverTLS(configuration)
                    }
                    .onMove {
                        configuration.servers.move(fromOffsets: $0, toOffset: $1)
                        self.server.configuration = .dnsOverTLS(configuration)
                    }
                    Button("Add New Server") {
                        configuration.servers.append("")
                        self.server.configuration = .dnsOverTLS(configuration)
                    }
                }
                Section(
                    header: Text("DNS-over-TLS Settings"),
                    footer: Text("The TLS name of a DNS-over-TLS server.")
                ) {
                    HStack {
                        Text("Server Name")
                        Spacer()
                        TextField(
                            "Server Name",
                            text: .init(
                                get: {
                                    configuration.serverName ?? ""
                                },
                                set: {
                                    configuration.serverName = $0
                                }
                            ),
                            onCommit: {
                                self.server.configuration = .dnsOverTLS(configuration)
                            }
                        )
                        .multilineTextAlignment(.trailing)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                }
            case var .dnsOverHTTPS(configuration):
                Section(
                    header: EditButton()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .overlay(Text("Servers"), alignment: .leading),
                    footer: Text("The DNS server IP addresses.")
                ) {
                    ForEach(0..<configuration.servers.count, id: \.self) { i in
                        TextField(
                            "IP address",
                            text: .init(
                                get: { configuration.servers[i] },
                                set: { configuration.servers[i] = $0 }
                            ),
                            onCommit: {
                                self.server.configuration = .dnsOverHTTPS(configuration)
                            }
                        )
                        .textContentType(.URL)
                        .keyboardType(.numbersAndPunctuation)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .onDelete {
                        configuration.servers.remove(atOffsets: $0)
                        self.server.configuration = .dnsOverHTTPS(configuration)
                    }
                    .onMove {
                        configuration.servers.move(fromOffsets: $0, toOffset: $1)
                        self.server.configuration = .dnsOverHTTPS(configuration)
                    }
                    Button("Add New Server") {
                        configuration.servers.append("")
                        self.server.configuration = .dnsOverHTTPS(configuration)
                    }
                }
                Section(
                    header: Text("DNS-over-HTTPS Settings"),
                    footer: Text("The URL of a DNS-over-HTTPS server.")
                ) {
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
                                    configuration.serverURL = URL(string: $0)
                                }
                            ),
                            onCommit: {
                                self.server.configuration = .dnsOverHTTPS(configuration)
                            }
                        )
                        .multilineTextAlignment(.trailing)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                }
            }
        }
        .navigationTitle(self.server.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            server: .constant(
                .init(
                    name: "My Server",
                    configuration: .dnsOverTLS(DoTConfiguration())
                )
            ),
            isOn: .constant(true)
        )
    }
}
