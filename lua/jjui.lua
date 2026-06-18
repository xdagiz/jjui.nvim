local prev_win = -1
local win = -1
local buf = -1
local loaded = false
local autocmd_id = nil

local config = {
  scaling = 0.9,
  border = "none",
  winblend = 0,
  on_exit = nil,
}

local function setup(opts)
  if opts then
    if opts.scaling then
      config.scaling = opts.scaling
    end
    if opts.border then
      config.border = opts.border
    end
    if opts.winblend then
      config.winblend = opts.winblend
    end
    if opts.on_exit then
      config.on_exit = opts.on_exit
    end
  end

  if vim.g.jjui_floating_window_scaling_factor then
    config.scaling = vim.g.jjui_floating_window_scaling_factor
  end
  if vim.g.jjui_border then
    config.border = vim.g.jjui_border
  end
  if vim.g.jjui_winblend then
    config.winblend = vim.g.jjui_winblend
  end
  if vim.g.jjui_on_exit then
    config.on_exit = vim.g.jjui_on_exit
  end
end

local function get_window_pos()
  local scaling = config.scaling

  local height_factor, width_factor
  if type(scaling) == "table" then
    height_factor = scaling.height or 0.9
    width_factor = scaling.width or 0.9
  else
    height_factor = scaling
    width_factor = scaling
  end

  local height = math.ceil(vim.o.lines * height_factor) - 1
  local width = math.ceil(vim.o.columns * width_factor)
  local row = math.ceil(vim.o.lines - height) / 2
  local col = math.ceil(vim.o.columns - width) / 2
  return width, height, row, col
end

local function cleanup()
  if autocmd_id then
    pcall(vim.api.nvim_del_autocmd, autocmd_id)
    autocmd_id = nil
  end

  if vim.api.nvim_win_is_valid(prev_win) then
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end

    vim.api.nvim_set_current_win(prev_win)
  end

  prev_win = -1
  win = -1
  loaded = false
end

local function open_floating_window()
  local width, height, row, col = get_window_pos()

  local opts = {
    style = "minimal",
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    border = config.border,
  }

  if buf == -1 or not vim.api.nvim_buf_is_valid(buf) or vim.fn.bufwinnr(buf) == -1 then
    buf = vim.api.nvim_create_buf(false, true)
  end

  win = vim.api.nvim_open_win(buf, true, opts)

  vim.bo[buf].filetype = "jjui"
  vim.bo.bufhidden = "hide"
  vim.wo.cursorcolumn = false
  vim.wo.signcolumn = "no"
  vim.wo.winblend = config.winblend

  autocmd_id = vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_del_autocmd, autocmd_id)
        autocmd_id = nil
        return
      end
      local new_width, new_height, new_row, new_col = get_window_pos()
      vim.api.nvim_win_set_config(win, {
        width = new_width,
        height = new_height,
        relative = "editor",
        row = new_row,
        col = new_col,
      })
    end,
  })

  return win, buf
end

local function on_exit(_, code, _)
  if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  buf = -1
  loaded = false

  cleanup()

  if config.on_exit then
    config.on_exit(code)
  end
end

local function exec_jjui(cmd)
  if loaded then
    return
  end

  local command
  if type(cmd) == "string" then
    command = {}
    for arg in string.gmatch(cmd, "%S+") do
      table.insert(command, arg)
    end
  else
    command = cmd
  end

  loaded = true

  vim.schedule(function()
    vim.fn.jobstart(command, { term = true, on_exit = on_exit })
    vim.cmd("startinsert")
  end)
end

local function is_open()
  return win ~= -1 and vim.api.nvim_win_is_valid(win)
end

local function open()
  if is_open() then
    vim.api.nvim_set_current_win(win)
    return
  end

  prev_win = vim.api.nvim_get_current_win()
  win, buf = open_floating_window()
  exec_jjui({ "jjui" })
end

local function toggle()
  if is_open() then
    cleanup()
  else
    open()
  end
end

vim.api.nvim_create_user_command("Jjui", open, { desc = "Open jjui" })
vim.api.nvim_create_user_command("JjuiToggle", toggle, { desc = "Toggle jjui" })

return {
  jjui = open,
  setup = setup,
  toggle = toggle,
  open = open,
  is_open = is_open,
}
