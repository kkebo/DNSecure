//
//  HowToActivateView.swift
//  DNSecure
//
//  Created by Kenta Kubo on 9/27/20.
//

import SwiftUI

struct HowToActivateView {
    @Environment(\.presentationMode) var presentationMode
    @State var isSheet: Bool
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
                }
            }
            if self.isSheet {
                Spacer()
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Dismiss")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
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
