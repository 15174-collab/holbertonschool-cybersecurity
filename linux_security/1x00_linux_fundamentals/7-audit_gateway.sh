TARGET_USER="${1:-auditor}"

cat << EOF > "$WRAPPER"
#!/bin/bash
cat "$TARGET"
EOF

chown root:root "$WRAPPER"
chmod 755 "$WRAPPER"

echo "$TARGET_USER ALL=(root) NOPASSWD: $WRAPPER" > /etc/sudoers.d/audit-gateway
chmod 440 /etc/sudoers.d/audit-gateway
