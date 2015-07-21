module("Http", package.seeall)

makeHash = appConfig.makeHash()

httpTaskSetup = function(url, callback, post, data)
  local thread = MOAIThread.new()
  thread:run (function ( )
    local httptask = MOAIHttpTask.new ()
    if data then
      local jsonbody = MOAIJsonParser.encode(data)
      httptask:setHeader ( "Content-Type", "application/json" )
      httptask:setBody(jsonbody)
    end

    -- Set some secret stuff in the header.
    local number, hash = makeHash()
    httptask:setHeader ( appConfig.headerControl, number .. '' )
    httptask:setHeader ( appConfig.headerHash, hash )
    local name = multiplayer.name and multiplayer.name or ""
    local id = multiplayer.id and multiplayer.id or 0
    local mail  = multiplayer.mail and multiplayer.mail or ""
    local userdata = {
      name = name,
      id = id,
      version = GAME_VERSION,
      mail = mail
    }
    httptask:setHeader("X-User", MOAIJsonParser.encode(userdata))

    httptask:setCallback( function ( task, code )
      if callback then
        callback(task, code)
      end
    end )
    httptask:setUrl ( url )
    if post then
      httptask:setVerb ( MOAIHttpTask.HTTP_POST )
    end
    httptask:setTimeout ( 60 )
    httptask:performAsync ()
  end)
end
