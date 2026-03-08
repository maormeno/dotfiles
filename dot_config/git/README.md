# Git Configuration

Managed git config with support for machine-local overrides.

## Files

| File | Managed | Purpose |
|------|---------|---------|
| `config` | Yes | Default identity, delta pager, colors, editor |
| `ignore` | Yes | Global gitignore (macOS, Node, editor noise) |
| `config.local` | No | Machine-local overrides (not tracked by chezmoi) |

## Default identity

The managed `config` sets the personal default:

```ini
[user]
  name = maormeno
  email = maormeno@uc.cl
```

## Machine-local overrides

`config` includes `~/.config/git/config.local` via Git's `[include]` directive. This file is **not managed by chezmoi** and is ignored in `.chezmoiignore`.

On a work machine, create `~/.config/git/config.local`:

```ini
[user]
  name = mateo
  email = mateo@fintual.com
```

Git processes includes last-wins, so values in `config.local` override the defaults. No file is needed on personal machines — the defaults apply as-is.

## Delta pager

Diffs use [delta](https://github.com/dandavison/delta) with side-by-side mode, hyperlinks, and navigate mode. This applies to `git diff`, `git blame`, and interactive add/patch.
