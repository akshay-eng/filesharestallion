#!/usr/bin/env bash
set -euo pipefail

DOMAIN="example.com"        # <-- change
HOST="wg"                   # 'wg' => wg.example.com (use '@' for root)
KEY="YOUR_GODADDY_KEY"      # <-- change
SECRET="YOUR_GODADDY_SECRET"# <-- change
TTL=600                     # GoDaddy A-record TTL min is 600 seconds

PUBLIC_IP="$(curl -fsS https://ifconfig.co)"
[ -z "$PUBLIC_IP" ] && { echo "Cannot detect public IP"; exit 1; }

# Read current A record
REC_JSON="$(curl -fsS -H "Authorization: sso-key $KEY:$SECRET" \
  "https://api.godaddy.com/v1/domains/$DOMAIN/records/A/$HOST")"
CURR_IP="$(echo "$REC_JSON" | jq -r '.[0].data // empty')"

if [ "$PUBLIC_IP" != "$CURR_IP" ]; then
  curl -fsS -X PUT \
    -H "Authorization: sso-key $KEY:$SECRET" \
    -H "Content-Type: application/json" \
    "https://api.godaddy.com/v1/domains/$DOMAIN/records/A/$HOST" \
    -d "[{\"data\":\"$PUBLIC_IP\",\"ttl\":$TTL}]"
  echo "$(date) Updated $HOST.$DOMAIN to $PUBLIC_IP"
else
  echo "$(date) No change ($PUBLIC_IP)"
fi