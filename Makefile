TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/

.PHONY: test
.PHONY: smoke

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}' }"

smoke:
	@nvim --headless -u NONE -i NONE -c "set rtp+=." -c "lua require('gui-keymap').setup({show_welcome=false})" -c "qa"
	@nvim --headless -u NONE -i NONE -c "set rtp+=." -c "runtime plugin/gui-keymap.lua" -c "lua print(vim.fn.exists(':GuiKeymapDemo')); print(vim.fn.exists(':GuiKeymapInfo')); print(vim.fn.exists(':GuiKeymapExplain'))" -c "qa"
	@nvim --headless -u NONE -i NONE -c "set rtp+=." -c "runtime plugin/gui-keymap.lua" -c "GuiKeymapDemo" -c "lua print(vim.bo.buftype); print(vim.bo.bufhidden)" -c "qa"
	@nvim --headless -u NONE -i NONE -c "set rtp+=." -c "lua require('gui-keymap').setup({show_welcome=false})" -c "checkhealth gui-keymap" -c "qa"
