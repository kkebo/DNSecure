import NetworkExtension
import SwiftUI

struct ProbeURLView {
    @Binding var rule: OnDemandRule

    private var probeURL: Binding<String> {
        .init(
            get: { self.rule.probeURL?.absoluteString ?? "" },
            set: { self.rule.probeURL = URL(string: $0) }
        )
    }
}

extension ProbeURLView: View {
    var body: some View {
        Form {
            Section {
                LazyTextField("Probe URL", text: self.probeURL)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } footer: {
                Text(
                    "If a request sent to this URL results in a HTTP 200 OK response and all of the other conditions in the rule match, then the rule matches. If you don't want to use this rule, leave it empty."
                )
            }
        }
        .navigationTitle("Probe URL")
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var rule = OnDemandRule(name: "Preview Rule")
    NavigationStack {
        ProbeURLView(rule: $rule)
    }
}
