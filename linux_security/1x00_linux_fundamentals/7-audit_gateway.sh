#!/bin/bash
# Déploie un accès root restreint en lecture seule sur un fichier unique,
# via un wrapper figé + une règle sudoers nominative.
# Usage : sudo ./deploy-audit-access.sh <utilisateur>

set -euo pipefail

readonly WRAPPER="/usr/local/bin/audit-read-secret"
readonly TARGET="/var/www/html/secret_config.php"
readonly SUDOERS_DIR="/etc/sudoers.d"

if [[ $EUID -ne 0 ]]; then
    echo "Erreur : ce script doit être exécuté en root (sudo)." >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage : $0 <utilisateur>" >&2
    exit 1
fi

readonly AUDITOR="$1"

if ! id "$AUDITOR" &>/dev/null; then
    echo "Erreur : l'utilisateur '$AUDITOR' n'existe pas." >&2
    exit 1
fi

# --- 1. Déploiement du wrapper ---------------------------------------------
# Chemin cible en dur, aucun argument utilisateur exploité : empêche
# toute lecture de fichier arbitraire via ce binaire.

install -m 750 -o root -g root /dev/stdin "$WRAPPER" <<'WRAPPER_EOF'
#!/bin/bash
set -euo pipefail
readonly TARGET="/var/www/html/secret_config.php"
if [[ ! -f "$TARGET" ]]; then
    echo "Erreur : fichier cible introuvable." >&2
    exit 1
fi
exec /bin/cat -- "$TARGET"
WRAPPER_EOF

echo "OK : wrapper installé -> $WRAPPER (root:root, 750)"

# --- 2. Autorisation sudo nominative ---------------------------------------
# Fichier dédié par utilisateur, validé avant installation pour ne jamais
# risquer de casser sudo globalement.

readonly SUDOERS_FILE="${SUDOERS_DIR}/audit-read-secret-${AUDITOR}"
readonly TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

cat > "$TMP_FILE" << RULE
# Généré le $(date -Is) — accès nominatif en lecture au wrapper d'audit
${AUDITOR} ALL=(root) NOPASSWD: ${WRAPPER}
RULE

if ! visudo -c -f "$TMP_FILE" &>/dev/null; then
    echo "Erreur : syntaxe sudoers invalide, rien n'a été installé." >&2
    exit 1
fi

install -m 440 -o root -g root "$TMP_FILE" "$SUDOERS_FILE"
echo "OK : ${AUDITOR} peut exécuter '${WRAPPER}' via sudo, sans mot de passe."
echo "Règle installée dans : ${SUDOERS_FILE}"
