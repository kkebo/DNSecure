//
//  DNSecureApp.swift
//  DNSecure
//
//  Created by Kenta Kubo on 7/1/20.
//

import os
import SwiftUI

let logger = Logger()

@main
struct DNSecureApp {
    @AppStorage("servers") var servers = Presets.servers
    @AppStorage("usedID") var usedID: String?
}

extension DNSecureApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(servers: self.$servers, usedID: self.$usedID)
        }
    }
}
