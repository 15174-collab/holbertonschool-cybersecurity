 #!/bin/bash
set -euo pipefail

# Définition des variables de l'exercice
readonly WRAPPER="/usr/local/bin/audit-read-secret"
readonly TARGET="/var/www/html/secret_config.php"
readonly SUDOERS_DIR="/etc/sudoers.d"

# Récupération de l'utilisateur passé en paramètre ($1), sinon "auditor" par défaut
TARGET_USER="${1:-auditor}"

# 1. Création du wrapper figé (lecture seule, pas de chemin contrôlé par l'utilisateur)
cat << 'EOF' > "$WRAPPER"
#!/bin/bash
cat /var/www/html/secret_config.php
EOF

# Sécurisation des permissions du wrapper (appartenance à root et exécutable)
chown root:root "$WRAPPER"
chmod 755 "$WRAPPER"

# 2. Création de la règle d'accès nominative sans mot de passe
# Note : On écrit directement dans le sous-dossier de configuration
echo "$TARGET_USER ALL=(root) NOPASSWD: $WRAPPER" > "$SUDOERS_DIR/audit-gateway"
chmod 440 "$SUDOERS_DIR/audit-gateway"
