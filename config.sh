#!/usr/bin/env bash
#
# GoDaddy Dynamic DNS Updater
# 
# This script automatically updates a GoDaddy DNS A record with your current public IP address.
# Useful for maintaining DNS records when you have a dynamic IP address.
#
# Requirements:
#   - curl
#   - jq (JSON processor)
#
# Setup:
#   1. Get your GoDaddy API key and secret from: https://developer.godaddy.com/keys
#   2. Update the configuration variables below
#   3. Make executable: chmod +x godaddy-ddns-update.sh
#   4. (Optional) Add to crontab for automatic updates: */5 * * * * /path/to/godaddy-ddns-update.sh
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

DOMAIN="stallion-ai.in"          # Your domain name
HOST="server"                     # Subdomain host ('wg' => wg.example.com, '@' for root)
KEY="eo1tuNXsuQpJ_6AnR2H9qs8dwmEoo54Y9mW"        # Your GoDaddy API key
SECRET="28A9dqXNaNS4UZ1hk81rQF"  # Your GoDaddy API secret
TTL=600                       # DNS record TTL (minimum 600 seconds for GoDaddy)

# ============================================================================
# Get Current Public IP
# ============================================================================

PUBLIC_IP="$(curl -fsS https://ifconfig.co)"

if [ -z "$PUBLIC_IP" ]; then
    echo "ERROR: Cannot detect public IP address" >&2
    exit 1
fi

# ============================================================================
# Check Current DNS Record
# ============================================================================

REC_JSON="$(curl -fsS \
    -H "Authorization: sso-key $KEY:$SECRET" \
    "https://api.godaddy.com/v1/domains/$DOMAIN/records/A/$HOST")"

CURR_IP="$(echo "$REC_JSON" | jq -r '.[0].data // empty')"

# ============================================================================
# Update DNS Record if Changed
# ============================================================================

if [ "$PUBLIC_IP" != "$CURR_IP" ]; then
    curl -fsS -X PUT \
        -H "Authorization: sso-key $KEY:$SECRET" \
        -H "Content-Type: application/json" \
        "https://api.godaddy.com/v1/domains/$DOMAIN/records/A/$HOST" \
        -d "[{\"data\":\"$PUBLIC_IP\",\"ttl\":$TTL}]"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Updated $HOST.$DOMAIN to $PUBLIC_IP"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No change needed (current IP: $PUBLIC_IP)"
fi