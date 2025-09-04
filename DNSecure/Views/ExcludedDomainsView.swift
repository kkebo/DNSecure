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
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
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

@available(iOS 17, *)
#Preview {
    @Previewable @State var domains = ["example.com"]
    NavigationStack {
        ExcludedDomainsView(domains: $domains)
    }
}
