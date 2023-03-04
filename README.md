# Fuzzy-tag.nvim

Fuzzy file search by tags.
For those who want to use the tag system and don't change a source file.


API functions
- init_project(project_root_dir) -- use git init
- add_tag(filepath, tag_name)
- get_tags(filepath)
- remove_tag(filepath, tag_name)
- fuzzy_search(user_input) (tags) -- files array


## Plugin Requerements 
- https://github.com/kkharji/sqlite.lua
- Telescope (Optional ui support)
- Plenary

