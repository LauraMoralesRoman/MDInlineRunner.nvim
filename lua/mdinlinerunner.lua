local M = {}

local parser = require"MDInlineRunner.parser"
local window = require"MDInlineRunner.window"

-- Default configuration
M.langs = {}
M.langs.lua = {
    command = 'lua %s',
    icon = ''
}
-- Create highlight groups
local highlight_ns = vim.api.nvim_create_namespace('InlineMarkdownSnippetRunner')
--------------------------

local function filter_snippets(snippets)
    local filtered = {}
    for _, snippet in ipairs(snippets) do
        if M.langs[snippet.lang] then
            table.insert(filtered, snippet)
        end
    end
    return filtered
end

local TMP_FILENAME = '/tmp/inline_markdown_runner'
local function execute(snippet)
    -- Create temporal file
    local tmp_file = io.open(TMP_FILENAME, "w+")
    -- Write data to temp file
    for _, line in ipairs(snippet.content) do
        tmp_file:write(line .. '\n')
    end
    tmp_file:close()
    -- Run user-specified command for language type
    vim.api.nvim_command('!printf "\\n" && ' .. string.format(M.langs[snippet.lang].command, TMP_FILENAME))
end

function M.run_under_line()
    local snippets = parser.parse(vim.api.nvim_get_current_buf())
    cur, _ = unpack(vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()))
    -- Check if line is under any snippet

    for _, snippet in ipairs(snippets) do
        -- Check bounds
        if (cur >= snippet.start.y) and (cur <= snippet.stop.y) then
            execute(snippet)
            break
        end
    end
end

function M.get()
    local snippets = parser.parse(vim.api.nvim_get_current_buf())
    local buffer = window.open_global(snippets)

    -- Exit if window is already open
    if buffer == nil then return end

    -- Filter snippets to keep only available languages

    local bounds = {}
    local filtered = filter_snippets(snippets)

    -- Add snippets to buffer
    local MAX_LINES_PRINTED = 3
    local lines = {}
    local cnt = 0

    local function insert(line)
        table.insert(lines, line)
        cnt = cnt + 1
        return cnt
    end

    local highlight_positions = {}
    for _, snippet in ipairs(filtered) do
        local start = insert(string.format("%s\t%d:%d", M.langs[snippet.lang].icon, snippet.start.y - 1, snippet.stop.y - 1))
        table.insert(highlight_positions, start - 1)
        
        for i, line in ipairs(snippet.content) do
            if i == MAX_LINES_PRINTED + 1 then 
                insert('...')
                break
            end
            insert(line)
        end
        local finish = insert('')
        -- Add to bounds
        table.insert(bounds, {
            start = start,
            finish = finish,
            snippet = snippet
        })
    end
    -- Add executor to buffer
    vim.keymap.set('n', '<cr>', function() 
        -- Check cursor position
        local cur, _ = unpack(vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()))
        -- Locate
        for _, bound in ipairs(bounds) do
            -- Check if inside bound
            if (cur >= bound.start) and (cur <= bound.finish) then
                execute(bound.snippet)
                break
            end
        end
    
    end, {buffer = buffer, silent=true})

    vim.api.nvim_buf_set_lines(buffer, 0, 0, false, lines)
    -- Add highlight
    for i=0,#lines-1,1 do
        vim.api.nvim_buf_add_highlight(buffer, -1, "NonText", i, 0, -1)
    end
    for _, position in ipairs(highlight_positions) do
        vim.api.nvim_buf_add_highlight(buffer, -1, "Identifier", position, 3, -1)
        vim.api.nvim_buf_add_highlight(buffer, -1, "Statement", position, 0, 3)
    end
end

return M
