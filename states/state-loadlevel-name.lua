local loadlevel_name = {}

loadlevel_name.layerTable = nil

loadlevel_name.onFocus = function ( self )
end

loadlevel_name.onLoad = function ( self )

  loadlevel_name.layerTable = {}
  loadlevel_name.clickables = {}

  loadlevel_name.layer = MOAILayer2D.new ()
  menu.addTopBar(loadlevel_name.layer, "Load level", function ()
    statemgr.swap ( "states/state-loadlevel.lua" )
  end)
  loadlevel_name.layer:setViewport ( viewport )

  loadlevel_name.layerTable [ 1 ] = { loadlevel_name.layer }

  menu.makeBackground ( loadlevel_name.layer )

  local textEdit = menu.makeButton ( { -SCREEN_UNITS_X / 2 + 10, 120, SCREEN_UNITS_X / 2 - 10, 160 } )
  menu.setButtonTexture( textEdit, "gfx/editbox.png" )
  menu.setButtonText ( textEdit, "")
  loadlevel_name.layer.textEdit = textEdit

  local loadButton = menu.makeButton ( menu.MENUPOS4 )
  menu.setButtonCallback (loadButton, (function ()
    -- Try to find out what we are looking for.
    local levelName = menu.getButtonText(self.layer.textEdit)
    if levelName and levelName ~= "" then
      LevelEditor.load(levelName, function(task, responsecode)
        if responsecode == 404 then
          Error.showError("No level found with that name, sorry!")
          return
        end
        if responsecode ~= 200 then
          Error.showError("We are having some problems loading this level. Sorry.")
          return
        end
        local level = MOAIJsonParser.decode(task:getString())
        EmptyLevel.setLevel(level)
        EmptyLevel.setOffsets(level.offsets)
        EmptyLevel.setPowerups(level.powerups)
        EmptyLevel.setBlocks(level.blocks)
        globalData.config.currentLevel = "emptylevel"
        globalData.config.currentWorld = "special"
        -- Then we need to go back to level, and push game state again.
        statemgr.pop()
        statemgr.swap( "states/state-game.lua" )
      end)
    end
  end))
  menu.setButtonText ( loadButton, "Load")

  menu.new(loadlevel_name.layer, {textEdit, loadButton})
  loadlevel_name.layer.loadButton = loadButton
  Keyboard.showKeyBoard(menu.getButtonText(loadlevel_name.layer.textEdit))
end

loadlevel_name.onUnload = function ( self )
  Keyboard.hideKeyBoard()
  unloader.cleanUp(self)
end

loadlevel_name.onUpdate = function ( self )
  local t = Keyboard.onUpdate()
  if not t then return end
  if t and menu.getButtonText(self.layer.textEdit) ~= t then
    if string.len(t) < 26 then
      menu.changeButtonText(self.layer, self.layer.textEdit, t)
    end
  end
end

loadlevel_name.onInput = function ( self )
  menu.onInput ( self.layer )
end

return loadlevel_name
