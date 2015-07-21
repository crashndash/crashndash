module ( "cloud", package.seeall )

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------
local CLOUD_URL_BASE = multiplayer.SERVER_BASE

--------------------------------------------------------------------
-- global helpers
--------------------------------------------------------------------
function escape ( str )

  str = string.gsub ( str, "([&=+%c])",
    function ( c )
      return string.format( "%%%02X", string.byte ( c ))
    end
  )

  str = string.gsub ( str, " ", "+" )

  return str
end

----------------------------------------------------------------
function encode ( t )

  local s = ""

  for k,v in pairs ( t ) do
    s = s .. "&" .. escape ( k ) .. "=" .. escape ( v )
  end

  return string.sub ( s, 2 ) -- remove first '&'
end
--------------------------------------------------------------------
-- local helpers
--------------------------------------------------------------------
local function createTask ()

  local task = {}

  task.isFinished = false

  task.waitFinish = function ( self )
    while ( not self.isFinished ) do
      coroutine.yield ()
    end
    return self.result, self.responseCode
  end


  task.callback = function ( self )
    return function ( task, responseCode )
      self.responseCode = responseCode
      self.result = MOAIJsonParser.decode ( task:getString ())
      self.isFinished = true
    end
  end

  return task
end

--------------------------------------------------------------------
-- exposed functions
--------------------------------------------------------------------
function createGetTask ( urlExt, data, debug )

  local task = createTask ()

  if not data then
    data = {}
  end

  if USE_CLIENT_KEY then
    data.clientkey = CLOUD_CLIENT_KEY
  end

  task.httptask = MOAIHttpTask.new ()
  task.httptask:setCallback ( task:callback ())
  task.httptask:setUserAgent ( "Moai" )

  if debug then
    print ( CLOUD_URL_BASE .. urlExt .. "?" .. encode ( data ))
  end

  task.httptask:setUrl ( CLOUD_URL_BASE .. urlExt .. "?" .. encode ( data ))
  task.httptask:httpGet ( CLOUD_URL_BASE .. urlExt .. "?" .. encode ( data ) )

  return task
end

----------------------------------------------------------------
function createPostTask ( urlExt, data, debug )

  local task = createTask ()

  task.httptask = MOAIHttpTask.new ()
  task.httptask:setCallback ( task:callback ())
  task.httptask:setUserAgent ( "Moai" )

  if debug then
   print ( CLOUD_URL_BASE .. urlExt .. encode ( data ))
  end

  task.httptask:setUrl ( CLOUD_URL_BASE .. urlExt )
  --task.httptask:setVerb ( MOAIHttpTask.HTTP_POST )
  task.httptask:setBody ( MOAIJsonParser.encode ( data ) )

  -- Be sure that multiplayer module does not use on the fly generated id.
  multiplayer.id = globalData.config.id

  -- Set some secret stuff in the header.
  local number, hash = Http.makeHash()
  task.httptask:setHeader ( appConfig.headerControl, number .. '' )
  task.httptask:setHeader ( appConfig.headerHash, hash )
  task.httptask:setHeader ( "Content-Type", "application/json" )
  local userdata = {
      name = multiplayer.name,
      id = multiplayer.id,
      version = GAME_VERSION,
      mail = globalData.config.mail
  }
  task.httptask:setHeader("X-User", MOAIJsonParser.encode(userdata))


  task.httptask:performAsync ()

  return task
end

postHighScore = function ( layer )
  local data = {
    userid = globalData.config.id,
    username = globalData.config.name or multiplayer.name,
    score = config.data.config.highScore,
    -- Hash the score together with a super secret string.
    check = util.getMD5(config.data.config.highScore .. "burn rubber, burn!")
  }
  layer.postedStuff = true
  postThread = MOAICoroutine.new ()
  -- Be sure that we have an id and a name, when posting hashes and stuff.
  multiplayer.init()
  postThread:run (function (  )
    local task = cloud.createPostTask( "/score", data )
    local result, code  = task:waitFinish ()
    if code == 200 then
      layer.popups = layer.popups or {}
      table.insert ( layer.popups, Popup.new ( "Your score was posted!", layer ) )
      globalData.hiscorePosted = true
      achmng.sendAchievements ( layer )
      globalData.hiscorePosted = false
    else
      layer.popups = layer.popups or {}
      table.insert ( layer.popups, Popup.new ( "There was a problem posting your highscore. Please try again later!", layer ) )
    end
  end)
end
