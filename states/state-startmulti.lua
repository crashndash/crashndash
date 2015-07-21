local startmulti = {}

startmulti.layerTable = nil

startmulti.onFocus = function ( self )
end

startmulti.onLoad = function ( self )

  startmulti.layerTable = {}
  startmulti.clickables = {}

  startmulti.layer = MOAILayer2D.new ()
  menu.addTopBar(startmulti.layer, "Join room", function ()
    statemgr.swap ("states/state-multiplayer.lua")
  end)
  startmulti.layer:setViewport ( viewport )

  startmulti.layerTable [ 1 ] = { startmulti.layer }

  menu.makeBackground ( startmulti.layer )

  local textguide = "Players online: " .. multiplayer.totalPlayers .. "\n" ..
    "Room suggestion: " .. multiplayer.roomSuggestion .. " (" .. multiplayer.roomPlayers .. " playing).\n\n" ..
    "Enter room to start or join:"
  local textBox2 = util.makeText ( textguide, SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 120, 15 )
  textBox2:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  startmulti.layer:insertProp ( textBox2 )

  local textEdit = menu.makeButton ( { -SCREEN_UNITS_X / 2 + 10, 0, SCREEN_UNITS_X / 2 - 10, 40 } )
  menu.setButtonTexture( textEdit, "gfx/editbox.png" )
  menu.setButtonText ( textEdit, multiplayer.roomSuggestion .. "" )
  startmulti.layer.textEdit = textEdit
  local keytable = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "<"}
  local keybuttons = {}

  -- for i, k in ipairs (keytable) do
  --   local xOffset = 10
  --   local left = (-util.halfX + xOffset) + (i -1) * 28
  --   local keybutton = menu.makeButton ( { left, -50, left + 25, -10 } )
  --   menu.setButtonText ( keybutton, k )
  --   if k == "<" then
  --     -- This is our delete button. So we need to erase instead of add.
  --     menu.setButtonCallback ( keybutton, function ()
  --       local text = menu.getButtonText ( textEdit ) or ""
  --       text = string.sub( text, 1, -2 )
  --       menu.changeButtonText ( startmulti.layer, textEdit, text )
  --     end)
  --   else
  --     menu.setButtonCallback ( keybutton, function ()
  --       local text = menu.getButtonText ( textEdit ) or ""
  --       if string.len(text) > 10 then
  --         -- Do we really have more than 999999999 rooms busy? I doubt it.
  --         -- You, my good sir, should stop joining rooms with such long names.
  --         return
  --       end
  --       text = text .. k
  --       menu.changeButtonText ( startmulti.layer, textEdit, text )
  --     end )
  --   end
  --   table.insert( keybuttons, keybutton )
  -- end

  startmulti.layer.textEdit = textEdit

  local button1 = menu.makeButton ( menu.MENUPOS5 )
  menu.setButtonCallback (button1, (function ()
    local name = menu.getButtonText ( textEdit ) or ""
    if string.len(name) < 1 then
      return
    end
    if name == "1984" or name == "1983" then
      -- Woohoo. It's easter eggs!
      globalData.brsound = util.getSound ( "sound/burninrubber.ogg" )
      -- That person better not start playing right away, because then he will
      -- get double music playing...
      if globalData.bgsound.playing then
        globalData.bgsound.sound:pause ()
        globalData.bgsound.playing = false
      end
      globalData.brsound:play ()
    end
    menu.setButtonCallback(button1, function (  )
      -- Set empty callback so user does not click 2 times.
    end)
    multiplayer.startGame ( name, textBox2 )
  end))
  menu.setButtonText(button1, "Start")

  menu.new(startmulti.layer, {textEdit, button1})
  Keyboard.showKeyBoard(multiplayer.roomSuggestion .. "", Keyboard.NUMBERS)

end

startmulti.onUnload = function ( self )
  Keyboard.hideKeyBoard()
  unloader.cleanUp(self)
end

startmulti.onUpdate = function ( self )
  local t = Keyboard.onUpdate()
  -- Since the keyboard allows for different kinds of characters, we make sure
  -- the input is an int. And since 1.2 is type(number), we chack all characters
  -- to make sure they are numbers, ergo making up an int.
  if type(t) ~= "string" then return end
  for i = 1, string.len(t) do
    local c = string.sub(t, i, i)
    if not tonumber(c) then
      Keyboard.showKeyBoard(menu.getButtonText(self.layer.textEdit), Keyboard.NUMBERS)
      return
    end
  end
  if t and menu.getButtonText(self.layer.textEdit) ~= t then
    if string.len(t) < 11 then
      menu.changeButtonText(self.layer, self.layer.textEdit, t)
    end
  end
end

startmulti.onInput = function ( self )
  menu.onInput(self.layer)
end

return startmulti
