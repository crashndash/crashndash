local win = {}
win.layerTable = nil

win.onFocus = function ( self )
end

win.onLoad = function ( self )
  win.layerTable = {}
  win.clickables = {}

  win.layer = MOAILayer2D.new ()
  menu.addTopBar(win.layer, "You won!" )
  win.layer:setViewport ( viewport )

  win.layerTable [ 1 ] = { win.layer }

  menu.makeBackground ( win.layer, true, "gfx/skiesbg.png", menu.MENUBG_HORIZONTAL, 1 )

  -- Make level 1 the global current level.
  globalData.config.currentLevel = 1
  globalData.config.currentWorld = 1

  textBox = util.makeText ( "Score: " .. globalData.score, SCREEN_UNITS_X, 30, 0, 140 )
  textBox:setTextSize ( 24 )
  textBox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )

  win.layer:insertProp ( textBox )

  local button1 = menu.makeButton ( menu.MENUPOS1 )
  menu.setButtonCallback (button1, (function ( )
    statemgr.swap ( "states/state-game.lua")
  end))
  menu.setButtonText ( button1, "Play again")
  local button2 = menu.makeButton ( menu.MENUPOS2 )
  menu.setButtonCallback (button2, (function ( )
    statemgr.swap ( "states/state-main-menu.lua")
  end))
  menu.setButtonText ( button2, "Back to menu")
  local button3 = menu.makeButton ( menu.MENUPOS3 )
  menu.setButtonCallback (button3, function()
    cloud.postHighScore ( win.layer )
  end)
  menu.setButtonText ( button3, "Post high score")
  menu.new ( win.layer, { button1, button2, button3 } )
  achmng.sendAchievements ( win.layer )

  -- Make sure people unlock survival mode with this.
  globalData.config.expBought.survival = true
  config:saveGame()

end

win.onUnload = function ( self )
  unloader.cleanUp(self)
end

win.onInput = function (  )
  menu.onInput ( win.layer )
end

win.onUpdate = function ( self )
  achmng.onUpdate ( self.layer )
end

return win

