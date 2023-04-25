//
//  DoTSections.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/23/22.
//

import SwiftUI

struct DoTSections {
    @Binding var configuration: DoTConfiguration
}

extension DoTSections: View {
    var body: some View {
        Section {
            ForEach(0..<self.configuration.servers.count, id: \.self) { i in
                LazyTextField("IP address", text: self.$configuration.servers[i])
                    .textContentType(.URL)
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .onDelete { self.configuration.servers.remove(atOffsets: $0) }
            .onMove { self.configuration.servers.move(fromOffsets: $0, toOffset: $1) }
            Button("Add New Server") {
                self.configuration.servers.append("")
            }
        } header: {
            EditButton()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .overlay(alignment: .leading) {
                    Text("Servers")
                }
        } footer: {
            Text("The DNS server IP addresses.")
        }
        Section {
            LazyTextField(
                "Server Name",
                text: .init(
                    get: { self.configuration.serverName ?? "" },
                    set: { self.configuration.serverName = $0 }
                )
            )
            .textContentType(.URL)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        } header: {
            Text("Server Name")
        } footer: {
            Text("The TLS name of a DNS-over-TLS server.")
        }
    }
}

struct DoTSections_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DoTSections(
                configuration: .constant(
                    .init(
                        servers: [
                            "1.1.1.1",
                            "1.0.0.1",
                            "2606:4700:4700::1111",
                            "2606:4700:4700::1001",
                        ],
                        serverName: "cloudflare-dns.com"
                    )
                )
            )
        }
    }
}
