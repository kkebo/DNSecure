import NetworkExtension
import SwiftUI

struct InterfaceTypeMatchView {
    @Binding var rule: OnDemandRule
}

extension InterfaceTypeMatchView: View {
    var body: some View {
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
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var rule = OnDemandRule(name: "Preview Rule")
    NavigationStack {
        InterfaceTypeMatchView(rule: $rule)
    }
}
