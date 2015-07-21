module ( "sound", package.seeall )

fx = true
music = true

turnOffFx = function (  )
  fx = false
  config.data.config.soundFx = false
  config:saveGame ()
end

turnOnFx = function (  )
  fx = true
  config.data.config.soundFx = true
  config:saveGame ()
end

turnOffMusic = function (  )
  music = false
  config.data.config.soundMusic = false
  config:saveGame ()
  if globalData.bgsound and globalData.bgsound.loaded and globalData.bgsound.playing then
    globalData.bgsound.playing = false
    globalData.bgsound.sound:pause ()
  end
end

turnOnMusic = function (  )
  music = true
  config.data.config.soundMusic = true
  config:saveGame ()
  if globalData.bgsound and globalData.bgsound.loaded and not globalData.bgsound.playing then
    globalData.bgsound.playing = true
    play ( globalData.bgsound.sound )
  end
end

play = function ( playsound, type )
  -- Defaults to fx, since we only have one music track ATM.
  type = type or "fx"
  if sound[type] then
    playsound:play ()
  end
end
