# Notifications (Actito Integration)

The SDK can automatically display a campaign in response to a **remote notification** or
an **inbox message** sent through [Actito](https://www.actito.com). This lets you drive
engagement from your messaging campaigns: when a user opens a notification that references
a Qualifio campaign, the campaign opens directly inside your app.

## How it works

The SDK exposes an internal integration point that the Actito SDK uses to ask Qualifio to
present a campaign. When a notification or inbox message references a Qualifio campaign,
Actito invokes that integration, which in turn calls
[`launchCampaign`](./03-campaigns.md) and opens the campaign in a Safari view controller.

You do **not** call this integration directly in most cases — it is invoked for you by the
Actito SDK. The only requirements on your side are that the Qualifio iOS SDK is **added to
your app** and **[configured](./02-configuration.md)**, so it is available and able to
launch campaigns.

## Setup checklist

To enable Actito-triggered campaigns:

1. **Add the Qualifio iOS SDK** to your app — see [Getting Started](./01-getting-started.md).
2. **Configure the SDK** with your domain — see [Configuration](./02-configuration.md).
   Without configuration, campaigns cannot be launched. Automatic configuration makes this
   step zero-code.
3. **Integrate the Actito SDK** following Actito's documentation. When a notification or
   inbox message references a Qualifio campaign, Actito presents it through the Qualifio
   SDK for you.

## Next steps

- [Configuration](./02-configuration.md) — required for notifications to launch campaigns.
- [Campaigns](./03-campaigns.md) — the underlying launch behavior.
