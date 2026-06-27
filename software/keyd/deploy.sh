#!/usr/bin/env bash
set -euo pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo ./deploy.sh)"
  exit 1
fi

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

REAL_USER=ntv
WAYBAR_CFG="/home/$REAL_USER/.config/waybar"

echo "Deploying keyd configuration..."

# 1. Clean up broken previous scripts/configs
rm -f /etc/keyd/laptop-urob.conf

# 2. Copy config
cp "$SCRIPT_DIR/laptop-urob.conf" /etc/keyd/default.conf

# 3. Copy runtime binds
mkdir -p /etc/keyd/runtime
cp "$SCRIPT_DIR/runtime/qwerty.bind" /etc/keyd/runtime/
cp "$SCRIPT_DIR/runtime/vietnamese.bind" /etc/keyd/runtime/

# 4. Install scripts and menu layout
cp "$SCRIPT_DIR/keyd-layout-mode" /usr/local/bin/
cp "$SCRIPT_DIR/keyd-waybar-module.sh" /usr/local/bin/keyd-waybar-module
cp "$SCRIPT_DIR/keyd-tui.sh"           /usr/local/bin/keyd-tui
cp "$SCRIPT_DIR/keyd-waybar-menu.xml"  /usr/local/share/keyd-waybar-menu.xml
chmod +x /usr/local/bin/keyd-layout-mode \
         /usr/local/bin/keyd-waybar-module \
         /usr/local/bin/keyd-tui
chmod 644 /usr/local/share/keyd-waybar-menu.xml

# 5. Install sudoers rule
cp "$SCRIPT_DIR/sudoers-snippet.txt" /etc/sudoers.d/keyd-layout
chmod 440 /etc/sudoers.d/keyd-layout
visudo -c -f /etc/sudoers.d/keyd-layout && echo "  ✓ /etc/sudoers.d/keyd-layout"

# 6. Automate Waybar config.jsonc
echo "── Step 6: Automate Waybar config.jsonc ──"
python3 - <<EOF
import json, sys
cfg_path = "$WAYBAR_CFG/config.jsonc"
try:
    with open(cfg_path, "r") as f:
        config = json.load(f)
    
    modified = False
    
    # Remove from modules-left if it exists
    if "custom/keyd-layout" in config.get("modules-left", []):
        config["modules-left"].remove("custom/keyd-layout")
        modified = True
        
    # Add to modules-right
    if "custom/keyd-layout" not in config.get("modules-right", []):
        if "modules-right" not in config: config["modules-right"] = []
        config["modules-right"].insert(0, "custom/keyd-layout")
        modified = True

    # Overwrite the definition to use the new native menu
    new_def = {
        "exec": "/usr/local/bin/keyd-waybar-module",
        "return-type": "json",
        "interval": "once",
        "signal": 8,
        "tooltip": True,
        "on-click": "sudo /usr/local/bin/keyd-layout-mode toggle-qwerty",
        "menu": "on-click-right",
        "menu-file": "/usr/local/share/keyd-waybar-menu.xml",
        "menu-actions": {
            "vietnamese": "sudo /usr/local/bin/keyd-layout-mode toggle-vietnamese",
            "qwerty": "sudo /usr/local/bin/keyd-layout-mode toggle-qwerty",
            "tui": "xdg-terminal-exec /usr/local/bin/keyd-tui"
        },
        "escape": True
    }
    
    if config.get("custom/keyd-layout") != new_def:
        config["custom/keyd-layout"] = new_def
        modified = True
    
    if modified:
        with open(cfg_path, "w") as f:
            json.dump(config, f, indent=2)
        print("  ✓ Injected custom/keyd-layout into config.jsonc")
    else:
        print("  ✓ config.jsonc already configured, skipping")
except Exception as e:
    print(f"  ✗ Failed to update config.jsonc: {e}", file=sys.stderr)
EOF
chown $REAL_USER:$REAL_USER "$WAYBAR_CFG/config.jsonc"

# 7. Automate Waybar CSS
echo "── Step 7: Automate Waybar CSS ──"
if ! grep -q "#custom-keyd-layout" "$WAYBAR_CFG/style.css"; then
  cat "$SCRIPT_DIR/waybar-style.css" >> "$WAYBAR_CFG/style.css"
  echo "  ✓ Appended styles to $WAYBAR_CFG/style.css"
else
  echo "  ✓ Styles already exist in $WAYBAR_CFG/style.css, skipping"
fi
chown $REAL_USER:$REAL_USER "$WAYBAR_CFG/style.css"

# 8. Reload keyd & waybar
keyd reload
runuser -u "$REAL_USER" -- bash -c "/home/$REAL_USER/.local/share/omarchy/bin/omarchy-restart-waybar 2>/dev/null || true"

echo "Deployment complete."
