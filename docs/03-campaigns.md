# Campaigns

A **campaign** is the interactive Qualifio experience (quiz, contest, survey, and so on)
that you display to your users. The SDK can present campaigns in two ways:

- **[Launched](#launching-a-campaign)** in a `SFSafariViewController` presented modally
on top of your app.
- **[Inline](#inline-campaigns)** inside your own screens, with `QualifioInlineCampaignView` for
  UIKit or `QualifioInlineCampaign` for SwiftUI.

> Make sure the SDK is [configured](./02-configuration.md) before launching or embedding a campaign.
> To personalize campaigns with signed user data, register a
[secure token provider](./04-secure-tokens.md) first.

## The campaign parameter

Both presentation options identify the campaign by its **slug**, passed as the
`campaign` parameter. The slug identifies the campaign within your Qualifio account.
The SDK combines it with your configured domain to build the campaign URL.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `campaign` | `String` | No | `"sdk"` | The campaign slug to display. |

- When no campaign is given, the default slug `"sdk"`is used. This applies to 
`launchCampaign()`, `loadCampaign()`, `QualifioInlineCampaignView` and `QualifioInlineCampaign`.
- The slug may contain multiple path segments separated by `/` (for example
  `contests/summer-quiz`).
- A blank slug is rejected: `launchCampaign()` throws an `QualifioError.invalidArgument`, and the inline
view ignores it and logs `Invalid campaign parameter.` 

## Launching a campaign

Call `launchCampaign` with the **slug** of the campaign you want to display. It is an
`async throws` function, so call it from an asynchronous context with `try await`:

```swift
import QualifioKit

Task {
    try await Qualifio.shared.launchCampaign("summer-quiz")
}
```

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

### How the campaign is presented

When you launch a campaign, the SDK:

1. Builds the campaign URL from your configured domain and the campaign slug.
2. Asks the registered [secure-token provider](./04-secure-tokens.md), if one is set, and
   appends the token to the URL.
3. Presents an `SFSafariViewController` (as a page sheet by default) from the top-most view
   controller, applying any [customizations](./06-customizations.md) you registered.

The user dismisses the campaign with the Safari view controller's **Done** button or by
swiping the sheet down, returning to your app.

### Considerations

- **Not configured:** if the SDK has not been configured, `launchCampaign` throws a
  `QualifioError.notConfigured`. Always configure first — see
  [Configuration](./02-configuration.md).
- **Presentation failure:** if the SDK cannot find a view controller to present from, it
  throws. Call `launchCampaign` with `try` inside a `do/catch` to surface problems
  gracefully.

## Inline campaigns

Use an inline campaign when it should be part of your screen instead of presenting in a
`SFSafariViewController`. `QualifioInlineCampaignView` (UIKit) and `QualifioInlineCampaign` (SwiftUI)
host the campaign in a `WKWebView`.

### UIKit

Create the view in code and add it to your view hierarchy:

```swift
let campaignView = QualifioInlineCampaignView(
    campaign: "summer-quiz",
    autoScrollOnPageLoadEnabled: true
)

stackView.addArrangedSubview(campaignView)
```

To show another campaign later, call `loadCampaign()`:

```swift
campaignView.loadCampaign("winter-quiz")
```

### UIKit (Interface Builder)

In a storyboard or xib, set the view's class to `QualifioInlineCampaignView` (module `QualifioKit`)
and set **Qualifio Campaign** and **Auto Scroll On Page Load Enabled** in the Attributes inspector.

### SwiftUI

Use `QualifioInlineCampaign` in your SwiftUI view.

```swift
struct InlineCampaignView: View {
    var body: some View {
        QualifioInlineCampaign(
            campaign: "summer-quiz",
            autoScrollOnPageLoadEnabled: true
        )
    }
}
```

Changing `campaign` loads the new campaign.

### Properties

| Property | Inspector field | Default | Description |
|----------|-----------------|---------|-------------|
| `campaign`| Qualifio Campaign | `"sdk"` | The campaign to be loaded, or pending until the view is attached. |
| `autoScrollOnPageLoadEnabled` | Auto Scroll On Page Load Enabled | `true` | When the campaign moves to another page, scrolls the parent so the top of the view is visible. Not applied to the first page. |

### When the campaign loads

- The campaign loads once the view is **attached to a window**, not when it is created. A view
  that is never attached does not request a [secure token](./04-secure-tokens.md) or load anything.
- `loadCampaign()` starts loading immediately if the view is attached. Otherwise it replaces the
  pending campaign, so creating a view and calling `loadCampaign("winter-quiz")` before adding it
  to the hierarchy loads only `winter-quiz`.

### Size and loading state

While a campaign loads, the view takes no space and shows no loader. Once loaded, the view sizes its
height to the campaign content through `intrinsicContentSize` and follows it as the content changes, so
don't constrain its height.

### Considerations

- **Not configured:** unlike `launchCampaign`, the inline view does not throw. It logs
  `No configuration set. Please call Qualifio.shared.configure()` and does not load. Configure the SDK
  before creating inline views.

## Next steps

- [Secure Tokens](./04-secure-tokens.md) — personalize campaigns per user.
- [Customizations](./06-customizations.md) — style the Safari view controller to match your brand.
- [Notifications](./05-notifications.md) — launch campaigns from Actito notifications.
