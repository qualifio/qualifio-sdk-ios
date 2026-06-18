# Campaigns

A **campaign** is the interactive Qualifio experience (quiz, contest, survey, and so on)
that you display to your users. The SDK presents campaigns in a `SFSafariViewController`
presented modally on top of your app, so the user stays within your experience without
switching to a separate browser app.

> Make sure the SDK is [configured](./02-configuration.md) before launching a campaign.

## Launching a campaign

Call `launchCampaign` with the **slug** of the campaign you want to display. It is an
`async throws` function, so call it from an asynchronous context with `try await`:

```swift
import QualifioKit

Task {
    try await Qualifio.shared.launchCampaign("summer-quiz")
}
```

The slug identifies the campaign within your Qualifio account. The SDK combines it with
your configured domain to build the campaign URL and opens it in the Safari view controller.

### The campaign parameter

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `campaign` | `String` | No | `"sdk"` | The campaign slug to display. |

- If you call `launchCampaign()` with **no argument**, the default slug `"sdk"` is used.
- The slug may contain multiple path segments separated by `/` (for example
  `contests/summer-quiz`).

### Example: launch from a button (SwiftUI)

```swift
import SwiftUI
import QualifioKit

struct PlayButton: View {
    var body: some View {
        Button("Play the quiz") {
            Task {
                do {
                    try await Qualifio.shared.launchCampaign("summer-quiz")
                } catch {
                    print("Failed to launch campaign:", error)
                }
            }
        }
    }
}
```

## How the campaign is presented

When you launch a campaign, the SDK:

1. Builds the campaign URL from your configured domain and the campaign slug.
2. Asks the [delegate](./04-secure-tokens.md) for a secure token, if one is set, and
   appends it to the URL.
3. Presents an `SFSafariViewController` (as a page sheet by default) from the top-most view
   controller, applying any [customizations](./06-customizations.md) from the delegate.

The user dismisses the campaign with the Safari view controller's **Done** button or by
swiping the sheet down, returning to your app.

## Considerations

- **Not configured:** if the SDK has not been configured, `launchCampaign` throws a
  `QualifioError.notConfigured`. Always configure first — see
  [Configuration](./02-configuration.md).
- **Presentation failure:** if the SDK cannot find a view controller to present from, it
  throws. Call `launchCampaign` with `try` inside a `do/catch` to surface problems
  gracefully.
- **Personalization:** to attach signed user data to the campaign, set a delegate that
  provides a secure token before launching — see [Secure Tokens](./04-secure-tokens.md).

## Next steps

- [Secure Tokens](./04-secure-tokens.md) — personalize campaigns per user.
- [Customizations](./06-customizations.md) — style the Safari view controller to match your brand.
- [Notifications](./05-notifications.md) — launch campaigns from Actito notifications.
