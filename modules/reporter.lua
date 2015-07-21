module ( "Reporter", package.seeall )

REPORT_URL = appConfig.reportUrl
--REPORT_URL = "http://localhost:2000/messages"

sendMessage = function ( message, cb )
  local callback = function ( task, responsecode )
    if responsecode == 200 then
      cb()
      return
    end
    cb("Problems")
  end
  Http.httpTaskSetup(REPORT_URL, callback, true, message)
end

addMessage = function ( message )
  if not message or not message.type or not message.message then return end
  table.insert(globalData.config.messages, message)
end

traceBack = function(err)
  -- Try to pop back a few times, and push main menu.
  statemgr.pop()
  statemgr.pop()
  statemgr.pop()
  statemgr.push("states/state-main-menu.lua")

  -- Add a infotext about the incident.
  local text = "There was a problem, and we are sorry to exit back to the main menu."
  Error.showError(text)
  -- Add the error to config, so we can post it when we have a reason to.
  Reporter.addMessage({
    type = 'error',
    message = MOAIJsonParser.encode(util.explode("\n", debug.traceback(err, 1)))
  })
  config:saveGame()
end
