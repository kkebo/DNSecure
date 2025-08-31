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

            Section("Matching Conditions") {
                NavigationLink {
                    Form {
                        Section {
                            Picker("Interface Type", selection: self.$rule.interfaceType) {
                                ForEach(NEOnDemandRuleInterfaceType.allCases, id: \.self) {
                                    Text($0.description)
                                }
                            }
                            .pickerStyle(.inline)
                            .labelsHidden()
                        } footer: {
                            Text(
                                "If the current primary network interface is of this type and all of the other conditions in the rule match, then the rule matches."
                            )
                        }
                    }
                    .navigationTitle("Interface Type Match")
                } label: {
                    HStack {
                        Text("Interface Type Match")
                        Spacer()
                        Text(self.rule.interfaceType.description)
                            .foregroundStyle(.secondary)
                    }
                }

                if self.rule.interfaceType.isSSIDUsed {
                    NavigationLink {
                        Form {
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
                            } footer: {
                                Text(
                                    "If the Service Set Identifier (SSID) of the current primary connected network matches one of the strings in this array and all of the other conditions in the rule match, then the rule matches."
                                )
                            }
                        }
                        .navigationTitle("SSID Match")
                        .toolbar {
                            EditButton()
                        }
                    } label: {
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

                NavigationLink {
                    Form {
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
                        } footer: {
                            Text(
                                "If the current default search domain is equal to one of the strings in this array and all of the other conditions in the rule match, then the rule matches."
                            )
                        }
                    }
                    .navigationTitle("DNS Search Domain Match")
                    .toolbar {
                        EditButton()
                    }
                } label: {
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

                NavigationLink {
                    Form {
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
                        } footer: {
                            Text(
                                "If each of the current default DNS servers is equal to one of the strings in this array and all of the other conditions in the rule match, then the rule matches."
                            )
                        }
                    }
                    .navigationTitle("DNS Server Address Match")
                    .toolbar {
                        EditButton()
                    }
                } label: {
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

                NavigationLink {
                    Form {
                        Section {
                            LazyTextField(
                                "Probe URL",
                                text: .init(
                                    get: { self.rule.probeURL?.absoluteString ?? "" },
                                    set: { self.rule.probeURL = URL(string: $0) }
                                )
                            )
                        } footer: {
                            Text(
                                "If a request sent to this URL results in a HTTP 200 OK response and all of the other conditions in the rule match, then the rule matches. If you don't want to use this rule, leave it empty."
                            )
                        }
                    }
                    .navigationTitle("Probe URL")
                } label: {
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

            Section {
                Picker("Action", selection: self.$rule.action) {
                    ForEach(NEOnDemandRuleAction.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
            }
        }
        .navigationTitle(self.rule.name)
    }
}

#Preview {
    RuleView(rule: .constant(OnDemandRule(name: "Preview Rule")))
}
