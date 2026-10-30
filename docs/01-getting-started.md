# Getting Started

This guide walks you through adding the Qualifio iOS SDK to your app and launching your
first campaign. The SDK is distributed with **Swift Package Manager**.

## Installation

In Xcode, choose **File ▸ Add Package Dependencies…**, enter the repository URL, and select
the version you want:

```
https://github.com/qualifio/qualifio-sdk-ios
```

Then add the **QualifioKit** library product to your app target.

If you manage dependencies in a `Package.swift`, add the package and product manually:

```swift
dependencies: [
    .package(url: "https://github.com/qualifio/qualifio-sdk-ios.git", from: "{{version}}"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "QualifioKit", package: "qualifio-sdk-ios"),
        ]
    ),
]
```

> Replace `{{version}}` with the release you want to use (for example the
> [latest published version](https://github.com/qualifio/qualifio-sdk-ios/releases)). Pin an
> exact version in production so a new release can never change your app's behavior
> unexpectedly; bump it deliberately when you are ready to upgrade.

### Import the SDK

Import the framework where you use it:

```swift
import QualifioKit
```

The library requires a deployment target of **iOS 15.0** or higher. The SDK can present
campaigns in a `SFSafariViewController`, or embed them inline alongside your own SwiftUI
content.

## Your first campaign

Once installed, integrating a campaign takes two steps.

### 1. Configure the SDK

The SDK needs your Qualifio **domain** before it can launch campaigns. The simplest path is
to let it configure **automatically** at app startup from a `QualifioServices.plist` file —
see [Configuration](./02-configuration.md) for the full setup. To configure explicitly in
code instead, call `configure` once, as early as possible (for example in your app
delegate's `didFinishLaunchingWithOptions`):

```swift
import QualifioKit

func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
) -> Bool {
    Qualifio.shared.configure(QualifioConfiguration(domain: "your-account.qualifio.com"))
    return true
}
```

### 2. Launch a campaign

Call `launchCampaign` with the slug of the campaign you want to display. The SDK opens the
campaign in a Safari view controller presented on top of your app:

```swift
import QualifioKit

// launchCampaign is async and throwing — call it from a Task or async context.
Task {
    try await Qualifio.shared.launchCampaign("summer-quiz")
}
```

To show the campaign inline with the content of your app, see
[Inline campaigns](./03-campaigns.md).

## Next steps

- [Configuration](./02-configuration.md) — automatic vs. manual configuration.
- [Campaigns](./03-campaigns.md) - launch campaigns or embed them inline.
- [Secure Tokens](./04-secure-tokens.md) — personalize campaigns with user data.
- [Customizations](./06-customizations.md) — style the Safari view controller or the inline view to match your brand.
- [Notifications](./05-notifications.md) — trigger campaigns from Actito.
