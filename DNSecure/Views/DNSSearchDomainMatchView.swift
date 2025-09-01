import NetworkExtension
import SwiftUI

struct DNSSearchDomainMatchView {
    @Binding var rule: OnDemandRule
}

extension DNSSearchDomainMatchView: View {
    var body: some View {
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
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var rule = OnDemandRule(name: "Preview Rule")
    NavigationStack {
        DNSSearchDomainMatchView(rule: $rule)
    }
}
