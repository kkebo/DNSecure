import NetworkExtension
import SwiftUI

struct DNSServerAddressMatchView {
    @Binding var rule: OnDemandRule
}

extension DNSServerAddressMatchView: View {
    var body: some View {
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
                    .textContentType(.URL)
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
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
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var rule = OnDemandRule(name: "Preview Rule")
    NavigationStack {
        DNSServerAddressMatchView(rule: $rule)
    }
}
