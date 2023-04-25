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

    private func binding(for id: UUID) -> Binding<OnDemandRule> {
        guard let index = self.server.onDemandRules.map(\.id).firstIndex(of: id) else {
            preconditionFailure("Can't find rule in array")
        }
        return self.$server.onDemandRules[index]
    }
}

extension DetailView: View {
    var body: some View {
        if #available(iOS 16, *) {
            self.modernBody
        } else {
            self.legacyBody
        }
    }

    @available(iOS 16, *)
    private var modernBody: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Use This Server", isOn: self.$isOn)
                }
                Section("Name") {
                    LazyTextField("Name", text: self.$server.name)
                }
                self.serverConfigurationSections
                Section {
                    ForEach(self.server.onDemandRules) { rule in
                        NavigationLink(rule.name, value: rule.id)
                    }
                    .onDelete { self.server.onDemandRules.remove(atOffsets: $0) }
                    .onMove { self.server.onDemandRules.move(fromOffsets: $0, toOffset: $1) }
                    Button("Add New Rule") {
                        self.server.onDemandRules
                            .append(OnDemandRule(name: "New Rule"))
                    }
                } header: {
                    EditButton()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .overlay(alignment: .leading) {
                            Text("On Demand Rules")
                        }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                // When RuleView is opened and tap another server on the sidebar, the previous server's rule comes here.
                if self.server.onDemandRules.map(\.id).contains(id) {
                    RuleView(rule: self.binding(for: id))
                }
            }
        }
        .navigationTitle(self.server.name)
    }

    private var legacyBody: some View {
        Form {
            Section {
                Toggle("Use This Server", isOn: self.$isOn)
            }
            Section("Name") {
                LazyTextField("Name", text: self.$server.name)
            }
            self.serverConfigurationSections
            Section {
                ForEach(self.server.onDemandRules) { rule in
                    NavigationLink(rule.name) {
                        RuleView(rule: self.binding(for: rule.id))
                    }
                }
                .onDelete { self.server.onDemandRules.remove(atOffsets: $0) }
                .onMove { self.server.onDemandRules.move(fromOffsets: $0, toOffset: $1) }
                Button("Add New Rule") {
                    self.server.onDemandRules
                        .append(OnDemandRule(name: "New Rule"))
                }
            } header: {
                EditButton()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .overlay(alignment: .leading) {
                        Text("On Demand Rules")
                    }
            }
        }
        .navigationTitle(self.server.name)
    }

    @ViewBuilder private var serverConfigurationSections: some View {
        switch self.server.configuration {
        case .dnsOverTLS(let configuration):
            DoTSections(
                configuration: .init(
                    get: { configuration },
                    set: { self.server.configuration = .dnsOverTLS($0) }
                )
            )
        case .dnsOverHTTPS(let configuration):
            DoHSections(
                configuration: .init(
                    get: { configuration },
                    set: { self.server.configuration = .dnsOverHTTPS($0) }
                )
            )
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
