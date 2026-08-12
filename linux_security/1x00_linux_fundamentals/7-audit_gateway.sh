#!/bin/bash

# 1. Définition explicite des variables requises
TARGET_USER="auditor"
WRAPPER="/usr/local/bin/audit-read-secret"

# 2. Création du wrapper avec le chemin du fichier cible en dur
cat << 'EOF' > "$WRAPPER"
#!/bin/bash
cat "/var/www/html/secret_config.php"
EOF

# 3. Assignation des droits et du propriétaire root
chown root:root "$WRAPPER"
chmod 755 "$WRAPPER"

# 4. Configuration de la règle sudoers dédiée
echo "$TARGET_USER ALL=(root) NOPASSWD: $WRAPPER" > /etc/sudoers.d/audit-gateway
chmod 440 /etc/sudoers.d/audit-gateway
