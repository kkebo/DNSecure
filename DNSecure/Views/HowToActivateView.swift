//
//  HowToActivateView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/27/20.
//

import SwiftUI

private enum MacOSVersion {
    case venturaOrLater
    case monterey
}

struct HowToActivateView {
    @Environment(\.dismiss) private var dismiss
    @State private var macOSVersion: MacOSVersion = .venturaOrLater
    let isSheet: Bool
}

extension HowToActivateView: View {
    var body: some View {
        VStack {
            if self.isSheet {
                Text("How to Activate")
                    .font(.title)
                Spacer()
            }
            ScrollView {
                #if targetEnvironment(macCatalyst)
                    Picker("", selection: self.$macOSVersion) {
                        Text("macOS 13 or later").tag(MacOSVersion.venturaOrLater)
                        Text("macOS 12").tag(MacOSVersion.monterey)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                #endif
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("1. Select a DNS server you like, or add another one")
                        Image("SelectServer")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    VStack(alignment: .leading) {
                        Text("2. Enable \"Use This Server\"")
                        Image("UseThisServer")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    #if targetEnvironment(macCatalyst)
                        switch self.macOSVersion {
                        case .venturaOrLater:
                            VStack(alignment: .leading) {
                                Text("3. Open the System Settings")
                                Image(.systemSettingsIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                            }
                            VStack(alignment: .leading) {
                                Text("4. Go to Network settings and click \"Filters\"")
                                Image(.networkSettings)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 400)
                            }
                            VStack(alignment: .leading) {
                                Text("5. Click on the status of \"\(Bundle.main.displayName!)\"")
                                Image(.filtersSettings)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 400)
                            }
                            VStack(alignment: .leading) {
                                Text("6. Click \"Enabled\"")
                                Image(.makeItEnabled)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                            }
                            VStack(alignment: .leading) {
                                Text("7. All done 🎉")
                                Image(.allDone)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 400)
                            }
                        case .monterey:
                            VStack(alignment: .leading) {
                                Text("3. Open the System Preferences")
                                Image(.montereySystemPreferencesIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                            }
                            VStack(alignment: .leading) {
                                Text("4. Go to Network settings")
                                Image(.montereySystemPreferences)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 400)
                            }
                            VStack(alignment: .leading) {
                                Text(
                                    "5. Select \"\(Bundle.main.displayName!)\" and click \(Image(systemName: "ellipsis.circle")) button"
                                )
                                Image(.montereyNetworkSettings)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 400)
                            }
                            VStack(alignment: .leading) {
                                Text("6. Click \"Make Service Active\"")
                                Image(.montereyMakeServiceActive)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                            }
                            VStack(alignment: .leading) {
                                Text("7. Click \"Apply\" button")
                                Image(.montereyNetworkSettingsApply)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 400)
                            }
                        }
                    #else
                        VStack(alignment: .leading) {
                            Text("3. Open the Settings")
                            Image("Settings")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        }
                        VStack(alignment: .leading) {
                            Text("4. Go to \"General\" > \"VPN & Network\" > \"DNS\"")
                            ScrollView(.horizontal) {
                                HStack {
                                    Image("GeneralVPNNetwork")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                    Image("DNS")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                }
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("5. \"Automatic\" is selected by default, so select \"\(Bundle.main.displayName!)\"")
                            Image("DNSProvider")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        }
                    #endif
                }
            }
            if self.isSheet {
                Spacer()
                Button("Dismiss") {
                    self.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .hoverEffect()
            }
        }
        .padding()
        .navigationTitle("How to Activate")
    }
}

#Preview {
    HowToActivateView(isSheet: true)
}
