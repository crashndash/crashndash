module ( "menu", package.seeall )

MENUBG_HORIZONTAL = 1
MENUBG_VERTICAL = 2
MENUPOS0 = { -105, 150, 105, 110 }
MENUPOS1 = { -105, 100, 105, 60 }
MENUPOS2 = { -105, 50, 105, 10 }
MENUPOS3 = { -105, 0, 105, -40 }
MENUPOS4 = { -105, -50, 105, -90 }
MENUPOS5 = { -105, -100, 105, -140 }
MENUPOS6 = { -105, -150, 105, -190 }

addTopBar = function ( layer, text, backCallback )
  layer.useTopBar = true
  layer.menutitle = text
  layer.backCallback = backCallback
end

shouldNotify = function ( category )
  if globalData.notify and globalData.notify[category] then
    return globalData.notify[category]
  end
  return false
end

addTopBarProps = function ( layer )
  layer.topbar = util.getProp("gfx/topbar.png", SCREEN_UNITS_X, 40, 0, SCREEN_UNITS_Y / 2 - 20)
  layer.topbar:setPriority(1)
  layer.title = util.makeText (layer.menutitle, SCREEN_UNITS_X, 40, 0, SCREEN_UNITS_Y/2 - 18, 24)
  layer.title:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  layer.title:setFont((util.getFont("gfx/visitor1.ttf", 30)))
  layer:insertProp(layer.topbar)
  layer:insertProp(layer.title)
end

new = function ( layer, buttons )
  if layer.useTopBar then
    addTopBarProps(layer)
    if layer.backCallback then
      layer.backbutton = makeButton({-util.halfX + 4, util.halfY - 34, -util.halfX + 53, util.halfY - 5})
      setButtonText(layer.backbutton, "")
      setButtonCallback(layer.backbutton, layer.backCallback)
      setButtonTextSize(layer.backbutton, 160)
      setButtonTexture(layer.backbutton, "gfx/backbutton.png")
      table.insert(buttons, layer.backbutton)
    end
  end

  if not layer.removeButtonBar then
    layer.buttonBar = util.getProp("gfx/bottombar.png", SCREEN_UNITS_X, 60, 0, -SCREEN_UNITS_Y / 2 + 30)
    layer.buttonBar:setPriority(1)
    local mbuttons = {
      "achievements",
      "globalstats",
      "settings",
      "shop"
    }

    layer.buttonIcons = layer.buttonIcons or {}
    for i, g in ipairs(mbuttons) do
      local x = -SCREEN_UNITS_X / 2 + tonumber(i) * 80 - 40
      local b = makeButton({x - 40, -SCREEN_UNITS_Y / 2, x + 40, -SCREEN_UNITS_Y / 2+ 60})
      setButtonCallback(b, function (  )
        statemgr.tidyUp("states/state-" .. g .. ".lua")
        statemgr.push("states/state-" .. g .. ".lua")
      end)
      b.id = g
      b.x = x
      setButtonTexture(b, "gfx/trans.png")
      layer.buttonIcons[b] = util.getProp("gfx/".. g ..".png", 40, 40, x, -SCREEN_UNITS_Y / 2 + 30)
      layer.buttonIcons[b]:setPriority(2)
      layer:insertProp(layer.buttonIcons[b])
      checkNotifyProp(b, layer)
      table.insert(buttons, b)
    end

    layer:insertProp(layer.buttonBar)
  end

  layer.clickables = {}
  layer.textBoxes = {}
  for i, button in ipairs ( buttons ) do
    makeMenuButtonProp ( layer, button )
    table.insert ( layer.clickables, button )
  end
end

checkNotifyProp = function ( button, layer )
  local id = button.id
  local notice_number = shouldNotify(id)
  local x = button.x
  if notice_number and not layer.buttonIcons[button].notification then
    layer.buttonIcons[button].notification = util.getProp("gfx/notification.png", 24, 24, x + 30, -SCREEN_UNITS_Y / 2 + 55)
    layer.buttonIcons[button].notification.id = id
    layer.buttonIcons[button].notification:setPriority(2)
    layer:insertProp(layer.buttonIcons[button].notification)
    layer.buttonIcons[button].notificationText = util.makeText(notice_number .. "", 10, 10, x + 33, -SCREEN_UNITS_Y / 2 + 55, 16)
    layer.buttonIcons[button].notificationText:setFont((util.getFont("gfx/visitor1.ttf", 10)))
    layer:insertProp(layer.buttonIcons[button].notificationText)

  end
end

onInput = function ( layer )
  -- Find out if the notifications should be removed.
  if layer.buttonIcons then
    for i, n in next, layer.buttonIcons, nil do
      if n.notification then
        -- Check if we should still notify
        if not shouldNotify(n.notification.id) then
          layer:removeProp(n.notification)
          layer:removeProp(n.notificationText)
        end
      end
      -- Also check if we should add some notifications.
      checkNotifyProp(i, layer)
    end
  end
  if DEBUGDATA and game and game.tick > 0 then
    -- OK, this will give us keyboard control.
    if inputmgr.getKey () == 32 then
      -- Space is clicked
      layer.clickables[4].callback ()
    end
    local x, y, z = inputmgr.getLevel ()
    if layer.clickables then
      if x == -1 then
        layer.clickables[2].callback ()
      end
      if x == 1 then
        layer.clickables[3].callback ()
      end
    end
  end
  local clicktable = inputmgr.getTouch ( layer )

  for i, n in ipairs ( clicktable ) do
    local pointX, pointY = n[1], n[2]
    local clickedButtons = {}



    -- Iterate over buttons in layer
    if layer.clickables then
      for i, clickable in ipairs ( layer.clickables ) do
        if inputmgr.isDown () then
          if clickable.box:inside ( pointX, pointY) then
            clickable.hit = true
            table.insert( clickedButtons, { clickable.priority, clickable } )
            if clickable.pressAndHold then
              table.insert( clickedButtons, { clickable.priority, clickable } )
            end
          else
            clickable.hit = false
          end
        else
          if clickable.box:inside ( pointX, pointY ) and clickable.hit then
            table.insert( clickedButtons, { clickable.priority, clickable } )
            clickable.hit = false
          else
            clickable.hit = false
          end
        end
      end
    end
    table.sort( clickedButtons, function ( a, b )
      return a[1] < b[1]
    end )
    if clickedButtons[1] and clickedButtons[1][2] then
      local c = clickedButtons[1][2]
      if c.pressAndHold then
        clickedButtons[1][2].callback ()
      else
        if not c.hit then
          c.callback ()
        end
      end
    end
  end
  if layer.animatedBG then
    local lastloc = layer.bgprop.lastloc or 0
    if layer.scroll == MENUBG_HORIZONTAL then
      -- Scrolling is horizontal.
      if lastloc == -SCREEN_UNITS_X / 2 then
        lastloc = SCREEN_UNITS_X / 2
      end
      layer.bgprop:setLoc ( lastloc )
      layer.bgprop.lastloc = lastloc - layer.scrollspeed
      return
    end
    -- Scrolling is vertical.
    if lastloc == -SCREEN_UNITS_Y / 2 then
      lastloc = SCREEN_UNITS_Y / 2
    end
    layer.bgprop:setLoc ( 0, lastloc )
    layer.bgprop.lastloc = lastloc - layer.scrollspeed
  end
  return false
end

onUnload = function ( layer )
  clearScreen(layer)
  if layer.buttonIcons then
    for i, icon in next, layer.buttonIcons, nil do
      layer:removeProp(icon)
    end
  end
  if layer.buttonBar then
    layer:removeProp(layer.buttonBar)
  end
end

makeMenuButtonProp = function ( layer, button )
  local x1, y1, x2, y2 = unpack ( button.pos )
  scriptDeck = MOAIScriptDeck.new ()
  scriptDeck:setRect ( x1, y1, x2, y2 )
  scriptDeck:setDrawCallback ( function (index, xOff, yOff, xFlip, yFlip )
    if button.border then
      MOAIGfxDevice.setPenColor ( 100, 100, 100, 1 )
      MOAIDraw.drawRect( x1, y1, x2, y2 )
    end
  end)
  local box = MOAIProp2D.new ()
  box:setDeck(scriptDeck)
  button.box = box
  layer:insertProp ( box )

  layer.textBoxes[button] = {}
  if button.text then
    local width = -(x1 - x2)
    local height = button.height
    local textx = (x1 + x2) / 2
    local texty = (y1 + y2) / 2
    if button.textPositionAlter then
      width, height, textx, texty = unpack(button.textPositionAlter)
    end


    layer.textBoxes[button].text = util.makeText ( button.text, width, height, textx, texty, button.textSize)
    layer.textBoxes[button].text:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
    layer:insertProp ( layer.textBoxes[button].text )
    layer.textBoxes[button].text:setPriority ( 2 )
  end
  if button.texture then
    layer.textBoxes[button].texture = MOAIProp2D.new ()
    layer.textBoxes[button].texture:setDeck ( button.texture )
    layer.textBoxes[button].texture:setLoc ( (x1 + x2) / 2, (y1 + y2) / 2 )
    layer:insertProp ( layer.textBoxes[button].texture )
    layer.textBoxes[button].texture:setPriority ( 1 )
  end
end

makeButton = function ( pos, border )
  local button = {}
  button.pressAndHold = false
  button.pos = pos
  button.height = 30
  button.textSize = 16
  button.priority = 1
  -- Flag for if we want a border on the button or not.
  button.border = false
  if border then
    button.border = true
  end

  button.callback = (function  ()
    -- Empty callback as default
  end)
  -- Now defaults to having texture.
  local width = pos[3] - pos[1]
  local height = pos[4] - pos[2]
  setButtonTexture ( button, "gfx/menubg.png", width, height )
  return button
end

setButtonCallback = function ( button, callback )
  button.callback = callback
end

setButtonText = function ( button, text )
  button.text = text
end

getButtonText = function ( button )
  return button.text
end

setButtonTextSize = function ( button, size )
  button.textSize = size
end

setButtonHeight = function ( button, height )
  button.height = height
end

setButtonTexture = function ( button, texture, width, height )
  local rect
  if width and height then
    rect = {
      -width / 2,
      -height / 2,
      width / 2,
      height / 2
    }
  else
    local x1, y1, x2, y2 = unpack ( button.pos )
    rect = { (x1 - x2) / 2, -(y1 - y2) / 2, -(x1 - x2) / 2, (y1 - y2) / 2 }
  end
  button.texture = MOAIGfxQuad2D.new ()
  button.texture:setTexture ( util.getTexture ( texture ) )
  button.texture:setRect ( unpack ( rect ) )
end

setButtonTextPosition = function ( button, position )
  button.textPositionAlter = position
end

changeButtonText = function ( layer, button, text )
  button.text = text
  layer.textBoxes[button].text:setString ( text )
end

changeButtonTextColor = function ( layer, button, r, g, b )
  layer.textBoxes[button].text:setColor ( r, g, b )
end

changeButtonTexture = function ( layer, button, gfx )
  setButtonTexture ( button, gfx, width, height )
  layer.textBoxes[button].texture:setDeck(button.texture)
end

makeBackground = function ( layer, animate, file, scroll, scrollspeed )
  local filename = file or "gfx/roadbg.png"
  local gfx = MOAIGfxQuad2D.new ()
  local speed = scrollspeed or 2
  gfx:setTexture ( util.getTexture ( filename ) )
  if scroll == MENUBG_HORIZONTAL then
    gfx:setRect ( -SCREEN_UNITS_X, -SCREEN_UNITS_Y / 2, SCREEN_UNITS_X, SCREEN_UNITS_Y / 2 )
  else
    gfx:setRect ( -SCREEN_UNITS_X/2, -SCREEN_UNITS_Y, SCREEN_UNITS_X/2, SCREEN_UNITS_Y )
  end
  layer.bgprop = MOAIProp2D.new ()
  layer.bgprop:setDeck ( gfx )
  layer:insertProp ( layer.bgprop )
  layer.animatedBG = animate or true
  layer.scroll = scroll
  layer.scrollspeed = speed
end

setPageSize = function ( layer, size )
  layer.pageSize = size
end

setTotalPagerItems = function ( layer, size )
  layer.totalPagerItems = size
end

initPager = function ( layer, file )
  layer.layerfile = file

  if not globalData.page then
    globalData.page = {}
  end
  if not globalData.page[layer.layerfile] then
    layer.page = 0
  else
    layer.page = globalData.page[layer.layerfile]
    globalData.page[layer] = nil
  end
end

pageItems = function ( layer, i )
  local page = layer.page
  local offset = page * layer.pageSize
  if i > offset and i <= offset + layer.pageSize then
    return true
  end
  return false
end

makePagerButtons = function ( layer, y )
  local page = layer.page
  local screenEdge = ((SCREEN_UNITS_X / 2) - SCREEN_UNITS_X / 10)
  local leftbutton = makeButton ( { -screenEdge + 40, y - 20, -screenEdge + 80, y + 10 } )
  setButtonCallback (leftbutton, (function ()
    if layer.page == 0 then
      -- Go back if we are on page 1? Never!
      return
    end
    globalData.page[layer.layerfile] = layer.page - 1
    statemgr.swap ( layer.layerfile )
  end))
  setButtonTexture ( leftbutton, "gfx/menubg.png" )
  setButtonText ( leftbutton, "<")
  setButtonTextSize ( leftbutton, 24 )

  local pagetext = makeButton ( { -50, y - 20, 50, y + 10 } )
  local totalpages
  if not layer.totalPagerItems then
    -- Just always assuming we have two pages, if we forget to specify it.
    totalpages = 2
  else
    totalpages = math.ceil( layer.totalPagerItems / layer.pageSize )
  end
  setButtonText ( pagetext, layer.page  + 1 .. " of " .. totalpages )
  setButtonTexture ( pagetext, "gfx/background.png" )
  setButtonTextSize ( pagetext, 16 )
  local rightbutton = makeButton ( { screenEdge - 80, y - 20, screenEdge - 40, y + 10 } )
  setButtonCallback (rightbutton, (function ()
    if layer.page + 1 == totalpages then
      -- Trying to go past the last page? No way!
      return
    end
    -- Flag the pager to be flipped on reload.
    globalData.page[layer.layerfile] = layer.page + 1
    -- Swap state, making the paging render the wanted page.
    statemgr.swap ( layer.layerfile )
  end))
  setButtonTexture ( rightbutton, "gfx/menubg.png" )
  setButtonText ( rightbutton, ">")
  setButtonTextSize ( rightbutton, 24 )
  return leftbutton, rightbutton, pagetext
end

clearScreen = function ( layer )
  if not layer.clickables then return end
  for i, clickable in ipairs ( layer.clickables ) do
    layer:removeProp ( clickable.box )
  end
  for i, textBox in next, layer.textBoxes, nil do
    if textBox.text then
      layer:removeProp ( textBox.text )
    end
    if textBox.texture then
      layer:removeProp ( textBox.texture )
    end
  end
end
