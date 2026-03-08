# Chezmoi Dotfiles

macOS-only chezmoi dotfiles repo for user `maormeno`. Single-machine bootstrap via `.setup.sh`, daily sync via `chezmoi update`.

## Project structure

```
.setup.sh                          # Bootstrap entrypoint (bash, 255 lines)
.chezmoi.toml.tmpl                 # Chezmoi config template (email, name)
.chezmoiignore                     # Excludes README, LICENSE, .setup.sh, .git, .github

dot_zshrc                          # Main shell config (~/.zshrc)
dot_dotfiles/                      # Shell fragments loaded by zshrc
  dot_aliases                      #   Safe defaults, navigation, readability
  dot_exports                      #   PATH, editors, locale, XDG
  dot_functions                    #   mcd(), zipf(), tsline(), tsrun()
  dot_extra                        #   Late-load integrations (fzf, zoxide, atuin, starship, plugins)
  dot_languages                    #   fnm initialization

dot_Brewfile.essentials            # Core packages (zsh, duti, dockutil, fonts, ghostty)
dot_Brewfile.nice-cli              # CLI tools (git, bat, eza, fzf, atuin, fnm, uv, starship, zoxide)

dot_config/
  git/{config,ignore}              # Git identity + delta pager
  starship/starship.toml           # Prompt config
  ghostty/config                   # Terminal config

Library/Application Support/Cursor/User/
  settings.json                    # IDE settings (100+ indexed sections)
  keybindings.json                 # IDE keybindings (7 indexed sections)

run_onchange_before_*.sh.tmpl      # Brew reconciliation, Cursor extensions (re-run on change)
run_once_after_*.sh.tmpl           # One-time: macOS defaults, default apps, Node.js, Codex
```

## Chezmoi conventions

- `dot_*` prefix becomes `.` in `$HOME` (e.g. `dot_zshrc` -> `~/.zshrc`)
- `run_once_*` scripts execute once per machine; `run_onchange_*` re-run when tracked content changes
- Numeric prefixes on hooks control order: `10_` (essentials brew), `20_` (cli brew), `30_` (cursor extensions)
- Templates use Go template syntax: `{{- if eq .chezmoi.os "darwin" -}}`, `{{ include "file" | sha256sum }}`
- `.chezmoiignore` keeps repo-only files (README, LICENSE, .setup.sh) out of `$HOME`

## Code style

- All shell scripts use `set -euo pipefail` (strict mode)
- Scripts must be idempotent (safe to re-run)
- Use `command -v tool >/dev/null 2>&1` for tool existence checks
- Safe file sourcing: `if [[ -r "$file" && -f "$file" ]]; then source "$file"; fi`
- Prefer Homebrew-managed plugins and tools over manual installs

## Key tools

- **Shell**: Zsh (via Homebrew at `/opt/homebrew/bin/zsh`)
- **Terminal**: Ghostty | **Prompt**: Starship | **Font**: FiraCode Nerd Font Mono
- **Editor/IDE**: Cursor (with VIM extension) | **Git pager**: Delta (side-by-side)
- **Packages**: Homebrew (`brew bundle`) | **Node.js**: fnm | **Python**: uv
- **CLI**: fzf, zoxide, atuin (local-only), eza, bat, glow
- **macOS**: duti (default apps), dockutil (dock management), Arc (browser)

## Working with this repo

- `chezmoi diff` to preview changes before applying
- `chezmoi apply` to apply changes to `$HOME`
- `chezmoi edit <target>` to edit a managed file in the source dir
- Test hook scripts with `chezmoi apply --dry-run --verbose`
- The `.chezmoiignore` file must be updated when adding repo-only files
- Cursor extensions are declared inline in `run_onchange_before_30_install-cursor-extensions.sh.tmpl`
- Brewfile changes trigger automatic `brew bundle` via onchange hooks
