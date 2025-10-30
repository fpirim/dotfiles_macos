#!/usr/bin/env zsh

# Tailscale Setup
# Automatically detects if this is first machine (export) or additional machine (import)

SCRIPT_DIR="${0:A:h}"
GOOGLE_DRIVE_CONFIG="$HOME/Google Drive/My Drive/private/configs/tailscale.config.yml"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "${BLUE}Tailscale Setup${NC}"
echo ""

# Check if Google Drive config exists
if [[ -f "$GOOGLE_DRIVE_CONFIG" ]]; then
    # Import mode - configuration exists in Google Drive
    echo "Configuration found in Google Drive"
    echo "Importing configuration..."
    echo ""
    "${SCRIPT_DIR}/scripts/tailscale_config.zsh" import
else
    echo "No configuration found in Google Drive, skipping import."
fi
