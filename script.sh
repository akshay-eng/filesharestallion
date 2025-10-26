mkdir -p /opt/duckdns
cat >/opt/duckdns/update.sh <<'EOF'
#!/bin/sh
curl -fsS "https://www.duckdns.org/update?domains=stallion-ai&token=3008307a-5070-47b8-945d-fd6467aa81e0
&ip=" \
  >>/var/log/duckdns.log 2>&1
EOF
chmod +x /opt/duckdns/update.sh
echo '*/5 * * * * root /opt/duckdns/update.sh' >/etc/cron.d/duckdns
systemctl restart cron