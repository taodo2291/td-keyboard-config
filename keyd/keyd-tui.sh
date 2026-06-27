#!/usr/bin/env bash
# keyd-layout TUI — interactive state viewer & toggler

STATE=/run/keyd-laptop-layout
REAL_USER=ntv
REAL_UID=1000
LAYOUT_MODE=/usr/local/bin/keyd-layout-mode

fcitx_state() {
  if [ "$EUID" -eq 0 ]; then
    runuser -u "$REAL_USER" -- \
      env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
      fcitx5-remote 2>/dev/null
  else
    fcitx5-remote 2>/dev/null
  fi
}

get_state() {
  layout="$(cat "$STATE" 2>/dev/null || echo colemakdh)"
  fcitx="$(fcitx_state)"
  if [[ "$fcitx" == "1" ]]; then
    lang="vietnamese"
  else
    lang="english"
  fi
}

print_status() {
  clear
  echo "┌─────────────────────────────────────┐"
  echo "│       keyd Layout Controller        │"
  echo "├─────────────────────────────────────┤"
  printf  "│  Keyboard  :  %-22s│\n" "${layout^^}"
  printf  "│  Language  :  %-22s│\n" "${lang^^}"
  echo "├─────────────────────────────────────┤"
  case "${layout}-${lang}" in
    colemakdh-english)    mode="ColemakDH + EN  (full HRM+combos)" ;;
    colemakdh-vietnamese) mode="ColemakDH + VI  (no HRM/combos)" ;;
    qwerty-english)       mode="QWERTY + EN     (plain passthrough)" ;;
    qwerty-vietnamese)    mode="QWERTY + VI     (plain passthrough)" ;;
  esac
  printf  "│  Active    :  %-22s│\n" "$mode"
  echo "└─────────────────────────────────────┘"
  echo ""
  echo "  [1] Toggle Vietnamese  (CapsLock)"
  echo "  [2] Toggle QWERTY      (layout swap)"
  echo "  [r] Refresh"
  echo "  [q] Quit"
  echo ""
  printf "  > "
}

get_state
while true; do
  print_status
  read -r -n1 key
  echo ""
  case "$key" in
    1) sudo "$LAYOUT_MODE" toggle-vietnamese ;;
    2) sudo "$LAYOUT_MODE" toggle-qwerty ;;
    r|R) ;;
    q|Q) echo "Bye!"; exit 0 ;;
    *) echo "  Unknown key." ; sleep 0.4 ;;
  esac
  get_state
done
