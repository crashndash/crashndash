require('elements/powerup')
local helpme = {}
helpme.layerTable = nil

helpme.onFocus = function ( self )

end

helpme.onLoad = function ( self )
  helpme.layerTable = {}

  helpme.layer = MOAILayer2D.new ()
  menu.addTopBar(helpme.layer, "Help", function ()
    statemgr.swap ( "states/state-help.lua" )
  end)
  helpme.layer:setViewport ( viewport )

  menu.makeBackground ( helpme.layer )

  helpme.layerTable [ 1 ] = { helpme.layer }

  local nextYValue = 165
  local width = SCREEN_UNITS_X - 20
  local height = 30

  for p in next, Powerup.powerups, nil do
    local bg = util.getProp ( "gfx/road.png", width + 6, height + 8, 0, nextYValue )
    local img = util.getProp ( "gfx/" .. p .. ".png", 15, 15, -SCREEN_UNITS_X / 2 + 25, nextYValue )
    local exptext = util.makeText ( Powerup.infotext[p], width - 35, height, 15, nextYValue - 8, 8 )
    helpme.layer:insertProp ( bg )
    helpme.layer:insertProp ( exptext )
    helpme.layer:insertProp ( img )
    nextYValue = nextYValue - height - 15
  end

  local button1 = menu.makeButton ( menu.MENUPOS5 )
  menu.setButtonCallback (button1, (function ()
    statemgr.swap ( "states/state-help-me2.lua" )
  end))
  menu.setButtonText ( button1, "More help")
  menu.new ( helpme.layer, { button1 } )
end

helpme.onUnload = function ( self )
  unloader.cleanUp(self)
end

helpme.onInput = function ( self )
  menu.onInput ( helpme.layer )
end

return helpme
