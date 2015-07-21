local helpme = {}
helpme.layerTable = nil

helpme.onFocus = function ( self )

end

helpme.onLoad = function ( self )
  helpme.layerTable = {}

  helpme.layer = MOAILayer2D.new ()
  menu.addTopBar(helpme.layer, "Help", function ()
    statemgr.swap ( "states/state-help.lua" )
  end)
  helpme.layer:setViewport ( viewport )

  menu.makeBackground ( helpme.layer )

  helpme.layerTable [ 1 ] = { helpme.layer }


  local nextYValue = 150
  local width = SCREEN_UNITS_X - 20
  local height = 55
  local bg = util.getProp ( "gfx/road.png", width + 6, 240, 0, 65 )
  helpme.layer:insertProp ( bg )

  local qas = {
    {
      q = "How does multiplayer work?" ,
      a = "In multiplayer mode, the goal is to score more points than your opponents. Every time you crash a car, it will pop up on the screen of your opponents. You will get points for crashing cars, getting powerups or getting first across the finish line."
    },
    {
      q = "How is my level determined?",
      a = "Your level is stored online, and you will level up by crashing cars and winning matches."
    },
    {
      q = "What is the high score list?",
      a = "When playing single-player, your score stays with you if you complete several levels in a row. Try to clear many levels in a row to improve your best score. Your best score will be remembered, and can be submitted to the list at any time!"
    }
  }


  for i, n in ipairs(qas) do
    local text1 = util.makeText(n.q, width - 30, height, 0, nextYValue, 16)
    local text2 = util.makeText(n.a, width - 30, height, 0, nextYValue - 20, 8)
    helpme.layer:insertProp(text1)
    helpme.layer:insertProp(text2)
    nextYValue = nextYValue - 60
  end

  local button1 = menu.makeButton ( menu.MENUPOS5 )
  menu.setButtonCallback (button1, (function ()
    statemgr.swap ( "states/state-help-me.lua" )
  end))
  menu.setButtonText ( button1, "More help")
  menu.new ( helpme.layer, { button1 } )
end

helpme.onUnload = function ( self )
  unloader.cleanUp(self)
end

helpme.onInput = function ( self )
  menu.onInput ( helpme.layer )
end

return helpme
