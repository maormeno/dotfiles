# dotfiles

Minimal, macOS-only dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Goals

- Clarity: one bootstrap entrypoint, one daily command.
- Correctness: declarative package/state management.
- Conciseness: minimal moving parts, no duplicated setup flows.

## Scope

- Supported OS: macOS.
- Canonical bootstrap entrypoint: `.setup.sh`.
- Daily sync command: `chezmoi update`.
- No encrypted secrets workflow in v1.

## Quick Start

Run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/maormeno/dotfiles/main/.setup.sh) && exec zsh -l
```

Alternative:

```bash
(curl -fsSL https://raw.githubusercontent.com/maormeno/dotfiles/main/.setup.sh | bash) && exec zsh -l
```

## Operational Model

### 1) Bootstrap (`.setup.sh`)

`.setup.sh` is the only supported initial entrypoint.

It does this in order:

1. Verifies macOS.
2. Ensures Xcode Command Line Tools are installed (prompted).
3. Ensures Homebrew is installed (prompted).
4. Ensures git is installed (prompted).
5. Ensures chezmoi is installed (prompted).
6. Runs one of:
   - `chezmoi init --apply maormeno/dotfiles` (first machine setup)
   - `chezmoi update` (already initialized machine)

Bootstrap runs in a child `bash` process. It cannot replace your current terminal process; open a new tab or run `exec zsh -l` after completion.

### 2) Daily sync (`chezmoi update`)

Use this for normal ongoing maintenance:

```bash
chezmoi update
```

`chezmoi update` pulls the repo and applies changes. It does **not** re-prompt prerequisite installers.

### 3) Hook behavior

- `run_once_*` scripts: execute once per machine state (unless state is reset).
- `run_onchange_*` scripts: execute only when tracked input content changes.

In this repo that means:

- Package reconciliation runs when Brewfile declarations change.
- One-time defaults (system/app preferences, Codex installation) do not run every update.

## Package Management

Two package sets are declared in-repo:

- `dot_Brewfile.essentials`
- `dot_Brewfile.nice-cli`

Applied via:

- `run_onchange_before_10_brew-essentials-packages.sh.tmpl`
- `run_onchange_before_20_brew-nice-cli-packages.sh.tmpl`

Both scripts call `brew bundle` from managed content, so package state is declarative and tied to these files.

## What Is Managed

### Shell and CLI UX

- `dot_zshrc`
- `dot_dotfiles/` (`.aliases`, `.exports`, `.functions`, `.extra`)
- `dot_config/starship/starship.toml`

### Terminal and Git visuals

- `dot_config/ghostty/config`
- `dot_config/git/config`

### Cursor config (managed through `Library/...` in source state)

Source-state files in this repo:

- `Library/Application Support/Cursor/User/settings.json`
- `Library/Application Support/Cursor/User/keybindings.json`
- `Library/Application Support/Cursor/User/snippets/README.md`

Applied target files in your home directory:

- `~/Library/Application Support/Cursor/User/settings.json`
- `~/Library/Application Support/Cursor/User/keybindings.json`
- `~/Library/Application Support/Cursor/User/snippets/README.md`

### One-time setup hooks

- `run_once_after_setup-codex.sh.tmpl`
- `run_once_after_setup-default-apps.sh.tmpl`
- `run_once_after_setup-system-settings.sh.tmpl`

## Arc, Cursor, and Codex

### System defaults

`run_once_after_setup-system-settings.sh.tmpl` sets:

1. Finder path bar visible.
2. Finder sidebar visible.
3. Scrollbars always visible (`AppleShowScrollBars = Always`).
4. Dock reset to a minimal app set: Finder (system-fixed), Ghostty, Arc.
5. Scrolling behavior is manual (not automated by setup hooks).
6. Keyboard/input-source behavior is manual (not automated by setup hooks).

### Arc/Cursor defaults

`run_once_after_setup-default-apps.sh.tmpl` sets:

1. Arc as default for URL schemes `http` and `https` (verified with `duti -d`).
2. Cursor as default for common code/text file types.

Git `core.editor` is managed declaratively in `dot_config/git/config`.

### Codex installation

`run_once_after_setup-codex.sh.tmpl` installs:

- Codex CLI (`codex` cask)
- Codex app (`codex-app` cask)
- Zsh completion at `~/.zsh/completions/_codex`

Then run:

```bash
codex login
```

### Cursor tweak shortcuts

```bash
cursorcfg
cursor-settings
cursor-keys
```

### Terminal UX defaults (Ghostty + Zsh)

- Ghostty uses the custom dark theme from `dot_config/ghostty/themes/Squirrelsong Dark Deep Purple`.
- Ghostty explicitly pins `command = /opt/homebrew/bin/zsh` for deterministic shell startup.
- Ghostty explicitly pins `shell-integration = zsh` for deterministic shell integration behavior.
- Ghostty pins `font-family = "FiraCode Nerd Font Mono"` for reliable prompt/file-icon glyph rendering.
- Ghostty enables `window-save-state = always` to restore window/tab/split layout after normal exits.
- Ghostty state restore is layout-level only; it does not resume running terminal processes after close.
- FZF owns `Ctrl-R` history search via `eval "$(fzf --zsh)"`.
- FZF default scope is wide/fast: hidden and ignored paths from the current directory, while skipping heavy directories (`.git,node_modules,.venv,venv,dist,build,.next,.cache,__pycache__,target`).
- zoxide is enabled for directory jumping with `z <dir-fragment>`.
- Atuin is enabled in local-only mode (no sync setup) and does not hijack `Ctrl-R` (`ATUIN_NOBIND=true`).
- Starship path context uses native 3-segment truncation (`.../dir1/dir2/dir3`) and color-shifts in git repos.
- Starship Python signal is compact (`pyX.Y (venv)`).
- Command duration appears as a right-aligned pre-prompt line in mixed format (`532ms`, `1s234ms`), and shows `(output error code: !<code>)` on failures.
- `ls` is icon-rich and dirs-first; use `ll` and `la` for detailed views.
- Use `tsrun <cmd>` or `... | tsline` for per-line output timestamps (`HH:MM:SS.mmm`) when needed.
- Use `hts` for ISO-style command history timestamps (`fc -li 1`).

## Git + SSH (Custom Key Name)

Follow GitHub's Git setup guide first:
[Set up Git](https://docs.github.com/en/get-started/git-basics/set-up-git#setting-up-git)

Use SSH and always use a custom key filename.

1. Generate key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted, set a custom path:

```text
Enter file in which to save the key (/Users/mateo/.ssh/id_ed25519): /Users/mateo/.ssh/maormeno_git_key
```

2. Add key to agent:

```bash
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/maormeno_git_key
```

3. Copy public key and add it to GitHub:

```bash
pbcopy < ~/.ssh/maormeno_git_key.pub
```

4. Use the same key path in `~/.ssh/config`:

```sshconfig
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/maormeno_git_key
  IdentitiesOnly yes
```

Use the same basename everywhere (`maormeno_git_key`): key file, `.pub`, and `IdentityFile`.

## Common Commands

```bash
chezmoi diff
chezmoi apply
chezmoi edit ~/.zshrc
chezmoi edit "$HOME/Library/Application Support/Cursor/User/settings.json"
chezmoi edit "$HOME/Library/Application Support/Cursor/User/keybindings.json"
```

Manually rerun one-time hooks when needed:

```bash
chezmoi execute-template < run_once_after_setup-codex.sh.tmpl | bash
chezmoi execute-template < run_once_after_setup-default-apps.sh.tmpl | bash
chezmoi execute-template < run_once_after_setup-system-settings.sh.tmpl | bash
```

## Troubleshooting

### `Error: No Brewfile found`

This indicates an old package hook version. Pull latest dotfiles and rerun:

```bash
chezmoi update
```

### `duti`/LaunchServices handler warnings

Defaults may partially apply if macOS rejects a specific mapping. Current setup checks URL-scheme handlers (`http`/`https`) with `duti -d` and reports the active bundle ids.

`duti -x http` / `duti -x https` checks file extension handlers (`.http`, `.https`), which are different from browser URL-scheme defaults used when tools open web links.

### `zsh compinit: insecure directories`

Setup hooks and shell startup try to auto-fix this by removing group/world write bits from Homebrew completion parent directories.

If you still see it, run:

```bash
compaudit
compaudit | while read -r path; do chmod go-w "$path"; done
```

## Repository Notes

These stay repo-local (not applied to `$HOME`) via `.chezmoiignore`:

- `README.md`
- `LICENSE`
- `.setup.sh`
- `.git/`
- `.github/`
- `reference-dotfiles-repo/`

## License

MIT

## References and Valuable Reads

- This repo (source of truth): [maormeno/dotfiles](https://github.com/maormeno/dotfiles)
- Reference inspiration: [carloscuesta/dotfiles](https://github.com/carloscuesta/dotfiles?tab=readme-ov-file)
- Chezmoi homepage/docs: [chezmoi.io](https://www.chezmoi.io/)
- Chezmoi scripts (`run_once_`, `run_onchange_`): [Use scripts to perform actions](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- Homebrew install docs: [brew.sh](https://brew.sh/)
- Homebrew Bundle docs (`brew bundle` / Brewfile): [Brew Bundle and Brewfile](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- Xcode Command Line Tools context: [Apple Developer - Xcode resources](https://developer.apple.com/xcode/resources/)
- Git setup guide: [GitHub Docs - Set up Git](https://docs.github.com/en/get-started/git-basics/set-up-git#setting-up-git)
- SSH with GitHub: [GitHub Docs - Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- Generate SSH keys: [GitHub Docs - Generating a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- Add SSH key to account: [GitHub Docs - Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- Ghostty docs: [ghostty.org/docs](https://ghostty.org/docs)
- Starship config docs: [starship.rs/config](https://starship.rs/config/)
- Git Delta docs/repo: [dandavison/delta](https://github.com/dandavison/delta)
- Arc docs/help center: [resources.arc.net](https://resources.arc.net/hc/en-us)
- Cursor docs: [docs.cursor.com](https://docs.cursor.com/)
- `duti` (default app handler tool): [Homebrew Formula - duti](https://formulae.brew.sh/formula/duti)
- Codex project/repo: [openai/codex](https://github.com/openai/codex)
- Codex getting started: [OpenAI Help - Codex CLI Getting Started](https://help.openai.com/en/articles/11096431-openai-codex-ci-getting-started)
