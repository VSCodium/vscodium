<!-- order: 10 -->

# Getting all the Telemetry Out

This page explains how VSCodium handles telemetry and how to ensure your privacy.

## Table of Contents

- [Telemetry in VSCodium](#telemetry)
- [Replacements to Microsoft Online Services](#replacements)
- [Checking for Telemetry](#checking)
- [Additional Privacy Settings](#additional-settings)
- [VSCodium Announcements](#announcements)
- [Malicious & Deprecated Extensions](#malicious-extensions)

## <a id="telemetry"></a>Telemetry in VSCodium

VSCodium is built to minimize telemetry. We do not pass telemetry-specific build flags and actively work to disable or remove baked-in telemetry mechanisms from Microsoft's upstream vscode repository. However, it's important to understand that the original codebase from Microsoft may still contain elements that could attempt usage tracking by default if not properly configured.

VSCodium addresses this by:
- Setting default values for `telemetry.enableTelemetry` and `telemetry.enableCrashReporter` to `false`. You can verify these in your VSCodium `settings.json`.
- Guiding users to review and manage settings that use online services.

It is also highly recommended that you review all the settings that "use online services" by following [these instructions](https://code.visualstudio.com/docs/getstarted/telemetry#_managing-online-services). The `@tag:usesOnlineServices` filter on the settings page will show that by default:

- Extensions auto check for updates and auto install updates
- Searches within the app are sent to an online service for "natural language processing"
- Updates to the app are fetched in the background

These can all be disabled.

__Please note that some extensions send telemetry data to Microsoft as well. We have no control over this and can only recommend removing the extension.__ _(For example, the C# extension `ms-vscode.csharp` sends tracking data to Microsoft.)_

## <a id="replacements"></a>Replacements to Microsoft Online Services

When searching the `@tag:usesOnlineServices` filter, note that while the "Update: Mode" setting description still says "The updates are fetched from a Microsoft online service", VSCodium's build script [sets the `updateUrl` field](https://github.com/VSCodium/vscodium/blob/master/prepare_vscode.sh#L135) in `product.json` directly to the GitHub page, so enabling that setting won't actually result in any calls to Microsoft online service.

Likewise, while the descriptions for "Extensions: Auto Check Updates" and "Extensions: Auto Update" include the same phrase, VSCodium [replaces](https://github.com/VSCodium/vscodium/blob/master/prepare_vscode.sh#L121) the Visual Studio Marketplace with Open VSX, so these settings won't call Microsoft, either.

## <a id="checking"></a>Checking for Telemetry

If you want to verify that no telemetry is being sent, you can use network monitoring tools like:

- Wireshark
- Little Snitch (macOS)
- GlassWire (Windows)

Look for connections to Microsoft domains and telemetry endpoints.

## <a id="additional-settings"></a>Additional Privacy Settings

For maximum privacy, you can add these settings to your `settings.json`:

```json
{
  "telemetry.enableTelemetry": false,
  "telemetry.enableCrashReporter": false,
  "telemetry.feedback.enabled": false,
  "update.enableWindowsBackgroundUpdates": false,
  "update.mode": "manual",
  "workbench.enableExperiments": false,
  "workbench.settings.enableNaturalLanguageSearch": false
}
```

These settings will disable various telemetry and tracking features.

## <a id="announcements"></a>VSCodium Announcements

The Welcome page in VSCodium displays announcements that are fetched from the project's GitHub repository.

If you prefer to disable this feature, you can set the `workbench.welcomePage.extraAnnouncements` setting to `false` in your `settings.json`.

## <a id="malicious-extensions"></a>Malicious & Deprecated Extensions

The definitions for malicious and deprecated extensions are dynamically loaded from the following URL:
https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json.

If you prefer to avoid any external connections, you can set the`extensions.excludeUnsafes` setting to `false` in your `settings.json`.
However, this is not recommended as it may reduce the safety of your environment.
