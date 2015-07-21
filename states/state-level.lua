local level_state = {}
level_state.layerTable = nil

level_state.onFocus = function ( self )

end

local multiplayerMenu = function ( layer )
  local button1 = menu.makeButton ( menu.MENUPOS2 )
  menu.setButtonCallback (button1, (function ()
    statemgr.pop ()
    multiplayer.sendMessage ( "startover", multiplayer.room )
  end))
  menu.setButtonText ( button1, "Start")
  if multiplayer.alone then
      -- This dude is all alone. And must wait to play.
    menu.setButtonCallback ( button1, function (  )
      -- Empty function.
    end )
    menu.setButtonText ( button1, "waiting for opponents..." )
    menu.setButtonTextSize ( button1, 16 )
    menu.setButtonTexture ( button1, "gfx/trans.png" )
    layer.isWaitingForOpponents = true
  end

  layer.backButtonCallback = function (  )
    multiplayer.connected = false
    multiplayer.alone = false
    game.levelNumber = 1
    game.loadLevel ( 1, 1 )
    game.level.multiplayer = false
    statemgr.swap ( "states/state-multiplayer.lua" )
  end

  -- Add some polite nagging about sharing on facebook.

  local sharetext = util.makeText("Invite your friends, and earn experience points!", SCREEN_UNITS_X - 40, 50, 0, -20, 16)
  sharetext:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  layer:insertProp(sharetext)

  table.insert(layer.buttons, button1)

  -- Construct a share URL.
  local shareUrl = "http%3A%2F%2Fcrashndash.com%2Fplay%3Froom%3D" .. multiplayer.room .. "%26referrer%3D" .. multiplayer.id

  -- Add some sharing options.
  local shareOnFb = menu.makeButton(menu.MENUPOS4)
  menu.setButtonText(shareOnFb, "Invite Facebook friends")
  menu.setButtonCallback(shareOnFb, function (  )
    util.openURL("https://www.facebook.com/sharer/sharer.php?u=" .. shareUrl)
  end)
  table.insert(layer.buttons, shareOnFb)

  local shareOnTw = menu.makeButton(menu.MENUPOS5)
  menu.setButtonText(shareOnTw, "Invite people on twitter")
  menu.setButtonCallback(shareOnTw, function ()
    util.openURL("https://twitter.com/intent/tweet?text=Playing%20Crash%20n%20Dash%20in%20room%20" .. multiplayer.room .. "%20" .. shareUrl  .. "%20%23crashndash")
  end)
  table.insert(layer.buttons, shareOnTw)
end

local regularMenu = function ( layer )

  local button1 = menu.makeButton ( menu.MENUPOS2 )
  menu.setButtonCallback (button1, (function ()
    statemgr.pop ()
  end))
  menu.setButtonText ( button1, "Start")

  local button2 = menu.makeButton ( menu.MENUPOS3 )
  menu.setButtonCallback (button2, (function ()
    statemgr.pop ()
    statemgr.swap ( "states/state-level-chooser.lua" )
  end))
  menu.setButtonText ( button2, "Choose level")

  local button4 = menu.makeButton ( menu.MENUPOS4 )
  button4.survival = true
  menu.setButtonCallback ( button4, function ()
    game.levelNumber = "survival"
    game.loadLevel ( "survival", "special" )
    -- Pop back state-level.
    statemgr.pop()
    statemgr.swap ( "states/state-game.lua" )
    statemgr.pop()
  end )
  menu.setButtonText ( button4, "Survival mode" )

  local loadLevel = menu.makeButton(menu.MENUPOS5)
  menu.setButtonCallback(loadLevel, function (  )
    statemgr.pop()
    statemgr.swap("states/state-loadlevel.lua")
  end)
  menu.setButtonText(loadLevel, "Find level online!")

  layer.backButtonCallback = function (  )
    statemgr.pop ()
    statemgr.swap( "states/state-main-menu.lua" )
  end

  local hiddenbutton = menu.makeButton ( { SCREEN_UNITS_X / 2 - 40, SCREEN_UNITS_Y / 2 - 40, SCREEN_UNITS_X / 2 - 20, SCREEN_UNITS_Y / 2 - 20 } )
  menu.setButtonTexture ( hiddenbutton, "gfx/trans.png" )
  menu.setButtonCallback ( hiddenbutton, function (  )
    globalData.config.carType = "whitecar"
    statemgr.pop ()
    statemgr.swap ( "states/state-game.lua" )
    local state = statemgr.getCurState ()
    achmng.sendAchievements ( state.layer )
  end )
  table.insert( layer.buttons, button1 )
  table.insert( layer.buttons, button2 )
  table.insert( layer.buttons, hiddenbutton )
  table.insert( layer.buttons, loadLevel )

  if globalData.config.expBought.survival then
    table.insert( layer.buttons, button4 )
  end
end


level_state.onLoad = function ( self )
  level_state.layerTable = {}

  level_state.layer = MOAILayer2D.new ()
  local levelTitle = "Level " .. game.worldNumber .. "-" .. game.levelNumber
  if game.level.useLevelNumberAsTitle then
    levelTitle = game.levelNumber
  end
  if game.level.name then
    levelTitle = game.level.name
  end
  level_state.layer:setViewport ( viewport )

  menu.makeBackground ( level_state.layer )

  local starsplaced = 1
  local xpos = -30
  local scorelevel = game.levelNumber
  if game.level.name then
    scorelevel = game.level.name
  end
  if globalData.config.doneWorlds[game.worldNumber][scorelevel] then
    while starsplaced < 4 do
      local filename = "gfx/star-off.png"
      if globalData.config.doneWorlds[game.worldNumber][scorelevel] >= starsplaced then
        filename = "gfx/star-on.png"
      end
      local prop  = util.getProp ( filename, 15, 16, xpos, SCREEN_UNITS_Y / 2 - 68 )
      level_state.layer:insertProp ( prop )
      starsplaced = starsplaced + 1
      xpos = xpos + 30
    end
  end

  if globalData.config.worldScores[game.worldNumber][scorelevel] then
    local bestText = util.makeText ( "Personal best:  " .. globalData.config.worldScores[game.worldNumber][scorelevel], SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 50, 16 )
    bestText:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
    level_state.layer:insertProp ( bestText )
  end

  local tagline = util.makeText ( game.level.tagline , SCREEN_UNITS_X - 40, 100, 0, 80, 16 )
  tagline:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  level_state.layer:insertProp ( tagline )

  local carType = globalData.config.carType or "redcar"
  level_state.carType = carType
  local pr = Car.carProperties[carType]
  level_state.carProp = util.getProp ( "gfx/" .. carType .. ".png", pr.width, pr.height, -40, 130 )
  level_state.layer:insertProp ( level_state.carProp )


  local carbutton = menu.makeButton( {-70, 100, 70, 160})
  menu.setButtonText ( carbutton, "     Change\n     car" )
  menu.setButtonCallback ( carbutton, function (  )
    game.saveLevel()
    statemgr.pop()
    statemgr.swap( "states/state-choose-car.lua" )
  end )
  menu.setButtonTexture ( carbutton, "gfx/carbg.png" )

  level_state.layer.buttons = {}
  table.insert(level_state.layer.buttons, carbutton)

  if game.levelNumber == 'multiplayer' then
    multiplayerMenu ( level_state.layer )
  else
    regularMenu ( level_state.layer )
  end

  menu.addTopBar(level_state.layer, levelTitle, level_state.layer.backButtonCallback)

  menu.new ( level_state.layer, { unpack(level_state.layer.buttons) } )

  level_state.layerTable [ 1 ] = { level_state.layer }
end

level_state.onUnload = function ( self )
  unloader.cleanUp(self)
end

level_state.onUpdate = function ( self )
  if game.levelNumber == 'multiplayer' then
    if self.layer.isWaitingForOpponents and not multiplayer.alone then
      self.layer.isWaitingForOpponents = nil
      -- Hooray! Not forever alone. Let's just push this state again, and things
      -- will start to work.
      statemgr.swap ( "states/state-level.lua" )
    end
  end
  achmng.onUpdate ( self.layer )
end

level_state.onInput = function ( self )
  menu.onInput ( level_state.layer )
end

return level_state
