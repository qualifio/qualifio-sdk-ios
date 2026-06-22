# Customizations

The SDK can be tailored to your application in two ways: customizing the **Safari view
controller** that presents the campaign so it matches your brand, and controlling the
**logging** verbosity to suit development or production. Both are optional — the SDK works
with sensible defaults out of the box.

- [Safari view controller appearance](#safari-view-controller-appearance) — style the view controller that shows the campaign.
- [Logging](#logging) — control the SDK's log output.

---

## Safari view controller appearance

Campaigns are presented in a `SFSafariViewController`. Because the campaign content itself
is hosted and styled by Qualifio, customization on the app side applies to the **view
controller** — the tint colors, dismiss button style, and presentation style —
through the standard `SFSafariViewController` API.

Register a customizer with `setSafariViewControllerCustomizer`. The SDK invokes it with the
view controller it is about to present, so any properties you set are applied:

```swift
import QualifioKit
import SafariServices

Qualifio.shared.setSafariViewControllerCustomizer { viewController in
    viewController.preferredControlTintColor = .systemPink
    viewController.dismissButtonStyle = .close
    viewController.modalPresentationStyle = .fullScreen
}
```

The customizer type is:

```swift
public typealias QualifioCustomTabsCustomizer = (SFSafariViewController) -> Void
```

| Aspect | Details |
|--------|---------|
| Argument | `viewController` — the `SFSafariViewController` the SDK is about to present. |
| When | Invoked on every `launchCampaign`, just before the view controller is presented. |

By default the campaign is presented as a **page sheet**. Override `modalPresentationStyle`
in the customizer (for example to `.fullScreen`) if you prefer a different presentation.

Registering a customizer is optional — without one, the SDK presents the campaign with its
default appearance.

---

## Logging

The SDK writes diagnostic messages using Apple's unified logging system under the subsystem
`com.qualifio`. This is useful while integrating — for example to confirm that configuration
succeeded or to see why a campaign did not launch.

### Enabling debug logging

By default, the SDK logs at **info** level and above (info, warnings, and errors). Verbose
**debug** messages are suppressed unless you opt in with the `debug_logging_enabled` option,
either in `QualifioOptions.plist` or in code:

```xml
<!-- QualifioOptions.plist -->
<key>debug_logging_enabled</key>
<true/>
```

```swift
Qualifio.shared.configure(
    QualifioConfiguration(domain: "your-account.qualifio.com"),
    options: QualifioOptions(debugLoggingEnabled: true)
)
```

| Option | Type | Default | Effect |
|--------|------|---------|--------|
| `debug_logging_enabled` | Boolean | `false` | When `true`, debug-level messages are emitted (and prefixed with the originating source file). When `false`, only info, warnings, and errors are logged. |

See [Configuration](./02-configuration.md#options) for the full list of options.

### Recommendation

- **Development:** enable `debug_logging_enabled` to see the full picture while integrating.
- **Production:** leave it at its default (`false`) to keep the log output to a minimum
  while still surfacing warnings and errors.

> Filter the Xcode console or Console.app by the `com.qualifio` subsystem to isolate the
> SDK's output.
