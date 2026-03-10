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
  copy_directories = {
    "lua",
    "plugin",
    "doc",
  },
}
