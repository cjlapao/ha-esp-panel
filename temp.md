substitutions:
  name: 'guition-esp32-s3-4848s040'
  friendly_name: 'Guition480-basic'
  device_description: 'Guition ESP32-S3-4848S040 480*480 Smart Screen'
  project_name: 'Guition.ESP32_S3_4848S040'
  project_version: '1.0.0'

  lightbulb: "\U000F0335"
  ceiling_light: "\U000F0769"
  lamp: "\U000F06B5"
  floor_lamp: "\U000F08DD"
  string_lights: "\U000F12BA"

esphome:
  name: '${name}'
  friendly_name: '${friendly_name}'
  #name_add_mac_suffix: true
  project:
    name: '${project_name}'
    version: '${project_version}'
  platformio_options:
    board_build.flash_mode: dio

esp32:
  board: esp32-s3-devkitc-1
  variant: esp32s3
  flash_size: 16MB
  framework:
    type: esp-idf
    sdkconfig_options:
      COMPILER_OPTIMIZATION_SIZE: y
      CONFIG_ESP32S3_DEFAULT_CPU_FREQ_240: 'y'
      CONFIG_ESP32S3_DATA_CACHE_64KB: 'y'
      CONFIG_ESP32S3_DATA_CACHE_LINE_64B: 'y'
      CONFIG_SPIRAM_FETCH_INSTRUCTIONS: y
      CONFIG_SPIRAM_RODATA: y

psram:
  mode: octal
  speed: 80MHz

logger:

# Enable Home Assistant API
api:
  encryption:
    key: 'zKRdzlIG/QpnXFo7svwqoQVx2niJojYrqxLUlkhy6F8='
  on_client_connected:
    - if:
        condition:
          lambda: 'return (0 == client_info.find("Home Assistant "));'
        then:
          - lvgl.widget.show: lbl_hastatus
          - lvgl.widget.hide: boot_screen

  on_client_disconnected:
    - if:
        condition:
          lambda: 'return (0 == client_info.find("Home Assistant "));'
        then:
          - lvgl.widget.hide: lbl_hastatus
          - lvgl.widget.show: boot_screen

ota:
  - platform: esphome
    password: '3cf57b5a4f3fedff51e3f172f02988b4'

wifi:
  ssid: Solus
  password: solusb16fC215!

  # Enable fallback hotspot (captive portal) in case wifi connection fails
  ap:
    ssid: 'Test1 Fallback Hotspot'
    password: 'tc5CN7Vzq8IY'

web_server:
  port: 80

external_components:
  - source:
      type: git
      url: https://github.com/clydebarrow/esphome
    components: [lvgl]

image:
  - file: images/background01.png
    id: boot_logo
    resize: 480x480
    type: RGB565
    use_transparency: true

sensor:
  - platform: wifi_signal
    name: 'WiFi Signal'
    id: wifi_signal_db
    update_interval: 60s
    entity_category: diagnostic
    internal: true

  # Reports the WiFi signal strength in %
  - platform: copy
    source_id: wifi_signal_db
    name: 'WiFi Strength'
    filters:
      - lambda: return min(max(2 * (x + 100.0), 0.0), 100.0);
    unit_of_measurement: '%'
    entity_category: diagnostic
    on_value: 
      then:
        - lvgl.label.update:
            id: temperature_text2
            text:
              format: "%.1f%"
              args: [ 'x' ]        

  - platform: homeassistant
    id: temperature_sensor
    entity_id: sensor.hallway_motion_sensor_temperature
    device_class: temperature
    accuracy_decimals: 2
    on_value:
      then:
        - lvgl.indicator.update:
            id: temperature_needle
            value: !lambda return x * 10;
        - lvgl.label.update:
            id: temperature_text
            text:
              format: "%.1f°C"
              args: [ 'x' ]
        - lvgl.label.update:
            id: temperature_text1
            text:
              format: "%.1f°C"
              args: [ 'x' ]
text_sensor:
  - platform: wifi_info
    ip_address:
      name: 'IP Address'
      entity_category: diagnostic
    ssid:
      name: 'Connected SSID'
      entity_category: diagnostic
    mac_address:
      name: 'Mac Address'
      entity_category: diagnostic

time:
  - platform: homeassistant
    id: burn_out
    on_time:
      - hours: 2,3,4,5
        minutes: 5
        seconds: 0
        then:
          - switch.turn_on: switch_antiburn
      - hours: 2,3,4,5
        minutes: 35
        seconds: 0
        then:
          - switch.turn_off: switch_antiburn

binary_sensor:
  - platform: homeassistant
    id: hallway_light_1
    entity_id: light.hallway_light_1
    on_state: 
      then:
        - if:
            condition:
              binary_sensor.is_on: hallway_light_1
            then: 
                - lvgl.widget.update:
                    id: hallway_light_1__icon
                    text_color: 0xB6B6B6
        - logger.log: 'state changed'
  - platform: homeassistant
    id: small_office_leds
    entity_id: light.small_office_leds
    on_state: 
      then:
        - if:
            condition:
              binary_sensor.is_on: small_office_leds
            then: 
                - lvgl.widget.update:
                    id: small_office_leds_icon
                    text_color: 0xB6B6B6
                - lvgl.widget.update:
                    id: small_office_leds_btn
                    state:
                      checked: true
                - logger.log: 'state changed to on'
        - if:
            condition:
              binary_sensor.is_off: small_office_leds
            then: 
                - lvgl.widget.update:
                    id: small_office_leds_icon
                    text_color: 0xFFFFFF
                - lvgl.widget.update:
                    id: small_office_leds_btn
                    state:
                      checked: false
                - logger.log: 'state changed to off'
switch:
  - platform: template
    name: Antiburn
    id: switch_antiburn
    icon: mdi:television-shimmer
    optimistic: true
    entity_category: "config"
    turn_on_action:
      - logger.log: "Starting Antiburn"
      - if:
          condition: lvgl.is_paused
          then:
            - lvgl.resume:
            - lvgl.widget.redraw:
      - lvgl.pause:
          show_snow: true
    turn_off_action:
      - logger.log: "Stopping Antiburn"
      - if:
          condition: lvgl.is_paused
          then:
            - lvgl.resume:
            - lvgl.widget.redraw:

#-------------------------------------------
# LVGL Buttons
#-------------------------------------------
lvgl:
  displays:
    - my_display
  touchscreens:
    - my_touchscreen
  on_idle:
    - timeout: 20s
      then:
        - logger.log: idle timeout
        - if:
            condition:
              lvgl.is_idle:
                timeout: 5s
            then:
              - logger.log: LVGL is idle
              - light.turn_on:
                  id: backlight
                  brightness: 50%
    - timeout: 30s
      then:
        - logger.log: idle 20s timeout
        - lvgl.page.show: test_page
    - timeout: 60s
      then:
        - logger.log: idle 60s timeout
        - light.turn_off:
           id: backlight
           transition_length: 5s
        - lvgl.pause:
      #- lvgl.pause:
      #- light.turn_off:
      #    id: display_backlight
      #    transition_length: 5s

  style_definitions:
    - id: style_line
      line_color: 0x0000FF
      line_width: 8
      line_rounded: true
    - id: date_style
      text_font: roboto24
      align: center
      text_color: 0x333333
      bg_opa: cover
      radius: 4
      pad_all: 2
    - id: header_footer
      text_color: 0x333333

  theme:
    button:
      text_font: roboto24
      scroll_on_focus: true
      radius: 25
      width: 150
      height: 109
      pad_left: 10px
      pad_top: 10px
      pad_bottom: 10px
      pad_right: 10px
      shadow_width: 0
      bg_color: 0x313131
      text_color: 0xB6B6B6
      checked:
        bg_color: 0xCC5E14
        text_color: 0xB6B6B6

  page_wrap: true
  top_layer:
    widgets:
      - label:
          id: lbl_hastatus
      - buttonmatrix:
          align: bottom_mid
          styles: header_footer
          pad_all: 0
          outline_width: 0
          id: top_layer
          items:
            styles: header_footer
          rows:
            - buttons:
              - id: page_prev
                text: "\uF053"
                on_press:
                  then:
                    lvgl.page.previous:
              - id: page_home
                text: "\uF015"
                on_press:
                  then:
                    lvgl.page.show: main_page
              - id: page_next
                text: "\uF054"
                on_press:
                  then:
                    lvgl.page.next:
      - obj:
          id: boot_screen
          x: 0
          y: 0
          width: 100%
          height: 100%
          bg_color: 0xffffff
          bg_opa: COVER
          radius: 0
          pad_all: 0
          border_width: 0
          widgets:
            - image:
                align: CENTER
                src: boot_logo
                y: -40
            - spinner:
                align: CENTER
                y: 95
                height: 50
                width: 50
                spin_time: 1s
                arc_length: 60deg
                arc_width: 8
                indicator:
                  arc_color: 0x18bcf2
                  arc_width: 8
          on_press:
            - lvgl.widget.hide: boot_screen
  pages:
    - id: main_page
      skip: true
      layout:
        type: flex
        flex_flow: column_wrap
      width: 100%
      bg_color: 0x000000
      bg_opa: cover
      pad_all: 5
      widgets:
        - button:
            height: 150
            width: 150
            checkable: true
            id: lv_button_1
            widgets:
              - label:
                  text_font: light40
                  align: top_left
                  text: $lightbulb
                  id: lv_button_1_icon
              - label:
                  align: bottom_left
                  text: 'Center Light'
                  long_mode: dot
            on_click:
              light.toggle: internal_light
        - button:
            height: 150
            width: 150
            checkable: true
            id: hallway_light_1_button
            widgets:
              - label:
                  text_font: light40
                  align: top_left
                  text: $lightbulb
                  id: hallway_light_1__icon
              - label:
                  align: bottom_left
                  text: 'Center Light'
                  long_mode: dot
            on_click:
              - homeassistant.action:
                  action: light.toggle
                  data:
                    entity_id: light.remote_light
        - button:
            height: 75
            width: 75
            checkable: true
            id: small_office_leds_btn
            widgets:
              - label:
                  text_font: light40
                  align: top_left
                  text: $lightbulb
                  id: small_office_leds_icon
              - label:
                  align: bottom_left
                  text: 'Leds'
                  long_mode: dot
            on_release:
              - homeassistant.service:
                    service: light.toggle
                    data:
                      entity_id: light.small_office_leds
              - logger.log: "pressed the buton released"
        - label:
            id: temperature_text1
            text: --.-
            align: CENTER
            text_align: CENTER
            text_color: 0xFFFFFF
        - label:
            id: temperature_text2
            text: --.-
            align: CENTER
            text_align: CENTER
            text_color: 0xFFFFFF
        - label:
            id: backlight_value
            text: --.-
            align: CENTER
            text_align: CENTER
            text_color: 0xFFFFFF
        - label:
            id: hallway_light_1_value
            text: --
            align: CENTER
            text_align: CENTER
            text_color: 0xFFFFFF
        - obj:
            height: 240
            width: 240
            align: CENTER
            y: -18
            bg_color: 0xFFFFFF
            border_width: 0
            pad_all: 14
            widgets:
              - meter:
                  height: 100%
                  width: 100%
                  border_width: 0
                  align: CENTER
                  bg_opa: TRANSP
                  scales:
                    - range_from: -15
                      range_to: 35
                      angle_range: 180
                      ticks:
                        count: 70
                        width: 1
                        length: 31
                      indicators:
                        - tick_style:
                            start_value: -15
                            end_value: 35
                            color_start: 0x3399ff
                            color_end: 0xffcc66
                    - range_from: -150
                      range_to: 350
                      angle_range: 180
                      ticks:
                        count: 0
                      indicators:
                        - line:
                            id: temperature_needle
                            width: 8
                            r_mod: 2
                            value: -150
              - obj: # to cover the middle part of meter indicator line
                  height: 123
                  width: 123
                  radius: 73
                  align: CENTER
                  border_width: 0
                  pad_all: 0
                  bg_color: 0xFFFFFF
              - label:
                  id: temperature_text
                  text: '--.-°C'
                  align: CENTER
                  y: -26
              - label:
                  text: 'Outdoor'
                  align: CENTER
                  y: -6
    - id: test_page
      layout:
        type: flex
        flex_flow: column_wrap
      width: 100%
      bg_color: 0x000000
      bg_opa: cover
      pad_all: 5
      widgets:
        - button:
            height: 223
            checkable: true
            id: lv_button_2
            widgets:
              - label:
                  text_font: light40
                  align: top_left
                  text: $lightbulb
                  id: lv_button_2_icon
              - label:
                  align: bottom_left
                  text: 'I made a thing'
                  long_mode: dot
            on_click:
              light.toggle: internal_light
#-------------------------------------------
# Internal outputs
#-------------------------------------------
output:
  # Backlight LED
  - platform: ledc
    pin: GPIO38
    id: GPIO38
    frequency: 100Hz

    # Built in 240v relay
  - id: internal_relay_1
    platform: gpio
    pin: 40

    # Additional relays (3 relay model)
  - id: internal_relay_2
    platform: gpio
    pin: 2
  - id: internal_relay_3
    platform: gpio
    pin: 1

#-------------------------------------------
# Internal lights
#-------------------------------------------
light:
  - platform: monochromatic
    output: GPIO38
    name: Backlight
    id: backlight
    restore_mode: ALWAYS_ON
    on_state: 
      then:
        - lvgl.label.update:
            id: backlight_value
  - platform: binary
    output: internal_relay_1
    name: Internal Light
    id: internal_light
    on_turn_on:
      then:
        - lvgl.widget.update:
            id: lv_button_1_icon
            text_color: 0xFFFF00
        - lvgl.widget.update:
            id: lv_button_1
            state:
              checked: true
    on_turn_off:
      then:
        - lvgl.widget.update:
            id: lv_button_1_icon
            text_color: 0xB6B6B6
        - lvgl.widget.update:
            id: lv_button_1
            state:
              checked: false

#-------------------------------------------
# Graphics and Fonts
#-------------------------------------------
font:
  - file: 'gfonts://Roboto'
    id: roboto24
    size: 24
    bpp: 4
    extras:
      - file: 'fonts/materialdesignicons-webfont.ttf' # http://materialdesignicons.com/cdn/7.4.47/
        glyphs: ["\U000F004B", "\U000F006E", "\U000F012C", "\U000F179B", "\U000F0748", "\U000F1A1B", "\U000F02DC", "\U000F0A02", "\U000F035F", "\U000F0156", "\U000F0C5F", "\U000f0084", "\U000f0091"]

  - file: 'fonts/materialdesignicons-webfont.ttf' # http://materialdesignicons.com/cdn/7.4.47/
    id: light40
    size: 40
    bpp: 4
    glyphs: [
        "\U000F0335", # mdi-lightbulb
        "\U000F0769", # mdi-ceiling-light
        "\U000F06B5", # mdi-lamp
        "\U000F08DD", # mdi-floor-lamp
        "\U000F12BA", # mdi-string-lights
      ]

#-------------------------------------------
# Touchscreen gt911 i2c
#-------------------------------------------
i2c:
  - id: bus_a
    sda: GPIO19
    scl: GPIO45
    #frequency: 100kHz

touchscreen:
  platform: gt911
  transform:
    mirror_x: false
    mirror_y: false
  id: my_touchscreen
  display: my_display

  on_touch:
    - logger.log:
        format: Touch at (%d, %d)
        args: [touch.x, touch.y]
    - lambda: |-
        ESP_LOGI("cal", "x=%d, y=%d, x_raw=%d, y_raw=%0d",
            touch.x,
            touch.y,
            touch.x_raw,
            touch.y_raw
            );
  on_release:
    then:
      - if:
          condition: lvgl.is_paused
          then:
            - lvgl.resume:
            - lvgl.widget.redraw:
            - lvgl.page.show: main_page
            - light.turn_on:
                id: backlight
                brightness: 100%
                transition_length: 3s
      - if:
            condition: 
              lvgl.is_idle:
                timeout: 5s
            then:
              - logger.log: idle 20s timeout
              - lvgl.page.show: main_page
#-------------------------------------------
# Display st7701s spi
#-------------------------------------------
spi:
  - id: lcd_spi
    clk_pin: GPIO48
    mosi_pin: GPIO47

display:
  - platform: st7701s
    id: my_display
    update_interval: never
    auto_clear_enabled: False
    spi_mode: MODE3
    data_rate: 2MHz
    color_order: RGB
    invert_colors: False
    dimensions:
      width: 480
      height: 480
    cs_pin: 39
    de_pin: 18
    hsync_pin: 16
    vsync_pin: 17
    pclk_pin: 21
    pclk_frequency: 12MHz
    pclk_inverted: False
    hsync_pulse_width: 8
    hsync_front_porch: 10
    hsync_back_porch: 20
    vsync_pulse_width: 8
    vsync_front_porch: 10
    vsync_back_porch: 10
    init_sequence:
      - 1
      # Custom sequences are an array, first byte is command, the rest are data.
      - [0xFF, 0x77, 0x01, 0x00, 0x00, 0x10] # CMD2_BKSEL_BK0
      - [0xCD, 0x00] # disable MDT flag
    data_pins:
      red:
        - 11 #r1
        - 12 #r2
        - 13 #r3
        - 14 #r4
        - 0 #r5
      green:
        - 8 #g0
        - 20 #g1
        - 3 #g2
        - 46 #g3
        - 9 #g4
        - 10 #g5
      blue:
        - 4 #b1
        - 5 #b2
        - 6 #b3
        - 7 #b4
        - 15 #b5
