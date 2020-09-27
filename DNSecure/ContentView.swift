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
    @State var selection: Int?
    @State var alertIsPresented = false
    @State var alertTitle = ""
    @State var alertMessage = ""

    func addNewDoTServer() {
        self.servers.append(
            .init(
                name: "New",
                configuration: .dnsOverTLS(DoTConfiguration())
            )
        )
        self.selection = self.servers.count - 1
    }

    func addNewDoHServer() {
        self.servers.append(
            .init(
                name: "New",
                configuration: .dnsOverHTTPS(DoHConfiguration())
            )
        )
        self.selection = self.servers.count - 1
    }

    func updateStatus() {
        let manager = NEDNSSettingsManager.shared()
        manager.loadFromPreferences {
            if let err = $0 {
                logger.error("\(err.localizedDescription)")
                self.alert("Load Error", err.localizedDescription)
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
                self.alert("Load Error", loadError.localizedDescription)
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
                    self.alert("Save Error", saveError.localizedDescription)
                    return
                }
                logger.debug("DNS settings are saved")
            }
        }
    }

    func alert(_ title: String, _ message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.alertIsPresented = true
    }
}

extension ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Servers")) {
                    ForEach(Array(self.servers.enumerated()), id: \.offset.self) { i, server in
                        NavigationLink(
                            destination: DetailView(
                                server: .init(
                                    get: { server },
                                    set: { self.servers[i] = $0 }
                                ),
                                isOn: .init(
                                    get: {
                                        self.usedID == server.id.uuidString
                                    },
                                    set: {
                                        if $0 {
                                            self.usedID = server.id.uuidString
                                        } else {
                                            self.usedID = nil
                                        }
                                        self.syncSettings()
                                    }
                                )
                            ),
                            tag: i,
                            selection: self.$selection
                        ) {
                            VStack(alignment: .leading) {
                                Text(server.name)
                                Text(server.configuration.description)
                                    .foregroundColor(.secondary)
                            }
                            if self.usedID == server.id.uuidString {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if let current = self.selection, indexSet.contains(current) {
                            self.selection = min(
                                current,
                                self.servers.count - 1 - indexSet.count
                            )
                        }
                        self.servers.remove(atOffsets: indexSet)
                    }
                    .onMove { src, dst in
                        // TODO: Change self.selection if needed
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
            .alert(isPresented: self.$alertIsPresented) {
                Alert(
                    title: Text(self.alertTitle),
                    message: Text(self.alertMessage)
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
