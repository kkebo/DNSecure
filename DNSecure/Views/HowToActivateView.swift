//
//  HowToActivateView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/27/20.
//

import SwiftUI

struct HowToActivateView {
    @Environment(\.dismiss) private var dismiss
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
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("1. Select a DNS server you like, or add another one")
                        Image(.selectServer)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    VStack(alignment: .leading) {
                        Text("2. Enable \"Use This Server\"")
                        Image(.useThisServer)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    #if targetEnvironment(macCatalyst)
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
                            HStack {
                                Text("5. Select \"\(Bundle.main.displayName!)\" and click")
                                Image(systemName: "ellipsis.circle")
                                Text("button")
                            }
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
                    #else
                        VStack(alignment: .leading) {
                            Text("3. Open the Settings")
                            Image(.settings)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        }
                        VStack(alignment: .leading) {
                            Text("4. Go to \"General\" > \"VPN & Network\" > \"DNS\"")
                            ScrollView(.horizontal) {
                                HStack {
                                    Image(.generalVPNNetwork)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                    Image(.dns)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                }
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("5. \"Automatic\" is selected by default, so select \"\(Bundle.main.displayName!)\"")
                            Image(.dnsProvider)
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

struct HowToActivateView_Previews: PreviewProvider {
    static var previews: some View {
        HowToActivateView(isSheet: true)
    }
}
