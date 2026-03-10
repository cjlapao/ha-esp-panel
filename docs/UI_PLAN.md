# UI Plan (Initial)

## Screen Model (480x480)

- Header: room label, time, online/offline indicator.
- Body: cards for lights, blinds, climate, weather/network snapshot.
- Footer: global actions (`All Lights Off`, `All Blinds Stop`, `Relay`).

## Animation Plan

- Blinds: position bar + animated blind slats/curtain movement.
- Weather: subtle icon animation (cloud drift/rain pulse/sun glow).
- Navigation: short page slide + button press feedback.

## Performance Targets

- Keep frame updates bounded to changed widgets.
- Use short animation durations (120-250ms) for responsiveness.
- Avoid full-screen redraws when only one card changes.
