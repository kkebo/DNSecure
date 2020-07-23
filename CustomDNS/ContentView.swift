//
//  ContentView.swift
//  CustomDNS
//
//  Created by Kenta Kubo on 7/1/20.
//

import Combine
import NetworkExtension
import SwiftUI

struct ContentView {
    @State var isEnabled = false
    var cancellable: Cancellable?

    init() {
        self.cancellable = Future<Bool, Error> { resolve in
            let manager = NEDNSSettingsManager.shared()
            manager.loadFromPreferences {
                if let err = $0 {
                    resolve(.failure(err))
                } else {
                    resolve(.success(manager.isEnabled))
                }
            }
        }
        .mapError { fatalError("\($0.localizedDescription)") }
        .assign(to: \.isEnabled, on: self)
    }
}

extension ContentView: View {
    @ViewBuilder var body: some View {
        if self.isEnabled {
            Text("Enabled")
                .foregroundColor(.green)
        } else {
            Text("Disabled")
                .foregroundColor(.secondary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
