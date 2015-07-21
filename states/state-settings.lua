local settings = {}
settings.layerTable = nil

settings.onFocus = function ( self )
end

settings.onLoad = function ( self )
  settings.layerTable = {}

  settings.layer = MOAILayer2D.new ()
  menu.addTopBar(settings.layer, "Settings", function ()
    statemgr.pop()
  end)
  settings.layer:setViewport ( viewport )

  settings.layerTable [ 1 ] = { settings.layer }

  menu.makeBackground ( settings.layer )

  local sfxbutton = menu.makeButton ( menu.MENUPOS1 )
  menu.setButtonCallback (sfxbutton, (function ( )
    if (globalData.config.soundFx == true) then
      menu.changeButtonText ( settings.layer, sfxbutton, "Sound off" )
      sound.turnOffFx ()
    else
      menu.changeButtonText ( settings.layer, sfxbutton, "Sound on")
      sound.turnOnFx ()
    end
  end))
  menu.setButtonText ( sfxbutton, "Sound on")
  if (globalData.config.soundFx == false) then
    menu.setButtonText ( sfxbutton, "Sound off")
  end
  local musicbutton = menu.makeButton ( menu.MENUPOS2 )
  menu.setButtonCallback (musicbutton, (function ( )
    if (globalData.config.soundMusic == true) then
      menu.changeButtonText ( settings.layer, musicbutton, "Music off" )
      sound.turnOffMusic ()
    else
      menu.changeButtonText ( settings.layer, musicbutton, "Music on")
      sound.turnOnMusic ()
    end
  end))
  menu.setButtonText ( musicbutton, "Music on")
  if (globalData.config.soundMusic == false) then
    menu.setButtonText ( musicbutton, "Music off")
  end

  local button3 = menu.makeButton ( menu.MENUPOS3 )
  menu.setButtonCallback (button3, (function ( )
    statemgr.swap ( "states/state-change-name.lua" )
  end))
  menu.setButtonText ( button3, "Change name")

  -- Some optional buttons.
  local optButtons = {}

  if not globalData.config.fb then
    local button4 = menu.makeButton ( menu.MENUPOS4 )
    menu.setButtonCallback (button4, (function ( )
      facebook.connect ( function ()
        -- Do the standard FB callback to save the info.
        facebook.loginSuccessCallback ()
        local thread = MOAIThread.new()
        thread:run (function ( )
          -- Wait until we have a saved name for this person.
          while not globalData.config.fbid do
            coroutine:yield ()
          end
          statemgr.swap("states/state-settings.lua")
          local ls = statemgr.getCurState()
          achmng.sendAchievements ( ls.layer )
        end )
      end)
    end))
    menu.setButtonText ( button4, "Facebook connect")
    table.insert(optButtons, button4)
  end

  menu.new ( settings.layer, { sfxbutton, musicbutton, button3, unpack(optButtons) } )
end

settings.onUnload = function ( self )
  unloader.cleanUp(self)
end

settings.onUpdate = function ( self )
  achmng.onUpdate(self.layer)
end

settings.onInput = function ( self )
  menu.onInput ( settings.layer )
end

return settings

