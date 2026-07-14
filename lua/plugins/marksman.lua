-- Marksman (LazyVim markdown extra) validates generic markdown links and fights
-- Obsidian wiki-link semantics. obsidian-ls owns the vault instead.
local VAULT = vim.fs.normalize(vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/main"))

local function in_vault(path)
  if not path or path == "" then
    return false
  end
  path = vim.fs.normalize(path)
  return path == VAULT or path:find(VAULT .. "/", 1, true) == 1
end

local function purge_marksman(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not in_vault(vim.api.nvim_buf_get_name(buf)) then
    return
  end

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, name = "marksman" })) do
    pcall(vim.lsp.buf_detach_client, buf, client.id)
  end

  for _, client in ipairs(vim.lsp.get_clients({ name = "marksman" })) do
    local ns = vim.lsp.diagnostic.get_namespace(client.id)
    if ns then
      vim.diagnostic.reset(ns, buf)
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = { enabled = false },
      },
    },
    init = function()
      -- Runs at startup (before lazy-loaded LSP). Catches any Marksman that
      -- already attached or sneaks in via a parent .git workspace root.
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        desc = "Keep Marksman out of the Obsidian vault",
        group = vim.api.nvim_create_augroup("obsidian_no_marksman", { clear = true }),
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype
          if ft == "markdown" or ft == "markdown.mdx" then
            purge_marksman(ev.buf)
          end
        end,
      })
    end,
  },
}
