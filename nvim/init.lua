-- Basic editor options
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 5
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"

-- Clipboard: local -> native OS clipboard (macOS pbcopy / Linux xclip or
-- wl-clipboard / Windows built-in). Over SSH -> OSC52 escape codes carry
-- yanks into your local terminal's clipboard.
vim.opt.clipboard = "unnamedplus"
if vim.env.SSH_CONNECTION then
  vim.g.clipboard = "osc52"
end

-- Leader key: space
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.timeoutlen = 500   -- how long to wait before which-key pops up

-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("colorscheme slate")

-- Plugins via built-in vim.pack (nvim >= 0.12)
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/folke/which-key.nvim",
}, { confirm = false })

-- Telescope: fuzzy finder + project-wide search
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files,            { desc = "Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep,             { desc = "Grep in project (like Cmd-Shift-F)" })
vim.keymap.set("n", "<leader>fb", builtin.buffers,               { desc = "Open buffers" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols,  { desc = "Symbols in file" })
vim.keymap.set("n", "<leader>fr", builtin.lsp_references,        { desc = "References (LSP)" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags,             { desc = "Help tags" })
vim.keymap.set("n", "<leader>gs", builtin.git_status,            { desc = "Git changed files" })

require("telescope").setup({
  defaults = {
    file_ignore_patterns = { "node_modules", "%.git/", "dist" },
    layout_config = { prompt_position = "top" },
    sorting_strategy = "ascending",
  },
})

-- nvim-tree: left file explorer (VSCode sidebar)
require("nvim-tree").setup({
  renderer = {
    icons = {
      show = { file = false, folder = false, folder_arrow = true,
               git = false, modified = false, diagnostics = false, bookmarks = false, hidden = false },
      glyphs = { folder = { arrow_closed = ">", arrow_open = "v" } },
    },
  },
})
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Explorer (file tree)" })

-- gitsigns: git blame, diffs, hunk operations
local gitsigns = require("gitsigns")
gitsigns.setup({
  current_line_blame = true,
  current_line_blame_opts = { delay = 500 },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  signs = {
    add = { text = "|" },
    change = { text = "|" },
    delete = { text = "_" },
    topdelete = { text = "-" },
    changedelete = { text = "|" },
  },
  -- Canonical gitsigns keymap set (what the docs and distros use)
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Hunk navigation (in a diff window, falls back to vim's native jump)
    bmap("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next hunk")
    bmap("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev hunk")

    -- Hunk stage / reset (n = line hunk, v = visual selection)
    bmap("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    bmap("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
    bmap("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
    bmap("n", "<leader>hS", gs.stage_buffer, "Stage whole file")
    bmap("n", "<leader>hR", gs.reset_buffer, "Reset whole file")
    bmap("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

    -- Text object: select a hunk
    bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Hunk")
  end,
})

-- Global (non-buffer) git view keys
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>",                  { desc = "Blame this line (popup)" })
vim.keymap.set("n", "<leader>gB", ":Gitsigns blame<CR>",                       { desc = "Blame sidebar (whole file)" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>",                { desc = "Preview hunk diff" })
vim.keymap.set("n", "<leader>gd", function()
  if vim.wo.diff then
    vim.cmd("diffoff!")
  else
    gitsigns.diffthis()
  end
end, { desc = "Diff vs index (toggle; close the old pane with <C-w>c)" })
vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>",   { desc = "Toggle inline blame" })

-- Window navigation: Ctrl-h/j/k/l moves between tree/splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- which-key: popup legend of available keys after you press <leader>
require("which-key").setup({ delay = 300 })
require("which-key").add({
  { "<leader>f", group = "find" },
  { "<leader>g", group = "git views" },
  { "<leader>h", group = "git hunks" },
  { "<leader>r", group = "refactor" },
  { "<leader>c", group = "code (LSP)" },
})

-- LSP setup (Haskell) - separate file
require("lsp")
