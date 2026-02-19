# dotfiles

Minimal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Scope

- Supported platform: macOS only.
- Canonical bootstrap entrypoint: `.setup.sh`.
- Daily sync command: `chezmoi update`.
- Package installs are declarative via `run_onchange` scripts and Brewfiles.
- No encrypted secrets workflow is included in this repository.

## Bootstrap

Run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/maormeno/dotfiles/main/.setup.sh)
```

Alternative (works too, but stdin is piped):

```bash
curl -fsSL https://raw.githubusercontent.com/maormeno/dotfiles/main/.setup.sh | bash
```

What `.setup.sh` does:

1. Checks macOS compatibility.
2. Checks Xcode Command Line Tools, Homebrew, and chezmoi.
3. Prompts before installing any missing prerequisite.
4. Runs `chezmoi init --apply maormeno/dotfiles` on first setup.
5. Runs `chezmoi update` on already-initialized setups.

## Codex Installation

Codex CLI and Codex desktop app are installed automatically on first machine setup by:
`run_once_after_setup-codex.sh.tmpl`

What it does:

1. Requires Homebrew on macOS.
2. Installs the `codex` Homebrew cask (CLI) if missing.
3. Installs the `codex-app` Homebrew cask (desktop app) if missing.
4. Generates Zsh completion at `~/.zsh/completions/_codex`.
5. Prints a reminder to run `codex login`.

Manual install/update command:

```bash
brew install --cask codex codex-app
```

Manual completion refresh command:

```bash
mkdir -p ~/.zsh/completions
codex completion zsh > ~/.zsh/completions/_codex
```

## Arc and Cursor Defaults

Default browser/IDE preferences are applied once by:
`run_once_after_setup-default-apps.sh.tmpl`

What it does:

1. Sets Arc as default browser handler for `http` and `https`.
2. Sets Cursor as default handler for common code/text file types.
3. Sets Git `core.editor` to `cursor --wait`.

Cursor tweak shortcuts (from your shell):

```bash
cursorcfg
cursor-settings
cursor-keys
```

Managed Cursor config files:

- `~/Library/Application Support/Cursor/User/settings.json`
- `~/Library/Application Support/Cursor/User/keybindings.json`
- `~/Library/Application Support/Cursor/User/snippets/`

Edit managed Cursor files with chezmoi:

```bash
chezmoi edit "$HOME/Library/Application Support/Cursor/User/settings.json"
chezmoi edit "$HOME/Library/Application Support/Cursor/User/keybindings.json"
```

If you need to re-run this manually:

```bash
chezmoi execute-template < run_once_after_setup-default-apps.sh.tmpl | bash
```

## Daily Usage

Use this command to pull latest changes and apply them:

```bash
chezmoi update
```

Use these commands for manual inspection and edits:

```bash
chezmoi diff
chezmoi apply
chezmoi edit ~/.zshrc
```

## Git and SSH Setup

Set up Git identity/config first using the official GitHub guide:
[Set up Git](https://docs.github.com/en/get-started/git-basics/set-up-git#setting-up-git)

Use SSH and always use a custom key filename (not the default `id_ed25519`).

1. Generate an SSH key.

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

At the prompt, enter a custom file path:

```text
Enter file in which to save the key (/Users/mateo/.ssh/id_ed25519): /Users/mateo/.ssh/maormeno_git_key
```

2. Add the key to your macOS SSH agent.

```bash
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/maormeno_git_key
```

3. Add the public key to GitHub.

```bash
pbcopy < ~/.ssh/maormeno_git_key.pub
```

Then paste it in GitHub `Settings` -> `SSH and GPG keys`.

4. Use the same key name in `~/.ssh/config`.

```sshconfig
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/maormeno_git_key
  IdentitiesOnly yes
```

Use the same basename (`maormeno_git_key`) in all related places:
private key path, `.pub` file, and `IdentityFile`.

You can also manage `~/.ssh/config` with chezmoi by adding a managed file in this repo.

## Package Management

This repository keeps package declarations in two files:

- `dot_Brewfile.essentials` -> `~/.Brewfile.essentials`
- `dot_Brewfile.nice-cli` -> `~/.Brewfile.nice-cli`

Package installation is triggered by:

- `run_onchange_before_10_brew-essentials-packages.sh.tmpl`
- `run_onchange_before_20_brew-nice-cli-packages.sh.tmpl`

Each script runs `brew bundle` for its Brewfile. A checksum comment in each script makes chezmoi rerun it whenever the corresponding Brewfile content changes.

## Configured Tools

- Ghostty config: `dot_config/ghostty/config` for terminal visuals and window behavior.
- Starship config: `dot_config/starship/starship.toml` for a clean prompt layout.
- Git visual config: `dot_config/git/config` (delta pager and color tuning).
- Cursor user config: `Library/Application Support/Cursor/User/` (settings, keybindings, snippets).
- Codex install hook: `run_once_after_setup-codex.sh.tmpl` for first-run CLI installation.
- Dotfile fragments: `dot_dotfiles/` (`.aliases`, `.exports`, `.functions`, `.extra`).

## Zsh Configuration

`dot_zshrc` is Homebrew-first and has no network side effects on shell startup.

- Loads fragments from `~/.dotfiles`.
- Sources Homebrew plugin files directly.
- Enables Starship when installed, with `adam1` as fallback.

## One-Time macOS Visual Defaults

`run_once_after_setup-system-settings.sh.tmpl` applies one-time visual defaults:

- Show `~/Library` in Finder.
- Auto-hide Dock.
- Finder icon view preference.
- Trackpad right-click and scroll-direction defaults.

`run_once_after_setup-default-apps.sh.tmpl` applies one-time app defaults:

- Arc as default browser for web links (`http`/`https`).
- Cursor as default IDE/file handler.

## Repository Notes

Repo-only files are excluded from apply via `.chezmoiignore`:

- `README.md`
- `LICENSE`
- `.setup.sh`
- `.github/`

## Acknowledgments

This setup was heavily informed by Carlos Cuesta's dotfiles repository:
[carloscuesta/dotfiles](https://github.com/carloscuesta/dotfiles?tab=readme-ov-file)

## License

MIT
