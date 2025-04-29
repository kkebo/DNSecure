//
//  ContentView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 7/1/20.
//

import NetworkExtension
import SwiftUI

struct ContentView {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Binding var servers: Resolvers
    @Binding var usedID: String?
    @State private var isEnabled = false
    @State private var selection: Int?
    @State private var alertIsPresented = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var guideIsPresented = false
    @State private var isRestoring = false

    private func addNewDoTServer() {
        self.servers.append(
            .init(
                name: "New",
                configuration: .dnsOverTLS(DoTConfiguration())
            )
        )
        self.selection = self.servers.count - 1
    }

    private func addNewDoHServer() {
        self.servers.append(
            .init(
                name: "New",
                configuration: .dnsOverHTTPS(DoHConfiguration())
            )
        )
        self.selection = self.servers.count - 1
    }

    private func restoreFromPresets(resolvers: Set<Resolver>) {
        self.servers.append(contentsOf: resolvers)
    }

    private func removeServers(at indexSet: IndexSet) {
        if let current = self.selection, indexSet.contains(where: { $0 <= current }) {
            // FIXME: This is a workaround not to crash on deletion.
            self.selection = -1
        }
        if indexSet.map({ self.servers[$0].id.uuidString }).contains(self.usedID) {
            self.removeSettings()
        }
        // FIXME: This is a workaround not to crash on deletion.
        // Wait for closing DetailView.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.servers.remove(atOffsets: indexSet)
        }
    }

    private func moveServers(from src: IndexSet, to dst: Int) {
        // TODO: Change self.selection if needed
        self.servers.move(fromOffsets: src, toOffset: dst)
    }

    private func updateStatus() {
        #if !targetEnvironment(simulator)
            // Early return if running on Swift Playground or Xcode Previews
            guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
                return
            }

            let manager = NEDNSSettingsManager.shared()
            manager.loadFromPreferences {
                if let err = $0 {
                    logger.error("\(err.localizedDescription)")
                    self.alert("Load Error", err.localizedDescription)
                } else {
                    self.isEnabled = manager.isEnabled
                }
            }
        #endif
    }

    private func saveSettings(of server: Resolver) {
        if self.usedID != server.id.uuidString {
            self.usedID = server.id.uuidString
        }

        #if !targetEnvironment(simulator)
            // Early return if running on Swift Playground or Xcode Previews
            guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
                return
            }

            let manager = NEDNSSettingsManager.shared()
            manager.dnsSettings = server.configuration.toDNSSettings()
            manager.onDemandRules = server.onDemandRules.toNEOnDemandRules()
            manager.saveToPreferences { saveError in
                if let saveError = saveError as NSError? {
                    guard
                        saveError.domain != "NEConfigurationErrorDomain"
                            || saveError.code != 9
                    else {
                        // Nothing was changed
                        return
                    }
                    logger.error("\(saveError.localizedDescription)")
                    self.alert("Save Error", saveError.localizedDescription)
                    self.removeSettings()
                    return
                }
                logger.debug("DNS settings was saved")
            }
        #endif
    }

    private func removeSettings() {
        self.usedID = nil

        #if !targetEnvironment(simulator)
            // Early return if running on Swift Playground or Xcode Previews
            guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
                return
            }

            let manager = NEDNSSettingsManager.shared()
            guard manager.dnsSettings != nil else {
                // Already removed
                return
            }
            manager.removeFromPreferences { removeError in
                self.updateStatus()
                if let removeError = removeError {
                    logger.error("\(removeError.localizedDescription)")
                    self.alert("Remove Error", removeError.localizedDescription)
                    return
                }
                logger.debug("DNS settings was removed")
            }
        #endif
    }

    private func alert(_ title: String, _ message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.alertIsPresented = true
    }
}

@MainActor
extension ContentView: View {
    var body: some View {
        if #available(iOS 16, *) {
            self.modernBody
        } else if self.hSizeClass == .compact {
            // Workaround for iOS 15
            self.legacyBody.navigationViewStyle(.stack)
        } else {
            self.legacyBody
        }
    }

    @available(iOS 16, *)
    private var modernBody: some View {
        NavigationSplitView {
            List(selection: self.$selection) {
                NavigationLink("Instructions", value: -1)
                Section("Servers") {
                    ForEach(0..<self.servers.count, id: \.self) { i in
                        NavigationLink(value: i) {
                            self.sidebarRow(at: i)
                        }
                    }
                    .onDelete(perform: self.removeServers)
                    .onMove(perform: self.moveServers)
                }
            }
            .navigationTitle(Bundle.main.displayName!)
            .toolbar { self.toolbarContent }
            .alert(self.alertTitle, isPresented: self.$alertIsPresented) {
            } message: {
                Text(self.alertMessage)
            }
        } detail: {
            if self.selection == -1 {
                HowToActivateView(isSheet: false)
            } else if let i = self.selection {
                self.detailView(at: i)
            } else if !self.isEnabled {
                HowToActivateView(isSheet: false)
            } else {
                Text("Select a server on the sidebar")
                    .navigationBarHidden(true)
            }
        }
        .onAppear(perform: self.updateStatus)
        .onChange(of: self.scenePhase) { phase in
            if phase == .active {
                self.updateStatus()
            } else if phase == .background {
                // FIXME: This is a workaround for self.$severs[i].
                // That cannot save settings as soon as it is modified.
                guard let id = self.usedID,
                    let uuid = UUID(uuidString: id),
                    let server = self.servers.find(by: uuid)
                else {
                    return
                }
                self.saveSettings(of: server)
            }
        }
    }

    private var legacyBody: some View {
        NavigationView {
            List {
                if self.hSizeClass == .compact {
                    NavigationLink(
                        "Instructions",
                        tag: -1,
                        selection: self.$selection
                    ) {
                        HowToActivateView(isSheet: false)
                    }
                } else {
                    // Workaround for iOS 15
                    Button("Instructions") {
                        self.selection = -1
                    }
                }
                Section("Servers") {
                    ForEach(0..<self.servers.count, id: \.self) { i in
                        if self.hSizeClass == .compact {
                            NavigationLink(
                                tag: i,
                                selection: self.$selection
                            ) {
                                self.detailView(at: i)
                            } label: {
                                self.sidebarRow(at: i)
                            }
                        } else {
                            // Workaround for iOS 15
                            Button {
                                self.selection = i
                            } label: {
                                self.sidebarRow(at: i)
                            }
                        }
                    }
                    .onDelete(perform: self.removeServers)
                    .onMove(perform: self.moveServers)
                }
            }
            .navigationTitle(Bundle.main.displayName!)
            .toolbar { self.toolbarContent }
            .alert(self.alertTitle, isPresented: self.$alertIsPresented) {
            } message: {
                Text(self.alertMessage)
            }

            if self.selection == -1 {
                HowToActivateView(isSheet: false)
            } else if let i = self.selection {
                self.detailView(at: i)
            } else if !self.isEnabled {
                HowToActivateView(isSheet: false)
            } else {
                Text("Select a server on the sidebar")
                    .navigationBarHidden(true)
            }
        }
        .onAppear(perform: self.updateStatus)
        .onChange(of: self.scenePhase) { phase in
            if phase == .active {
                self.updateStatus()
            } else if phase == .background {
                // FIXME: This is a workaround for self.$severs[i].
                // That cannot save settings as soon as it is modified.
                guard let id = self.usedID,
                    let uuid = UUID(uuidString: id),
                    let server = self.servers.find(by: uuid)
                else {
                    return
                }
                self.saveSettings(of: server)
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button("DNS-over-TLS", action: self.addNewDoTServer)
                Button("DNS-over-HTTPS", action: self.addNewDoHServer)
                Button("Restore from Presets") {
                    self.isRestoring = true
                }
            } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: self.$isRestoring) {
                RestorationView(onAdd: self.restoreFromPresets)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            EditButton()
        }
        ToolbarItem(placement: .status) {
            VStack {
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(self.isEnabled ? .green : .secondary)
                    Text(self.isEnabled ? "Active" : "Inactive")
                    #if targetEnvironment(macCatalyst)
                        Text("-")
                        Button("Refresh", action: self.updateStatus)
                    #endif
                }
                if !self.isEnabled {
                    Button("How to Activate") {
                        self.guideIsPresented = true
                    }
                    .sheet(isPresented: self.$guideIsPresented) {
                        HowToActivateView(isSheet: true)
                    }
                }
            }
        }
    }

    private func sidebarRow(at i: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.servers[i].name)
                Text(self.servers[i].configuration.description)
                    .foregroundStyle(.secondary)
            }
            if self.usedID == self.servers[i].id.uuidString {
                Spacer()
                Image(systemName: "checkmark")
            }
        }
    }

    private func detailView(at i: Int) -> some View {
        DetailView(
            server: self.$servers[i],
            isOn: .init(
                get: {
                    self.usedID == self.servers[i].id.uuidString
                },
                set: {
                    if $0 {
                        self.saveSettings(of: self.servers[i])
                    } else {
                        self.removeSettings()
                    }
                }
            )
        )
    }
}

#Preview {
    ContentView(servers: .constant(Presets.servers), usedID: .constant(nil))
}
