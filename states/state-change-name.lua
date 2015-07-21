local changename = {}

changename.layerTable = nil

changename.onFocus = function ( self )
end

changename.onLoad = function ( self )

  changename.layerTable = {}
  changename.clickables = {}

  changename.layer = MOAILayer2D.new ()
  menu.addTopBar(changename.layer, "My name", function ()
    statemgr.swap ( "states/state-settings.lua" )
  end)
  changename.layer:setViewport ( viewport )

  changename.layerTable [ 1 ] = { changename.layer }

  menu.makeBackground ( changename.layer )

  local textEdit = menu.makeButton ( { -SCREEN_UNITS_X / 2 + 10, 120, SCREEN_UNITS_X / 2 - 10, 160 } )
  menu.setButtonTexture( textEdit, "gfx/editbox.png" )
  menu.setButtonText ( textEdit, (globalData.config.name or multiplayer.name) .. "" )
  changename.layer.textEdit = textEdit
  -- local keys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "<",
  --         "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "!",
  --         "", "a", "s", "d", "f", "g", "h", "j", "k", "l",  ".",
  --         "", "", "z", "x", "c", "v", "b", "n", "m", "", " "}
  -- local keybuttons = {}
  -- local yOffset = 120
  -- local xOffset = -178

  -- for i, k in ipairs (keys) do
  --   if (i - 1) % 11 == 0 then
  --     yOffset = yOffset - 28
  --     xOffset = -178
  --   end
  --   local left = xOffset + 28
  --   xOffset = xOffset + 28
  --   local keybutton = menu.makeButton ( { left, yOffset - 12, left + 24, yOffset + 12 } )
  --   menu.setButtonText ( keybutton, k )
  --   if k == "<" then
  --     -- This is our delete button. So we need to erase instead of add.
  --     menu.setButtonCallback ( keybutton, function ()
  --       local text = menu.getButtonText ( textEdit ) or ""
  --       text = string.sub( text, 1, -2 )
  --       menu.changeButtonText ( changename.layer, textEdit, text )
  --     end)
  --     menu.setButtonTexture(keybutton, "gfx/bg2.png")
  --   else
  --     menu.setButtonCallback ( keybutton, function ()
  --       local text = menu.getButtonText ( textEdit ) or ""
  --       -- Limit string to a fixed length of 25.
  --       if string.len(text) > 25 then
  --         return
  --       end
  --       text = text .. k
  --       menu.changeButtonText ( changename.layer, textEdit, text )
  --     end )
  --     menu.setButtonTexture(keybutton, "gfx/black.png")
  --   end
  --   table.insert( keybuttons, keybutton )
  -- end

  local button2 = menu.makeButton ( menu.MENUPOS4 )
  menu.setButtonCallback (button2, (function ()
    local name = menu.getButtonText (textEdit) or ""
    if string.len(name) < 1 then
      return
    end
    globalData.config.name = name
    config:saveGame()
    statemgr.swap ( "states/state-settings.lua" )
  end))
  menu.setButtonText ( button2, "Save")

  local clearButton = menu.makeButton ( menu.MENUPOS5 )
  menu.setButtonCallback (clearButton, (function ()
    menu.changeButtonText(changename.layer, textEdit, "")
  end))
  menu.setButtonText ( clearButton, "Clear")

  menu.new(changename.layer, {textEdit, button2})
  Keyboard.showKeyBoard(menu.getButtonText(changename.layer.textEdit))
end

changename.onUnload = function ( self )
  Keyboard.hideKeyBoard()
  unloader.cleanUp(self)
end

changename.onUpdate = function ( self )
  local t = Keyboard.onUpdate()
  if not t then return end
  if t and menu.getButtonText(self.layer.textEdit) ~= t then
    if string.len(t) < 26 then
      menu.changeButtonText(self.layer, self.layer.textEdit, t)
    end
  end
end

changename.onInput = function ( self )
  menu.onInput ( self.layer )
end

return changename
