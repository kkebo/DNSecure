//
//  ContentView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 7/1/20.
//

import NetworkExtension
import SwiftUI

struct ContentView {
    @AppStorage("servers") var servers = Presets.servers
    @AppStorage("usedID") var usedID: String?
    @State var isEnabled = false

    func addNewDoTServer() {
        self.servers.append(
            .init(
                name: "New",
                configuration: .dnsOverTLS(DoTConfiguration())
            )
        )
    }

    func addNewDoHServer() {
        self.servers.append(
            .init(
                name: "New",
                configuration: .dnsOverHTTPS(DoHConfiguration())
            )
        )
    }

    func updateStatus() {
        let manager = NEDNSSettingsManager.shared()
        manager.loadFromPreferences {
            if let err = $0 {
                logger.error("\(err.localizedDescription)")
            } else {
                self.isEnabled = manager.isEnabled
            }
        }
    }

    func syncSettings() {
        let manager = NEDNSSettingsManager.shared()
        manager.loadFromPreferences { loadError in
            if let loadError = loadError {
                logger.error("\(loadError.localizedDescription)")
                return
            }
            manager.dnsSettings = self.usedID
                .flatMap(UUID.init)
                .flatMap(self.servers.find)
                .map(\.configuration)
                .map { $0.toDNSSettings() }
            manager.saveToPreferences { saveError in
                if let saveError = saveError {
                    logger.error("\(saveError.localizedDescription)")
                    return
                }
                logger.debug("DNS settings are saved")
            }
        }
    }
}

extension ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Servers")) {
                    ForEach(0..<self.servers.count, id: \.self) { i in
                        NavigationLink(
                            destination: DetailView(
                                server: .init(
                                    get: { self.servers[i] },
                                    set: { self.servers[i] = $0 }
                                ),
                                isOn: .init(
                                    get: {
                                        self.usedID == self.servers[i].id.uuidString
                                    },
                                    set: {
                                        if $0 {
                                            self.usedID = self.servers[i].id.uuidString
                                        } else {
                                            self.usedID = nil
                                        }
                                        self.syncSettings()
                                    }
                                )
                            )
                        ) {
                            VStack(alignment: .leading) {
                                Text(self.servers[i].name)
                                Text(self.servers[i].configuration.description)
                                    .foregroundColor(.secondary)
                            }
                            if self.usedID == self.servers[i].id.uuidString {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        self.servers.remove(atOffsets: indexSet)
                    }
                    .onMove { src, dst in
                        self.servers.move(fromOffsets: src, toOffset: dst)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(Bundle.main.displayName!)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button("DNS-over-TLS", action: self.addNewDoTServer)
                        Button("DNS-over-HTTPS", action: self.addNewDoHServer)
                    } label: {
                        Image(systemName: "plus")
                    }
                    EditButton()
                }
                ToolbarItem(placement: .status) {
                    VStack {
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(self.isEnabled ? .green : .secondary)
                            Text(self.isEnabled ? "Active" : "Inactive")
                        }
                        .onAppear(perform: self.updateStatus)
                        if !self.isEnabled {
                            Link("Activate", destination: URL(string: "App-prefs:root=General&path=Network/VPN")!)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
