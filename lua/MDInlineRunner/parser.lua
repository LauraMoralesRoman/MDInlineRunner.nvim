local M = {}

local u = require"MDInlineRunner.utility"

local Snippet = {}
function Snippet.new(lang, start, stop)
    local self = setmetatable({}, Snippet)
    self.lang = lang
    self.start = start
    self.stop = stop
    self.content = {}
    return self
end

local parser_states = {}

parser_states.ctx = {
    line_number = 0,
    line = '',
    snippets = {},
    current_snippet = nil
}

-- Start state
function parser_states.waiting_snippet()
    local start, final, match = string.find(parser_states.ctx.line, "```(%a+) ?")

    if match then
        -- Create new snippet in temporal variable
        parser_states.ctx.current_snippet = Snippet.new(match, u.Coordinate.new(final + 1, parser_states.ctx.line_number))
        -- Get content from this line
        local content = string.sub(parser_states.ctx.line, final + 1)
        if string.gsub(content, ' ', '') ~= '' then
            table.insert(parser_states.ctx.current_snippet.content, content)
        end

        return parser_states.reading_snippet
    end

    return parser_states.waiting_snippet
end

-- End state
function parser_states.reading_snippet()
    local start, final, match = string.find(parser_states.ctx.line, "```")

    if start then
        -- Insert snippet into list
        parser_states.ctx.current_snippet.stop = u.Coordinate.new(start - 1, parser_states.ctx.line_number)
        -- Get content from this line
        local content = string.sub(parser_states.ctx.line, 1, start - 1)
        if vim.trim(content) ~= '' then
            table.insert(parser_states.ctx.current_snippet.content, content)
        end

        table.insert(parser_states.ctx.snippets, parser_states.ctx.current_snippet)

        return parser_states.waiting_snippet
    else
        table.insert(parser_states.ctx.current_snippet.content, parser_states.ctx.line)
    end

    return parser_states.reading_snippet
end

-- Main parser
function M.parse(buffer)
    -- Iterate lines

    local current_state = parser_states.waiting_snippet

    -- Clear states
    parser_states.ctx.snippets = {}

    for i, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0 ,-1, true)) do
        parser_states.ctx.line_number = i
        parser_states.ctx.line = line
        -- Update parser state machine
        current_state = current_state()
    end

    return parser_states.ctx.snippets
end

return M
