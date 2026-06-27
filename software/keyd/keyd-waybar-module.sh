#!/usr/bin/env bash
# Waybar custom module for keyd keyboard layout state
# Triggered by signal only (interval: once) — no polling
#
# Outputs JSON: { text, tooltip, class }

STATE=/run/keyd-laptop-layout
REAL_USER=ntv
REAL_UID=1000

fcitx_state() {
  if [ "$EUID" -eq 0 ]; then
    runuser -u "$REAL_USER" -- \
      env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
      fcitx5-remote 2>/dev/null
  else
    fcitx5-remote 2>/dev/null
  fi
}

layout="$(cat "$STATE" 2>/dev/null || echo colemakdh)"
fcitx="$(fcitx_state)"

# fcitx5-remote: 1 = Vietnamese active, 2 = English active
if [[ "$fcitx" == "1" ]]; then
  lang="VI"
  lang_icon="🇻🇳"
  lang_class="vietnamese"
else
  lang="EN"
  lang_icon="🇺🇸"
  lang_class="english"
fi

case "$layout" in
  qwerty)
    layout_icon="Q"
    layout_label="QWERTY"
    layout_class="qwerty"
    ;;
  *)
    layout_icon="C"
    layout_label="Colemak-DH"
    layout_class="colemakdh"
    ;;
esac

text="${layout_icon} ${lang_icon}"
tooltip="Layout: ${layout_label}\nLanguage: ${lang}\nLeft-click: toggle layout\nRight-click: actions menu"
class="${layout_class} ${lang_class}"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$text" "$tooltip" "$class"
