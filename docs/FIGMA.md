# Figma UI — FreeTube iOS Personal Edition

## Design file

[Figma: FreeTube iOS Personal Edition — UI](https://www.figma.com/design/7mKy3p7ZwvknXS1nHtOtQI)

Created in the connected Figma account. Reference device is iPhone 13 at 390 × 844 pt. The screens are separate editable Figma frames.

## Pages and coverage

- `00 — Design system`: dark-first palette and layout-token board; editable Figma variables for colors and layout values.
- `01 — iPhone screens`: 14 frames — Home, Search, Results, Player, Mini-player, Queue, Subscriptions, Library, Playlists, History, Channel, Settings, Login, and Error.
- `02 — Components & states`: reusable Figma components for primary button, search field, video row, mini-player, and Loading / Empty / Error / Success states.

## Tokens

- Background `#101114`
- Surface `#1C1E24`
- Raised surface `#272A33`
- Accent `#6366F1`
- Primary text `#F5F5F7`
- Secondary text `#8E8E93`
- Spacing: 4 / 8 / 12 / 16 / 24 / 32 pt
- Radii: 12 / 16 / 24 pt
- Minimum touch target: 44 pt

The mockups use Inter for legible Figma previews. Use the native SF Pro system font when implementing in SwiftUI. Keep Liquid Glass progressive: use it only on supported iOS versions and preserve a solid-material fallback.

## UI decisions

- Dark mode is the primary presentation; light mode remains a later implementation requirement.
- Native tab bar, compact thumbnail-led feed, short metadata rows, and a persistent mini-player.
- Player screen treats streaming availability as conditional and does not imply that every video can be played.
- Login screen explicitly warns that the upstream cookie-in-WebView approach needs security review.
- Error state gives a clear retry action without suggesting a restriction bypass.

## Integration status

The Figma deliverable is complete for the initial screen set, tokens, reusable components, and four required content states. SwiftUI integration has not started because the requested first upstream compile has not been run. The Figma components are intentionally independent of the current SwiftUI source so the baseline build remains the next gate.
