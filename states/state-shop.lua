require "elements/car"

local getLevel = function ( world )
  return globalData.config.maxLevels[world] or 1
end

local countCars = function (  )
  local list = Car.getCarTypes()
  local count = 0
  for i, c in next, list, nil do
    if Car.carAvailable(c) then
      count = count + 1
    end
  end
  return count
end

local getShopList = function (  )
  return {
    {
      id = "4mpoints",
      title = "4,000,000 points",
      description = "Buy 4,000,000 experience points",
      successdescription = "You now have 4,000,000 extra experience points. Have fun!",
      price = "$0.99",
      rewards = (function ( layer )
        globalData.config.expPoints = globalData.config.expPoints + 4000000
      end)
    },
    {
      id = 'skiplevel',
      title = "Skip level in world 1",
      description = "Current level: " .. getLevel (1),
      successdescription = "Level skipped. Have fun!",
      price = "$0.99",
      unavailable = getLevel (1) >= #Level.levels[1],
      unavailtext = "Already unlocked all levels",
      rewards = (function ( layer )
        globalData.config.maxLevels[1] = (globalData.config.maxLevels[1] or 1) + 1
        globalData.updateLevelChooser = true
        layer.achievements.skiplevel2:setString ( "Current level: " .. getLevel (1) )
      end)

    },
    {
      id = 'skiplevel',
      title = "Skip level in world 2",
      description = "Current level: " .. getLevel (2),
      successdescription = "Level skipped. Have fun!",
      price = "$0.99",
      unavailable = getLevel (2) >= #Level.levels[2] or not globalData.config.achievements.unlockworld2,
      unavailtext = "",
      rewards = (function ( layer )
        globalData.config.maxLevels[2] = (globalData.config.maxLevels[2] or 1) + 1
        globalData.updateLevelChooser = true
        layer.achievements.skiplevel3:setString ( "Current level: " .. getLevel (2) )
      end)
    },
    {
      id = 'unlockw2',
      title = "World 2",
      description = "Unlock world 2",
      successdescription = "World 2 unlocked! Have fun!",
      price = "$0.99",
      unavailable = globalData.config.achievements.unlockworld2,
      unavailtext = "Already unlocked world 2",
      rewards = (function ( layer )
        globalData.config.achievements.unlockworld2 = 1
      end)
    },
    {
      id = 'allthecars',
      title = "Arsenal of cars",
      description = "Unlock all cars",
      successdescription = "All cars are unlocked! Have fun!",
      price = "$0.99",
      unavailable = countCars() == #Car.getCarTypes(),
      unavailtext = "Already have all cars!",
      rewards = (function ( layer )
        globalData.config.boughtAllCars = true
      end)
    },
    {
      id = 'weaponspack',
      title = "Arsenal of weapons",
      description = "Get 10 bombs, 10 stars, 10 swarms and 10 rockets",
      successdescription = "Weapons are upgraded. Have fun!",
      price = "$0.99",
      rewards = (function ( layer )
        for i,r in next, {"rocket", "bomb", "swarm", "nitro", "invincible"}, nil do
          globalData.config.expBought[r] = globalData.config.expBought[r] or 0
          globalData.config.expBought[r] = globalData.config.expBought[r] + 10
        end
      end)
    }
  }
end

local shop_state = {}
shop_state.layerTable = nil

shop_state.onFocus = function ( self )

end

shop_state.onLoad = function ( self )
  globalData.updateShop = true
  shop_state.layerTable = {}

  shop_state.layer = MOAILayer2D.new ()
  menu.addTopBar(shop_state.layer, "Shop", function ()
    statemgr.pop()
  end)
  shop_state.layer:setViewport ( viewport )

  menu.makeBackground ( shop_state.layer )

  shop_state.layerTable [ 1 ] = { shop_state.layer }
  shop_state.layer.achievements = {}

  local nextYValue = 160
  local width = SCREEN_UNITS_X - 20
  local height = 30

  local nextXValue = 50
  local buttonlist = {}
  local delta = 1
  local list = getShopList()
  menu.initPager ( shop_state.layer, "states/state-shop_state.lua" )
  menu.setPageSize ( shop_state.layer, 6 )
  menu.setTotalPagerItems ( shop_state.layer, #list )
  local leftbutton, rightbutton, pagetext = menu.makePagerButtons ( shop_state.layer, - 130 )
  for i, item in next, list, nil do
    if menu.pageItems ( shop_state.layer, delta ) then
      local bg
      local id = item.id
      local buybutt = menu.makeButton ( { 110, nextYValue + 15, 150, nextYValue - 15} )
      buybutt.id = item.id
      local cost = item.price
      local extratext = item.description
      menu.setButtonText ( buybutt, "buy" )
      menu.setButtonTextSize ( buybutt, 14 )
      local title = item.title
      if item.unavailable then
        bg = util.getProp ( "gfx/background.png", width + 6, height + 8, 0, nextYValue )
        menu.setButtonCallback ( buybutt, function (  )
          return false
        end )
        menu.setButtonTexture ( buybutt, "gfx/menubg-red.png" )
        if item.unavailtext then
          extratext = item.unavailtext
        end
      else
        bg = util.getProp ( "gfx/black.png", width + 6, height + 8, 0, nextYValue )
        menu.setButtonCallback ( buybutt, function (  )
          bill.payForProduct ( item.id, function (  )
            -- Insert a notice into the popup table.
            item.rewards ( shop_state.layer )
            config:saveGame()
            statemgr.swap ( "states/state-shop.lua" )
            shop_state.layer.popups = shop_state.layer.popups or {}
            table.insert( shop_state.layer.popups, Popup.new ( 'Thanks! ' .. item.successdescription, shop_state.layer ) )
          end )
          return true
        end )
      end

      local propid = id .. i
      shop_state.layer.achievements[propid] = util.makeText ( extratext, width - 105, height, nextXValue - 35, nextYValue - 8, 8 )
      shop_state.layer.achievements[propid].cost = util.makeText ( cost .. "", 50, height, -115, nextYValue - 5, 16 )
      shop_state.layer.achievements[propid].title = util.makeText ( title, width - 35, height, nextXValue, nextYValue, 16 )
      shop_state.layer.achievements[propid]:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
      bg:setPriority( 1 )
      shop_state.layer:insertProp ( bg )
      nextYValue = nextYValue - 40

      table.insert( buttonlist, buybutt )

      shop_state.layer:insertProp ( shop_state.layer.achievements[propid] )
      shop_state.layer:insertProp ( shop_state.layer.achievements[propid].title )
      shop_state.layer:insertProp ( shop_state.layer.achievements[propid].cost )
    end
    delta = delta + 1
  end

  if MOAIBillingIOS then
    -- We must add a redeem purchases button for iOS.
    local rp = menu.makeButton(menu.MENUPOS5)
    menu.setButtonCallback(rp, function()
      bill.restoreTransactions(function(pid)
        -- Cycle over the list to find the right one.
        for i, item in next, list, nil do
          if item.id == pid then
            item.rewards(shop_state.layer)
          end
        end
        statemgr.swap("states/state-shop.lua")
        config:saveGame()
      end)
    end)
    menu.setButtonText(rp, "Restore purchases")
    table.insert(buttonlist, rp)
  end

  -- Since we only have one item for sale, do not render all buttons. But
  -- uncomment this, once we have alot for sale.
  --menu.new ( shop_state.layer, { button1, rightbutton, leftbutton, pagetext, unpack( buttonlist ) } )
  menu.new ( shop_state.layer, { unpack( buttonlist ) } )
end

shop_state.onUnload = function ( self )
  unloader.cleanUp(self)
end

shop_state.onInput = function ( self )
  menu.onInput ( shop_state.layer )
end

shop_state.onUpdate = function ( self )
  achmng.onUpdate ( self.layer )
end

return shop_state
