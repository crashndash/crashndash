local globalstats = {}
globalstats.layerTable = nil

globalstats.onFocus = function ( self )

end

globalstats.onLoad = function ( self )
  globalstats.layerTable = {}

  globalstats.layer = MOAILayer2D.new ()
  menu.addTopBar(globalstats.layer, "Upgrades", function ()
    statemgr.pop ()
  end)
  globalData.notify.globalstats = nil
  globalstats.layer:setViewport ( viewport )

  menu.makeBackground ( globalstats.layer )

  globalstats.layerTable [ 1 ] = { globalstats.layer }
  globalstats.layer.achievements = {}

  local nextYValue = -50
  local width = SCREEN_UNITS_X - 20
  local height = 30
  local exptext = util.makeText ( "Your experience points: " .. globalData.config.expPoints, width - 35, height * 2, 0, -90, 16 )
  local exptext2 = util.makeText ( 'Collect more by playing the game, or from the \ncoin button at the bottom right.', width - 35, height * 2, 0, -125, 8 )
  local hint = util.getProp("gfx/hint_arrow.png", 60, 80, 115, -115)
  globalstats.layer:insertProp(hint)
  globalstats.layer:insertProp ( exptext )
  globalstats.layer:insertProp ( exptext2 )

  nextYValue = 180
  nextXValue = 10
  local buttonlist = {}
  local delta = 1
  local list = achmng.getUnlockList ()
  menu.initPager ( globalstats.layer, "states/state-globalstats.lua" )
  menu.setPageSize ( globalstats.layer, 6 )
  menu.setTotalPagerItems ( globalstats.layer, #list )
  local leftbutton, rightbutton, pagetext = menu.makePagerButtons ( globalstats.layer, - 130 )
  for i, unlocker in next, list, nil do
    if menu.pageItems ( globalstats.layer, delta ) then
      local bg
      local check
      local buybutt = menu.makeButton ( { 120, nextYValue + 15, 150, nextYValue - 15} )
      buybutt.id = unlocker.id
      local cost = unlocker.points
      local extratext = ""
      if (globalData.config.expBought[unlocker.id] and globalData.config.expBought[unlocker.id] ~= true) or unlocker.forceCount then
        if unlocker.forceCount or globalData.config.expBought[unlocker.id] > 0 then
          local level = globalData.config.expBought[unlocker.id]
          if unlocker.customCount then
            level = unlocker.customCount
          end
          -- Add some more text on the label.
          local counter = unlocker.counter or "level"
          extratext = ". Current " .. counter .. ": " .. level
          -- Multiply the cost some (so higher levels are more expensive)
          cost = math.floor ( unlocker.points * ( 1.1 ^ (level) ) )
        end
      end
      menu.setButtonText ( buybutt, "+" )
      local title = unlocker.title
      local hasit = false
      if globalData.config.expBought[unlocker.id] or unlocker.altUnlock then
        check = util.getProp ( "gfx/check.png", 12, 12, -SCREEN_UNITS_X / 2 + 20, nextYValue )
        if globalData.config.expBought[unlocker.id] == true or unlocker.altUnlock == true then
          hasit = true
        end
      else
        check = util.getProp ( "gfx/check-no.png", 12, 12, -SCREEN_UNITS_X / 2 + 20, nextYValue )
      end
      if globalData.config.expPoints >= cost then
        bg = util.getProp ( "gfx/black.png", width + 6, height + 8, 0, nextYValue )
        menu.setButtonCallback ( buybutt, function (  )
          if unlocker.count then
            -- One can for example buy consumables like more bombs or something
            -- at some point?
            globalData.config.expBought[unlocker.id] = globalData.config.expBought[unlocker.id] or 0
            globalData.config.expBought[unlocker.id] = globalData.config.expBought[unlocker.id] + 1
          else
            globalData.config.expBought[unlocker.id] = true
          end
          -- Save and refresh.
          globalData.config.expPoints = globalData.config.expPoints - cost
          config:saveGame ()
          statemgr.swap ( "states/state-globalstats.lua" )
          return true
        end )
      else
        bg = util.getProp ( "gfx/background.png", width + 6, height + 8, 0, nextYValue )
        if not hasit then
          check = util.getProp ( "gfx/check-no.png", 12, 12, -SCREEN_UNITS_X / 2 + 20, nextYValue )
        end
        menu.setButtonCallback ( buybutt, function (  )
          -- Not allowed. Should we play a sound or something?
          return false
        end )
        menu.setButtonTexture ( buybutt, "gfx/menubg-red.png" )
        if unlocker.hidden then
          -- We do not tell what this unlocks until it actually is available.
          title = "unlock ??? (secret)"
        end
      end

      globalstats.layer.achievements[i] = util.makeText ( cost .. " points" .. extratext, width - 35, height, nextXValue, nextYValue - 8, 8 )
      globalstats.layer.achievements[i].title = util.makeText ( title, width - 35, height, nextXValue, nextYValue, 16 )
      globalstats.layer.achievements[i]:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
      bg:setPriority( 1 )
      globalstats.layer:insertProp ( bg )
      nextYValue = nextYValue - 40
      local noBuyButt = false
      if globalData.config.expBought[unlocker.id] and globalData.config.expBought[unlocker.id] == true then
        noBuyButt = true
      end
      if unlocker.altUnlock and unlocker.altUnlock == true then
        noBuyButt = true
      end
      if noBuyButt then
        -- This is just bought, and has no quantity. Disable buy button!
        buybutt = nil
      else
        table.insert( buttonlist, buybutt )
        -- This can never be "checked", so disable the check box.
        check = nil
      end

      globalstats.layer:insertProp ( globalstats.layer.achievements[i] )
      if check then
        globalstats.layer:insertProp ( check )
      end
      globalstats.layer:insertProp ( globalstats.layer.achievements[i].title )
    end
    delta = delta + 1
  end

  menu.new ( globalstats.layer, { rightbutton, leftbutton, pagetext, unpack( buttonlist ) } )
end

globalstats.onUpdate = function ( self )
  if globalData.updateShop == true then
    globalData.updateShop = nil
    statemgr.swap ( "states/state-globalstats.lua" )
  end
end

globalstats.onUnload = function ( self )
  unloader.cleanUp(self)
end

globalstats.onInput = function ( self )
  menu.onInput ( globalstats.layer )
end

return globalstats
