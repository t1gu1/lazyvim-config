---@param increment boolean
---@param g? boolean
function Dial(increment, g)
  local mode = vim.fn.mode(true)
  -- Use visual commands for VISUAL 'v', VISUAL LINE 'V' and VISUAL BLOCK '\22'
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
  return require("dial.map")[func](group)
end

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      mappings = {
        submit_prompt = {
          normal = "<C-s>",
          insert = "<C-s>",
        },
        accept_diff = {
          normal = "<C-cr>",
          insert = "<C-cr>",
        },
      },
      prompts = {
        Complete = {
          prompt = "Try to compplete the code for the selected code.",
          system_prompt = "You are very good at explaining programming code and keepping the code easy to understand.",
          mapping = "<leader>ac",
        },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true, -- Crucial for ghost text
        auto_trigger = true, -- Copilot suggests as you type
        keymap = {
          accept = "<c-cr>", -- Primary key to accept ghost text
          next = "<c-[>", -- Cycle to the next ghost text suggestion (e.g., Alt + ])
          prev = "<c-]>", -- Cycle to the previous ghost text suggestion (e.g., Alt + [)
          -- You can also add:
          accept_word = "<c-w>", -- Accept the next word of the suggestion
          accept_line = "<c-l>", -- Accept the entire line of the suggestion
          -- dismiss = "<C-]>",    -- Dismiss the current ghost text suggestion
        },
      },
      panel = {
        enabled = false, -- Most users prefer inline ghost text over a separate panel
      },
    },
  },
  -- Remove copilot from the sources in blick (I prefer the ghost text)
  {
    "saghen/blink.cmp",
    keymap = {
      preset = "none",
    },

    opts = function(_, opts)
      -- Create a new sources table, excluding 'copilot'
      local new_default_sources = {}
      for _, source_name in ipairs(opts.sources.default or {}) do
        if source_name ~= "copilot" then
          table.insert(new_default_sources, source_name)
        end
      end
      opts.sources.default = new_default_sources

      -- Also, ensure 'copilot' is not defined as a provider
      -- This might be redundant if it's not a source, but good for completeness.
      if opts.sources.providers and opts.sources.providers.copilot then
        opts.sources.providers.copilot = nil
      end

      return opts
    end,
  },
  {
    "saghen/blink.compat",
    optional = true, -- make optional so it's only enabled if any extras need it
    opts = {},
    version = not vim.g.lazyvim_blink_main and "*",
  },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },
  {
    "monaqa/dial.nvim",
    -- stylua: ignore
    keys = {
      { "<c-=>", function() return Dial(true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
      { "<C-->", function() return Dial(false) end, expr = true, desc = "Decrement", mode = {"n", "v"} },
      { "g<C-=>", function() return Dial(true, true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
      { "g<C-->", function() return Dial(false, true) end, expr = true, desc = "Decrement", mode = {"n", "v"} },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        sections = {
          lualine_a = {
            function()
              local projectName = vim.fn.getcwd():match("([^/]+)$")
              local firstLetter = projectName:sub(1, 1)
              local restOfString = projectName:sub(2)
              local capitalizedProjectName = firstLetter:upper() .. restOfString
              return capitalizedProjectName
            end,
          },
          lualine_b = { "branch", "diff" },
          lualine_c = { "diagnostics" },
          lualine_x = { "encoding", "fileformat" },
          lualine_y = { "filetype" },
          lualine_z = { "progress" },
        },
      }
    end,
  },
  {
    "vuki656/package-info.nvim",
    event = "VeryLazy",
    config = function()
      local package_info = require("package-info")

      require("package-info").setup({
        colors = {
          up_to_date = "#3C4048", -- Text color for up to date dependency virtual text
          outdated = "#d19a66", -- Text color for outdated dependency virtual text
        },
        icons = {
          enable = true, -- Whether to display icons
          style = {
            up_to_date = "|  ", -- Icon for up to date dependencies
            outdated = "|  ", -- Icon for outdated dependencies
          },
        },
        autostart = true, -- Whether to autostart when `package.json` is opened
        hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
        hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
        -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
        -- The plugin will try to auto-detect the package manager based on
        -- `yarn.lock` or `package-lock.json`. If none are found it will use the
        -- provided one, if nothing is provided it will use `yarn`
        package_manager = "npm",
      })

      package_info.get_status()
    end,
  },
  {
    "luckasRanarison/tailwind-tools.nvim",
    event = "VeryLazy",
    opts = {
      document_color = {
        enabled = true,
        kind = "foreground",
        inline_symbol = "󰝤 ",
        debounce = 200,
      },
      conceal = {
        enabled = false,
        symbol = "󱏿",
        highlight = {
          fg = "#38BDF8",
        },
      },
    },
  },
}
