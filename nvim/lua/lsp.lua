-- Haskell LSP (HLS) via direnv. Starts only where the tooling actually
-- exists: `direnv` on PATH, a project root, and a .envrc to load it.
-- On any other machine (no direnv / not a Haskell project) this is a no-op.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "haskell", "lhaskell" },
  callback = function()
    if vim.fn.executable("direnv") ~= 1 then return end
    local root = vim.fs.root(0, { "cabal.project", ".git" })
    if not root or not vim.uv.fs_stat(root .. "/.envrc") then return end

    for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if c.name == "hls" then return end
    end

    vim.lsp.start({
      name = "hls",
      cmd = { "direnv", "exec", root, "haskell-language-server-wrapper", "--lsp" },
      root_dir = root,
      settings = {
        haskell = {
          hlintOn = true,
          formatProvider = "ormolu",
        },
      },
    })
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Keymaps + completion for any LSP that attaches (any language, any machine)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local bufnr = event.buf
    local keys = vim.keymap.set
    keys("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
    keys("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Find references" })
    keys("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover info" })
    keys("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
    keys("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
    -- Insert-mode only: keeps normal-mode <C-k> free for window navigation
    keys("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature help" })

    -- Built-in completion (no plugin). Auto-popup; <C-n>/<C-p> navigate,
    -- <C-y> accept, <C-e> dismiss.
    vim.opt.completeopt = { "menuone", "noselect" }
    vim.lsp.completion.enable(true, event.data.client_id, bufnr, { autotrigger = true })
  end,
})
