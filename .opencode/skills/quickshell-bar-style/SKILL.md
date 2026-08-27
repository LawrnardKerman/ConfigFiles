---
name: quickshell-bar-style
description: Style guide and conventions for the user's quickshell status bar QML (shell.qml, BarStats.qml, Workspaces.qml, *Popup.qml, WeatherStatus.qml). Use when creating or editing any widget/pill/popup in the quickshell config so new components match the existing Gruvbox pill design.
---

# Quickshell Bar Style Guide

The bar is a transparent top PanelWindow containing sharp-cornered "pills"
(Rectangle modules) on a Gruvbox dark palette. Follow these rules exactly when
adding or modifying widgets so everything stays visually consistent.

## Palette (Gruvbox dark) — use these exact hex values

| Role                        | Color      |
|-----------------------------|------------|
| Pill / popup background     | `#282828`  |
| Pill border                 | `#3c3836`  |
| Inner element borders (graphs, sliders, popup border) | `#504945` |
| Primary foreground text     | `#ebdbb2`  |
| Muted / hover background    | `#3c3836`  |
| Lightest (urgent flash)     | `#fbf1c7`  |
| Accent per module:          |            |
| – Clock                     | `#8ec07c` (green) |
| – Volume / audio            | `#fe8019` (orange) |
| – Mic                       | `#d3869b` (purple) |
| – Memory                    | `#b8bb26` (green)  |
| – CPU                       | `#ebdbb2`          |
| – Weather sun               | `#fabd2f`  |
| – Rain                      | `#83a598`  |
| – Snow                      | `#ebdbb2`  |
| – Thunderstorm              | `#fb4934`  |
| – Warning state (DND off, no wifi) | `#fe8019` |

Rule: one accent color per module; icon, value text, slider fill, and graph
line all share that accent. Generic labels/text are `#ebdbb2`.

## Layout

- Bar: `implicitHeight: 24`, `color: "transparent"`, margins derived from
  `swayGapsInner` (4) + `swayGapsOuter` (2); `exclusiveZone` = implicitHeight.
- Each module is a `Rectangle` pill: `color: "#282828"`,
  `border.color: "#3c3836"`, `border.width: swayBorderWidth` (3),
  `height: parent.height`, NO corner radius anywhere.
- Horizontal padding inside pills: content width `+ 12`.
- Content centered via `anchors.centerIn: parent`; side-by-side elements in a
  `Row { spacing: 4 }`.
- Pills sit in left/right `Row`s with `spacing: swayGapsInner`.
- Popups: `PopupWindow` anchored below the pill
  (`anchor.rect.y = bar.implicitHeight + 2`), x computed from
  `pill.mapToItem(null, ...)`. Popup body: `Rectangle` fill `#282828`,
  border `#504945` width 3, inner `ColumnLayout` margins 8, spacing 6.
- Stacked popups under one anchor separated by 6px vertically.

## Typography

- Text: `"iosevka, monospace"`, `font.pixelSize: 11`.
- Popup headings/values may be size 10 bold in the module's accent color.
- Icon glyphs: `"JetBrainsMono Nerd Font"` (preferred, e.g. `\ue30d`) or
  `"Font Awesome 5 Free"` codepoints (`\uf...`), `font.pixelSize: 12`
  (11 inside dense rows like BarStats). Note FA is NOT installed on this
  system — prefer Nerd Font codepoints for anything new.

## Data / component architecture

- Long-running data sources are singleton-style Items instantiated once in
  shell.qml (`SystemStats`, `NetworkStatus`, `WeatherStatus`,
  `NotificationsStatus`) and passed down as `required property QtObject ...`
  on child components.
- File naming: `<Name>Status.qml` = shared data provider,
  `<Name>Popup.qml` = popup window, plain names (`BarStats`, `MiniPlayer`)
  = inline pill content components.
- Network/shell work via `Process` + bash + jq/curl with caching under
  `~/.cache/quickshell/`; refresh timers ~30 min.
- Expose display-ready properties/functions on Status items
  (e.g. `weatherIcon(code)`, `weatherColor(code)`), keep pills dumb.

## Interaction

- Clickable pills/popups: `MouseArea { cursorShape: Qt.PointingHandCursor }`
  toggling a popup's `open` property.
- Hover highlight uses background `#3c3836` (HoverHandler), never color
  changes to text.
- Sliders/graphs: track `#3c3836` with `#504945` border width 1, fill/handle
  in the module accent; pressed handle darkens via
  `Qt.darker(fillColor, 1.3)`.

## Reference examples

- Canonical pill: clockPill in shell.qml (~line 235).
- Dense icon+graph+value row: BarStats.qml.
- Interactive workspace cells with hover/urgent states: Workspaces.qml.
- Vertical slider pattern: VolumeSlider.qml.
