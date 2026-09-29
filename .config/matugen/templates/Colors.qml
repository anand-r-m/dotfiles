pragma Singleton
import Quickshell
import QtQuick

Singleton {
  readonly property color pill: "#d9{{colors.surface_container.default.hex_stripped}}"
  readonly property color text: "{{colors.on_surface.default.hex}}"
  readonly property color dim: "{{colors.on_surface_variant.default.hex}}"
  readonly property color primary: "{{colors.primary.default.hex}}"
  readonly property color primaryText: "{{colors.on_primary.default.hex}}"
  readonly property color accent: "{{colors.tertiary.default.hex}}"
  readonly property color occupied: "{{colors.surface_variant.default.hex}}"
  readonly property color border: "{{colors.outline_variant.default.hex}}"
}
