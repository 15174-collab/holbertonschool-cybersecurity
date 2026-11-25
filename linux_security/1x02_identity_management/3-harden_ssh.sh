#!/bin/bash
#!/bin/bash
sed -i -E 's/^#?\s*PermitRootLogin\s.*/PermitRootLogin no/' "$1"
sed -i -E 's/^#?\s*PasswordAuthentication\s.*/PasswordAuthentication no/' "$1"
sed -i -E 's/^#?\s*PubkeyAuthentication\s.*/PubkeyAuthentication yes/' "$1"

grep -q '^PermitRootLogin no' "$1" || echo 'PermitRootLogin no' >> "$1"
grep -q '^PasswordAuthentication no' "$1" || echo 'PasswordAuthentication no' >> "$1"
grep -q '^PubkeyAuthentication yes' "$1" || echo 'PubkeyAuthentication yes' >> "$1"

if sshd -t -f "$1"; then
    systemctl reload ssh 2>/dev/null || service ssh reload
else
    echo "Invalid sshd configuration, reload aborted" >&2
    exit 1
fi
