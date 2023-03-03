local sqlite = require "sqlite.db"

local M = {}
local L = {}

local function find_root_dir()
    local root_dir = "";
    local job_id = vim.fn.jobstart("git rev-parse --show-toplevel", {
        stdout_buffered = true,
        on_stdout = function(_, data)
            root_dir = root_dir .. table.concat(data)
        end
    })

    local results = vim.fn.jobwait({ job_id }, -1)
    if results[1] ~= 0 then
        error("Can't find root dir. Use `git init` command to specify it")
    end
    return root_dir;
end

M.init_project = function()
    L.root_dir = find_root_dir()

    local uri = L.root_dir .. "/.fuzzy-tag.db"
    L.sqlite_db = sqlite:extend {
        uri = uri,
        tags = {
            id = true,
            name = { "text", required = true, unique = true }
        },
        files = {
            id = true,
            file_path = { "text", required = true, unique = true },
        },
        files_tags = {
            file_id = { type = "integer", reference = "files.id" },
            tag_id = { type = "integer", reference = "tags.id" },
        },
        opts = { keep_open = false },
    }

    return uri;
end

local function get_or_insert_id(get_func, insert_func)
    local res = get_func()
    if #res == 0 then
        return insert_func()
    elseif #res > 1 then
        error("Tag duplicate found. It should never happen")
    else
        return res[1].id
    end
end

-- filepath must be relative to root dir
M.add_tag = function(file_path, tag_name)
    local tag_name_l = string.lower(tag_name)
    L.sqlite_db:with_open(function(db)
        local tag_id = get_or_insert_id(
            function() return db.tags:get { where = { name = tag_name_l } } end,
            function() return db.tags:insert { name = tag_name_l } end
        )
        local file_id = get_or_insert_id(
            function() return db.files:get { where = { file_path = file_path } } end,
            function() return db.files:insert { file_path = file_path } end
        )

        local is_exists = #db.files_tags:get { where = { file_id = file_id, tag_id = tag_id } }
        if is_exists == 1 then
            print("Warning! Tag has been already added to the current file")
            return
        end

        db.files_tags:insert { file_id = file_id, tag_id = tag_id }
    end)
end

M.get_tags = function(file_path)
    local query = [[
    SELECT tags.name FROM tags
    JOIN files_tags ON tags.id = files_tags.tag_id
    JOIN files ON files_tags.file_id = files.id
    WHERE files.file_path = ?
    ]]

    local tags = L.sqlite_db:with_open(function(db)
        return db:eval(query, file_path)
    end)

    if type(tags) ~= "table" then
        return {}
    end

    local output = {}
    for _, subtable in ipairs(tags) do
        for _, item in pairs(subtable) do
            table.insert(output, item)
        end
    end
    return output
end

-- True if tag deleted, otherwise false
M.remove_tag = function(file_path, tag_name)
    local tag_name_l = string.lower(tag_name)
    return L.sqlite_db:with_open(function(db)
        local tag = db.tags:get { where = { name = tag_name_l } }
        if #tag == 0 then
            print("Warning! Tag not found")
            return false
        end
        local tag_id = tag[1].id

        local file = db.files:get { where = { file_path = file_path } }
        if #file == 0 then
            print("Warning! File not found")
            return false
        end
        local file_id = file[1].id
        db.files_tags:remove { where = { file_id = file_id, tag_id = tag_id } }
        return true
    end)
end
return M;
