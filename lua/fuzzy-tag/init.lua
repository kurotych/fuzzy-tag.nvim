local M = {}
local ftapi = require "fuzzy-tag.api"
local ftcmd = require "fuzzy-tag.cmd"

M.setup = function(opts)
    vim.api.nvim_create_user_command('AddTag', ftcmd.add_tag_cmd, { nargs = 1 })
    vim.api.nvim_create_user_command('RemoveTag', ftcmd.remove_tag_cmd, { nargs = 1 })
    vim.api.nvim_create_user_command('ShowTags', ftcmd.show_tags_cmd, {})
end

return M;
