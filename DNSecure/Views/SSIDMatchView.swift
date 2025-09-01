import NetworkExtension
import SwiftUI

struct SSIDMatchView {
    @Binding var rule: OnDemandRule
}

extension SSIDMatchView: View {
    var body: some View {
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
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var rule = OnDemandRule(name: "Preview Rule")
    NavigationStack {
        SSIDMatchView(rule: $rule)
    }
}
