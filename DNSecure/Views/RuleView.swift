//
//  RuleView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 10/27/20.
//

import NetworkExtension
import SwiftUI

struct ExcludedDomainsView {
    @Binding var domains: [String]
}

extension ExcludedDomainsView: View {
    var body: some View {
        Form {
            Section {
                ForEach(0..<self.domains.count, id: \.self) { i in
                    LazyTextField(
                        "Domain",
                        // self.$rule.excludedDomains[i] causes crash on deletion
                        text: .init(
                            get: { self.domains[i] },
                            set: { self.domains[i] = $0 }
                        )
                    )
                }
                .onDelete { self.domains.remove(atOffsets: $0) }
                .onMove { self.domains.move(fromOffsets: $0, toOffset: $1) }
                Button("Add Domain") {
                    self.domains.append("")
                }
            } footer: {
                Text(
                    "Each domain is matched against the destination hostname using suffix matching, and each label in the domain must match an entire label in the hostname. For example, the domain `example.com` will match the hostname `www.example.com` but not `www.anotherexample.com`."
                )
            }
        }
        .navigationTitle("Excluded Domains")
        .toolbar {
            EditButton()
        }
    }
}

struct RuleView {
    @Binding var rule: OnDemandRule
}

@MainActor
extension RuleView: View {
    var body: some View {
        Form {
            Section("Name") {
                LazyTextField("Name", text: self.$rule.name)
            }

            Section("Matching Conditions") {
                NavigationLink {
                    InterfaceTypeMatchView(rule: self.$rule)
                } label: {
                    self.interfaceTypeMatchLabel
                }

                if self.rule.interfaceType.isSSIDUsed {
                    NavigationLink {
                        SSIDMatchView(rule: self.$rule)
                    } label: {
                        self.ssidMatchLabel
                    }
                }

                NavigationLink {
                    DNSSearchDomainMatchView(rule: self.$rule)
                } label: {
                    self.dnsSearchDomainMatchLabel
                }

                NavigationLink {
                    DNSServerAddressMatchView(rule: self.$rule)
                } label: {
                    self.dnsServerAddressMatchLabel
                }

                NavigationLink {
                    ProbeURLView(rule: self.$rule)
                } label: {
                    self.probeURLLabel
                }
            }

            Section {
                Picker("Action", selection: self.$rule.action) {
                    ForEach(
                        [
                            NEOnDemandRuleAction.connect,
                            .evaluateConnection,
                            .disconnect,
                        ],
                        id: \.self
                    ) {
                        Text($0.description)
                    }
                }
                if self.rule.action == .evaluateConnection {
                    NavigationLink {
                        ExcludedDomainsView(
                            domains: .init(
                                get: { self.rule.excludedDomains ?? [] },
                                set: { self.rule.excludedDomains = $0 }
                            )
                        )
                    } label: {
                        HStack {
                            Text("Excluded Domains")
                            Spacer()
                            Text("\(self.rule.excludedDomains?.count ?? 0)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(self.rule.name)
    }

    @ViewBuilder private var interfaceTypeMatchLabel: some View {
        if #available(iOS 16, *) {
            LabeledContent("Interface Type Match", value: self.rule.interfaceType.description)
        } else {
            HStack {
                Text("Interface Type Match")
                Spacer()
                Text(self.rule.interfaceType.description)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var ssidMatchLabel: some View {
        if #available(iOS 16, *) {
            LabeledContent("SSID Match") {
                if !self.rule.ssidMatch.isEmpty {
                    Text("\(self.rule.ssidMatch.count)")
                } else {
                    Text("Not Used")
                }
            }
        } else {
            HStack {
                Text("SSID Match")
                Spacer()
                Group {
                    if !self.rule.ssidMatch.isEmpty {
                        Text("\(self.rule.ssidMatch.count)")
                    } else {
                        Text("Not Used")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var dnsSearchDomainMatchLabel: some View {
        if #available(iOS 16, *) {
            LabeledContent("DNS Search Domain Match") {
                if !self.rule.dnsSearchDomainMatch.isEmpty {
                    Text("\(self.rule.dnsSearchDomainMatch.count)")
                } else {
                    Text("Not Used")
                }
            }
        } else {
            HStack {
                Text("DNS Search Domain Match")
                Spacer()
                Group {
                    if !self.rule.dnsSearchDomainMatch.isEmpty {
                        Text("\(self.rule.dnsSearchDomainMatch.count)")
                    } else {
                        Text("Not Used")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var dnsServerAddressMatchLabel: some View {
        if #available(iOS 16, *) {
            LabeledContent("DNS Server Address Match") {
                if !self.rule.dnsServerAddressMatch.isEmpty {
                    Text("\(self.rule.dnsServerAddressMatch.count)")
                } else {
                    Text("Not Used")
                }
            }
        } else {
            HStack {
                Text("DNS Server Address Match")
                Spacer()
                Group {
                    if !self.rule.dnsServerAddressMatch.isEmpty {
                        Text("\(self.rule.dnsServerAddressMatch.count)")
                    } else {
                        Text("Not Used")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var probeURLLabel: some View {
        if #available(iOS 16, *) {
            LabeledContent("Probe URL") {
                if let url = self.rule.probeURL?.absoluteString {
                    Text(url)
                } else {
                    Text("Not Used")
                }
            }
        } else {
            HStack {
                Text("Probe URL")
                Spacer()
                Group {
                    if let url = self.rule.probeURL?.absoluteString {
                        Text(url)
                    } else {
                        Text("Not Used")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var rule = OnDemandRule(name: "Preview Rule")
    NavigationStack {
        RuleView(rule: $rule)
    }
}
