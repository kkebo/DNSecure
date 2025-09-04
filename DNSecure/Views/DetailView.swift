//
//  DetailView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/25/20.
//

import SwiftUI

struct DetailView {
    @Binding var server: Resolver
    @Binding var isSelected: Bool
    @Binding var isActivated: Bool
    @State private var isGuidePresented = false

    private func binding(for id: UUID) -> Binding<OnDemandRule> {
        guard let index = self.server.onDemandRules.map(\.id).firstIndex(of: id) else {
            preconditionFailure("Can't find rule in array")
        }
        return self.$server.onDemandRules[index]
    }
}

@MainActor
extension DetailView: View {
    var body: some View {
        Form {
            Section {
                Toggle("Use This Server", isOn: self.$isSelected)
                if self.isSelected && !self.isActivated {
                    Button("One more step is required.", systemImage: "exclamationmark.triangle") {
                        self.isGuidePresented = true
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(.red)
                    .sheet(isPresented: self.$isGuidePresented) {
                        NavigationView {
                            HowToActivateView()
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        if #available(iOS 26, *) {
                                            Button("Close", systemImage: "xmark", role: .close) {
                                                self.isGuidePresented = false
                                            }
                                        } else {
                                            Button("Close", systemImage: "xmark", role: .cancel) {
                                                self.isGuidePresented = false
                                            }
                                        }
                                    }
                                }
                        }
                        .navigationViewStyle(.stack)
                    }
                }
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
                        Text("On-Demand Rules")
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

#Preview {
    DetailView(
        server: .constant(
            .init(
                name: "My Server",
                configuration: .dnsOverTLS(DoTConfiguration())
            )
        ),
        isSelected: .constant(true),
        isActivated: .constant(true)
    )
}
