# ESP32 S3 Home Assistant Wall Controller

Scaffold for a Guition ESP32-S3-4848S040 control panel using ESPHome.

## Goals

- Room-aware dashboard UI (lights, blinds, climate)
- Shared global actions on every panel
- Local fallback (relay control even when Home Assistant is offline)
- Clean structure for iterative UI work (LVGL pages, animations, theming)

## Repository Layout

- `esphome/`: device configs and reusable packages
- `esphome/guition_ui/`: vendored upstream LVGL UI package (based on alaltitov project)
- `scripts/`: lint, validation, and scaffolding helpers
- `docs/`: architecture and implementation notes
- `.github/workflows/`: CI checks for YAML + ESPHome config validation

## Quick Start

1. Create local secrets file:
   ```bash
   cp esphome/secrets.example.yaml esphome/secrets.yaml
   ```
2. Fill in Wi-Fi/API values in `esphome/secrets.yaml`.
3. Validate config:
   ```bash
   make validate
   ```
4. Lint + validate:
   ```bash
   make check
   ```

## Create a Room Config

```bash
./scripts/new-room.sh hallway
```

This creates:

- `esphome/rooms/hallway.yaml`
- `esphome/dashboard_hallway.yaml`

## Next Step

Add an LVGL package for the Guition display/touch stack and wire widgets to Home Assistant entities.

## Living Room Build

Primary config:

- `esphome/dashboard_living_room.yaml`

Main customization files:

- `esphome/guition_ui/common/substitutions.yaml`
- `esphome/guition_ui/widgets/light/substitutions.yaml`
- `esphome/guition_ui/widgets/cover/substitutions.yaml`

Flash (USB):

```bash
esphome run esphome/dashboard_living_room.yaml
```
