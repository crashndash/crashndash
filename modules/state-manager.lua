module ( "statemgr", package.seeall )

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------
local curState = nil
local loadedStates = {}
local stateStack = {}

----------------------------------------------------------------
-- run loop
----------------------------------------------------------------
local updateThread = MOAIThread.new ()

local function updateFunction ()

  while true do

    coroutine.yield ()

    if curState then

      if type ( curState.onInput ) == "function" then
        local thread = MOAIThread.new ()
        thread:run (function (  )
          curState:onInput ()
          inputmgr.popKey ()
        end)
      end

      if type ( curState.onUpdate ) == "function" then
        curState:onUpdate ()
      end


    else
      error ( "WARNING - There is no current state. Please call state.push/state.swap to add a state." )
    end

    -- Last cleanup, do everything else before this!!!

  end
end

if MOAIAppAndroid then
  local onBackButtonPressed = function ()
    if curState then
      if curState.filename == 'states/state-main-menu.lua' then
        -- Will make the game exit.
        return false
      end
      -- If there is a back button, trigger that.
      if curState.layer and curState.layer.backCallback then
        curState.layer.backCallback()
      end
    end
    return true
  end

  MOAIAppAndroid.setListener ( MOAIAppAndroid.BACK_BUTTON_PRESSED, onBackButtonPressed )
end

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------
local function addStateLayers ( state, stackLoc )

  if not state.layerTable then print ( "WARNING - state: " .. state.stateFilename .. " does not have a layerTable" ) end

  -- This grabs the layer set from the state that corresponds to the position in the stack that the state currently is.
  --    If the state is the top most state, it will grab layerSet [ 1 ] and so forth.
  local stackPos = ( #stateStack - stackLoc ) + 1
  if state.layerTable [ stackPos ] then

    for j, layer in ipairs ( state.layerTable [ stackPos ] ) do

      MOAIRenderMgr.pushRenderPass ( layer )
    end
  end
end

----------------------------------------------------------------
local function rebuildRenderStack (skipGarbage)

  MOAIRenderMgr.clearRenderStack ()

  MOAISim.forceGC()

  for i, state in ipairs ( stateStack ) do
    addStateLayers ( state, i )
  end

end

----------------------------------------------------------------
local function loadState ( stateFile )

  if not loadedStates [ stateFile ] then

    local newState = dofile ( stateFile )
    loadedStates [ stateFile ] = newState
    loadedStates [ stateFile ].stateFilename = stateFile
  end

  return loadedStates [ stateFile ]
end

----------------------------------------------------------------
-- functions
----------------------------------------------------------------
function begin ()

  updateThread:run ( updateFunction )
end

----------------------------------------------------------------
function getCurState ( )

  return curState
end

----------------------------------------------------------------
function makePopup ( state )

  state.IS_POPUP = true
end

local saveTime = function ( )
  -- Find out how long we have been playing.
  local time = os.time() - globalData.startTime
  globalData.config.playDuration = globalData.config.playDuration + time
  config:saveGame()
end

initTime = function (  )
  globalData.startTime = os.time()
end

function onPause()
  if curState and type (  curState.onPause ) == "function" then
    curState:onPause ()
  end
  saveTime()
end

----------------------------------------------------------------
function pop ( )

  -- do the state's onLoseFocus
  if curState and type ( curState.onLoseFocus ) == "function" then
    curState:onLoseFocus ()
  end

  -- do the state's onUnload
  if curState and type ( curState.onUnload ) == "function" then
    curState:onUnload ()
  end

  curState = nil
  table.remove ( stateStack, #stateStack )
  curState = stateStack [ #stateStack ]

  rebuildRenderStack ()

  -- do the new current state's onFocus
  if curState and type ( curState.onFocus ) == "function" then
    curState:onFocus ( )
  end
end

----------------------------------------------------------------
function push ( stateFile, popit, skipGarbage, ... )

  -- do the old current state's onLoseFocus
  if curState then

    if type ( curState.onLoseFocus ) == "function" then
      curState:onLoseFocus ( )
    end
  end

  if popit then
    pop()
  end

  -- update the current state to the new one
  local newState = loadState ( stateFile )
  newState.filename = stateFile
  table.insert ( stateStack, newState )
  curState = stateStack [ #stateStack ]

  -- do the state's onLoad
  if type ( curState.onLoad ) == "function" then
    curState:onLoad ()
  end

  -- do the state's onFocus
  if type ( curState.onFocus ) == "function" then
    curState:onFocus ()
  end

  if curState.IS_POPUP then

    addStateLayers ( curState, #stateStack )
  else

    rebuildRenderStack(skipGarbage)
  end
end

----------------------------------------------------------------
function stop ( )

  updateThread:stop ()
end

----------------------------------------------------------------
function swap ( stateFile, skipGarbage )

  push ( stateFile, true, skipGarbage )

end

function tidyUp(filename)
  for i, l in ipairs(stateStack) do
    if l.filename == filename then
      table.remove(stateStack, i)
    end
  end

end

MOAISim.setListener( MOAISim.EVENT_PAUSE, onPause )
MOAISim.setListener( MOAISim.EVENT_RESUME, initTime )
if MOAIAppAndroid and not MOAIApp then
  MOAIApp = MOAIAppAndroid
end
if MOAIApp then
  if MOAIApp.APP_OPENED_FROM_URL then
    MOAIApp.setListener(MOAIApp.APP_OPENED_FROM_URL, util.openedFromUrl)
  end
end
