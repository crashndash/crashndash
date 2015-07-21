local config = {}

local hashCounter = 0

local makeHash = function ()
  return function ()
    hashCounter = hashCounter + math.random(2,10)
    -- Generate a random, but not the same as last time number
    local number = hashCounter .. '' .. math.random(100, 999)
    local id = 0
    if multiplayer.id then
      id = multiplayer.id
    end

    return number, util.getMD5(id .. GAME_VERSION .. number)
  end
end

config.headerHash = 'X-Thisisthehash'
config.headerControl = 'X-Number'
config.makeHash = makeHash
config.billingKey = "key"
config.serverBase = "http://localhost:3333"
config.reportUrl = "http://localhost:3333/messages"
config.facebookId = '1234'
config.iosLeaderboard = 'leader'
config.androidLeaderboard = 'leader'

return config
