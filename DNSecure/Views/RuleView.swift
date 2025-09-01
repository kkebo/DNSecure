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
                    ForEach(NEOnDemandRuleAction.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
            }
        }
        .navigationTitle(self.rule.name)
    }

    private var interfaceTypeMatchLabel: some View {
        @available(iOS 16, *)
        var modern: some View {
            LabeledContent("Interface Type Match", value: self.rule.interfaceType.description)
        }
        var legacy: some View {
            HStack {
                Text("Interface Type Match")
                Spacer()
                Text(self.rule.interfaceType.description)
                    .foregroundStyle(.secondary)
            }
        }
        if #available(iOS 16, *) {
            return modern
        } else {
            return legacy
        }
    }

    private var ssidMatchLabel: some View {
        @available(iOS 16, *)
        var modern: some View {
            LabeledContent("SSID Match") {
                if !self.rule.ssidMatch.isEmpty {
                    Text("\(self.rule.ssidMatch.count)")
                } else {
                    Text("Not Used")
                }
            }
        }
        var legacy: some View {
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
        if #available(iOS 16, *) {
            return modern
        } else {
            return legacy
        }
    }

    private var dnsSearchDomainMatchLabel: some View {
        @available(iOS 16, *)
        var modern: some View {
            LabeledContent("DNS Search Domain Match") {
                if !self.rule.dnsSearchDomainMatch.isEmpty {
                    Text("\(self.rule.dnsSearchDomainMatch.count)")
                } else {
                    Text("Not Used")
                }
            }
        }
        var legacy: some View {
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
        if #available(iOS 16, *) {
            return modern
        } else {
            return legacy
        }
    }

    private var dnsServerAddressMatchLabel: some View {
        @available(iOS 16, *)
        var modern: some View {
            LabeledContent("DNS Server Address Match") {
                if !self.rule.dnsServerAddressMatch.isEmpty {
                    Text("\(self.rule.dnsServerAddressMatch.count)")
                } else {
                    Text("Not Used")
                }
            }
        }
        var legacy: some View {
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
        if #available(iOS 16, *) {
            return modern
        } else {
            return legacy
        }
    }

    private var probeURLLabel: some View {
        @available(iOS 16, *)
        var modern: some View {
            LabeledContent("Probe URL") {
                if let url = self.rule.probeURL?.absoluteString {
                    Text(url)
                } else {
                    Text("Not Used")
                }
            }
        }
        var legacy: some View {
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
        if #available(iOS 16, *) {
            return modern
        } else {
            return legacy
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
