local M = {}

local function add_keymaps(buffer)

end

M.global_window_opened = false

local WIN_SCALE = 0.8
function M.open_global(snippets)
    if M.global_window_opened then return nil end
    M.global_window_opened = true
    -- Create buffer
    local buff = vim.api.nvim_create_buf(false, true)
    add_keymaps(buff)

    -- Add autocommand for buffer close
    vim.api.nvim_create_autocmd({"BufWinLeave"}, {
        buffer = buff,
        callback = function()
            M.global_window_opened = false
            return true
        end
    })

    -- Create window size
    local width = math.ceil(vim.api.nvim_get_option('columns') * WIN_SCALE)
    local height = math.ceil(vim.api.nvim_get_option('lines') * WIN_SCALE)
    local row = math.floor((vim.api.nvim_get_option('lines') - height) / 2)
    local col = math.ceil((vim.api.nvim_get_option('columns') - width) / 2)

    -- Create and open window
    vim.api.nvim_open_win(buff, true, {
        style = 'minimal',
        border = 'rounded',

        relative = 'editor',

        -- Size
        width = width,
        height = height,
        row = row,
        col = col
    })

    return buff
end

return M
