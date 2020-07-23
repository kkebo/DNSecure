#  CustomDNS

This is a sample app that configures a DNS-over-TLS resolver to the system. `NEDNSSettingsManager`, added in iOS 14, iPadOS 14, and macOS Bug Sur, makes that possible.

## Steps to Use

### In case of iOS/iPadOS

1. Open this app once
1. Open the Settings
1. Go to "General" > "VPN & Network" > "DNS"
1. "Automatic" is selected by default, so select "CustomDNS"
1. Force-quit and reopen this app
1. If "Enabled" is displayed, the configuration is successfully enabled

### In case of macOS

1. Open this app once
1. Open the Preferences
1. Go to "Network"
1. I don't know how to use it yet

## References

- https://developer.apple.com/documentation/networkextension/dns_settings
- https://developer.apple.com/wwdc20/10047
