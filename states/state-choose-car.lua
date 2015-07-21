require('elements/powerup')
local choosecar = {}
choosecar.layerTable = nil

choosecar.onFocus = function ( self )

end

choosecar.onLoad = function ( self )
  choosecar.layerTable = {}

  choosecar.layer = MOAILayer2D.new ()
  menu.addTopBar(choosecar.layer, "Choose car", function ()
    statemgr.swap ( "states/state-game.lua" )
  end)
  choosecar.layer:setViewport ( viewport )

  menu.makeBackground ( choosecar.layer )

  choosecar.layerTable [ 1 ] = { choosecar.layer }

  local nextYValue = 130
  local width = SCREEN_UNITS_X - 20
  local height = 54

  local types = Car.getCarTypes()
  local buttonlist = {}
  choosecar.layer.cars = {}
  menu.setPageSize ( choosecar.layer, 4 )
  menu.initPager ( choosecar.layer, "states/state-choose-car.lua" )
  local imgx = -SCREEN_UNITS_X / 2 + 51
  local bgwidth = width - 20
  local bgXoffset = 0

  for t, carType in next, types, nil do
    if menu.pageItems ( choosecar.layer, t ) then

      local bg
      local check
      local pr = Car.carProperties[carType]
      local callback = function (  )
        globalData.config.carType = carType
        statemgr.swap ( "states/state-choose-car.lua" )
      end
      local globaltype = globalData.config.carType or "redcar"
      if globaltype == carType then
        -- If car is selected, show a check sign and do nothing on button.
        check = util.getProp ( "gfx/check.png", 12, 12, 110, nextYValue )
        callback = function (  )
          -- DO NOTHING!
        end
      else
        check = util.getProp ( "gfx/trans.png", 12, 12, 110, nextYValue )
      end
      local title = pr.title or carType

      bg = util.getProp ( "gfx/car-bg.png", bgwidth, height + 8, bgXoffset, nextYValue )
      local textOffset = bgXoffset + 60
      bg:setPriority(0)
      check:setPriority ( 100 )
      local pr = Car.carProperties[carType]


      local img = util.getProp ( "gfx/" .. carType .. ".png", pr.width, pr.height, imgx, nextYValue )
      if not Car.carAvailable(carType) then
        if pr.secret then
          img = util.getProp ( "gfx/secret.png", 24, 24, imgx, nextYValue )
          title = "???"
        end
        callback = function ()
          -- Nada. this is so so secret.
        end
        bg = util.getProp ( "gfx/car-bg2.png", bgwidth, height + 8, bgXoffset, nextYValue )
        bg:setPriority(0)
        if not pr.secret then
          local buybutton = menu.makeButton({90, nextYValue - 10, 130, nextYValue + 20})
          menu.setButtonText(buybutton, "Unlock")
          menu.setButtonTextSize(buybutton, 8)
          menu.setButtonCallback(buybutton, function ()
            statemgr.push("states/state-globalstats.lua")
            -- Go straight to page 2 where the cars are located.
            globalData.page["states/state-globalstats.lua"] = 1
            statemgr.swap("states/state-globalstats.lua")
            -- Flag this page to be updated when we get back. Regardless if we
            -- bought anything.
            globalData.updateCars = true
          end)
          table.insert(buttonlist, buybutton)
        end
      end
      local button = menu.makeButton ( {-105, nextYValue + 24, 145, nextYValue - 24} )

      menu.setButtonCallback ( button, callback )
      menu.setButtonText(button, "")
      menu.setButtonTexture(button, "gfx/trans.png")

      table.insert( buttonlist, button )
      choosecar.layer.cars[carType] = util.makeText ( title, bgwidth, height, textOffset + 6, nextYValue + 19, 16 )
      choosecar.layer.cars[carType]:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )

      -- Multiply speed with 100, so the number makes sense.
      choosecar.layer.cars[carType].speed = util.makeText ( "Speed: " .. (pr.speed * 100), bgwidth, height, textOffset + 10, nextYValue + 6, 8 )
      choosecar.layer.cars[carType].speed:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )

      -- Multiply weight with 1000, so the number makes sense.
      choosecar.layer.cars[carType].weight = util.makeText ( "Weight: " .. (pr.weight * 1000), bgwidth, height, textOffset + 10, nextYValue - 6, 8 )
      choosecar.layer.cars[carType].weight:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )

      -- Add description, if available.
      choosecar.layer.cars[carType].desc = util.makeText ( "" .. pr.description, bgwidth, height, textOffset + 10, nextYValue - 17, 8 )
      choosecar.layer.cars[carType].desc:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )

      choosecar.layer:insertProp ( bg )
      choosecar.layer:insertProp ( check )
      choosecar.layer:insertProp ( img )
      choosecar.layer:insertProp ( choosecar.layer.cars[carType] )
      choosecar.layer:insertProp ( choosecar.layer.cars[carType].speed )
      choosecar.layer:insertProp ( choosecar.layer.cars[carType].weight )
      choosecar.layer:insertProp ( choosecar.layer.cars[carType].desc )
      nextYValue = nextYValue - height - 12
    end
  end
  menu.setTotalPagerItems ( choosecar.layer, #types )
  local leftbutton, rightbutton, pagetext = menu.makePagerButtons ( choosecar.layer, - 130 )

  menu.new ( choosecar.layer, { pagetext, leftbutton, rightbutton, unpack(buttonlist) } )
end

choosecar.onUnload = function ( self )
  unloader.cleanUp(self)
end

choosecar.onUpdate = function ( self )
  if globalData.updateCars == true then
    globalData.updateCars = nil
    statemgr.swap ( "states/state-choose-car.lua" )
  end
end

choosecar.onInput = function ( self )
  menu.onInput ( choosecar.layer )
end

return choosecar
