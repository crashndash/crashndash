module("Gamecenter", package.seeall)

IOS_LEADERBOARD = appConfig.iosLeaderboard
ANDROID_LEADERBOARD = appConfig.androidLeaderboard

-- String used in the interface.
centername = "Google Play Services"
if MOAIGameCenterIOS then
  centername = "Game Center"
end

local connected = false
local showNotConnected = function (  )
  -- Add a infotext about the incident.
  local text = "You must be signed in to " .. centername .. " to show the leaderboard."
  Error.showError(text)
end
local androidSetup = function(cb)
  local connectionComplete = function()
    globalData.config.gamecenterConnected = true
    connected = true
    cb()
  end
  MOAIGooglePlayServicesAndroid.setListener(MOAIGooglePlayServicesAndroid.CONNECTION_COMPLETE, connectionComplete)
  if MOAIGooglePlayServicesAndroid.isConnected() then
    connected = true
    globalData.config.gamecenterConnected = true
    cb()
  else
    MOAIGooglePlayServicesAndroid.connect()
  end

  reportScore = function(score)
    if not connected then return end
    MOAIGooglePlayServicesAndroid.submitScore(ANDROID_LEADERBOARD, score)
  end
  showLeaderboard = function()
    if not connected then
      showNotConnected()
      return
    end
    MOAIGooglePlayServicesAndroid.showLeaderboard(ANDROID_LEADERBOARD)
  end
end

local iosSetup = function(cb)
  MOAIGameCenterIOS.authenticatePlayer()

  -- iOS does not have a callback to tell us when things went OK. So we just
  -- check for a while.
  local t = MOAIThread.new()
  t:run(function()
    local retries = 0
    while not connected and retries < 60 do
      if MOAIGameCenterIOS.getPlayerAlias() then
        connected = true
        globalData.config.gamecenterConnected = true
      end
      retries = retries + 1
      util.sleep(1)
    end
    cb()
  end)

  reportScore = function(score)
    if not connected then return end
    MOAIGameCenterIOS.reportScore(score, IOS_LEADERBOARD)
  end

  showLeaderboard = function()
    if not connected then
      showNotConnected()
      return
    end
    MOAIGameCenterIOS.showDefaultLeaderboard()
  end
end

reportScore = function(score)
  print("DEBUG: Would have reported a score of " .. score)
end

showLeaderboard = function()
  print("DEBUG: Would have shown a leaderboard now.")
end

connect = function(cb)
  if MOAIGooglePlayServicesAndroid then
    androidSetup(cb)
  end
  if MOAIGameCenterIOS then
    iosSetup(cb)
  end
end
