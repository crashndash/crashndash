module ( "facebook", package.seeall )

if MOAIFacebookAndroid and not MOAIFacebook then
  MOAIFacebook = MOAIFacebookAndroid
end

APP_ID = appConfig.facebookId

init = function (  )
  MOAIFacebook.init ( APP_ID )
end

loginSuccessCallback = function (  )
  if DEBUGDATA then
    -- @todo. Remove this in some way. Pretty sure it is not used?
    globalData.config.fb = true
    globalData.config.fbid = "testFacebookId"
    globalData.config.name = "Test Facebook Name"
    globalData.config.email = "testmail@facebook.com"
    config:saveGame()
    return
  end
  local token = MOAIFacebook.getToken()
  local expDate = MOAIFacebook.getExpirationDate ()
  saveFB ( token, expDate )
end

saveFB = function ( token, expDate )
  config.data.config.fb = true
  config.data.config.fbtoken = token
  config.data.config.expDate = expDate
  config:saveGame ()
  saveMyName ()
end

saveMyName = function (  )
  facebook.doGraph ( "me", function ( task, responseCode )
    local json = MOAIJsonParser.decode ( task:getString ())
    config.data.config.fbid = json.id
    config.data.config.name = json.name
    config.data.config.email = json.email
    config:saveGame ()
  end )
end

-- There is actually a function called "graphRequest", but the event constant
-- called "REQUEST_RESPONSE" is only implemented on iOS. :(
-- So we do our own, cleaner graph function.
doGraph = function ( path, callback )
  local thread = MOAIThread.new()
  thread:run (function ( )
    local httptask = MOAIHttpTask.new ()
    httptask:setCallback( callback )
    httptask:setUrl ( "https://graph.facebook.com/" .. path .. "?access_token=" .. config.data.config.fbtoken )
    httptask:performAsync ()
  end )
end

errorcb = function ()
  -- Meh. At least we listen for it, right?
end

connect = function ( callback )
  local successcallback = callback or loginSuccessCallback
  if MOAIFacebook then

    MOAIFacebook.init ( APP_ID )
    if MOAIFacebook.setListener then
      MOAIFacebook.setListener ( MOAIFacebook.SESSION_DID_LOGIN, successcallback )
      MOAIFacebook.setListener ( MOAIFacebook.DIALOG_DID_COMPLETE, loginSuccessCallback )
      MOAIFacebook.setListener ( MOAIFacebook.DIALOG_DID_NOT_COMPLETE, errorcb )
      MOAIFacebook.setListener ( MOAIFacebook.SESSION_DID_NOT_LOGIN, errorcb )
    end

    if MOAIFacebook.login then MOAIFacebook.login ({"email"}) end

  else
    if DEBUGDATA then
      successcallback ()
    end
  end

end
