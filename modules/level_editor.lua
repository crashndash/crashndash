module("LevelEditor", package.seeall)

local u = require('socket.url')

SERVER_BASE = 'http://levels.crashndash.com'
-- Useful for local development.
--SERVER_BASE = 'http://localhost:4000'

getLevels = function( callback )
  -- Use same http task as multiplayer.
  local url = SERVER_BASE .. '/api/level'
  return Http.httpTaskSetup(url, callback)
end

load = function ( level, callback )
  if not callback then
    callback = function ( task, responsecode )
      print(responsecode)
      print(task:getString())
    end
  end
  local url = SERVER_BASE .. '/api/level/' .. u.escape(level)
  print("Loading level from URL: " .. url)
  Http.httpTaskSetup(url, callback)
end
