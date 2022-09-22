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

    private func binding(for rule: OnDemandRule) -> Binding<OnDemandRule> {
        guard let index = self.server.onDemandRules.firstIndex(of: rule) else {
            preconditionFailure("Can't find rule in array")
        }
        return self.$server.onDemandRules[index]
    }
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
            self.serverConfigurationSections
            Section {
                ForEach(self.server.onDemandRules) { rule in
                    NavigationLink(
                        rule.name,
                        destination: RuleView(rule: self.binding(for: rule))
                    )
                }
                .onDelete { self.server.onDemandRules.remove(atOffsets: $0) }
                .onMove { self.server.onDemandRules.move(fromOffsets: $0, toOffset: $1) }
                Button("Add New Rule") {
                    self.server.onDemandRules
                        .append(OnDemandRule(name: "New Rule"))
                }
            } header: {
                EditButton()
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .overlay(Text("On Demand Rules"), alignment: .leading)
            }
        }
        .navigationTitle(self.server.name)
    }

    @ViewBuilder private var serverConfigurationSections: some View {
        switch self.server.configuration {
        case .dnsOverTLS(let configuration):
            self.dnsOverTLSSections(configuration)
        case .dnsOverHTTPS(let configuration):
            self.dnsOverHTTPSSections(configuration)
        }
    }

    @ViewBuilder
    private func dnsOverTLSSections(
        _ configuration: DoTConfiguration
    ) -> some View {
        var configuration = configuration
        Section {
            ForEach(0..<configuration.servers.count, id: \.self) { i in
                TextField(
                    "IP address",
                    text: .init(
                        get: { configuration.servers[i] },
                        set: {
                            configuration.servers[i] = $0
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    ),
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            self.server.configuration = .dnsOverTLS(configuration)
                        }
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
        } header: {
            EditButton()
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .overlay(Text("Servers"), alignment: .leading)
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
                        get: {
                            configuration.serverName ?? ""
                        },
                        set: {
                            configuration.serverName = $0
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    ),
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            self.server.configuration = .dnsOverTLS(configuration)
                        }
                    }
                )
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
    }

    @ViewBuilder
    private func dnsOverHTTPSSections(
        _ configuration: DoHConfiguration
    ) -> some View {
        var configuration = configuration
        Section {
            ForEach(0..<configuration.servers.count, id: \.self) { i in
                TextField(
                    "IP address",
                    text: .init(
                        get: { configuration.servers[i] },
                        set: {
                            configuration.servers[i] = $0
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    ),
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            self.server.configuration = .dnsOverHTTPS(configuration)
                        }
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
        } header: {
            EditButton()
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .overlay(Text("Servers"), alignment: .leading)
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
                    ),
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            self.server.configuration = .dnsOverHTTPS(configuration)
                        }
                    }
                )
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
