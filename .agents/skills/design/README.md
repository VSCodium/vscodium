# Design Skills for Cursor ING

Curated design skills adapted from Open Design (Apache 2.0).
Each skill defines what Cursor ING Design Studio can generate.

## Available Skills (Phase 1 Scaffold)

| Skill | Description | Triggers |
|-------|-------------|----------|
| landing-page | Marketing/product landing page | "landing page", "homepage" |
| dashboard | Admin/analytics dashboard | "dashboard", "admin panel" |
| app-screen | Mobile/desktop app screen | "app screen", "mobile app" |
| slide-deck | Presentation slides | "slides", "presentation", "deck" |
| prototype | Interactive web prototype | "prototype", "mockup" |

## Skill Metadata Format
Each skill has a `skill.json`:
```json
{
  "name": "landing-page",
  "description": "Marketing/product landing page in a single HTML file",
  "triggers": ["landing page", "homepage", "marketing page"],
  "mode": "prototype",
  "platform": "web",
  "preview": { "type": "html", "entry": "index.html" },
  "designSystem": { "required": true },
  "source": "open-design",
  "license": "Apache-2.0"
}
```

## Attribution
Skills are adapted from Open Design (https://github.com/Biyocon/open-design).
Original license: Apache 2.0. Cursor ING preserves attribution per license terms.
