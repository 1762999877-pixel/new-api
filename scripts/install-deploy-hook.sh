#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/.git/hooks/post-merge"

chmod +x "$ROOT/scripts/deploy.sh"

cat > "$HOOK" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
exec bash "$ROOT/scripts/deploy.sh" --hook
EOF

chmod +x "$HOOK"

echo "Installed git post-merge hook."
echo "From now on, 'git pull' on this machine will rebuild and restart new-api automatically."
echo ""
echo "If docker requires sudo, run once on the server:"
echo "  sudo usermod -aG docker \$USER"
echo "Then log out and log back in (or reboot)."
