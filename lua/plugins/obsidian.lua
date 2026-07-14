local VAULT = vim.fs.normalize(vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/main"))

local function in_vault(path)
  if not path or path == "" then
    return false
  end

  path = vim.fs.normalize(path)
  return path == VAULT or path:find(VAULT .. "/", 1, true) == 1
end

local LINK_STATUS_NS = vim.api.nvim_create_namespace("obsidian_link_status")

--- Dim unresolved / ambiguous wiki links (Obsidian-style hints, not LSP errors).
local function setup_link_status_highlights()
  vim.api.nvim_set_hl(0, "ObsidianUnresolvedLink", { fg = "#565f89", undercurl = true, sp = "#565f89" })
  vim.api.nvim_set_hl(0, "ObsidianAmbiguousLink", { fg = "#e0af68", undercurl = true, sp = "#e0af68" })

  local group = vim.api.nvim_create_augroup("ObsidianLinkStatus", { clear = true })
  local pending = {}

  local function classify_ref(ref)
    if ref.kind == "footnote" or ref.kind == "markdown" then
      return nil
    end

    local target = ref.target
    if target == "" then
      return nil
    end

    local link = require("obsidian.link")
    if link.resolve_link_path(target) then
      return nil
    end

    local notes = require("obsidian.search").find_notes(target, { timeout = 500 })
    if #notes == 0 then
      return "ObsidianUnresolvedLink"
    end
    if #notes > 1 then
      return "ObsidianAmbiguousLink"
    end
    return nil
  end

  local function update(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.b[buf].obsidian_buffer then
      return
    end

    vim.api.nvim_buf_clear_namespace(buf, LINK_STATUS_NS, 0, -1)

    local parse_refs = require("obsidian.parse.refs")
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    for lnum, line in ipairs(lines) do
      for _, ref in ipairs(parse_refs.extract(line)) do
        local hl = classify_ref(ref)
        if hl then
          vim.api.nvim_buf_set_extmark(buf, LINK_STATUS_NS, lnum - 1, ref.range.start_col, {
            end_row = lnum - 1,
            end_col = ref.range.end_col,
            hl_group = hl,
            priority = 110,
          })
        end
      end
    end
  end

  local function debounced_update(buf)
    if pending[buf] then
      pending[buf]:close()
    end
    pending[buf] = vim.defer_fn(function()
      pending[buf] = nil
      update(buf)
    end, 300)
  end

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ObsidianNoteEnter",
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      update(buf)
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
        group = group,
        buffer = buf,
        callback = function()
          debounced_update(buf)
        end,
      })
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ObsidianNoteLeave",
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      if pending[buf] then
        pending[buf]:close()
        pending[buf] = nil
      end
      vim.api.nvim_buf_clear_namespace(buf, LINK_STATUS_NS, 0, -1)
    end,
  })
end

--- Buffer-local keymaps for vault notes. Called after obsidian-ls attaches so we
--- win over LazyVim's global LSP maps (gd, etc.).
local function setup_vault_keymaps(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local actions = require("obsidian.actions")
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
  end

  -- Built-in obsidian.nvim maps (also set by the plugin; we re-apply after LSP attach)
  vim.keymap.set("n", "<CR>", require("obsidian.api").smart_action, {
    buffer = buf,
    expr = true,
    desc = "Obsidian smart action (link/tag/checkbox/fold)",
  })
  map("n", "]o", function()
    actions.nav_link("next")
  end, "Next link in note")
  map("n", "[o", function()
    actions.nav_link("prev")
  end, "Previous link in note")

  map("n", "gf", function()
    actions.follow_link(nil, { open_strategy = "current" })
  end, "Follow link under cursor")
  map("n", "gd", function()
    actions.follow_link(nil, { open_strategy = "current" })
  end, "Go to linked note (Obsidian)")
  map("n", "grr", vim.lsp.buf.references, "Backlinks (LSP references)")
  map("n", "grn", vim.lsp.buf.rename, "Rename note + update vault links")

  map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "Backlinks picker")
  map("n", "<leader>of", "<cmd>Obsidian follow_link<cr>", "Follow link")
  map("n", "<leader>ol", "<cmd>Obsidian links<cr>", "Links in this note")
  map("n", "<leader>oo", "<cmd>Obsidian open<cr>", "Open in Obsidian app")
  map("n", "<leader>on", "<cmd>Obsidian new<cr>", "New note")
  map("n", "<leader>oN", "<cmd>Obsidian new_from_template<cr>", "New note from template")
  map("n", "<leader>ou", "<cmd>Obsidian unique_note<cr>", "New unique (timestamp) note")
  map("n", "<leader>oq", "<cmd>Obsidian quick_switch<cr>", "Quick switch note")
  map("n", "<leader>os", "<cmd>Obsidian search<cr>", "Search vault")
  map("n", "<leader>or", "<cmd>Obsidian rename<cr>", "Rename note")
  map("n", "<leader>ot", "<cmd>Obsidian toc<cr>", "Table of contents")
  map("n", "<leader>oT", "<cmd>Obsidian tags<cr>", "Search tags")
  map("n", "<leader>ow", "<cmd>Obsidian workspace<cr>", "Switch workspace")
  map("n", "<leader>ok", "<cmd>Obsidian check<cr>", "Vault health check")
  map("n", "<leader>op", "<cmd>Obsidian paste_img<cr>", "Paste image from clipboard")
  map("n", "<leader>oc", actions.toggle_checkbox, "Toggle checkbox")
  map("n", "<leader>o;", actions.add_property, "Add frontmatter property")
  map("n", "<leader>oh", "<cmd>Obsidian help<cr>", "Obsidian.nvim help")

  map("n", "<leader>od", "<cmd>Obsidian today<cr>", "Today's daily note")
  map("n", "<leader>oy", "<cmd>Obsidian yesterday<cr>", "Yesterday's daily note")
  map("n", "<leader>o>", "<cmd>Obsidian tomorrow<cr>", "Tomorrow's daily note")

  map("v", "<leader>ol", "<cmd>Obsidian link<cr>", "Link selection to existing note")
  map("v", "<leader>on", "<cmd>Obsidian link_new<cr>", "Create note from selection")
  map("v", "<leader>oe", "<cmd>Obsidian extract_note<cr>", "Extract selection to new note")
end

local function bootstrap_vault_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
      local name = vim.api.nvim_buf_get_name(buf)
      if in_vault(name) and (vim.bo[buf].filetype == "markdown" or vim.bo[buf].filetype == "markdown.mdx") then
        vim.api.nvim_exec_autocmds("BufEnter", { buffer = buf })
      end
    end
  end
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    -- ft is reliable; the old BufReadPre glob had a broken backslash before the
    -- space in "Mobile Documents" so the plugin never loaded.
    ft = { "markdown", "markdown.mdx" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      legacy_commands = false,

      workspaces = {
        {
          name = "main",
          path = VAULT,
        },
      },

      notes_subdir = nil,
      new_notes_location = "current_dir",
      open_notes_in = "current",

      link = {
        style = "wiki",
        format = "shortest",
        auto_update = true,
      },

      completion = {
        min_chars = 2,
        match_case = false,
        create_new = true,
      },

      picker = {
        name = "telescope.nvim",
        note_mappings = {
          new = "<C-x>",
          insert_link = "<C-l>",
        },
        tag_mappings = {
          tag_note = "<C-x>",
          insert_tag = "<C-l>",
        },
      },

      search = {
        sort_by = "modified",
        sort_reversed = true,
        max_lines = 1000,
      },

      backlinks = {
        parse_headers = true,
      },

      daily_notes = {
        enabled = true,
        workdays_only = false,
      },

      templates = {
        enabled = true,
      },

      sync = {
        enabled = false,
      },

      checkbox = {
        enabled = true,
        create_new = true,
        -- Toggle cycle only: unchecked <-> done. Does not reorder lines in your note.
        order = { " ", "x" },
      },

      footer = {
        enabled = true,
        format = "󰋗 {{backlinks}} backlinks · {{properties}} props · {{words}} words · {{chars}} chars",
        hl_group = "Comment",
        separator = false,
      },

      ui = {
        enable = true,
        update_debounce = 200,
        max_file_length = 5000,
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "󰏌", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianImportant = { bold = true, fg = "#d73128" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#7aa2f7" },
          ObsidianExtLinkIcon = { fg = "#bb9af7" },
          ObsidianTag = { italic = true, fg = "#73daca" },
          ObsidianBlockID = { italic = true, fg = "#bb9af7" },
          ObsidianHighlightText = { bg = "#3d59a1" },
        },
      },

      callbacks = {
        post_setup = function()
          setup_link_status_highlights()

          -- Plain `- [ ]` / `- [x]` text: match checkbox lines so bullet conceal
          -- does not apply, but do not replace them with icons (set in post_setup
          -- to avoid the ui.checkboxes deprecation warning).
          local plain = {}
          for _, char in ipairs({ " ", "x", "~", "!", ">", "?" }) do
            plain[char] = {}
          end
          Obsidian.opts.ui.checkboxes = plain
        end,
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- Re-apply vault keymaps after LazyVim's LspAttach maps (gd, etc.)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("obsidian_keymaps", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= "obsidian-ls" then
            return
          end
          if not in_vault(vim.api.nvim_buf_get_name(ev.buf)) then
            return
          end
          setup_vault_keymaps(ev.buf)
        end,
      })

      -- First markdown buffer may have entered before setup finished.
      vim.schedule(bootstrap_vault_buffers)
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_y = opts.sections.lualine_y or {}
      if not vim.tbl_contains(opts.sections.lualine_y, "b:obsidian_status") then
        table.insert(opts.sections.lualine_y, "b:obsidian_status")
      end
    end,
  },
}
