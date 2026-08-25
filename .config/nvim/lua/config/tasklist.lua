-- ~/tasklist: reorder completed top-level tasks to the bottom on save,
-- and dim ("blend out") completed top-level tasks visually.
-- Sub-tasks (indented `- [ ]`/`- [x]`) never move and never get dimmed.

local tasklist_path = vim.fn.expand("~/tasklist")

local ns = vim.api.nvim_create_namespace("tasklist_blend")

local function set_hl()
    vim.api.nvim_set_hl(0, "TasklistDone", { fg = "#5c6370", strikethrough = true, italic = true })
end
set_hl()

vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

-- render as markdown so markview.nvim picks it up, even without a .md extension
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = tasklist_path,
    callback = function(args)
        vim.bo[args.buf].filetype = "markdown"
    end,
})

-- append/strip a "[done: YYYY-MM-DD HH:MM]" stamp when a checkbox (top-level
-- or sub-task) is checked/unchecked; idempotent, so safe to call repeatedly
local stamp_re = " %[done: %d%d%d%d%-%d%d%-%d%d %d%d:%d%d%]$"

local function stamp_done(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local changed = false

    for i, line in ipairs(lines) do
        local checked = line:match("^%s*%- %[[xX]%]") ~= nil
        local stamp_start = line:find(stamp_re)

        if checked and not stamp_start then
            lines[i] = line .. string.format(" [done: %s]", os.date("%Y-%m-%d %H:%M"))
            changed = true
        elseif not checked and stamp_start then
            lines[i] = line:sub(1, stamp_start - 1)
            changed = true
        end
    end

    if changed then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    end
end

local function highlight_done(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        -- top-level only: no leading whitespace before "- ["
        if line:match("^%- %[[xX]%]") then
            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                end_row = i - 1,
                end_col = #line,
                hl_group = "TasklistDone",
            })
        end
    end
end

vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    pattern = tasklist_path,
    callback = function(args)
        stamp_done(args.buf)
        highlight_done(args.buf)
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "TextChangedI" }, {
    pattern = tasklist_path,
    callback = function(args)
        highlight_done(args.buf)
    end,
})

-- move finished top-level tasks to the bottom, keeping their sub-tasks
-- attached and in original order; open top-level tasks keep their order too
local function reorder(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local open_blocks, done_blocks = {}, {}
    local current

    for _, line in ipairs(lines) do
        if line:match("^%- %[.%]") then
            current = { line }
            if line:match("^%- %[[xX]%]") then
                table.insert(done_blocks, current)
            else
                table.insert(open_blocks, current)
            end
        elseif line:match("^%s+%- %[") then
            if current then
                table.insert(current, line)
            end
        end
        -- blank lines are dropped and re-added once at EOF below
    end

    local result = {}
    for _, block in ipairs(open_blocks) do
        for _, l in ipairs(block) do
            table.insert(result, l)
        end
    end
    for _, block in ipairs(done_blocks) do
        for _, l in ipairs(block) do
            table.insert(result, l)
        end
    end
    table.insert(result, "")

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
end

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = tasklist_path,
    callback = function(args)
        stamp_done(args.buf)
        reorder(args.buf)
    end,
})
