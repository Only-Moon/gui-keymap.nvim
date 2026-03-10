param(
  [string]$Nvim = "nvim"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$rtp = $root -replace "\\", "/"

function Invoke-NvimCheck {
  param(
    [string]$Name,
    [string[]]$Args
  )

  Write-Host "== $Name =="
  & $Nvim @Args
  if ($LASTEXITCODE -ne 0) {
    throw "$Name failed with exit code $LASTEXITCODE"
  }
}

Invoke-NvimCheck "Headless load" @(
  "--headless", "-u", "NONE", "-i", "NONE",
  "-c", "set rtp+=$rtp",
  "-c", "lua require('gui-keymap').setup({show_welcome=false})",
  "-c", "qa"
)

Invoke-NvimCheck "Command registration" @(
  "--headless", "-u", "NONE", "-i", "NONE",
  "-c", "set rtp+=$rtp",
  "-c", "runtime plugin/gui-keymap.lua",
  "-c", "lua print(vim.fn.exists(':GuiKeymapDemo')); print(vim.fn.exists(':GuiKeymapInfo')); print(vim.fn.exists(':GuiKeymapExplain'))",
  "-c", "qa"
)

Invoke-NvimCheck "Demo buffer" @(
  "--headless", "-u", "NONE", "-i", "NONE",
  "-c", "set rtp+=$rtp",
  "-c", "runtime plugin/gui-keymap.lua",
  "-c", "GuiKeymapDemo",
  "-c", "lua print(vim.bo.buftype); print(vim.bo.bufhidden)",
  "-c", "qa"
)

Invoke-NvimCheck "Healthcheck" @(
  "--headless", "-u", "NONE", "-i", "NONE",
  "-c", "set rtp+=$rtp",
  "-c", "lua require('gui-keymap').setup({show_welcome=false})",
  "-c", "checkhealth gui-keymap",
  "-c", "qa"
)

Invoke-NvimCheck "Plenary tests" @(
  "--headless", "--noplugin",
  "-u", "tests/minimal_init.lua",
  "-c", "PlenaryBustedDirectory tests { minimal_init = 'tests/minimal_init.lua' }",
  "-c", "qall"
)

Write-Host "All gui-keymap smoke checks passed."
