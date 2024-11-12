# DNSecure

iOS 14+, iPadOS 14+, and macOS 11+ have supported encrypted DNS (e.g. DNS-over-TLS (DoT) and DNS-over-HTTPS (DoH)), but they don't have a native UI for enabling it. To solve that, DNSecure was created. DNSecure is a configuration tool of DoT and DoH.

This app uses the new [DNS Settings API](https://developer.apple.com/documentation/networkextension/dns_settings), so it requires iOS 14+, iPadOS 14+, or macOS 11+.

## Installation (iOS/iPadOS/macOS)

<a href="https://apps.apple.com/us/app/dnsecure/id1533413232?itscg=30200&itsct=apps_box_badge&mttnsubad=1533413232" style="display: inline-block;"><img src="https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/en-us?releaseDate=1601251200" alt="Download on the App Store" style="width: 245px; height: 82px; vertical-align: middle; object-fit: contain;" /></a>
or [TestFlight Beta](https://testflight.apple.com/join/A8GwCnq8)

## How to use (iOS/iPadOS)

1. Select a DNS server you like, or add another one
1. Enable "Use This Server"
1. Open the Settings
1. Go to "General" > "VPN & Network" > "DNS"
1. "Automatic" is selected by default, so select "DNSecure"

## How to use (macOS 13+)

1. Select a DNS server you like, or add another one
1. Enable "Use This Server"
1. Open the System Settings
1. Go to Network settings and click "Filters"
1. Enable "DNSecure"

## How to use (macOS 12)

1. Select a DNS server you like, or add another one
1. Enable "Use This Server"
1. Open the System Preferences
1. Go to Network settings
1. Select "DNSecure" and click "..." button on the bottom
1. Click "Make Service Active"
1. Click "Apply" button

## References

- https://developer.apple.com/documentation/networkextension/dns_settings
- https://developer.apple.com/wwdc20/10047
