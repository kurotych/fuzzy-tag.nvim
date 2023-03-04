describe("fuzzy_tag lua api tests", function()
    local fuzzy_tag = require('fuzzy-tag')
    local db_uri = nil;

    before_each(function()
        db_uri = fuzzy_tag.init_project()
    end)

    after_each(function()
        vim.loop.fs_unlink(db_uri)
    end)

    it("Add same tag twice", function()
        fuzzy_tag.add_tag("./README.md", "readme")
        fuzzy_tag.add_tag("./README.md", "readme")
        local tags = fuzzy_tag.get_tags("./README.md")
        assert.are.same(tags, { "readme" })
    end)

    it("get_tags empty result", function()
        assert.are.same(fuzzy_tag.get_tags("./README.md"), {})
    end)

    it("Add the same tag twice", function()
        fuzzy_tag.add_tag("./README.md", "readme")
        fuzzy_tag.add_tag("./README.md", "markdown")
        local tags = fuzzy_tag.get_tags("./README.md")
        assert.are.same(tags, { "readme", "markdown" })
    end)

    it("Delete tag", function()
        fuzzy_tag.add_tag("./README.md", "readme")
        fuzzy_tag.add_tag("./README.md", "markdown")
        local tags = fuzzy_tag.get_tags("./README.md")
        assert.are.same(tags, { "readme", "markdown" })
        assert.equals(fuzzy_tag.remove_tag("./README.md", "readme2"), false)
        assert.equals(fuzzy_tag.remove_tag("./README.md", "readme"), true)
        tags = fuzzy_tag.get_tags("./README.md")
        assert.are.same(tags, { "markdown" })
    end)


    it("Fuzzy search part of first tag", function()
        fuzzy_tag.add_tag("./README.md", "markdown")

        fuzzy_tag.add_tag("./README.md", "readme")
        fuzzy_tag.add_tag("./README2.md", "readyou")
        fuzzy_tag.add_tag("./README2.md", "readthem")
        local tags = fuzzy_tag.fuzzy_search("read")
        assert.are.same(tags, { "./README2.md", "./README.md" })

        tags = fuzzy_tag.fuzzy_search("readme")
        assert.are.same(tags, { "./README.md" })
    end)


    it("Fuzzy search part of first tag", function()
        fuzzy_tag.add_tag("./README.md", "markdown")

        fuzzy_tag.add_tag("./README.md", "readme")
        fuzzy_tag.add_tag("./README2.md", "readyou")
        fuzzy_tag.add_tag("./README2.md", "readthem")
        local tags = fuzzy_tag.fuzzy_search("read")
        assert.are.same(tags, { "./README2.md", "./README.md" })

        tags = fuzzy_tag.fuzzy_search("readme")
        assert.are.same(tags, { "./README.md" })
    end)

    it("Exact match is preoritized", function()
        fuzzy_tag.add_tag("./README.md", "readme")
        fuzzy_tag.add_tag("./README2.md", "read")
        local tags = fuzzy_tag.fuzzy_search("read")
        assert.are.same(tags, { "./README2.md", "./README.md" })
    end)

    it("Exact match is preoritized(2)", function()
        fuzzy_tag.add_tag("./README2.md", "read")
        fuzzy_tag.add_tag("./README.md", "readme")
        local tags = fuzzy_tag.fuzzy_search("read")
        assert.are.same(tags, { "./README2.md", "./README.md" })
    end)

    it("Two tags match preoritized", function()
        fuzzy_tag.add_tag("./README.md", "readme")
        fuzzy_tag.add_tag("./README2.md", "markdown")
        fuzzy_tag.add_tag("./README2.md", "code")

        local tags = fuzzy_tag.fuzzy_search("markdown code")

        assert.are.same(tags, { "./README2.md" })
    end)

    it("fuzzy_search. No one matched", function()
        fuzzy_tag.add_tag("./README.md", "testtag1")
        fuzzy_tag.add_tag("./README.md", "testtag2")
        fuzzy_tag.add_tag("./README.md", "tag3")
        fuzzy_tag.add_tag("./README2.md", "testtag1")
        fuzzy_tag.add_tag("./README2.md", "tag3")
        fuzzy_tag.add_tag("./src/main.lua", "testtag1")
        fuzzy_tag.add_tag("./src/main.lua", "testtag2")
        local result = fuzzy_tag.fuzzy_search("test tag2")
        assert(type(result) == "table")
        assert(#result == 0)

        result = fuzzy_tag.fuzzy_search("test")
        assert(#result == 3)
    end)

    it("remove_tag removes a tag from a file", function()
        fuzzy_tag.add_tag("./README.md", "testtag")
        local success = fuzzy_tag.remove_tag("./README.md", "testtag")
        assert(type(success) == "boolean")
        assert(success == true)
        local tags = fuzzy_tag.get_tags("./README.md")
        assert(type(tags) == "table")
        assert(#tags == 0)
    end)

    it("get_tags returns all tags associated with a file", function()
        fuzzy_tag.add_tag("./README.md", "testtag1")
        fuzzy_tag.add_tag("./README.md", "testtag2")
        fuzzy_tag.add_tag("./README.md", "testtag3")
        local tags = fuzzy_tag.get_tags("./README.md")
        assert(type(tags) == "table")
        assert(#tags == 3)
        assert(tags[1] == "testtag1")
        assert(tags[2] == "testtag2")
        assert(tags[3] == "testtag3")
    end)

    it("add_tag adds a tag to a file", function()
        fuzzy_tag.add_tag("./README.md", "testtag")
        local tags = fuzzy_tag.get_tags("./README.md")
        assert(type(tags) == "table")
        assert(#tags == 1)
        assert(tags[1] == "testtag")
    end)


    -- Test case for M.fuzzy_search()
    it("fuzzy_search returns matching files for a query", function()
        fuzzy_tag.add_tag("./README.md", "testtag1")
        fuzzy_tag.add_tag("./README.md", "testtag2")
        fuzzy_tag.add_tag("./README.md", "tag3")
        fuzzy_tag.add_tag("./README2.md", "testtag1")
        fuzzy_tag.add_tag("./README2.md", "tag3")
        fuzzy_tag.add_tag("./src/main.lua", "testtag1")
        fuzzy_tag.add_tag("./src/main.lua", "testtag2")

        -- Test a query that matches multiple files
        local result = fuzzy_tag.fuzzy_search("test tag3")
        assert(type(result) == "table")
        assert(#result == 2)
        assert(result[1] == "./README2.md")
        assert(result[2] == "./README.md")

        -- Test a query that matches only one file
        result = fuzzy_tag.fuzzy_search("tag3")
        assert(#result == 2)
        assert(result[1] == "./README2.md")
        assert(result[2] == "./README.md")

        --Test a query that doesn't match any files
        result = fuzzy_tag.fuzzy_search("foo bar")
        assert(type(result) == "table")
        assert(#result == 0)
    end)
end)
