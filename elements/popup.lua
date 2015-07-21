module ( "Popup", package.seeall )

new = function ( string, layer )
  local popup = {}
  if layer then
    popup.layer = layer
  end

  popup.sound = util.getSound ( "sound/alert.ogg" )
  popup.func = function ()
    local popupProp = util.makeText ( string, SCREEN_UNITS_X - 30, 40, 0, SCREEN_UNITS_Y / 2 - 35, 10 )
    popupProp:setFont(util.getFont("gfx/visitor1.ttf", 10))
    popupProp:setPriority ( 2 )
    popupProp:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
    local popupBgProp = util.getProp ( "gfx/popupbackground.png", SCREEN_UNITS_X - 20, 40, 0, SCREEN_UNITS_Y / 2 - 35 )
    if not popup.layer then
      popupProp:setPriority ( -10 )
      popupBgProp:setPriority ( -9 )
      game.insertPropIntoTextLayer ( popupProp )
      game.insertPropIntoTextLayer ( popupBgProp )
    else
      popupProp:setPriority ( 10 )
      popupBgProp:setPriority ( 9 )
      popup.layer:insertProp ( popupBgProp )
      popup.layer:insertProp ( popupProp )
    end
    util.sleep ( 2 )
    if not popup.layer then
      game.removePropFromTextLayer ( popupProp )
      game.removePropFromTextLayer ( popupBgProp )
    else
      popup.layer:removeProp ( popupProp )
      popup.layer:removeProp ( popupBgProp )
    end
    popupProp = nil
    popup.thread = nil
    popup.shown = true
  end

  popup.show = function ( self )
    self.thread = MOAICoroutine.new ()
    self.thread:run ( self.func )
    sound.play ( self.sound )
  end

  popup.onPause = function ( self )
    if self.thread then
      self.thread:pause ()
      self.sound:pause ()
    end
  end

  popup.onResume = function ( self )
    if self.thread then
      self.thread:start ()
      sound.play ( self.sound )
    end
  end

  return popup

end

createLayerPopup = function ( message )
  local ls = statemgr.getCurState()
  ls.layer.popups = ls.layer.popups or {}
  table.insert(ls.layer.popups, new(message, ls.layer))
end
