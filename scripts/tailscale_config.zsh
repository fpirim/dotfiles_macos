#!/usr/bin/env zsh

# Tailscale Configuration Manager
# Handles export/import of Tailscale configuration via Google Drive

GOOGLE_DRIVE_PATH="$HOME/Google Drive/My Drive/dotfiles-private"
CONFIG_FILE="tailscale.config.yml"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo "${GREEN}✓${NC} $1"; }
print_error() { echo "${RED}✗${NC} $1"; }
print_info() { echo "${BLUE}ℹ${NC} $1"; }
print_warning() { echo "${YELLOW}⚠${NC} $1"; }

# Export configuration to YAML
export_config() {
    local output_path="${GOOGLE_DRIVE_PATH}/${CONFIG_FILE}"

    print_info "Exporting Tailscale configuration..."

    # Check if Tailscale is available
    if ! command -v tailscale &> /dev/null; then
        print_error "Tailscale not installed"
        return 1
    fi

    # Get current preferences
    local prefs=$(tailscale debug prefs 2>&1)
    if [[ $? -ne 0 ]]; then
        print_error "Failed to read Tailscale preferences"
        return 1
    fi

    # Extract values
    local control_url=$(echo "$prefs" | grep '"ControlURL"' | sed 's/.*"ControlURL": "\(.*\)".*/\1/')
    local exit_node_id=$(echo "$prefs" | grep '"ExitNodeID"' | sed 's/.*"ExitNodeID": "\(.*\)".*/\1/' | tr -d '"')
    local route_all=$(echo "$prefs" | grep '"RouteAll"' | sed 's/.*"RouteAll": \(.*\),/\1/')
    local corp_dns=$(echo "$prefs" | grep '"CorpDNS"' | sed 's/.*"CorpDNS": \(.*\),/\1/')
    local run_ssh=$(echo "$prefs" | grep '"RunSSH"' | sed 's/.*"RunSSH": \(.*\),/\1/')
    local exit_node_allow_lan=$(echo "$prefs" | grep '"ExitNodeAllowLANAccess"' | sed 's/.*"ExitNodeAllowLANAccess": \(.*\),/\1/')

    # Convert booleans
    [[ "$route_all" == "true" ]] && local accept_routes="true" || local accept_routes="false"
    [[ "$corp_dns" == "true" ]] && local accept_dns="true" || local accept_dns="false"
    [[ "$run_ssh" == "true" ]] && local enable_ssh="true" || local enable_ssh="false"
    [[ "$exit_node_allow_lan" == "true" ]] && local allow_lan="true" || local allow_lan="false"

    # Ensure Google Drive directory exists
    mkdir -p "$GOOGLE_DRIVE_PATH"

    # Create YAML file
    cat > "$output_path" << EOF
# Tailscale Configuration
# Generated: $(date +"%Y-%m-%d %H:%M:%S")
# Machine: $(scutil --get ComputerName 2>/dev/null || hostname)

control_server:
  url: "${control_url}"

network:
  accept_routes: ${accept_routes}
  accept_dns: ${accept_dns}
  exit_node:
    id: "${exit_node_id}"
    allow_lan_access: ${allow_lan}

services:
  ssh_enabled: ${enable_ssh}

machine:
  hostname: "auto"
EOF

    print_success "Configuration exported to: ${output_path}"
    return 0
}

# Import configuration from YAML
import_config() {
    local config_path="${GOOGLE_DRIVE_PATH}/${CONFIG_FILE}"

    print_info "Importing Tailscale configuration..."

    # Wait for Google Drive and config file
    local max_wait=300
    local waited=0

    while [[ ! -f "$config_path" ]]; do
        if [[ $waited -ge $max_wait ]]; then
            print_error "Configuration file not found: ${config_path}"
            print_info "Please export config from another machine first"
            return 1
        fi

        if [[ $waited -eq 0 ]]; then
            print_warning "Waiting for configuration file..."
        elif [[ $((waited % 30)) -eq 0 ]]; then
            echo "  Still waiting... (${waited}s/${max_wait}s)"
        fi

        sleep 5
        ((waited += 5))
    done

    print_success "Configuration file found"

    # Check if yq is available
    if ! command -v yq &> /dev/null; then
        print_warning "yq not found, installing..."
        brew install yq
    fi

    # Parse YAML
    local control_url=$(yq eval '.control_server.url' "$config_path")
    local accept_routes=$(yq eval '.network.accept_routes' "$config_path")
    local accept_dns=$(yq eval '.network.accept_dns' "$config_path")
    local exit_node_id=$(yq eval '.network.exit_node.id' "$config_path")
    local allow_lan=$(yq eval '.network.exit_node.allow_lan_access' "$config_path")
    local ssh_enabled=$(yq eval '.services.ssh_enabled' "$config_path")
    local hostname_setting=$(yq eval '.machine.hostname' "$config_path")

    # Display configuration
    echo ""
    echo "Configuration to apply:"
    echo "  Control Server: ${control_url}"
    [[ -n "$exit_node_id" ]] && [[ "$exit_node_id" != "null" ]] && echo "  Exit Node: ${exit_node_id}"
    echo "  Accept Routes: ${accept_routes}"
    echo "  Accept DNS: ${accept_dns}"
    echo "  SSH: ${ssh_enabled}"
    echo ""

    # Check if Tailscale is running
    if ! tailscale status &> /dev/null; then
        print_warning "Tailscale is not running"
        echo ""
        if [[ "$control_url" != "https://controlplane.tailscale.com" ]] && [[ -n "$control_url" ]]; then
            echo "To authenticate with Headscale, run:"
            echo "  tailscale up"
        else
            echo "To authenticate with Tailscale, run:"
            echo "  open /Applications/Tailscale.app"
        fi
        return 0
    fi

    # Build and execute tailscale set command
    local cmd="tailscale set"

    [[ "$accept_routes" == "true" ]] && cmd="${cmd} --accept-routes"
    cmd="${cmd} --accept-dns=${accept_dns}"
    [[ "$ssh_enabled" == "true" ]] && cmd="${cmd} --ssh"

    if [[ -n "$exit_node_id" ]] && [[ "$exit_node_id" != "null" ]] && [[ "$exit_node_id" != '""' ]]; then
        cmd="${cmd} --exit-node=${exit_node_id}"
        [[ "$allow_lan" == "true" ]] && cmd="${cmd} --exit-node-allow-lan-access=true"
    fi

    if [[ "$hostname_setting" == "auto" ]]; then
        local hostname=$(scutil --get ComputerName | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        cmd="${cmd} --hostname=${hostname}"
    fi

    # Execute
    eval "$cmd"

    if [[ $? -eq 0 ]]; then
        print_success "Tailscale configuration applied"
        return 0
    else
        print_error "Failed to apply configuration"
        return 1
    fi
}

# Main
case "${1:-}" in
    export)
        export_config
        ;;
    import)
        import_config
        ;;
    *)
        echo "Usage: $0 {export|import}"
        echo ""
        echo "Commands:"
        echo "  export  - Export current Tailscale config to Google Drive"
        echo "  import  - Import Tailscale config from Google Drive"
        exit 1
        ;;
esac
