-- Alacritty
hs.hotkey.bind({"option"}, "/", function()
    alacritty = hs.application.find('alacritty')
    if alacritty then
      awin = alacritty:mainWindow()
    end
    if awin and alacritty and alacritty:isFrontmost() then
      alacritty:hide()
    else
      hs.application.launchOrFocus("/Applications/Alacritty.app")
      local alacritty = hs.application.find('alacritty')
      alacritty.setFrontmost(alacritty)
      alacritty.activate(alacritty)
    end
  end
)
-- Visual Studio Code
hs.hotkey.bind({"option"}, "\\", function()
  code = hs.application.find('Code')
  if code then
    awin = code:mainWindow()
  end
  if awin and code and code:isFrontmost() then
    code:hide()
  else
    hs.application.launchOrFocus("/Applications/Visual Studio Code.app")
    local code = hs.application.find('code')
    code.setFrontmost(code)
    code.activate(code)
  end
end
)