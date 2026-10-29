# Qualifio iOS SDK — Documentation

The Qualifio iOS SDK lets you embed and launch Qualifio campaigns directly inside your iOS
application, either in a Safari view controller on top of your app or inline with your
app's content, without sending the user to a separate browser app.

This documentation is organized by topic. If you are integrating the SDK for the first
time, start with **Getting Started**.

## Table of contents

| Page | Description |
|------|-------------|
| [Getting Started](./01-getting-started.md) | Add the SDK with Swift Package Manager and launch your first campaign. |
| [Configuration](./02-configuration.md) | Configure the SDK with your Qualifio domain (automatic or manual). |
| [Campaigns](./03-campaigns.md) | Launch campaigns in a Safari view controller or embed the inline. |
| [Secure Tokens](./04-secure-tokens.md) | Personalize campaigns with signed user data. |
| [Notifications](./05-notifications.md) | Display campaigns triggered by Actito remote notifications and inbox messages. |
| [Customizations](./06-customizations.md) | Style the Safari view controller or the inline view, and control the SDK's logging. |

## Requirements

- **iOS 15.0** or higher.
- Swift 6.
- A Qualifio account and at least one published campaign.

## At a glance

```swift
import QualifioKit

// 1. Configure once, at application startup.
Qualifio.shared.configure(QualifioConfiguration(domain: "your-account.qualifio.com"))

// 2. Launch a campaign whenever you need to (from an async context).
try await Qualifio.shared.launchCampaign("my-campaign-slug")
```

## Support

For account setup, campaign creation, and platform questions, visit
[qualifio.com](https://qualifio.com) or contact your Qualifio representative.
