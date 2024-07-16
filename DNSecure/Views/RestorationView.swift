//
//  RestorationView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 7/17/24.
//

import SwiftUI

struct RestorationView {
    @Environment(\.dismiss) private var dismiss
    @State private var selection = Set<Resolver>()
    @State private var keyword = ""
    let onAdd: (Set<Resolver>) -> ()

    private var servers: Resolvers {
        guard !self.keyword.isEmpty else { return Presets.servers }
        return Presets.servers.filter { $0.name.localizedCaseInsensitiveContains(self.keyword) }
    }
}

extension RestorationView: View {
    var body: some View {
        NavigationView {
            List(self.servers, id: \.self) { resolver in
                Button {
                    if self.selection.contains(resolver) {
                        self.selection.remove(resolver)
                    } else {
                        self.selection.insert(resolver)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(resolver.name)
                            Text(resolver.configuration.description)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if self.selection.contains(resolver) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add") {
                        self.onAdd(self.selection)
                        self.dismiss()
                    }
                    .disabled(self.selection.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Text("\(self.selection.count) Selected")
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
