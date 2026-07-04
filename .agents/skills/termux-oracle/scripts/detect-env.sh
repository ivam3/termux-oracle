#!/usr/bin/env bash
# detect-env.sh — Detecta el entorno de ejecución para la skill termux-oracle
# Uso: bash scripts/detect-env.sh
# Retorna JSON con el entorno detectado

ENV="unknown"
TERMUX_NATIVE=false
PROOT_DISTRO=false
SSH=false
IHAKLAB=false
WRAPPER_APT=false
GLIBC_REPO=false
ARCH=""

# Detectar Termux nativo
if [[ -d /data/data/com.termux/files/usr ]]; then
  TERMUX_NATIVE=true
  ENV="termux-native"
  ARCH=$(uname -m 2>/dev/null || echo "unknown")
fi

# Detectar proot-distro
if [[ -f /etc/proot-version ]] || [[ -d /data/data/com.termux/files/usr/var/lib/proot-distro ]]; then
  PROOT_DISTRO=true
  [[ "$ENV" == "unknown" ]] && ENV="proot-distro"
fi

# Detectar SSH
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CONNECTION" ]]; then
  SSH=true
fi

# Detectar i-HakLab
if command -v i-Haklab &>/dev/null || [[ -f ~/.local/bin/i-Haklab ]]; then
  IHAKLAB=true
fi

# Detectar wrapper apt
if [[ -f ~/.local/bin/apt ]]; then
  WRAPPER_APT=true
fi

# Detectar glibc-repo
if command -v apt &>/dev/null; then
  GLIBC_REPO=$(apt list --installed 2>/dev/null | grep -q "glibc-repo" && echo true || echo false)
fi

cat <<EOF
{
  "environment": "$ENV",
  "termux_native": $TERMUX_NATIVE,
  "proot_distro": $PROOT_DISTRO,
  "ssh": $SSH,
  "ihaklab_installed": $IHAKLAB,
  "wrapper_apt": $WRAPPER_APT,
  "glibc_repo": $GLIBC_REPO,
  "arch": "$ARCH",
  "prefix": "$PREFIX",
  "home": "$HOME"
}
EOF
