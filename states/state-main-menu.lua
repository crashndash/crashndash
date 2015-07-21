local mainMenu = {}
mainMenu.layerTable = nil

mainMenu.onFocus = function ( self )
end

mainMenu.onLoad = function ( self )

  -- Always reset high score on main menu, not matter how we got here.
  globalData.score = 0

  mainMenu.layerTable = {}

  mainMenu.layer = MOAILayer2D.new ()
  --menu.addTopBar(mainMenu.layer, "")
  mainMenu.layer:setViewport ( viewport )

  menu.makeBackground ( mainMenu.layer )

  mainMenu.layerTable [ 1 ] = { mainMenu.layer }

  local logo = util.getProp("gfx/logo.png", 44 * 5, 32 * 5, 0, 150)

  -- local textBox = util.makeText ( "Main Menu", SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 50, 50 )
  -- textBox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  mainMenu.layer:insertProp (logo)

  local play_online = menu.makeButton ( { -105, 50, 105, -10 }, false )
  menu.setButtonCallback (play_online, (function ( )
    statemgr.swap ( "states/state-game.lua" )
    statemgr.swap ( "states/state-multiplayer.lua" )
  end))
  menu.setButtonText ( play_online, "Play multiplayer!")
  menu.setButtonTexture(play_online, "gfx/menubg_ol.png")
  -- Add an id to this one too.
  play_online.id = "online"
  menu.setButtonTextPosition(play_online, {210, 40, 0, 30})

  mainMenu.layer.onlineTextBox = util.makeText ( "Offline", 150, 20, 0, 0, 8 )
  mainMenu.layer.onlineTextBox:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  mainMenu.layer:insertProp(mainMenu.layer.onlineTextBox)
  mainMenu.layer.onlineTextBox:setPriority(6)

  local play_quick = menu.makeButton ( { -105, -30, 105, -70 } )
  mainMenu.layer.quick_callback = function ( )
    -- Push game. Force level and world.
    globalData.config.currentWorld = "special"
    globalData.config.currentLevel = "quick"
    -- Make sure the infotext always shows on first game.
    globalData.skipQuickInfo = nil
    statemgr.swap("states/state-game.lua")
    -- Also start the game for the user.
    statemgr.pop()
  end
  menu.setButtonCallback (play_quick, mainMenu.layer.quick_callback)
  menu.setButtonText ( play_quick, "Quick game!" )

  local play_single = menu.makeButton ( { -105, -80, 105, -120 } )
  mainMenu.layer.single_callback = function ( )
    if globalData.config.currentWorld == "special" then
      globalData.config.currentLevel = 1
      globalData.config.currentWorld = 1
    end
    statemgr.swap ( "states/state-game.lua" )
  end
  menu.setButtonCallback (play_single, mainMenu.layer.single_callback)
  menu.setButtonText ( play_single, "Play singleplayer!" )

  local help_about = menu.makeButton ( { -105, -130, 105, -170 } )
  menu.setButtonCallback (help_about, (function ( )
    statemgr.swap ( "states/state-help.lua")
  end))
  menu.setButtonText ( help_about, "About / help!")

  menu.new ( mainMenu.layer, { play_online, play_single, help_about, play_quick } )
  if globalData.bgsound and globalData.bgsound.loaded and globalData.bgsound.playing then
    globalData.bgsound.playing = false
    globalData.bgsound.sound:pause ()
  end

  multiplayer.init()
  multiplayer.sendStats(function(task, code)
    if code == 204 then
      mainMenu.onLine = true
      mainMenu.users = task:getResponseHeader('X-opponents')
      globalData.crashedCars = task:getResponseHeader('X-crashes')
    end
  end )
  mainMenu.messageDelta = 0
end

mainMenu.onUnload = function ( self )
  unloader.cleanUp(self)
  mainMenu.buttons = {}
  mainMenu.onLine = nil
  mainMenu.onLineNotified = nil
end

mainMenu.onUpdate = function ( self )
  if self.onLine and not self.onLineNotified then
    self.onLineNotified = true
    local users = mainMenu.users or 1
    mainMenu.layer.onlineTextBox:setString("Online! " .. (users - 1) .. " playing.")
    for i, button in ipairs(self.layer.clickables) do
      if button.id and button.id == "online" then
        menu.changeButtonTexture(self.layer, button, "gfx/menubg_ol_on.png")
      end
    end
  end
  -- Try to post messages (errors and such) if we are online.
  if not self.inProgress then
    self.messageDelta = self.messageDelta + 1
    if globalData.config.messages[self.messageDelta] and globalData.config.messages[self.messageDelta].type and globalData.config.messages[self.messageDelta].message then
      self.inProgress = true
      local t = MOAIThread.new()
      t:run(function()
        Reporter.sendMessage(globalData.config.messages[self.messageDelta], function ( err )
          if not err then
            -- Everything went OK. Delete this message from the config.
            globalData.config.messages[self.messageDelta] = nil
            config:saveGame()
          end
          self.inProgress = nil
        end)
      end)
    end
  end
end

mainMenu.onInput = function ( self )
  menu.onInput ( mainMenu.layer )
end

return mainMenu

