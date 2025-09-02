//
//  RestorationView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 7/17/24.
//

import SwiftUI

struct RestorationView {
    @Environment(\.dismiss) private var dismiss
    @State private var added = Set<Resolver>()
    @State private var keyword = ""
    let onAdd: (Resolver) -> Void

    private var servers: Resolvers {
        guard !self.keyword.isEmpty else { return Presets.servers }
        return Presets.servers.filter { $0.name.localizedCaseInsensitiveContains(self.keyword) }
    }
}

extension RestorationView: View {
    var body: some View {
        NavigationView {
            List(self.servers, id: \.self) { resolver in
                HStack {
                    VStack(alignment: .leading) {
                        Text(resolver.name)
                        Text(resolver.configuration.description)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if self.added.contains(resolver) {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark")
                            Text("Added")
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        Button {
                            self.added.insert(resolver)
                            self.onAdd(resolver)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "plus")
                                Text("Add")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                }
            }
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        self.dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .searchable(text: self.$keyword, placement: .navigationBarDrawer(displayMode: .always))
    }
}

#Preview {
    RestorationView { _ in }
}
