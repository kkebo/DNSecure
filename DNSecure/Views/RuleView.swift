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
                    InterfaceTypeMatchView(rule: self.$rule)
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
                        SSIDMatchView(rule: self.$rule)
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
                    DNSSearchDomainMatchView(rule: self.$rule)
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
                    DNSServerAddressMatchView(rule: self.$rule)
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
                    ProbeURLView(rule: self.$rule)
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

@available(iOS 17, *)
#Preview {
    @Previewable @State var rule = OnDemandRule(name: "Preview Rule")
    NavigationStack {
        RuleView(rule: $rule)
    }
}
