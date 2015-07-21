module ( "multiplayer", package.seeall )

SERVER_BASE = appConfig.serverBase

connected = false
offline = false
roomSuggestion = ""
totalPlayers = ""
roomPlayers = ""
onlineUsers = {}
id = math.random ( 9999 ) + os.time() .. ""
local lasttime = 0
name = "player " .. math.random ( 999 )
opponents = 0
room = ""
lastsummary = {}
totalUps = {}
totalBlocks = {}
summaryAvailable = false
carstats = {}
teapot = true
score = 0
won = false
alone = false
messageQueue = {}
registeredProgress = {}
positions = {}
myProgress = 0
maxEnemies = 15
kickmessage = nil
rewards = 0
connecterror = false
mail = ""
referrer = false

httpTaskSetup = Http.httpTaskSetup

init = function (  )
  -- Generate a new name. Can not trust that other randomness.
  name = "player " .. math.random ( 999 )
  id = globalData.config.id or id
  name = globalData.config.name or name
  mail = globalData.config.email or ""

  -- Save this name for later. Meaning you only get assigned a name once.
  globalData.config.name = name
end

connect = function (  )
  local url = SERVER_BASE .. "/connect"
  return httpTaskSetup ( url, playerConnected )
end

sendStats = function(cb)
  local callback = cb or statsCallback
  local data = {
    config = globalData.config
  }
  local append = ""
  if referrer then
    if referrer ~= id then
      append = "?referrer=" .. referrer
    end
  end
  local url = SERVER_BASE .. "/stats" .. append
  return httpTaskSetup ( url, callback, true, data )
end

statsCallback = function ( task, responsecode )
  -- Meh. If we get an error, at least we tried. Callback does nothing.
  if referrer then
    referrer = false
  end
end

playerConnected = function ( task, responsecode )
  connecterror = false
  if (responsecode == 200) then
    -- I guess the server is a teapot?
    teapot = true
    local response = MOAIJsonParser.decode ( task:getString () )
    if not response.timestamp then return end
    lasttime = response.timestamp
    roomSuggestion = response.goodroom .. ""
    roomPlayers = response.roomPlayers .. ""
    totalPlayers = response.totalPlayers .. ""
    onlineUsers = response.users
    rewards = response.rewards or 0
    if response.allReward then
      local r = response.allReward
      if globalData.config.rewards[r] then
        -- User has collected this before.
        rewards = rewards - r
      else
        -- Put this in the configs. This way we can also see it in dashboard -
        -- stalker version.
        globalData.config.rewards[r] = true
      end
    end
    connected = true
  else
    if responsecode == 418 then
      -- The server is not a teapot? Who would have thought.
      teapot = false
      connected = true
      return
    else
      connecterror = responsecode
    end
    offline = true
    connected = false
  end
end

startGame = function ( gamename )
  myProgress = 0
  registeredProgress = {}

  local callback = function ( task, responsecode )
    if responsecode == 200 then
      -- Yes! We have created a game. (or joined).
      local response = MOAIJsonParser.decode(task:getString())
      if not response then
        -- Oh well. what are you gonna do... Must be old version.
        opponents = task:getString()
      else
        opponents = response.opponents
        totalBlocks = response.blocks
        totalUps = response.powerUps
      end
      gameStarted ( gamename )
    else
      -- @todo Error handling. Let's try again.
      if responsecode == 403 then
        -- This room is full.
        -- @todo: Show a popup here.
        return
      end
    end
  end
  local url = SERVER_BASE .. "/game?game=" .. gamename
  return httpTaskSetup(url, callback, true)
end

gameStarted = function ( name )
  room = name
  if opponents == 1 then
    -- We are alone in this world. boo-hoo.
    alone = true
  end
  -- We are ready to play!

  globalData.config.currentLevel = "multiplayer"
  globalData.config.currentWorld = "special"
  poll ( lasttime )

  game.loadLevel ( "multiplayer", "special" )

  statemgr.swap ( "states/state-level.lua", true )

  game.makeButtons ()
  sendMessage ( "join", room )
end

pollCallback = function ( task, responsecode )
  if game.levelNumber ~= "multiplayer" then
    -- We are mos def not playing multiplayer.
    return
  end
  if responsecode == 204 then
    local pollroom = task:getResponseHeader ('X-room')
    if pollroom ~= room then
      -- Woah, a poller looking for events in another room? Abort!
      return
    end
    -- 204 is the response that we want.
    opponents = task:getResponseHeader ('X-opponents')
    poll ( lasttime )
  else
    if responsecode ~= 200 then
      -- If it is not 204, and not 200, then something is wrong.
      connected = false
      return
    end
    local result = MOAIJsonParser.decode ( task:getString ())
    if result.room ~= room then
      -- Woah, a poller looking for events in another room? Abort!
      return
    end
    if alone then
      -- If we have recieved something while alone, it must mean we are not
      -- alone anymore.
      alone = false
    end
    -- Store timestamp to tell the polling from when we want events.
    lasttime = result.timestamp
    opponents = result.users
    if not game or not connected then
      poll ( lasttime )
      return
    end
    local ls = statemgr.getCurState()
    if ls.filename == "states/state-pause.lua" then
      -- The game is on pause. Swallow all events.
      poll ( lasttime )
      return
    end
    for i, event in ipairs ( result.events ) do
      if event.type == "progress" then
      end
      if event.type == "car" then
        if game.level.enemyCount > maxEnemies then
          -- Oh no you don't.
        else
          local badguy = game.enemyFactory.spawnCar ( game.level.world, game.tick, false, event.message )
          game.level:addEnemy ( badguy )
        end
        if game.level.multiplayerheads[event.fromname] then
          game.level.multiplayerheads[event.fromname]:animate ()
        end
      end
      if event.type == "death" then
        -- Someone died.
        table.insert( game.level.popups, Popup.new ( event.fromname .. " just lost one life (and a lot of bonus)" ))
      end
      if event.type == 'join' then
        -- Someone joined.
        table.insert( game.level.popups, Popup.new ( event.fromname .. " just joined!" ) )
      end
      if event.type == 'startover' then
        -- Someone started over. Neverminding this for now.
      end
      if event.type == 'rocket' then
        -- Oh noes. A rocket. Sorry to say that there will be a hole in
        -- your road.
        game.level:addObstacle ( "hole" )
        table.insert( game.level.popups, Popup.new ( event.fromname .. " blew a hole in your road!" ) )
      end
      if event.type == 'swarm' then
        -- Woah, a swarm. Let's spawn some random stuff!
        local random  = math.random(#game.level.enemyVariations)
        local type = game.level.enemyVariations[random]
        local swarm = {
          type = type,
          size = 5
        }
        game.level.makeSwarm ( swarm )
        table.insert( game.level.popups, Popup.new ( "A swarm from " .. event.fromname ) )
      end
      if event.type == 'summary' then
        multiplayer.lastsummary = event.message.results
        local level = event.message.level
        totalBlocks = level.blocks
        totalUps = level.powerUps
        multiplayer.summaryAvailable = true
      end
      if event.type == 'kick' then
        -- Someone is kicked. Since the server is the one sending this stuff,
        -- let's just use the fromname field to tell who it is.
        local kicked = event.fromname
        if kicked == name then
          kickmessage = event.message
          return
        end
        if game.level.multiplayerheads[kicked] then
          game.level.multiplayerheads[kicked]:remove()
          table.insert( game.level.popups, Popup.new ( kicked .. " got kicked out of the room. Reason: " .. event.message ) )
        end
      end
    end
    if result.stats then
      -- We have gathered some statistics. Let's present them.
      parseStats (result.stats)
    end
    if result.progress then
      positions = result.progress
    end
    poll ( lasttime )
  end
end

getKicked = function ( message )
  kickroom = room
  connected = false
  room = ""
  statemgr.swap ( "states/state-game.lua" )
  statemgr.swap ( "states/state-multiplayer.lua" )
  Popup.createLayerPopup ( "You got kicked out of " .. kickroom .. ". Reason: " .. (message or ""))
end

poll = function ( timestamp )
  if not connected then return end
  local url = SERVER_BASE .. "/poll?room=" .. room .. "&time=" .. lasttime
  return httpTaskSetup ( url, pollCallback )
end

parseStats = function ( stats )
  if stats == 0 then
    -- Nothing to report.
    return
  end
  carstats = stats
end

sendMessage = function ( type, reciever, message )
  local sendto = reciever or room
  if not sendto then
    return
  end
  if not type then
    return
  end
  local sendmessage = message or ""
  local url = SERVER_BASE .. "/?room=" .. sendto .. "&message=" .. sendmessage .. "&type=" .. type
  return httpTaskSetup ( url, messageCallback, true )
end

messageCallback = function ( task, responsecode )
  if responsecode ~= 200 then
    -- @todo: Error handling.
  else
    if not connected then
      -- If we are flagged as offline, then put us back up!
      connected = true
      poll ( lasttime )
    end
    -- Get the stats.
    local result = MOAIJsonParser.decode ( task:getString ())
    if result then
      parseStats ( result )
    end
  end
end

lostlife = function ( )
  sendMessage ( "death", room, "" )
  myProgress = myProgress - 5
  registeredProgress = {}
end

onUpdate = function ( )
  if #messageQueue > 0 then
    local s = ""
    for _, p in pairs(messageQueue) do
      s = s .. "," .. p
    end
    messageQueue = {}
    s = string.sub(s, 2)
    sendMessage ( "car", nil, s )
  end
end

progressUpdate = function (  )
  if not game.level.multiplayerpos[name] then
    local carType = globalData.config.carType or "redcar"
    game.level.multiplayerpos[name] = util.getProp ( "gfx/" .. carType .. ".png", 6, 6, myxpos, 130, nil )
    game.insertPropIntoTextLayer ( game.level.multiplayerpos[name] )
  end
  local myxpos = -util.halfX + 12
  local percent = myProgress / game.level.length
  game.level.multiplayerpos[name]:setLoc(myxpos, -140 + (percent * 260))
  if game.level.roadCount then
    if not registeredProgress[myProgress] then
      registeredProgress[myProgress] = true
      myProgress = myProgress + 1
      if myProgress % 5 == 0 then
        sendMessage ( "progress", nil, myProgress )
      end
    end
  end
end
