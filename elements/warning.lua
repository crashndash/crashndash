module ( "Warning", package.seeall )

new = function ()
  local warning = {}

  warning.sound = util.getSound ( "sound/warning.ogg" )
  warning.func = function ()
    local warningProp = util.getProp ( "gfx/warning.png", 48, 48, 0, util.halfY - 40, 0 )
    warningProp:setPriority ( 2 )
    game.insertPropIntoTextLayer ( warningProp )
    util.sleep ( 0.25 )
    game.removePropFromTextLayer ( warningProp )
    util.sleep ( 0.1 )
    game.insertPropIntoTextLayer ( warningProp )
    util.sleep ( 0.25 )
    game.removePropFromTextLayer ( warningProp )
    util.sleep ( 0.1 )
    game.insertPropIntoTextLayer ( warningProp )
    util.sleep ( 0.25 )
    game.removePropFromTextLayer ( warningProp )
    warningProp = nil
    warning.thread = nil
  end

  warning.play = function ( self )
    self.thread = MOAICoroutine.new ()
    self.thread:run ( self.func )
    sound.play ( self.sound )
  end

  warning.onPause = function ( self )
    if self.thread then
      self.thread:pause ()
      self.sound:pause ()
    end
  end

  warning.onResume = function ( self )
    if self.thread then
      self.thread:start ()
      sound.play ( self.sound )
    end
  end

  return warning

end
