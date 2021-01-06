# DNSecure

<a href="https://apps.apple.com/us/app/dnsecure/id1533413232?itsct=apps_box&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-top-left-radius: 13px; border-top-right-radius: 13px; border-bottom-right-radius: 13px; border-bottom-left-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1601251200&h=77f35e8e1cad98287ffaa894b10bb6e2" alt="Download on the App Store" style="border-top-left-radius: 13px; border-top-right-radius: 13px; border-bottom-right-radius: 13px; border-bottom-left-radius: 13px; width: 250px; height: 83px;"></a>
or [TestFlight Beta](https://testflight.apple.com/join/A8GwCnq8)

iOS/iPadOS has supported encrypted DNS (e.g. DNS-over-TLS (DoT) and DNS-over-HTTPS (DoH)) since 14.0, but the Settings app doesn't have settings for using it. To solve that, DNSecure was created. DNSecure is a configuration tool of DoT and DoH.

This app uses the new [DNS Settings API](https://developer.apple.com/documentation/networkextension/dns_settings), so it requires iOS 14, iPadOS 14, or later.

## How to use

1. Select a DNS server you like, or add another one
1. Enable "Use This Server"
1. Open the Settings
1. Go to "General" > "VPN & Network" > "DNS"
1. "Automatic" is selected by default, so select "DNSecure"

## References

- https://developer.apple.com/documentation/networkextension/dns_settings
- https://developer.apple.com/wwdc20/10047
