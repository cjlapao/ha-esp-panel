# Architecture

## Layers

1. Device layer (ESPHome): hardware control, local relay fallback, LVGL UI.
2. Integration layer (Home Assistant API): state sync and service calls.
3. Presentation layer (LVGL pages): room controls + global actions.

## Resilience Model

- Online: full stateful UI with live Home Assistant data.
- Offline: local controls remain functional (relay and local automations), UI indicates stale cloud/HA data.

## Config Strategy

- `packages/base.yaml`: common device/network/safety settings.
- `rooms/*.yaml`: room-specific Home Assistant entity mapping.
- `dashboard_<room>.yaml`: composition root for each panel instance.
