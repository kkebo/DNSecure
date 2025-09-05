//
//  ContentView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 7/1/20.
//

@preconcurrency import NetworkExtension
import SwiftUI

struct ContentView {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Binding var servers: Resolvers
    @Binding var usedID: String?
    @State private var isActivated = false
    @State private var selection: Int?
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isGuidePresented = false
    @State private var isRestoring = false

    private var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        if #available(iOS 26, *) {
            .inline
        } else {
            .automatic
        }
    }

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

    private func restoreFromPresets(resolver: Resolver) {
        self.servers.append(resolver)
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
                    self.isActivated = manager.isEnabled
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
            manager.localizedDescription = server.name
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
                //logger.debug("DNS settings was saved")
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
                //logger.debug("DNS settings was removed")
            }
        #endif
    }

    private func alert(_ title: String, _ message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.isAlertPresented = true
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
            .navigationBarTitleDisplayMode(self.navigationBarTitleDisplayMode)
            .toolbar {
                if #available(iOS 26, *) {
                    ToolbarItem(placement: .subtitle) {
                        self.statusIndicator
                            .foregroundStyle(.secondary)
                    }
                }
                self.toolbarContent
            }
            .alert(self.alertTitle, isPresented: self.$isAlertPresented) {
            } message: {
                Text(self.alertMessage)
            }
        } detail: {
            if let i = self.selection, i >= 0 {
                NavigationStack {
                    self.detailView(at: i)
                        .navigationBarTitleDisplayMode(self.navigationBarTitleDisplayMode)
                }
            } else if !self.isActivated {
                HowToActivateView()
                    .navigationBarTitleDisplayMode(self.navigationBarTitleDisplayMode)
            } else {
                Text("Select a server on the sidebar")
                    .navigationBarHidden(true)
            }
        }
        .onAppear(perform: self.updateStatus)
        .task {
            for await _ in NotificationCenter.default
                .notifications(named: .NEDNSSettingsConfigurationDidChange)
                .map(\.name)
            {
                self.updateStatus()
            }
        }
        .onChange(of: self.scenePhase) { phase in
            if phase == .background {
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
            .alert(self.alertTitle, isPresented: self.$isAlertPresented) {
            } message: {
                Text(self.alertMessage)
            }

            if let i = self.selection, i >= 0 {
                self.detailView(at: i)
            } else if !self.isActivated {
                HowToActivateView()
            } else {
                Text("Select a server on the sidebar")
                    .navigationBarHidden(true)
            }
        }
        .onAppear(perform: self.updateStatus)
        .task {
            for await _ in NotificationCenter.default
                .notifications(named: .NEDNSSettingsConfigurationDidChange)
                .map(\.name)
            {
                self.updateStatus()
            }
        }
        .onChange(of: self.scenePhase) { phase in
            if phase == .background {
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
            if #available(iOS 26, *) {
                EditButton()
            } else {
                self.addMenu
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            if #available(iOS 26, *) {
                self.addMenu
            } else {
                EditButton()
            }
        }
        ToolbarItem(placement: .status) {
            if #available(iOS 26, *) {
            } else {
                self.statusIndicator
            }
        }
    }

    private var addMenu: some View {
        Menu("Add", systemImage: "plus") {
            Button("DNS-over-TLS", action: self.addNewDoTServer)
            Button("DNS-over-HTTPS", action: self.addNewDoHServer)
            Button("Restore from Presets") {
                self.isRestoring = true
            }
        }
        .sheet(isPresented: self.$isRestoring) {
            RestorationView(onAdd: self.restoreFromPresets)
        }
    }

    private var statusIndicator: some View {
        Label {
            Text(self.isActivated ? "Active" : "Inactive")
        } icon: {
            Circle()
                .fill(self.isActivated ? .green : .secondary)
                .frame(width: 10, height: 10)
        }
        .labelStyle(.titleAndIcon)
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
                if !self.isActivated {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
                Image(systemName: "checkmark")
            }
        }
    }

    private func detailView(at i: Int) -> some View {
        DetailView(
            server: self.$servers[i],
            isSelected: .init(
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
            ),
            isActivated: self.$isActivated
        )
    }
}

#Preview {
    ContentView(servers: .constant(Presets.servers), usedID: .constant(nil))
}
