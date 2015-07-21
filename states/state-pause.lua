local pause = {}
pause.layerTable = nil

pause.onFocus = function ( self )
end

pause.onLoad = function ( self )
  pause.layerTable = {}

  pause.layer = MOAILayer2D.new ()
  menu.addTopBar(pause.layer, "Pause", function ()
    statemgr.pop ()
  end)
  pause.layer:setViewport ( viewport )

  pause.layerTable [ 1 ] = { pause.layer }

  local bgProp = util.getProp ( "gfx/background.png", SCREEN_UNITS_X, SCREEN_UNITS_Y, 0, 0 )
  pause.layer:insertProp ( bgProp )

  local sfxbutton = menu.makeButton ( menu.MENUPOS1 )
  menu.setButtonCallback (sfxbutton, (function ( )
    if (globalData.config.soundFx == true) then
      menu.changeButtonText ( pause.layer, sfxbutton, "Sound off" )
      sound.turnOffFx ()
    else
      menu.changeButtonText ( pause.layer, sfxbutton, "Sound on")
      sound.turnOnFx ()
    end
  end))
  menu.setButtonText ( sfxbutton, "Sound on")
  if (globalData.config.soundFx == false) then
    menu.setButtonText ( sfxbutton, "Sound off")
  end
  local button1 = menu.makeButton ( menu.MENUPOS2 )
  menu.setButtonCallback (button1, (function ( )
    if (globalData.config.soundMusic == true) then
      menu.changeButtonText ( pause.layer, button1, "Music off" )
      sound.turnOffMusic ()
    else
      menu.changeButtonText ( pause.layer, button1, "Music on")
      sound.turnOnMusic ()
    end
  end))
  menu.setButtonText ( button1, "Music on")
  if (globalData.config.soundMusic == false) then
    menu.setButtonText ( button1, "Music off")
  end
  local button2 = menu.makeButton ( menu.MENUPOS3 )
  menu.setButtonCallback (button2, (function ( )
    game.saveLevel()
    statemgr.pop ()
    statemgr.swap ( "states/state-main-menu.lua" )
  end))
  menu.setButtonText ( button2, "Back to menu" )
  local button3 = menu.makeButton ( menu.MENUPOS4 )
  menu.setButtonCallback (button3, (function ( )
    statemgr.pop ()
  end))
  menu.setButtonText ( button3, "Resume")

  local tryagain = menu.makeButton ( menu.MENUPOS5 )
  menu.setButtonCallback (tryagain, (function ( )
    statemgr.pop ()
    game.loseLife()
  end))
  menu.setButtonText ( tryagain, "Retry")

  menu.new ( pause.layer, { sfxbutton, button1, button2, button3, tryagain } )

end

pause.onUnload = function ( self )
  unloader.cleanUp(self)
end

pause.onInput = function ( self )
  menu.onInput ( pause.layer )
end

pause.IS_POPUP = true

return pause

