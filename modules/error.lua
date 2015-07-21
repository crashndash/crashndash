module("Error", package.seeall)

showError = function(string)
  globalData.infoTextText = string
  globalData.infoTextGfx = {gfx = "gfx/warning.png", width = 128, height = 128}
  globalData.infoTextSkipSupressButton = false
  statemgr.push("states/state-infotext.lua")
end
