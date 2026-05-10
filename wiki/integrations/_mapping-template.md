---
slug: shadow-ide/integration/INTEGRATION_NAME
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
last_updated:
mapped_date:
status: stub
vendor:
protocol:
auth_via:
features: []
components: []
tags: []
---

<!--
STRUCTURAL CONTRACT — READ BEFORE EDITING

An integration page describes an EXTERNAL DEPENDENCY — a third-party service,
hardware device, SDK, or API the application depends on. Integrations are
NOT user-visible directly; they power features that ARE user-visible.

When creating a new integration page:

1. Read frontmatter-schema.md.
2. Copy this entire file to OUTPUT_PATH/integrations/[name].md.
3. Replace shadow-ide and INTEGRATION_NAME (kebab-case, no `-integration`
   suffix — the directory already says it's an integration).
4. Required integration-specific frontmatter:
   - vendor: the third-party name (e.g. "BACtrack", "Stripe", "Twilio")
   - protocol: http | https | bluetooth-le | grpc | websocket | sdk-only | webhook | oauth2
   - auth_via: short human description of how auth works (or empty if no auth)
5. features: at least one — integrations exist to power features.
6. Audience: default [dev, agent]. End users don't see integrations directly,
   so omit `user`.

Lint validates: required frontmatter, vendor non-empty, protocol from enum,
at least one feature, slug grammar.

Section order: Vendor → Protocol → Auth → Endpoints used → What it enables → Failure modes → Components → Open questions
-->

# Integration Name

> One-line summary: vendor + what they provide.

## Vendor

<!-- Vendor name + short context. Include vendor's role and version if relevant.
     E.g. "BACtrack — distributed via static library libBACtrackSDK.a + header
     BACtrack.h. Used for breathalyzer-based sobriety testing." -->

## Protocol

<!-- The transport: HTTPS REST, gRPC, Bluetooth LE, SDK-only (no network),
     WebSocket, OAuth2 redirect, etc. Include any version constraints. -->

## Auth

<!-- How authentication is established. Include where the credential lives
     (env var, keychain, baked into the build, OAuth flow). DO NOT include
     the credential value itself.

     Example: "API key passed at SDK init: BacTrackAPI(delegate:andAPIKey:).
     Key is stored in Config.swift; rotated quarterly." -->

## Endpoints used

<!-- Bulleted list of every endpoint, SDK method, or callback the integration
     touches. For SDK integrations, list the methods. For HTTP integrations,
     list the URLs and verbs.

     Example:
     - POST https://api.stripe.com/v1/charges
     - GET https://api.stripe.com/v1/customers/{id}
     - SDK method: BacTrackAPI.startCountdown()
     - SDK delegate callback: bacTrackAPI(_:didReceiveResults:) -->

## What it enables

<!-- Bulleted list of [[features/feature-name]] that this integration powers.
     The features: frontmatter field should match.

     Example:
     - [[features/sobriety-test]] — the user-visible breathalyzer test feature.
     - [[features/credit-card-payment]] — the in-app payment flow. -->

## Failure modes

<!-- What can go wrong with this integration, observable from the app.
     Format:
     - <Vendor> down → fallback behavior or error shown.
     - Auth expired → re-auth flow triggers.
     - Rate limit hit → backoff strategy.

     The agentic assistant reads this when troubleshooting user reports. -->

## Components

<!-- Bulleted list of [[components/component-name]] that wrap or consume this
     integration. The components: frontmatter field should match. -->

## Open questions

<!-- TODO: clarify markers. "None at this time." if clean. -->
