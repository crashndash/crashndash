module ( "inputmgr", package.seeall )

----------------------------------------------------------------
-- local interface
----------------------------------------------------------------
local pointerX, pointerY = -1, -1
local levelX, levelY, levelZ = 0, 0, 0
local yOffset = nil

if MOAIInputMgr.device.pointer then

	local pointerCallback = function ( x, y )

		pointerX, pointerY = x, y

		if touchCallbackFunc then
			touchCallbackFunc ( MOAITouchSensor.TOUCH_MOVE, 1, pointerX, pointerY, 1 )
		end
	end

	MOAIInputMgr.device.pointer:setCallback ( pointerCallback )
end

resetYOffset = function ()
  yOffset = levelY
  return levelY
end

getYOffset = function ()
  return yOffset or resetYOffset ()
end

local onLevelEvent = function ( x, y, z )
  levelX = x
  levelY = y
  levelZ = z
end

local keys = {}
if MOAIInputMgr.device.keyboard then

	local keyCallback = function ( key, down )
		if down then
      table.insert ( keys, key )
    end
    if DEBUG then
      if key == 97 then
        levelX = down and -1 or 0
      elseif key == 100 then
        levelX = down and 1 or 0
      elseif key == 115 then
        levelY = down and -1 or 0
      elseif key == 119 then
        levelY = down and 1 or 0
      end
    end
	end

	MOAIInputMgr.device.keyboard:setCallback ( keyCallback )
end

if MOAIInputMgr.device.level then
  MOAIInputMgr.device.level:setCallback ( onLevelEvent )
end

charForCode = {
	[ 97 ] = "a",
	[ 98 ] = "b",
	[ 99 ] = "c",
	[ 100 ] = "d",
	[ 101 ] = "e",
	[ 102 ] = "f",
	[ 103 ] = "g",
	[ 104 ] = "h",
	[ 105 ] = "i",
	[ 106 ] = "j",
	[ 107 ] = "k",
	[ 108 ] = "l",
	[ 109 ] = "m",
	[ 110 ] = "n",
	[ 111 ] = "o",
	[ 112 ] = "p",
	[ 113 ] = "q",
	[ 114 ] = "r",
	[ 115 ] = "s",
	[ 116 ] = "t",
	[ 117 ] = "u",
	[ 118 ] = "v",
	[ 119 ] = "w",
	[ 120 ] = "x",
	[ 121 ] = "y",
	[ 122 ] = "z",
	[ 48 ] = "0",
	[ 49 ] = "1",
	[ 50 ] = "2",
	[ 51 ] = "3",
	[ 52 ] = "4",
	[ 53 ] = "5",
	[ 54 ] = "6",
	[ 55 ] = "7",
	[ 56 ] = "8",
	[ 57 ] = "9",
	[ 32 ] = " "
}

----------------------------------------------------------------
-- public interface
----------------------------------------------------------------
function down ( )

		if MOAIInputMgr.device.touch then
				return MOAIInputMgr.device.touch:down ()
		elseif MOAIInputMgr.device.pointer then

				return (
						MOAIInputMgr.device.mouseLeft:down ()
				)
		end
end

function getKey ()

	if MOAIInputMgr.device.keyboard then

		local key = keys [ 1 ]
		return key
	end
end

popKey = function ( )
	table.remove ( keys, 1 )
end

function getTouch ( layer )
	local x, y, clicks
  local touches = {}
	if MOAIInputMgr.device.touch then

		-- Support up to 3 touches (dont know why we need it, but what the heck).
    local touch1, touch2, touch3 = MOAIInputMgr.device.touch:getActiveTouches ()
    currentTouches = {
      touch1, touch2, touch3
    }
    for i, n in ipairs ( currentTouches ) do
      if not n then
        -- This will be nil, if there is f.ex only one touch.
      else
        local x, y, clicks = MOAIInputMgr.device.touch:getTouch ( n )
        x, y = layer:wndToWorld ( x, y )
        table.insert ( touches, {x, y, clicks} )
      end
    end

	elseif MOAIInputMgr.device.pointer then
    local x, y, clicks = pointerX, pointerY, 1
    x, y = layer:wndToWorld ( x, y )
		table.insert ( touches, { x, y, clicks } )
	end
	return touches
end

function isDown ( )

	if MOAIInputMgr.device.touch then

		return MOAIInputMgr.device.touch:isDown () or getKey () == 32

	elseif MOAIInputMgr.device.pointer then
		return (
			MOAIInputMgr.device.mouseLeft:isDown () or getKey () == 32
		)
	end
end

function up ( )

	if MOAIInputMgr.device.touch then

		return MOAIInputMgr.device.touch:up ()

	elseif MOAIInputMgr.device.pointer then

		return (
			MOAIInputMgr.device.mouseLeft:up ()
		)
	end
end

function getLevel ()
  return levelX, levelY, levelZ
end
