local M = {}

local ftapi = require "fuzzy-tag.api"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local function get_relative_path(root_dir)
    local current_buf = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(current_buf)

    local relative_path = string.sub(filepath, #root_dir + 1)
    if relative_path:sub(1, 1) == "/" then
        relative_path = relative_path:sub(2)
    end
    return relative_path;
end

M.add_tag_cmd = function(opts)
    local _, root_dir = ftapi.init_project()
    local relative_path = get_relative_path(root_dir)
    ftapi.add_tag(relative_path, opts.args)
end

M.remove_tag_cmd = function(opts)
    local _, root_dir = ftapi.init_project()
    local relative_path = get_relative_path(root_dir)
    ftapi.remove_tag(relative_path, opts.args)
end

M.fuzzy_search_cmd = function()
    ftapi.init_project()
    local picker;
    local function get_workspace_symbols_requester()
        local prompt = picker:_get_prompt()
        return ftapi.fuzzy_search(prompt)
        -- return { "README.md" }
    end

    local opts = {}
    picker = pickers.new(opts, {
        prompt_title = "Live tags",
        finder = finders.new_dynamic {
            -- results = results
            fn = get_workspace_symbols_requester,
            entry_maker = function(entry)
                return {
                    value = entry.file_path,
                    display = entry.file_path .. "\t[" .. entry.file_tags .. "]",
                    ordinal = entry,
                }
            end

        },
        previewer = conf.grep_previewer(opts),
    })

    picker:find()
end

M.show_tags_cmd = function(opts)
    local _, root_dir = ftapi.init_project()
    local relative_path = get_relative_path(root_dir)
    local res = ftapi.get_tags(relative_path)
    print(vim.inspect(res))
end

return M
