# nvim

Minimal Neovim config. Runs on Linux, macOS, and Windows — the only
hard requirement is **Neovim >= 0.12** (this config uses the built-in
`vim.pack` for plugins; no plugin manager to install).

## Files

- `init.lua` — options, keymaps, plugins
- `lua/lsp.lua` — LSP keymaps + built-in completion; Haskell/HLS only when
  the tooling exists on that machine
- `nvim-pack-lock.json` — pinned plugin revisions. **Always commit this**;
  it keeps every machine on identical plugin versions.

Plugins live in nvim's data dir (outside this repo), so nothing here
needs a `.gitignore`.

## Bootstrap a new machine

1. Install Neovim >= 0.12 (`nvim --version` to check). On Ubuntu/Debian do
   NOT use apt (ships 0.9/0.10 — this config needs 0.12 for `vim.pack`);
   install the prebuilt tarball from
   https://github.com/neovim/neovim/releases instead.
2. Clone this repo and link nvim into place:
   `git clone git@github.com:Car-ram-el/dotfiles.git ~/dotfiles`
   `ln -s ~/dotfiles/nvim ~/.config/nvim`

   (Unsure of the config path? `:echo stdpath('config')` inside nvim tells you.)
3. External tools: `git` (plugin installs), `ripgrep` (`<leader>fg` live
   grep), on Linux `xclip` or `wl-clipboard` (local clipboard):
   `sudo apt install git ripgrep xclip`
4. Launch nvim. Plugins auto-install at the locked revisions
   (needs network on first launch).
5. Clipboard over SSH needs nothing — yanks are carried to your terminal's
   clipboard via OSC52 automatically.

## Keymaps

Leader = `<Space>`. Press it and wait ~300ms — which-key shows every
available group. Conventions follow LazyVim/Doom Emacs/`vim`-emulation
layers in other editors, so habits transfer.

| Keys | Action |
|---|---|
| `<leader>ff` / `<leader>fg` | find files / live grep |
| `<leader>fb` / `<leader>fs` | open buffers / symbols in file |
| `<leader>fr` / `<leader>fh` | references / help tags |
| `<leader>gs` | git status (changed files) |
| `<leader>e` | toggle file explorer |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | move between splits |
| `]c` / `[c` | next / prev git hunk |
| `<leader>hs` / `<leader>hr` | stage / reset hunk (visual: selection) |
| `<leader>hS` / `<leader>hR` | stage / reset whole file |
| `<leader>hu` | undo stage |
| `<leader>gb` / `<leader>gB` | blame line / blame file |
| `<leader>gp` / `<leader>gd` | preview hunk / diff vs index (toggle) |
| `<leader>gt` | toggle inline blame |
| `gd` / `gr` / `K` | LSP: definition / references / hover |
| `<leader>rn` / `<leader>ca` | LSP: rename / code action |
| `<C-k>` (insert) | LSP: signature help |

Completion pops up automatically while typing:
`<C-n>`/`<C-p>` navigate, `<C-y>` accept, `<C-e>` dismiss.

## Syncing between machines

- Commit `nvim-pack-lock.json` whenever plugins change.
- On the other machine: `git pull` inside the clone, restart nvim —
  missing plugins install automatically at the locked revisions.
