local help = {}
help.layerTable = nil

help.onFocus = function ( self )

end

help.onLoad = function ( self )
  help.layerTable = {}

  help.layer = MOAILayer2D.new ()
  help.layer = MOAILayer2D.new ()
  menu.addTopBar(help.layer, "About/help", function ()
    statemgr.swap ("states/state-main-menu.lua")
  end)
  help.layer:setViewport ( viewport )

  menu.makeBackground ( help.layer )

  help.layerTable [ 1 ] = { help.layer }

  local button0 = menu.makeButton ( menu.MENUPOS2 )
  menu.setButtonCallback (button0, (function ()
    statemgr.swap ( "states/state-help-me.lua" )

  end))
  menu.setButtonText ( button0, "Help on powerups!")

  local button1 = menu.makeButton ( menu.MENUPOS3 )
  menu.setButtonCallback (button1, (function ()
    statemgr.swap ( "states/state-help-me2.lua" )

  end))
  menu.setButtonText ( button1, "FAQ")

  local button2 = menu.makeButton ( menu.MENUPOS4 )
  menu.setButtonCallback (button2, (function ()
    statemgr.swap ( "states/state-credits.lua" )
  end))
  menu.setButtonText ( button2, "Credits")

  menu.new ( help.layer, { button0, button1, button2 } )
end

help.onUnload = function ( self )
  unloader.cleanUp(self)
end

help.onInput = function ( self )
  menu.onInput ( help.layer )
end

return help
