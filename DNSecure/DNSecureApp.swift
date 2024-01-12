//
//  DNSecureApp.swift
//  DNSecure
//
//  Created by Kenta Kubo on 7/1/20.
//

import os.log
import SwiftUI

let logger = Logger()

@main
struct DNSecureApp {
    @AppStorage("servers") private var servers: Resolvers = []
    @AppStorage("usedID") private var usedID: String?

    init() {
        if UserDefaults.standard.object(forKey: "servers") == nil {
            // Set the default value in order to fix UUIDs
            self.servers = Presets.servers
        }
    }
}

extension DNSecureApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(servers: self.$servers, usedID: self.$usedID)
        }
    }
}
