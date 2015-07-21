local statistics = {}
statistics.layerTable = nil

statistics.onFocus = function ( self )

end

statistics.onLoad = function ( self )
  statistics.layerTable = {}

  statistics.layer = MOAILayer2D.new ()
  statistics.layer:setViewport ( viewport )

  menu.makeBackground ( statistics.layer )

  statistics.layerTable [ 1 ] = { statistics.layer }

  local textBox = util.makeText ( "statistics ", SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 50, 50 )
  textBox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  statistics.layer:insertProp ( textBox )

  local button1 = menu.makeButton ( { -105, 50, 105, -10 } )
  menu.setButtonCallback (button1, (function ()
    statemgr.swap ( "states/state-achievements.lua" )
  end))
  menu.setButtonText ( button1, "achievements")

  local button2 = menu.makeButton ( { -105, -20, 105, -80 } )
  menu.setButtonCallback (button2, (function ()
    statemgr.push ( "states/state-globalstats.lua" )
  end))
  menu.setButtonText ( button2, "Experience points")
  menu.setButtonTextSize ( button2, 18 )

  local button3 = menu.makeButton ( { -105, -90, 105, -150 } )
  menu.setButtonCallback (button3, (function ()
    statemgr.swap ( "states/state-shop.lua" )
  end))
  menu.setButtonText ( button3, "Buy cheats" )
  --menu.setButtonTextSize ( button3, 18 )

  local button4 = menu.makeButton ( { -105, -160, 105, -220 } )
  menu.setButtonCallback (button4, (function ()
    statemgr.swap ( "states/state-main-menu.lua" )
  end))
  menu.setButtonText ( button4, "back to menu")
  menu.new ( statistics.layer, { button1, button2, button3, button4 } )
end

statistics.onUnload = function ( self )
  unloader.cleanUp(self)
end

statistics.onInput = function ( self )
  menu.onInput ( statistics.layer )
end

return statistics
