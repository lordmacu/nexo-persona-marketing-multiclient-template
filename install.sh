#!/usr/bin/env bash
# Legacy v1 installer for marketing-multi. Operators on
# nexo-rs ≥ 0.1.6 should prefer:
#   nexo persona install lordmacu/nexo-persona-marketing-multiclient-template

set -euo pipefail

CONFIG_DIR="${HOME}/.nexo"
DRY_RUN=0
REINSTALL=0

usage() {
    cat <<EOF
Usage: $0 [--config-dir PATH] [--dry-run] [--reinstall]
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --config-dir) CONFIG_DIR="$2"; shift 2 ;;
        --dry-run)    DRY_RUN=1; shift ;;
        --reinstall)  REINSTALL=1; shift ;;
        -h|--help)    usage; exit 0 ;;
        *)            echo "unknown flag: $1" >&2; usage; exit 1 ;;
    esac
done

command -v nexo >/dev/null 2>&1 || { echo "error: nexo binary not on PATH" >&2; exit 1; }
echo "✓ nexo binary: $(nexo --version 2>/dev/null | awk '{print $NF}')"

mkdir -p "${CONFIG_DIR}/agents.d"

dst="${CONFIG_DIR}/agents.d/marketing-multi.yaml"
if [ -f "${dst}" ] && [ "${REINSTALL}" -eq 0 ]; then
    echo "→ ${dst} already exists; pass --reinstall to overwrite. Skipping."
else
    if [ "${DRY_RUN}" -eq 1 ]; then
        echo "[dry-run] cp agents.d/marketing-multi.yaml ${dst}"
    else
        cp agents.d/marketing-multi.yaml "${dst}"
        echo "✓ wrote ${dst}"
    fi
fi

for d in marketing_acme_intake marketing_bravo_retention marketing_charlie_exec; do
    target="${CONFIG_DIR}/data/workspace/${d}"
    if [ ! -d "${target}/.seeded" ] || [ "${REINSTALL}" -eq 1 ]; then
        if [ "${DRY_RUN}" -eq 1 ]; then
            echo "[dry-run] seed ${target}/"
        else
            mkdir -p "${target}"
            cp -r "data/workspace/${d}/." "${target}/"
            touch "${target}/.seeded"
            echo "✓ seeded ${target}/"
        fi
    fi
done

echo
echo "Next steps:"
echo "  1. Open ${dst} and rename agent ids to your real client names."
echo "  2. Edit each system_prompt with your real classification rules."
echo "  3. Configure matching marketing plugin instances in"
echo "     ${CONFIG_DIR}/plugins/<channel>.yaml (whatsapp/telegram/email)."
echo "  4. Restart: nexo daemon"
echo
echo "Done."
