# Integrated Keyboard keyd Layout Guide

This directory contains the `keyd` configuration ([laptop-urob.conf](laptop-urob.conf)) for the integrated laptop keyboard. It is designed to strictly mimic the wireless Corne 42-key ZMK configuration, with two key adaptions:
1. The **physical `space` key** functions as a normal spacebar.
2. **Vertical combos are omitted** since standard laptop keyboards have dedicated physical keys for those characters and standard flat keys are mechanically difficult to chord vertically.

---

## 1. Quick Layout Reference

- **Colemak-DH Layout (`main`)**: The default active layout upon startup.
- **QWERTY Layout (`qwerty`)**: A secondary layout with a clean, standard, unmodified QWERTY mapping (no home-row mods, no combos) for gaming or guest typing.
- **Toggle Shortcut**: Toggle between Colemak-DH and QWERTY at any time using:
  `Meta + Alt + Shift + T`
- **Vietnamese Input Toggle**: Press `CapsLock` to toggle Vietnamese (Fcitx5 Unikey) on/off.

### Vietnamese Input Mode (`CapsLock` toggle)

Pressing `CapsLock` executes the custom `keyd-layout-mode` script which manages a **two-dimensional state model** independently tracking:
1. **Keyd Layout**: persisted in `/run/keyd-laptop-layout` (`colemakdh` | `qwerty`).
2. **Fcitx Language**: queried live via `fcitx5-remote` (`us` | `vietnamese`).

When Vietnamese input is toggled:
- **Language**: Fcitx5 is toggled between English and Vietnamese.
- **Keyd Layout Preservation**: If you are using `colemakdh`, activating Vietnamese loads `colemakdh-vietnamese` (no home-row mods or horizontal combos) to prevent rapid Telex rolls (e.g. `uo` for `ươ`, `as` for `á`) from triggering accidental modifiers/chords. If you are using `qwerty`, it remains plain QWERTY layout. Toggling back to English restores your exact previous layout (`colemakdh` with full mods/combos or `qwerty`).

> **Why a script?** Using a real shortcut like `Ctrl+Alt+G` would be dangerous because home row mods (`f`=Ctrl, `s`=Alt) could accidentally produce that combo during normal English typing. By using `keyd-layout-mode`, we interact with Fcitx5 via D-Bus directly and securely.


## 2. Waybar Integration & GUI

The keyboard layout state is seamlessly integrated into Waybar on the right side of the panel:

- **Module Output**: Displays a compact icon indicating your current layout (`C` for Colemak, `Q` for QWERTY) and language (`🇺🇸` for English, `🇻🇳` for Vietnamese). 
- **Fast Layout Toggle**: Left-clicking the module instantly toggles your layout (between Colemak-DH and QWERTY).
- **Native GTK Menu**: Right-clicking the Waybar module opens a native context menu allowing you to:
  - Toggle Language (VI/EN)
  - Toggle Layout (QWERTY/COLEMAK)
  - Open the interactive terminal UI (TUI) for deeper configuration.

The interactive `keyd-tui` provides a terminal dashboard to visualize and change both the Fcitx5 language and the underlying Keyd mapping. It is automatically launched in your default terminal when selected from the menu.

---

## 3. Key Producibility Table (All Characters)

Since Colemak-DH occupies the physical semicolon key with the letter `o`, this table shows how every non-alpha character and symbol is produced in the default configuration:

| Symbol / Key | How to Produce | Key Combination | Description / Mechanics |
| :---: | :--- | :--- | :--- |
| **a-z** | Type normally | - | Colemak-DH standard alpha layout. |
| **0-9** | Type normally | - | Standard physical number row (falls through natively). |
| **;** | Semicolon | `Shift` + `,` | Custom morph mapped under `[shift]`. |
| **:** | Colon | `Shift` + `.` | Custom morph mapped under `[shift]`. |
| **<** | Less-Than | `Ctrl` + `Shift` + `,` _OR_ `Shift` + `j+k` | Custom morph in `[control+shift]` or chord under `[shift]`. |
| **>** | Greater-Than | `Ctrl` + `Shift` + `.` _OR_ `Shift` + `k+l` | Custom morph in `[control+shift]` or chord under `[shift]`. |
| **/** | Slash | Tapping `/` key | Physical bottom-right key falls through to standard `/`. |
| **?** | Question Mark | `Shift` + `/` key | Physical bottom-right key shifted (falls through). |
| **\\** | Backslash | Tapping `\` key | Physical backslash key (falls through). |
| **\|** | Pipe | `Shift` + `\` key | Physical backslash key shifted (falls through). |
| **!** | Exclamation | `Shift` + `1` | Standard shifting on number row. |
| **`** | Backtick / Grave | Tapping `` ` `` key | Standard top-left key (below Esc) (falls through). |
| **~** | Tilde | `Shift` + `` ` `` key | Standard top-left key shifted (falls through). |
| **-** | Hyphen | Tapping `-` key | Standard physical hyphen key (falls through). |
| **_** | Underscore | `Shift` + `-` key | Standard physical hyphen key shifted (falls through). |
| **=** | Equal | Tapping `=` key | Standard physical equal key (falls through). |
| **+** | Plus | `Shift` + `=` key | Standard physical equal key shifted (falls through). |
| **(** | Left Parenthesis | `j` + `k` (pressed together) | Horizontal chord in `[colemakdh]`. |
| **)** | Right Parenthesis | `k` + `l` (pressed together) | Horizontal chord in `[colemakdh]`. |
| **[** | Left Bracket | `m` + `,` (pressed together) | Horizontal chord in `[colemakdh]`. |
| **]** | Right Bracket | `,` + `.` (pressed together) | Horizontal chord in `[colemakdh]`. |
| **{** | Left Brace | `Shift` + `m` + `,` (together) | Horizontal chord under `[shift]`. |
| **}** | Right Brace | `Shift` + `,` + `.` (together) | Horizontal chord under `[shift]`. |

---

## 4. Thumb Key Mappings

Thumb keys behave as dual-function hold/taps to activate layers:

| Physical Key | Tap Action | Hold Action | ZMK Equivalent |
| :--- | :--- | :--- | :--- |
| **Left Win (Meta)** | - | Activates `[nav_layer]` | `&lt_spc NAV 0` (Space tap omitted) |
| **Left Alt** | `Enter` | Activates `[fn_layer]` | `&lt FN RET` |
| **Spacebar** | `Space` | `Space` | Omitted from layers (functions as normal space) |
| **Right Alt** | Sticky NUM layer | Activates `[num_layer]` | `SMART_NUM` (Tap: oneshot NUM, Hold: NUM) |
| **Right Win (Meta)**| Sticky SHIFT | Activates standard Shift | `SMART_SHIFT` (Tap: oneshot Shift, Hold: Shift)|

---

## 5. Layer Mappings

### 5.1. Navigation Layer (`[nav_layer]`)
*Activated by holding **Left Win (Meta)**.*

- **Left Hand Top**: `q` = Close Window (`Alt+F4`), `e` = Prev Tab (`Shift+Tab`), `r` = Switch Window (`Alt+Tab`).
- **Left Hand Middle (Oneshot Modifiers)**: `a` = Meta, `s` = Alt, `d` = Shift, `f` = Control.
- **Right Hand Top**: `y` = PageUp.
- **Right Hand Middle**: `h` = PageDown, `semicolon` = Enter.
- **Right Hand Bottom**: `n` = Insert, `m` = Tab.
- **Navigation Timeouts**: 
  These keys act as standard navigation keys when tapped, and fire advanced word/document jump operations when held for >200ms:
  - `u` = Tap: `Backspace` \| Hold: `Ctrl + Backspace` (Delete word backward)
  - `i` = Tap: `Up Arrow` \| Hold: `Ctrl + Home` (Start of document)
  - `o` = Tap: `Delete` \| Hold: `Ctrl + Delete` (Delete word forward)
  - `j` = Tap: `Left Arrow` \| Hold: `Home` (Start of line)
  - `k` = Tap: `Down Arrow` \| Hold: `Ctrl + End` (End of document)
  - `l` = Tap: `Right Arrow` \| Hold: `End` (End of line)
- **NAV Layer Horizontal Combos**:
  - `j+k` = `<`
  - `k+l` = `>`
  - `m+comma` = `{`
  - `comma+dot` = `}`

### 5.2. Numeric Layer (`[num_layer]`)
*Activated by holding **Right Alt**.*

- **Left Hand Numbers**: `w` = 7, `e` = 8, `r` = 9, `x` = 1, `c` = 2, `v` = 3.
- **Home Row Mods**: `a` = 0 (Meta), `s` = 4 (Alt), `d` = 5 (Shift), `f` = 6 (Control).

### 5.3. Function & Media Layer (`[fn_layer]`)
*Activated by holding **Left Alt**.*

- **F-Keys**: `q`-`r` (F12, F7-F9), `a`-`f` (F11, F4-F6), `z`-`v` (F10, F1-F3).
- **Media Keys**: `u` = Prev Song, `i` = Vol Up, `o` = Next Song, `rightalt` = Mute, `rightmeta` = Play/Pause.
- **System Shortcuts**:
  - `j` = Prev Desktop (`Meta+Ctrl+Left`) (Hold: Control)
  - `k` = Vol Down (`Vol Down`) (Hold: Shift)
  - `l` = Next Desktop (`Meta+Ctrl+Right`) (Hold: Alt)
  - `n` = Pin App (`Meta+Ctrl+Shift+A`)
  - `m` = Pin Window (`Meta+Ctrl+Shift+Q`)
  - `comma` = Desktop Manager (`Alt+Grave`)

---

## 6. Deployment and Troubleshooting

### Deployment
The robust `deploy.sh` script automates the entire installation and integration process idempotently:
1. Installs the `keyd` mapping configurations.
2. Installs the GUI scripts and Waybar native GTK XML menu to `/usr/local`.
3. Adds a passwordless `sudo` snippet so Waybar can securely trigger state changes.
4. Directly injects the custom `keyd-layout` module into `~/.config/waybar/config.jsonc` (on the right side) and styles into `style.css`.
5. Reloads `keyd` and restarts Waybar seamlessly.

To completely deploy or update your local system:
```bash
sudo ./deploy.sh
```

### Safety / Emergency Stop
If a configuration issue ever makes your keyboard unresponsive, you can immediately kill the keyd daemon by pressing:
`Backspace + Escape + Enter`
