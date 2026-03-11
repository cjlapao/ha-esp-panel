import sys
import re

def create_sdl_yaml(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    output_lines = []
    skip_indent = -1
    
    blocks_to_skip = {
        'esp32:', 'psram:', 'wifi:', 'captive_portal:', 'web_server:', 'ota:', 'i2c:', 'spi:',
        'display:', 'touchscreen:', 'output:', 'switch:'
    }

    in_text_sensor = False

    for line in lines:
        raw_stripped = line.lstrip(' \t')
        indent = len(line) - len(raw_stripped)
        stripped = raw_stripped.strip()

        if skip_indent != -1:
            if stripped == '' or stripped.startswith('#'):
                continue
            if indent <= skip_indent:
                skip_indent = -1
            else:
                continue

        if skip_indent == -1:
            if stripped in blocks_to_skip:
                skip_indent = indent
                continue
                
            # Specifically handle text_sensor blocks 
            if stripped == 'text_sensor:':
                in_text_sensor = True
                output_lines.append(line)
                continue
                
            if in_text_sensor and indent <= 0 and stripped != '' and not stripped.startswith('#'):
                in_text_sensor = False

            if in_text_sensor and stripped == '- platform: wifi_info':
                skip_indent = indent
                # add dummy text sensors instead
                output_lines.extend([
                    "  - platform: template\n",
                    "    id: wifi_ssid_text\n",
                    "    name: \"Wifi SSID\"\n",
                    "    update_interval: never\n",
                    "  - platform: template\n",
                    "    id: wifi_ip_text\n",
                    "    name: \"Wifi IP\"\n",
                    "    update_interval: never\n"
                ])
                continue

            # replace node name
            if line.startswith("  node_name: panel-living-room"):
                output_lines.append(line.replace("panel-living-room", "panel-living-room-sdl"))
                continue
            # replace sntp with homeassistant
            if stripped == '- platform: sntp':
                output_lines.append(line.replace("sntp", "homeassistant"))
                continue

            # remove wifi signal sensor
            elif stripped == '- platform: wifi_signal':
                skip_indent = indent
                output_lines.extend([
                    "  - platform: template\n",
                    "    id: wifi_signal_db\n",
                    "    name: \"WiFi Signal\"\n",
                    "    update_interval: never\n"
                ])
                continue
            # remove hardware_uart
            if 'hardware_uart:' in stripped:
                continue

            # remove wifi disable/enable actions
            if 'wifi.disable:' in stripped or 'wifi.enable:' in stripped:
                continue

            # remove wifi info sensor
            else:
                output_lines.append(line)

    # Patch the on_boot block to immediately bypass splash/wifi wait on SDL
    result = ''.join(output_lines)
    old_on_boot = """  on_boot:
    priority: 300
    then:
      - logger.log: "[boot] Starting splash boot sequence"
      - lvgl.widget.show: splash_layer
      - lvgl.label.update:
          id: splash_status_line
          text: "Connecting to WiFi..."
      - lvgl.widget.hide: splash_retry_line
      - lvgl.label.update:
          id: splash_retry_line
          text: "Retries WiFi 0 | API 0"
      - script.execute: apply_selected_theme"""
    new_on_boot = """  on_boot:
    priority: 300
    then:
      - logger.log: "[sdl] SDL mode: skipping splash, dashboard ready"
      - lambda: |-
          id(splash_done) = true;
      - lvgl.widget.hide: splash_layer
      - script.execute: apply_selected_theme"""
    result = result.replace(old_on_boot, new_on_boot, 1)
    output_lines = [result]


    # Now append SDL specific blocks
    sdl_additions = """
host:

json:

display:
  - platform: sdl
    id: panel_display
    dimensions:
      width: 480
      height: 480
    update_interval: never

touchscreen:
  - platform: sdl
    id: touch_id
    display: panel_display
    on_touch:
      - lambda: |-
          id(inactivity_seconds) = 0;
      - script.execute: restore_backlight_on_activity
      - if:
          condition:
            light.is_off: display_backlight
          then:
            - logger.log: "[ui] Wake display on touch"
            - light.turn_on:
                id: display_backlight
                transition_length: 0s
                brightness: !lambda |-
                  return id(backlight_restore_brightness);

output:
  - platform: template
    id: backlight_output
    type: float
    write_action:
      - logger.log:
          format: "Backlight set to %f"
          args: ["state"]

switch:
  - platform: template
    id: relay_light_1
    name: "Relay Light 1"
    optimistic: true
  - platform: template
    id: relay_light_2
    name: "Relay Light 2"
    optimistic: true
"""
    
    with open(output_file, 'w') as f:
        f.writelines(output_lines)
        f.write(sdl_additions)

if __name__ == '__main__':
    create_sdl_yaml('/Volumes/local_storage/code/esp32_tft_dashboard/esphome/dashboard_living_room.yaml', '/Volumes/local_storage/code/esp32_tft_dashboard/esphome/dashboard_living_room_sdl.yaml')
