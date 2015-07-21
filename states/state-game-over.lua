local gameOver = {}
gameOver.layerTable = nil

local HIGHSCORES_URL = "https://crashndash.com/world-high-scores"

gameOver.onFocus = function ( self )
end

gameOver.onLoad = function ( self )
  gameOver.layerTable = {}
  gameOver.clickables = {}

  gameOver.layer = MOAILayer2D.new ()
  menu.addTopBar(gameOver.layer, "Game over", function ()
    globalData.score = 0
    statemgr.swap ( "states/state-game.lua" )
  end)
  gameOver.layer:setViewport ( viewport )

  gameOver.layerTable [ 1 ] = { gameOver.layer }

  menu.makeBackground ( gameOver.layer )

  -- Make current level the global current level.
  game.saveLevel()

  -- Placeholder for cloud data.
  gameOver.layer.Hiscores = {}
  -- Flag for done downloading
  gameOver.layer.haveCloud = false
  gameOver.layer.postedStuff = false

  if not globalData.score then
    globalData.score = 0
  end

  if not config.data.config.highScore then
    config.data.config.highScore = 0
  end

  if globalData.score > config.data.config.highScore then
    config.data.config.highScore = globalData.score
    config:saveGame ()
  end

  local textBox = util.makeText ( "Score: " .. globalData.score, SCREEN_UNITS_X - 40, 30, 0, 150 )
  textBox:setFont((util.getFont("gfx/visitor1.ttf", 150)))
  textBox:setTextSize ( 30 )
  textBox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )

  gameOver.layer.hiscoresProp = util.makeText ( "", SCREEN_UNITS_X - 40, 60, 0, 100 )
  gameOver.layer.hiscoresProp:setTextSize ( 20 )
  gameOver.layer.hiscoresProp:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )

  gameOver.layer:insertProp ( textBox )
  gameOver.layer:insertProp ( gameOver.layer.hiscoresProp )

  local button1 = menu.makeButton ( menu.MENUPOS1 )
  menu.setButtonCallback (button1, (function ( )
    globalData.score = 0
    statemgr.swap ( "states/state-game.lua" )
  end))
  menu.setButtonText ( button1, "Play again")
  local button2 = menu.makeButton ( menu.MENUPOS2 )
  menu.setButtonCallback (button2, (function ( )
    statemgr.swap ( "states/state-main-menu.lua" )
  end))
  menu.setButtonText ( button2, "Back to menu")
  local button3 = menu.makeButton ( menu.MENUPOS3 )
  menu.setButtonCallback (button3, (function ( )
    cloud.postHighScore ( gameOver.layer )
  end))

  menu.setButtonText ( button3, "Post high score")

  local button4 = menu.makeButton ( menu.MENUPOS4 )
  menu.setButtonText ( button4, "View Hiscores")
  menu.setButtonCallback ( button4, function (  )
    util.openURL ( HIGHSCORES_URL )
  end)
  menu.new ( gameOver.layer, { button1, button2, button3, button4 } )
  achmng.sendAchievements ( gameOver.layer )

end

gameOver.onUnload = function ( self )
  unloader.cleanUp(self)
end

gameOver.onInput = function (  )
  menu.onInput ( gameOver.layer )
end

gameOver.onUpdate = function ( self )
  achmng.onUpdate ( self.layer )
end

return gameOver
