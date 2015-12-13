-- Make sure we have a config file.
local c = io.open('config.lua', 'r')
if c ~= nil then
  print('Will use modified config')
  io.close(c)
  appConfig = dofile('config.lua')
else
  print('Will use default config')
  appConfig = dofile('default.config.lua')
end

require "platforms/platform-osx"
require "modules/input-manager"
require "modules/savefile-manager"
require "modules/util"
require "modules/state-manager"
require "modules/menu"
require "modules/sound"
require "modules/facebook"
require "modules/achievements-manager"
require "modules/level"
require "modules/http"
require "modules/multiplayer"
require "modules/cloud-manager"
require "modules/billing"
require "modules/unloader"
require "modules/level_editor"
require "modules/empty_level"
require "modules/keyboard"
require "modules/error"
require "modules/reporter"
require "modules/gamecenter"
require "socket"
require "elements/bgsound"
require 'elements/popup'

MOAISim.openWindow ( "Crashndash", SCREEN_WIDTH, SCREEN_HEIGHT )
MOAISim.setTraceback(Reporter.traceBack)

MOAILogMgr.setLogLevel ( MOAILogMgr.LOG_ERROR )

viewport = MOAIViewport.new ()
local heightoffset = 0
local widthoffset = 0
if SCREEN_HEIGHT / SCREEN_WIDTH > 1.5 then
  heightoffset = (SCREEN_HEIGHT - (SCREEN_WIDTH * 1.5)) / 2
end
if SCREEN_HEIGHT / SCREEN_WIDTH < 1.5 then
  widthoffset = (SCREEN_WIDTH - (SCREEN_HEIGHT / 1.5)) / 2
end
viewport:setSize(widthoffset, heightoffset, SCREEN_WIDTH - widthoffset, SCREEN_HEIGHT - heightoffset)
viewport:setScale(SCREEN_UNITS_X, SCREEN_UNITS_Y)

-- seed random numbers
randomseed = os.time ()
math.randomseed ( randomseed )
math.random ( 9999 )

globalData = {}
-- For server. Needs to be a float.
GAME_VERSION = 1.7
-- Build version. Used in the "credits screen."
BUILD_VERSION = "1.7.0"
print("Crash n Dash, open source version. Build version " .. BUILD_VERSION)
MOAIUntzSystem.initialize ()
MOAIUntzSystem.setVolume(0.5)

config = savefiles.get ( "settings" )
if not config.data.config then
  config.data.config = {}
  config:saveGame ()
end

config:init()
globalData.config = config.data.config
globalData.notify = {}
globalData.weaponsAvailable = achmng.countUnlocksAvailable()
statemgr.initTime()

if not globalData.config.id then
  -- Save an ID on first startup of the game. Or first startup of new version.
  local uuid = MOAIEnvironment.generateGUID()
  config.data.config.id = "anon" .. uuid
  config:saveGame ()
end
if not config.data.config.expPoints then
  config.data.config.expPoints = 0
end
globalData.config.expBought = globalData.config.expBought or {}

if globalData.config.soundFx == false then
  sound.turnOffFx ()
else
  sound.turnOnFx ()
end
if globalData.config.soundMusic == false then
  sound.turnOffMusic ()
else
  sound.turnOnMusic ()
end

-- @todo: Should we really init FB right away?
-- Always check that MOAIFacebook is not nil, because it is nil in simulator!
if MOAIFacebook and globalData.config.fb then
  -- Just inits with our app id.
  facebook.init ( )
  MOAIFacebook.setToken ( globalData.config.fbtoken )
  MOAIFacebook.setExpirationDate ( globalData.config.expDate )
  -- Should we call extendToken always here?
end
statemgr.push ( "states/state-main-menu.lua" )
statemgr.begin ()
globalData.bgsound = Bgsound.new ()
globalData.bgsound.init()
