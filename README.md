# td-keyboard-config

A unified repository for my keyboard configurations, covering both the physical keyboard firmware (ZMK) and host-side software mappings (`keyd`).

## Structure

This repository is split into two primary components to keep the configuration modular and clean:

### `firmware/zmk/`
Contains the **ZMK firmware configuration** for my 42-key wireless Corne keyboard (using `nice_nano_v2`).
- **Keymap**: Features a base 34-key layout wrapped with an outer column mapping the 8 extra keys to `F13`–`F20`. This ensures these extra physical keys can be freely intercepted by the host without conflicting with standard keys used in ZMK combos.
- **Automated Builds**: Firmware is automatically built via GitHub Actions (`.github/workflows/build.yml`).
- **Keymap Drawer**: Visual representations of the keymap are automatically generated as SVGs using `keymap-drawer`.

### `software/keyd/`
Contains the **host-side mapping configurations** using [`keyd`](https://github.com/rvaiya/keyd) for Linux.
- intercepts the `F13`–`F20` keys emitted by the ZMK firmware and maps them to complex host-side behaviors, window management, and application-specific macros.
- Provides unified behavior for the built-in laptop keyboard as well.

## Local Development

This repository includes a `flake.nix` and `Justfile` to provide a reproducible local development environment. 

You can drop into the Nix shell and run local commands:
```bash
# Build firmware locally
just build

# Re-generate the keymap SVG locally
just draw
```
