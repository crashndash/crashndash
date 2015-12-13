local multiplayer_state = {}
multiplayer_state.layerTable = nil

multiplayer_state.onFocus = function ( self )
end

local tryToConnect = function (  )
  multiplayer_state.layer.loading:setString ( "Loading..." )
  multiplayer.connect ()
  multiplayer_state.triedtoconnect = true
end

local makeConnectMenu = function(layer)
  multiplayer.init()
  menu.clearScreen (layer)
  layer.loading:setString ( "" )
  layer.loading:setLoc(0, -50)
  -- Check if we have some suggestions.
  local buttonlist = {}
  local usedRooms = {}
  if multiplayer.onlineUsers then
    for d, u in next, multiplayer.onlineUsers, nil do
      -- Only care about users that we know where are playing.
      if u.room then
        local room = u.room
        usedRooms[room] = usedRooms[room] or 0
        usedRooms[room] = usedRooms[room] + 1
      end
    end
  end
  local x
  local y = 139
  local count = 0
  for r, c in next, usedRooms, nil do
    if #buttonlist < 6 and c < 4 then
      count = count + 1
      if count % 2 == 0 then
        x = 2
      else
        y = y - 50
        x = -140
      end
      local button = menu.makeButton({x, y + 24, x + 138, y - 24})
      button.room = r
      menu.setButtonCallback(button, function()
        menu.setButtonCallback(button, function (  )
          -- Set empty callback so user does not click 2 times.
        end)
        multiplayer.startGame(r, layer.loading)
      end)
      local textBox = util.makeText("Room #" .. r, 125, 20, x + 70, y + 10, 16)
      layer:insertProp(textBox)
      local users = util.makeText(c .. " online", 125, 20, x + 72, y - 10, 8)
      layer:insertProp(users)
      table.insert(layer.props, users)
      table.insert(layer.props, textBox)
      menu.setButtonText(button, "")
      menu.setButtonTexture(button, "gfx/background.png")
      table.insert(buttonlist, button)
    end
  end
  local button1 = menu.makeButton(menu.MENUPOS4)
  menu.setButtonCallback ( button1, function (  )
    statemgr.swap ( "states/state-startmulti.lua" )
  end)
  menu.setButtonText ( button1, "Enter room number" )

  if not MOAIGameCenterIOS then
    -- Add button to show best players.
    local lbButton = menu.makeButton(menu.MENUPOS5)
    menu.setButtonCallback(lbButton, function (  )
      Gamecenter.showLeaderboard()
    end)
    menu.setButtonText(lbButton, "Show top players")
    menu.new ( layer, { lbButton, button1, unpack(buttonlist) } )
  else
    menu.new ( layer, { button1, unpack(buttonlist) } )
  end
end

multiplayer_state.onLoad = function ( self )

  multiplayer.connected = false

  multiplayer_state.layerTable = {}

  multiplayer_state.layer = MOAILayer2D.new ()
  multiplayer_state.layer.props = {}
  menu.addTopBar(multiplayer_state.layer, "Multiplayer", function ()
    statemgr.pop ()
    statemgr.swap ( "states/state-main-menu.lua" )
  end)
  multiplayer_state.layer:setViewport ( viewport )

  menu.makeBackground ( multiplayer_state.layer, true, "gfx/skiesbg.png", menu.MENUBG_HORIZONTAL, 1 )

  multiplayer_state.layerTable [ 1 ] = { multiplayer_state.layer }

  multiplayer_state.layer.loading = util.makeText ( "", SCREEN_UNITS_X - 20, 80, 0, 40, 16 )
  multiplayer_state.layer.loading:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  multiplayer_state.layer:insertProp ( multiplayer_state.layer.loading )

  -- Make a kind of "status" screen for this user.
  local statsScreen = util.getProp("gfx/background.png", SCREEN_UNITS_X - 40, 80, 0, SCREEN_UNITS_Y / 2 - 85)
  multiplayer_state.layer:insertProp(statsScreen)

  local userIcon = util.getProp("gfx/user.png", 8, 10, -115, SCREEN_UNITS_Y / 2 - 60)
  multiplayer_state.layer:insertProp(userIcon)
  table.insert(multiplayer_state.layer.props, userIcon)

  local userName = util.makeText(multiplayer.name, SCREEN_UNITS_X - 40, 20, 40, SCREEN_UNITS_Y / 2 - 62, 16)
  multiplayer_state.layer:insertProp(userName)
  multiplayer_state.layer.insertedName = multiplayer.name
  table.insert(multiplayer_state.layer.props, userName)

  local matches = globalData.config.achievements.multiplay20 or 0
  local myCars = tonumber(globalData.crashedCars) or 0
  -- Try to calculate user level.
  local level
  local levelBase = 0
  if matches > 0 then
    levelBase = matches * 100
  end
  if myCars > 0 then
    levelBase = levelBase + myCars * 10
  end
  if levelBase > 0 then
    level = math.floor(levelBase / 1500)
  end
  if not level or level < 1 then
    level = 1
  end

  if myCars == 0 and multiplayer.connecterror then
    level = "???"
    myCars = "???"
  end

  local userData = util.makeText("MULTIPLAYER STATISTICS: \nMatches won: " .. matches .. "\nCars crashed: " .. myCars .. "\nPlayer level: " .. level, SCREEN_UNITS_X - 40, 40, 20, 150, 8)
  multiplayer_state.layer:insertProp(userData)
  table.insert(multiplayer_state.layer.props, userData)

  multiplayer_state.loadingtext = true

  multiplayer_state.triedtoconnect = false
  menu.new(multiplayer_state.layer, {})

  -- Try to connect to the platform gamecenter.
  if not MOAIGameCenterIOS then
    Gamecenter.connect(function()
      globalData.config.hasAskedGameCenter = true
      config:saveGame()
      if type(myCars) == "number" then
        -- Save in the super cloud what we are doing.
        Gamecenter.reportScore(myCars)
      end
    end)
  end

  -- See if person has a "generated" name.
  if globalData.config.hasAskedGameCenter and string.match(multiplayer.name, "player") then
    if not globalData.config.askedToChangeName then
      globalData.config.askedToChangeName = true
      if MOAIDialogAndroid then
        MOAIDialog = MOAIDialogAndroid
      end
      if MOAIDialog then
        MOAIDialog.showDialog("Add name?", "Do you want to enter your name?\n(Currently using " .. multiplayer.name .. ")", "Yes", nil, "No", false, function (answer)
          if answer == MOAIDialog.DIALOG_RESULT_POSITIVE then
            -- Erase name, as player probably wants to start from scratch.
            globalData.config.name = ""
            statemgr.push("states/state-change-name.lua")
            -- Override backbutton for next screen. How flexible.
            local ls = statemgr.getCurState()
            local overrideFunction = function ()
              statemgr.pop()
            end
            menu.setButtonCallback(ls.layer.backbutton, overrideFunction)
            -- Find the "save" button and override that as well
            for i, b in ipairs(ls.layer.clickables) do
              if b.text == "Save" then
                local cb = b.callback
                menu.setButtonCallback(b, function()
                  cb()
                  if multiplayer.name ~= "" then
                    multiplayer.name = globalData.config.name
                    overrideFunction()
                  end
                end)
              end
            end
          end
        end)
      end

    end
  end
end

multiplayer_state.onUnload = function ( self )
  unloader.cleanUp(self)
  self.layer.errorwarned = nil
  self.FBwarned = nil
  self.connectmenu = nil
  self.madeTeaparty = nil
  self.triedtoconnect = nil
  self.buttons = {}
end

multiplayer_state.onUpdate = function ( self )
  -- See if we have updated our name.
  if multiplayer_state.layer.insertedName ~= multiplayer.name then
    statemgr.swap("states/state-multiplayer.lua")
    return
  end

  if not multiplayer.teapot then
    multiplayer.connected = false
    self.FBwarned = true
    self.triedtoconnect = true
    if not self.madeTeaparty then
      self.madeTeaparty = true
      self.layer.loading:setString ( "You are using an old version of the game. Please upgrade to play multiplayer" )
      -- Clear screen.
      menu.clearScreen ( self.layer )
      -- Add a few buttons.
      local button1 = menu.makeButton ( menu.MENUPOS5 )
      menu.setButtonCallback(button1, function (  )
        local url = "http://itunes.com/apps/crashndash"
        if MOAIAppAndroid then
          url = "market://details?id=no.morland.roadrage"
        end
        util.openURL(url)
      end)
      menu.setButtonText(button1, "Upgrade!")
      menu.new ( multiplayer_state.layer, { button1 } )
      return
    end
  end
  if not multiplayer_state.triedtoconnect then
    tryToConnect ()
  end
  if multiplayer.connected then
    if not multiplayer.teapot then
      statemgr.swap ( "states/state-multiplayer.lua" )
      return
    end
    if not multiplayer_state.connectmenu then
      multiplayer.sendStats()
      multiplayer_state.connectmenu = true
      makeConnectMenu(self.layer)
      if multiplayer.rewards > 0 then
        -- Wooohoo, a reward just for connecting. What a lucky person!
        self.layer.popups = self.layer.popups or {}
        table.insert( self.layer.popups, Popup.new ( 'Congratulations! A bonus of ' .. multiplayer.rewards .. ' was awarded you from the server!', self.layer ))
        globalData.config.expPoints = globalData.config.expPoints + multiplayer.rewards
        config:saveGame()
        multiplayer.rewards = 0
      end
    end
  end
  achmng.onUpdate ( self.layer )
  if multiplayer.connecterror and not self.layer.errorwarned then
    self.layer.errorwarned = true
    if multiplayer.connecterror == 0 then
      -- User is most likely not connected to the internet.
      self.layer.loading:setString ( "Could not reach the multiplayer server. Are you sure you are online?" )

    else
      self.layer.loading:setString ( "We are experiencing some problems with the server. Try again later..." )
    end
  end
end

multiplayer_state.onInput = function ( self )
  menu.onInput(self.layer)
end

return multiplayer_state
