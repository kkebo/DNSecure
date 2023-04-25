//
//  RuleView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 10/27/20.
//

import NetworkExtension
import SwiftUI

struct RuleView {
    @Binding var rule: OnDemandRule
}

extension RuleView: View {
    var body: some View {
        Form {
            Section("Name") {
                LazyTextField("Name", text: self.$rule.name)
            }

            Section {
                Picker("Action", selection: self.$rule.action) {
                    ForEach(NEOnDemandRuleAction.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
            }

            Section {
                Picker("Interface Type", selection: self.$rule.interfaceType) {
                    ForEach(NEOnDemandRuleInterfaceType.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
            } header: {
                Text("Interface Type Match")
            } footer: {
                Text("If the current primary network interface is of this type and all of the other conditions in the rule match, then the rule matches.")
            }

            if self.rule.interfaceType.ssidIsUsed {
                Section {
                    ForEach(0..<self.rule.ssidMatch.count, id: \.self) { i in
                        LazyTextField(
                            "SSID",
                            // self.$rule.ssidMatch[i] causes crash on deletion
                            text: .init(
                                get: { self.rule.ssidMatch[i] },
                                set: { self.rule.ssidMatch[i] = $0 }
                            )
                        )
                    }
                    .onDelete { self.rule.ssidMatch.remove(atOffsets: $0) }
                    .onMove { self.rule.ssidMatch.move(fromOffsets: $0, toOffset: $1) }
                    Button("Add SSID") {
                        NEHotspotNetwork.fetchCurrent { network in
                            self.rule.ssidMatch.append(network?.ssid ?? "")
                        }
                    }
                } header: {
                    EditButton()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .overlay(alignment: .leading) {
                            Text("SSID Match")
                        }
                } footer: {
                    Text("If the Service Set Identifier (SSID) of the current primary connected network matches one of the strings in this array and all of the other conditions in the rule match, then the rule matches.")
                }
            }

            Section {
                ForEach(0..<self.rule.dnsSearchDomainMatch.count, id: \.self) { i in
                    LazyTextField(
                        "Search Domain",
                        // self.$rule.dnsSearchDomainMatch[i] causes crash on deletion
                        text: .init(
                            get: { self.rule.dnsSearchDomainMatch[i] },
                            set: { self.rule.dnsSearchDomainMatch[i] = $0 }
                        )
                    )
                }
                .onDelete { self.rule.dnsSearchDomainMatch.remove(atOffsets: $0) }
                .onMove { self.rule.dnsSearchDomainMatch.move(fromOffsets: $0, toOffset: $1) }
                Button("Add DNS Search Domain") {
                    self.rule.dnsSearchDomainMatch.append("")
                }
            } header: {
                EditButton()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .overlay(alignment: .leading) {
                        Text("DNS Search Domain Match")
                    }
            } footer: {
                Text("If the current default search domain is equal to one of the strings in this array and all of the other conditions in the rule match, then the rule matches.")
            }

            Section {
                ForEach(0..<self.rule.dnsServerAddressMatch.count, id: \.self) { i in
                    LazyTextField(
                        "IP Address",
                        // self.$rule.dnsServerAddressMatch[i] causes crash on deletion
                        text: .init(
                            get: { self.rule.dnsServerAddressMatch[i] },
                            set: { self.rule.dnsServerAddressMatch[i] = $0 }
                        )
                    )
                }
                .onDelete { self.rule.dnsServerAddressMatch.remove(atOffsets: $0) }
                .onMove { self.rule.dnsServerAddressMatch.move(fromOffsets: $0, toOffset: $1) }
                Button("Add DNS Server Address") {
                    self.rule.dnsServerAddressMatch.append("")
                }
            } header: {
                EditButton()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .overlay(alignment: .leading) {
                        Text("DNS Server Address Match")
                    }
            } footer: {
                Text("If each of the current default DNS servers is equal to one of the strings in this array and all of the other conditions in the rule match, then the rule matches.")
            }

            Section {
                LazyTextField(
                    "Probe URL",
                    text: .init(
                        get: { self.rule.probeURL?.absoluteString ?? "" },
                        set: { self.rule.probeURL = URL(string: $0) }
                    )
                )
            } header: {
                Text("Probe URL Match")
            } footer: {
                Text("If a request sent to this URL results in a HTTP 200 OK response and all of the other conditions in the rule match, then the rule matches. If you don't want to use this rule, leave it empty.")
            }
        }
        .navigationTitle(self.rule.name)
    }
}

struct RuleView_Previews: PreviewProvider {
    static var previews: some View {
        RuleView(rule: .constant(OnDemandRule(name: "Preview Rule")))
    }
}
