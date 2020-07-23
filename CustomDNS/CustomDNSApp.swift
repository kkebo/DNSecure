//
//  CustomDNSApp.swift
//  CustomDNS
//
//  Created by Kenta Kubo on 7/1/20.
//

import NetworkExtension
import SwiftUI

@main
struct CustomDNSApp {
    init() {
        // Create a DNS configuration
        let manager = NEDNSSettingsManager.shared()
        manager.loadFromPreferences { loadError in
            if let loadError = loadError {
                print(loadError)
                return
            }
            let dotSettings = NEDNSOverTLSSettings(servers: [
                "1.1.1.1",
                "1.0.0.1",
                "2606:4700:4700::64",
                "2606:4700:4700::6400",
            ])
            dotSettings.serverName = "cloudflare-dns.com"
            manager.dnsSettings = dotSettings
            manager.saveToPreferences { saveError in
                if let saveError = saveError {
                    print(saveError)
                    return
                }
                print("saved")
            }
        }
    }
}

extension CustomDNSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
