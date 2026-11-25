# Development guide

## Using a local build in another app

`Package.swift` points to the released binary on the CDN. To test unreleased changes in another app, such as the Actito SDK Sample app, use `scripts/spm.rb` to build a local `QualifioKit.xcframework` and point `Package.swift` to it. This script is also required to run local builds of the iOS SDK in the Flutter and React Native plugins.

```shell
# Build the XCFramework from this checkout and point Package.swift to it.
ruby scripts/spm.rb local

# Point Package.swift back to the released binary.
ruby scripts/spm.rb remote

# Show what Package.swift points to.
ruby scripts/spm.rb status
```

In the consuming app, add this repository as a local package (File → Add Package Dependencies… → Add Local…) and link the `QualifioKit` product.

Local builds use the `Debug` configuration by default, so you can set breakpoints in the SDK code. Pass `--release` to build with `Release`, or `--simulator-only` to skip the device slice for faster builds. Run `local` again after each change. If the consuming app keeps running the previous build, clean its build folder (⇧⌘K).

The build output lives in `.local/`, which is ignored by git. Never commit `Package.swift` while it points to a local build. Run `ruby scripts/spm.rb remote` first.
