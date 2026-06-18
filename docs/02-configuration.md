# Configuration

Before you can launch any campaign, the SDK must be configured with your Qualifio
**domain**. Configuration tells the SDK where to load campaigns from.

You only need to configure the SDK **once** per process. The current configuration is
available through `Qualifio.shared.configuration`, which is `nil` until the SDK is
configured.

There are two ways to configure the SDK: **automatically** from a `QualifioServices.plist`
file (recommended), or **manually** in code.

## Automatic configuration

If you would rather not hard-code the domain in your application, add a
`QualifioServices.plist` file to your app target and let the SDK configure itself at app
startup.

Create the file with your Qualifio domain:

```xml
<!-- QualifioServices.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>domain</key>
    <string>your-account.qualifio.com</string>
</dict>
</plist>
```

At launch, the SDK detects the file and calls `configure` for you — no code required. This
is useful when the same codebase ships across multiple targets or environments, each
bundling a different `QualifioServices.plist`.

Automatic configuration is **enabled by default**. You can turn it off with the
`auto_config_enabled` option (see [Options](#options) below), for example when you need to
resolve the domain at runtime and want to call `configure` yourself.

## Manual configuration

Call `configure` with a `QualifioConfiguration`, as early as possible in your application's
lifecycle (for example in your app delegate's `didFinishLaunchingWithOptions`):

```swift
import QualifioKit

Qualifio.shared.configure(QualifioConfiguration(domain: "your-account.qualifio.com"))
```

This is the right approach when the domain is only known at runtime — for example when it
depends on a remote setting. Disable automatic configuration (see below) so the two paths
don't compete.

You can also pass [options](#options) explicitly as the second argument:

```swift
Qualifio.shared.configure(
    QualifioConfiguration(domain: "your-account.qualifio.com"),
    options: QualifioOptions(debugLoggingEnabled: true)
)
```

### The `domain` field

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `domain` | `String` | Yes | The Qualifio domain that serves your campaigns, e.g. `your-account.qualifio.com`. |

## Checking whether the SDK is configured

Use `isConfigured` to find out whether the SDK has already been configured — handy when
both automatic and manual paths are possible:

```swift
if !Qualifio.shared.isConfigured {
    Qualifio.shared.configure(QualifioConfiguration(domain: "your-account.qualifio.com"))
}
```

## Options

The SDK reads a few optional settings from a `QualifioOptions.plist` file in your app
target. All keys are optional and fall back to their defaults if the file is absent.

```xml
<!-- QualifioOptions.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>auto_config_enabled</key>
    <false/>
</dict>
</plist>
```

| Key | Type | Default | Purpose |
|-----|------|---------|---------|
| `auto_config_enabled` | Boolean | `true` | Whether the SDK configures itself from `QualifioServices.plist` at startup. Set to `false` to configure manually. |
| `debug_logging_enabled` | Boolean | `false` | Enables verbose debug logging — see [Customizations](./06-customizations.md#logging). |

The same options can be passed in code through `QualifioOptions` when calling
[`configure`](#manual-configuration).

## Next steps

- [Campaigns](./03-campaigns.md) — launch a campaign once configured.
- [Secure Tokens](./04-secure-tokens.md) — attach signed user data to campaigns.
