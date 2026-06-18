# jjui.nvim

[demo](https://github.com/user-attachments/assets/90ceb139-eb5d-4cab-984a-61a1781da328)
## Installation

### vim.pack (Neovim 0.12)

```lua
vim.pack.add({ src = "https://github.com/xdagiz/jjui.nvim" })

local jjui = require("jjui")

vim.keymap.set("n", "<leader>jj", jjui.open, { desc = "Open jjui" })
vim.keymap.set("n", "<leader>jt", jjui.toggle, { desc = "Toggle jjui" })
```

### lazy.nvim

```lua
{
  "xdagiz/jjui.nvim",
  lazy = true,
  cmd = { "Jjui", "JjuiToggle" },
  keys = {
    { "<leader>jj", "<cmd>Jjui<cr>", desc = "JJui" },
    { "<leader>jt", "<cmd>JjuiToggle<cr>", desc = "Toggle Jjui" },
  },
  config = function()
    require("jjui").setup({
      scaling = 0.9,
      border = "none",
      winblend = 0,
      on_exit = function(code)
        -- optional callback
      end,
    })
  end,
}
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `scaling` | number\|table | `0.9` | Window size factor. Use `{ height = 0.8, width = 0.9 }` for separate factors |
| `border` | string | `"none"` | Border style: `"none"`, `"single"`, `"double"`, `"rounded"`, `"solid"`, `"shadow"` |
| `winblend` | number | `0` | Window transparency (0-100) |
| `on_exit` | function\|nil | `nil` | Callback when jjui exits, receives exit code |

or:

```lua
vim.g.jjui_floating_window_scaling_factor = 0.9
vim.g.jjui_border = "rounded"
vim.g.jjui_winblend = 10
```
