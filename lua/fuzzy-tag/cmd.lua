local M = {}

local ftapi = require "fuzzy-tag.api"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

-- fix me. Make relative file path
M.add_tag_cmd = function(opts)
    ftapi.init_project()
    local current_buf = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(current_buf)
    ftapi.add_tag(filepath, opts.args)
end

M.remove_tag_cmd = function(opts)
    ftapi.init_project()
    local current_buf = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(current_buf)
    ftapi.remove_tag(filepath, opts.args)
end

M.fuzzy_search_cmd = function()
    ftapi.init_project()
    local picker;
    local function get_workspace_symbols_requester()
        local prompt = picker:_get_prompt()
        return ftapi.fuzzy_search(prompt)
    end

    local opts = {}
    picker = pickers.new(opts, {
        prompt_title = "Live tags",
        finder = finders.new_dynamic {
            -- results = results
            fn = get_workspace_symbols_requester,
        },
        previewer = conf.grep_previewer(opts),
    })

    picker:find()
end

M.show_tags_cmd = function (opts)
    ftapi.init_project()
    local current_buf = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(current_buf)
    local res = ftapi.get_tags(filepath)
    print(vim.inspect(res))
end

return M
