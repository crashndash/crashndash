local credits = {}
credits.layerTable = nil

credits.onFocus = function ( self )
end

credits.onLoad = function ( self )
  credits.layerTable = {}

  credits.layer = MOAILayer2D.new ()
  credits.layer.removeButtonBar = true
  credits.layer:setClearColor (0, 0, 0, 1)
  credits.layer:setViewport ( viewport )

  credits.layerTable [ 1 ] = { credits.layer }

  local textBox = util.makeText ( "Credits", SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 50, 50 )
  textBox:setFont((util.getFont("gfx/visitor1.ttf", 50)))
  textBox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  credits.layer:insertProp ( textBox )

  local moaitext = util.makeText ( "Made with moai", SCREEN_UNITS_X, 20, 0, 60, 8 )
  moaitext:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  credits.layer:insertProp ( moaitext )

  local moaitext2 = util.makeText ( "www.getmoai.com", SCREEN_UNITS_X, 20, 0, 50, 8 )
  moaitext2:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  credits.layer:insertProp ( moaitext2 )

  local moaitext3 = util.makeText ( "Copyright (c) 2010-2012 Zipline Games, Inc. \nAll Rights Reserved.", SCREEN_UNITS_X, 20, 0, 35, 8 )
  moaitext3:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  credits.layer:insertProp ( moaitext3 )

  local moailogo = util.getProp ( "gfx/moailogo.png", 120, 46, 0, 100 )
  credits.layer:insertProp ( moailogo )

  local twcallback = function (  )
    util.openURL ( "https://twitter.com/CrashnDashgame" )
    globalData.config.twfollow = true
    achmng.sendAchievements ( credits.layer )
  end
  local twbutton = menu.makeButton ( {-105, 0, -75, -30} )
  menu.setButtonTexture ( twbutton, "gfx/tw.png" )
  menu.setButtonCallback ( twbutton, twcallback )
  local twtext = menu.makeButton ( { -70, 0, 105, -30} )
  menu.setButtonTexture ( twtext, "gfx/trans.png" )
  menu.setButtonText ( twtext, "@crashndashgame" )
  menu.setButtonCallback ( twtext, twcallback )

  local fbcallback = function (  )
    util.openURL ( "http://facebook.com/CrashnDash" )
    globalData.config.fbfollow = true
    achmng.sendAchievements ( credits.layer )
  end
  local fbbutton = menu.makeButton ( {-105, -40, -75, -70} )
  menu.setButtonTexture ( fbbutton, "gfx/fb.png" )
  menu.setButtonCallback ( fbbutton, fbcallback )
  local fbtext = menu.makeButton ( { -110, -40, 105, -70} )
  menu.setButtonTexture ( fbtext, "gfx/trans.png" )
  menu.setButtonText ( fbtext, "/CrashnDash" )
  menu.setButtonCallback ( fbtext, fbcallback )

  local button1 = menu.makeButton ( menu.MENUPOS6 )
  menu.setButtonCallback (button1, (function ()
    statemgr.swap ( "states/state-help.lua" )
  end))
  menu.setButtonText ( button1, "OK. Let's play")

  local versionText = util.makeText("version " .. BUILD_VERSION, SCREEN_UNITS_X, 15, 0, -120, 10)
  versionText:setAlignment(MOAITextBox.CENTER_JUSTIFY)
  credits.layer:insertProp(versionText)

  menu.new ( credits.layer, { button1, twbutton, twtext, fbtext, fbbutton } )
end

credits.onUnload = function ( self )
  unloader.cleanUp(self)
end

credits.onInput = function ( self )
  menu.onInput ( credits.layer )
end

credits.onUpdate = function ( self )
  achmng.onUpdate ( self.layer )
end

return credits
