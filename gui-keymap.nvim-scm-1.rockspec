package = "gui-keymap.nvim"
version = "scm-1"

source = {
  url = "git+https://github.com/Only-Moon/gui-keymap.nvim",
}

description = {
  summary = "GUI-style keymaps for Neovim users transitioning from GUI editors",
  homepage = "https://github.com/Only-Moon/gui-keymap.nvim",
  license = "MIT",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["gui-keymap"] = "lua/gui-keymap/init.lua",
    ["gui-keymap.clipboard"] = "lua/gui-keymap/clipboard.lua",
    ["gui-keymap.commands"] = "lua/gui-keymap/commands.lua",
    ["gui-keymap.config"] = "lua/gui-keymap/config.lua",
    ["gui-keymap.demo"] = "lua/gui-keymap/demo.lua",
    ["gui-keymap.health"] = "lua/gui-keymap/health.lua",
    ["gui-keymap.hints"] = "lua/gui-keymap/hints.lua",
    ["gui-keymap.info"] = "lua/gui-keymap/info.lua",
    ["gui-keymap.keymaps"] = "lua/gui-keymap/keymaps.lua",
    ["gui-keymap.onboard"] = "lua/gui-keymap/onboard.lua",
    ["gui-keymap.state"] = "lua/gui-keymap/state.lua",
    ["gui-keymap.utils"] = "lua/gui-keymap/utils.lua",
    ["gui-keymap.version"] = "lua/gui-keymap/version.lua",
  },
  copy_directories = {
    "plugin",
    "doc",
  },
}
