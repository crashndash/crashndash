local achievements = {}
achievements.layerTable = nil

achievements.onFocus = function ( self )

end

achievements.onLoad = function ( self )

  achievements.layerTable = {}

  achievements.layer = MOAILayer2D.new ()
  menu.addTopBar(achievements.layer, "Achievements", function ()
    statemgr.pop()
  end)
  globalData.notify.achievements = nil
  achievements.layer:setViewport ( viewport )

  menu.setPageSize ( achievements.layer, 6 )
  menu.initPager ( achievements.layer, "states/state-achievements.lua" )

  menu.makeBackground ( achievements.layer, true, "gfx/skiesbg.png", menu.MENUBG_HORIZONTAL, 1 )

  achievements.layerTable [ 1 ] = { achievements.layer }

  achmng.getMyAchievements ( self.layer )
end

achievements.onUnload = function ( self )
  unloader.cleanUp(self)
  achievements.buttons = {}
end

achievements.onUpdate = function ( self )

end

achievements.onInput = function ( self )
  menu.onInput ( achievements.layer )
end

return achievements

