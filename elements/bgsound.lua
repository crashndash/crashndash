module ("Bgsound", package.seeall )

new = function ()
  local sound = {}

  sound.init = function ()
    local thread = MOAIThread.new ()
    thread:run (function (  )
      sound.sound = util.getSound ( "sound/carchase.ogg", false )
      sound.loaded = true
      sound.sound:setLooping ( true )
      sound.sound:setVolume ( .2 )
    end)
  end

  return sound
end
