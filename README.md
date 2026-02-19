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
