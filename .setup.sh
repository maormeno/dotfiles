#!/usr/bin/env bash
set -euo pipefail

# Private dotfiles repo over SSH.
DOTFILES_REPO="git@github.com:maormeno/dotfiles.git"
SUDO_KEEPALIVE_PID=""

# Load Homebrew into PATH/environment when installed outside current shell PATH.
load_homebrew_env() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi

  if [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi

  return 1
}

# Prompt helper used for prerequisite installation confirmations.
prompt_yes_no() {
  local message="$1"
  local reply=""

  while true; do
    if [[ -t 0 ]]; then
      read -r -p "${message} [y/N]: " reply
    elif [[ -r /dev/tty ]]; then
      read -r -p "${message} [y/N]: " reply </dev/tty
    else
      echo "No interactive terminal available for prompt: ${message}" >&2
      return 1
    fi

    case "${reply}" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo]|"") return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

# Guardrail: this setup targets macOS only.
ensure_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This setup is supported on macOS only."
    exit 1
  fi
}

cleanup_sudo_session() {
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
  fi
}

# Ask for sudo once up-front and keep it alive for the script duration.
ensure_sudo_session() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "Run this script as your normal user, not root."
    echo "It will request sudo when needed."
    exit 1
  fi

  if ! sudo -v; then
    echo "sudo authentication failed."
    exit 1
  fi

  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPALIVE_PID="$!"

  trap cleanup_sudo_session EXIT
}

# Ensure Xcode CLI tools exist because many build/install steps depend on them.
ensure_xcode_clt() {
  local waited=0
  local timeout=1800

  if xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools already installed."
    return
  fi

  echo "Xcode Command Line Tools are required."
  if ! prompt_yes_no "Install Xcode Command Line Tools now?"; then
    echo "Setup cancelled: Xcode Command Line Tools are required."
    exit 1
  fi

  echo "Starting Xcode Command Line Tools installation..."
  if ! xcode-select --install >/dev/null 2>&1; then
    echo "Install command may already be running. Waiting for completion..."
  fi

  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
    waited=$((waited + 5))
    if (( waited >= timeout )); then
      echo "Timed out waiting for Xcode Command Line Tools installation."
      echo "Finish the install and re-run .setup.sh."
      exit 1
    fi
  done

  echo "Xcode Command Line Tools installed."
}

# Ensure Homebrew exists for package and chezmoi installation.
ensure_homebrew() {
  if load_homebrew_env; then
    echo "Homebrew already installed."
    return
  fi

  echo "Homebrew is required."
  if ! prompt_yes_no "Install Homebrew now?"; then
    echo "Setup cancelled: Homebrew is required."
    exit 1
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if ! load_homebrew_env; then
    echo "Homebrew installation finished but brew was not found in PATH."
    exit 1
  fi

  echo "Homebrew installed."
}

# Ensure git is available for chezmoi operations.
ensure_git() {
  if command -v git >/dev/null 2>&1; then
    echo "git already installed."
    return
  fi

  echo "git is required."
  if ! prompt_yes_no "Install git now?"; then
    echo "Setup cancelled: git is required."
    exit 1
  fi

  brew install git
  echo "git installed."
}

# Ensure chezmoi is installed before init/update operations.
ensure_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    echo "chezmoi already installed."
    return
  fi

  echo "chezmoi is required."
  if ! prompt_yes_no "Install chezmoi now?"; then
    echo "Setup cancelled: chezmoi is required."
    exit 1
  fi

  brew install chezmoi
  echo "chezmoi installed."
}

# Verify SSH access to the private dotfiles repository.
ensure_repo_access() {
  echo "Checking SSH access to ${DOTFILES_REPO}..."
  if git ls-remote "${DOTFILES_REPO}" >/dev/null 2>&1; then
    echo "SSH access confirmed."
    return
  fi

  echo "Cannot access ${DOTFILES_REPO} via SSH."
  echo "Ensure your GitHub SSH key is configured and loaded, then re-run."
  exit 1
}

# Initialize dotfiles on first run, otherwise update existing setup.
run_chezmoi() {
  local no_tty=0
  if [[ ! -t 0 ]]; then
    no_tty=1
  fi

  if [[ -d "${HOME}/.local/share/chezmoi/.git" ]]; then
    echo "chezmoi source already initialized. Running update..."
    if (( no_tty )); then
      chezmoi update --no-tty
    else
      chezmoi update
    fi
  else
    echo "Initializing chezmoi from ${DOTFILES_REPO}..."
    if (( no_tty )); then
      chezmoi init --apply --no-tty "${DOTFILES_REPO}"
    else
      chezmoi init --apply "${DOTFILES_REPO}"
    fi
  fi
}

# Main setup flow in dependency order.
echo "Setting up dotfiles..."
ensure_macos
ensure_sudo_session
ensure_xcode_clt
ensure_homebrew
ensure_git
ensure_chezmoi
ensure_repo_access
run_chezmoi

echo "Done."
