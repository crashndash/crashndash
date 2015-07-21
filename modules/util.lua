module ( "util", package.seeall )

local u = require('socket.url')

-- URL scheme is based on facebook id.
URL_SCHEME_BASE = "fb" .. appConfig.facebookId .. "://"

sleep = function ( n )
  local t0 = socket.gettime ()
  while socket.gettime () - t0 <= n do
    coroutine:yield ()
  end
end

wait = function ( action )
  while not action:isDone () do coroutine:yield() end
end

local makeProp = function ( gfx, x, y, parent )
  local prop = MOAIProp2D.new ()
  prop:setDeck ( gfx )
  prop:setLoc ( x, y )
  if parent then
    prop:setParent ( parent )
  end
  return prop
end

getProp  = function ( filename, width, height, x, y, parent )
  local gfx = MOAIGfxQuad2D.new ()
  gfx:setTexture ( util.getTexture ( filename ) )
  gfx:setRect ( -width/2, -height/2, width/2, height/2 )
  local prop = makeProp ( gfx, x, y, parent )
  return prop
end


halfX = SCREEN_UNITS_X / 2
halfY = SCREEN_UNITS_Y / 2

local fontCache = {}

getFont = function ( filename, size )
  local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÑÈÉÊÂËÃabcdefghijklmnopqrstuvwxyzæøåàáäâéèëêñ0123456789 .,:;!?()&/-<>+"$'
  local font = fontCache [ filename .. size ]
  if nil == font then
    font = MOAIFont.new ()
    font:loadFromTTF ( filename, charcodes, size )
    fontCache [ filename .. size ] = font
  end
  return font
end

makeText = function ( text, width, height, x, y, size )
  size = size or 32
	local font = getFont ( 'gfx/fireb.ttf', size )
	textbox = MOAITextBox.new ()
	textbox:setString ( text )
	textbox:setFont ( font )
	textbox:setRect ( -width/2, -height/2, width/2, height/2 )
	textbox:setLoc ( x, y )
	textbox:setYFlip ( true )
	return textbox
end

local textureCache = {}

getTexture = function ( fileName )
  local texture = textureCache [ fileName ]
  if nil == texture then
    texture = MOAITexture.new ()
    texture:load ( fileName )
    textureCache [ fileName ] = texture
  end
  return texture
end

getGrid = function ( width, length, gfx, offsetX, offsetY, size, tilewidth, stopanim )
  local grid = MOAIGrid.new()
  local gridsize = size or 50
  local tiles = tilewidth or 1
  if length % gridsize ~= 0 then
    -- Oh gee, try to use 50s for these things, eh?
    gridsize = length
  end
  if width % gridsize ~=0 then
    -- Find out how much we are off on dividing by 50.
    local over = width % gridsize
    -- Calculate how much we need to add to the width
    local missing = gridsize - over
    -- Adjust the width. Ugly hack, but will probably most often apply to when
    -- width is SCREEN_SIZE_X
    width = width + missing
  end
  local gridwidth = width / gridsize
  local gridheight = (length / gridsize)
  grid:initRectGrid ( gridwidth, gridheight, gridsize, gridsize )
  local i = 1
  local tiletable = {}
  while i <= gridwidth do
    table.insert( tiletable, 0x01 )
    i = i + 1
  end
  i = 0
  while i <= gridheight do
    -- Since the tile is 1x1, we want all tiles to be 0x01
    grid:setRow(i, unpack(tiletable) )
    i = i + 1
  end

  local deck = MOAITileDeck2D.new()
  deck:setTexture(gfx)
  deck:setSize(tiles, 1)

  local gridProp = MOAIProp2D.new()
  gridProp.tiles = tiles
  gridProp:setDeck(deck)
  gridProp:setGrid(grid)
  gridProp:setLoc ( offsetX, offsetY )

  gridProp.animate = function ( self )
    local grid = self:getGrid()
    self.lastrow = self.lastrow or 0
    self.lastrow = self.lastrow + 1
    local nowUsing = self.lastrow
    if self.lastrow > self.tiles then
      if stopanim then
        self.doneAnimating = true
        return
      end
      self.lastrow = 1
      nowUsing = 0x01
    end
    i = 0
    local tiletable = {}
    while i <= gridwidth do
      table.insert( tiletable, nowUsing )
      i = i + 1
    end
    i = 0
    while i <= gridheight do
      grid:setRow(i, unpack(tiletable) )
      i = i + 1
    end
    self:setGrid(grid)
  end

  return gridProp
end

getExplosionAnimation = function ( size )
  return util.getGrid ( size, size, "gfx/explodos.png", - (size / 2), - ( size / 2 ), size, 14, true )
end

local soundCache = {}

getSound = function ( filename, loadtomem )
  local sound = soundCache [ filename ]
  if loadtomem == nil then
    loadtomem = true
  end
  if nil == sound then
    sound = MOAIUntzSound.new ()
    sound:load ( filename, loadtomem )
    sound:setLooping ( false )
    soundCache [ filename ] = sound
  end
  sound:stop ()
  return sound
end

openURL = function ( url )
  if MOAIBrowserAndroid then
    MOAIBrowserAndroid.openURL(url)
  end
  if MOAISafariIOS then
    MOAISafariIOS.openURL ( url )
  end
  if DEBUG then
    print("open url: " .. url)
  end
end

getMD5 = function ( string )
  local writer = MOAIHashWriter.new ()
  writer:openMD5 ()
  writer:write ( string )
  writer:close ()
  return writer:getHashHex ()
end

-- Found this on stack overflow:
-- Source: http://lua-users.org/wiki/MakingLuaLikePhp
-- Credit: http://richard.warburton.it/
explode = function (div, str)
  local pos,arr = 1, {}
  for st,sp in function() return string.find(str, div, pos, true) end do
    table.insert(arr,string.sub(str,pos,st-1))
    pos = sp + 1
  end
  table.insert(arr,string.sub(str,pos))
  return arr
end

openedFromUrl = function ( url )
  -- We should probably have used some library, but here goes some hacky code:

  -- First strip out protocol (always the same)
  local no_p = string.gsub(url, URL_SCHEME_BASE, "")

  -- Then split to array, based on "&".
  local arr = explode("&", no_p)
  local values = {}

  for d, s in ipairs(arr) do
    if d == 1 then
      -- First string has a question mark in it.
      s = string.sub(s, 2)
    end
    -- Then split on "="
    local a = explode("=", s)
    values[a[1]] = a[2]
  end

  if values.action then
    -- We have an action to do. First rewind all states. Let's just try to pop
    -- alot of times. Seems to work.
    statemgr.pop()
    statemgr.pop()
    statemgr.pop()
    statemgr.pop()
    statemgr.pop()
    statemgr.pop()
    statemgr.pop()

    -- Push main menu, so we know where we come from.

    statemgr.push("states/state-main-menu.lua")

    local action = values.action
    if action == "multiplayer" then
      -- User wants to play multiplayer. So be it. Find room
      if not values.room then return end
      local room = values.room

      -- First press the multiplayer button for the user.
      statemgr.swap ( "states/state-game.lua" )
      statemgr.swap ( "states/state-multiplayer.lua" )

      -- Then start the game for the user.
      local state = statemgr.getCurState()
      if values.referrer then
        multiplayer.referrer = values.referrer
      end
      local t = MOAIThread.new()
      t:run(function()
        while not multiplayer.connected do
          util.sleep(.5)
          if state.madeTeaparty then
            -- Sorry! old version of the game!
            return
          end

          if multiplayer.connecterror then
            return
          end

        end
        multiplayer.startGame(room, state.layer.loading)

      end)
    end

    if action == "campaign" and values.id then
      -- This person has clicked some link we have generated. Store in config!
      globalData.config.campaigns[id] = true
    end

    if action == "level" and values.name then
      -- User wants to play a level he probably made himself.
      statemgr.swap("states/state-main-menu.lua")

      -- Fake a click on the "start single player button"
      if globalData.config.currentWorld == "special" then
        globalData.config.currentLevel = 1
        globalData.config.currentWorld = 1
      end
      statemgr.swap("states/state-game.lua")

      -- Fake a click on the load level and then load by name.
      statemgr.pop()
      statemgr.swap("states/state-loadlevel-name.lua")

      -- Fake entering of the level name.
      local ls = statemgr.getCurState()

      -- Oh boy, this was a pain. If I sent in a correctly encoded URI here,
      -- java would screw this up. So we send in a double encoded URI. Such
      -- hack, very success.
      menu.changeButtonText(ls.layer, ls.layer.textEdit, u.unescape(u.unescape(values.name)))

      -- Fake clicking the Load button.
      ls.layer.loadButton.callback()

    end
  end
end
