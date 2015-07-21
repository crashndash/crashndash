local play = {}
play.layerTable = nil

play.onFocus = function ( self )

end

play.onLoad = function ( self )
  play.layerTable = {}

  play.layer = MOAILayer2D.new ()
  menu.addTopBar(play.layer, "Play", function ()
    statemgr.swap ( "states/state-main-menu.lua" )
  end)
  play.layer:setViewport ( viewport )

  menu.makeBackground ( play.layer )

  play.layerTable [ 1 ] = { play.layer }

  -- local textBox = util.makeText ( "play ", SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 50, 50 )
  -- textBox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  -- play.layer:insertProp ( textBox )

  local button1 = menu.makeButton ( { -105, 50, 105, -10 } )
  menu.setButtonCallback (button1, (function ()
    if globalData.config.currentLevel == "multiplayer" then
      globalData.config.currentLevel = 1
      globalData.config.currentWorld = 1
    end
    if multiplayer.connected then
      multiplayer.connected = false
      multiplayer.alone = false
    end
    globalData.score = 0
    statemgr.swap ( "states/state-game.lua" )
  end))
  menu.setButtonText ( button1, "Play game")

  local button2 = menu.makeButton ( { -105, -20, 105, -80 } )
  menu.setButtonCallback (button2, (function ()
    statemgr.swap ( "states/state-game.lua" )
    statemgr.swap ( "states/state-multiplayer.lua" )
  end))
  menu.setButtonText ( button2, "Play multiplayer")
  menu.setButtonTextSize ( button2, 18 )

  local button3 = menu.makeButton ( { -105, -90, 105, -150 } )
  menu.setButtonText ( button3, "back to menu")
  menu.new ( play.layer, { button1, button2 } )
end

play.onUnload = function ( self )
  unloader.cleanUp(self)
end

play.onInput = function ( self )
  menu.onInput ( play.layer )
end

return play
