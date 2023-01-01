local M = {}
-- Add tab navigation
function M.set_nav(buffer, bounds)
    vim.keymap.set('n', '<tab>', function() 
        local cur, _ = unpack(vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()))
        for _, bound in ipairs(bounds) do
            -- Get first that is bigger
            if cur < bound.start then
                vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), {bound.start, 0})
                break
            end
        end
    end, {buffer = buffer, silent=true}) 

    vim.keymap.set('n', '<s-tab>', function ()
        local cur, _ = unpack(vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()))
        for i=#bounds,1,-1 do
            local bound = bounds[i]
            -- Get first that is bigger
            if cur > bound.start then
                vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), {bound.start, 0})
                break
            end
        end
    end, {buffer = buffer, silent=true})
end

return M
