SCREEN_WIDTH = MOAIEnvironment.horizontalResolution
SCREEN_HEIGHT = MOAIEnvironment.verticalResolution

-- @todo Will not work on other platforms anymore :(
if MOAIEnvironment.osBrand == 'OSX' then
  SCREEN_WIDTH = 320
  SCREEN_HEIGHT = 480
  DEBUGDATA = true
end

if SCREEN_HEIGHT == nil then
  SCREEN_HEIGHT = 480
end

SCREEN_UNITS_X = 320
SCREEN_UNITS_Y = 480

DEBUG = 1
