local infotext = {}
infotext.layerTable = nil

infotext.onFocus = function ( self )
end

infotext.onLoad = function ( self )
  infotext.layerTable = {}

  infotext.layer = MOAILayer2D.new ()
  infotext.layer.props = {}
  infotext.layer:setViewport ( viewport )

  infotext.layerTable [ 1 ] = { infotext.layer }

  local bgProp = util.getProp ( "gfx/background.png", SCREEN_UNITS_X, SCREEN_UNITS_Y, 0, 0 )
  infotext.layer:insertProp ( bgProp )
  table.insert(infotext.layer.props, bgProp)

  local textBox = util.makeText ( "Info", SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 50, 48 )
  textBox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
  infotext.layer:insertProp ( textBox )

  local textBox2 = util.makeText ( globalData.infoTextText, SCREEN_UNITS_X - 40, 200, 0, 50, 16 )
  textBox2:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
  infotext.layer:insertProp(textBox2)

  if globalData.infoTextGfx then
    local g = globalData.infoTextGfx
    local prop = util.getProp(g.gfx, g.width, g.height, 0, 0)
    infotext.layer:insertProp(prop)
    table.insert(infotext.layer.props, prop)
  end

  local supressbutton = menu.makeButton ( menu.MENUPOS5 )
  menu.setButtonCallback (supressbutton, (function ( )
    globalData.config.supressInfo = true
    statemgr.pop ()
  end))
  menu.setButtonText ( supressbutton, "Skip tutorial")

  local button3 = menu.makeButton ( menu.MENUPOS6 )
  menu.setButtonCallback (button3, (function ( )
    statemgr.pop()
  end))

  local dismisstext = 'OK! Continue.'
  if game and game.level and game.level.infoDismiss then
    -- Allow a level to override the info dismiss text.
    dismisstext = game.level.infoDismiss
  end
  menu.setButtonText ( button3, dismisstext)
  infotext.layer.removeButtonBar = true
  if globalData.infoTextSkipSupressButton == false then
    supressbutton = nil
  end
  menu.new ( infotext.layer, { button3, supressbutton } )

end

infotext.onUnload = function ( self )
  unloader.cleanUp(self)
end

infotext.onInput = function ( self )
  menu.onInput ( infotext.layer )
end

infotext.IS_POPUP = true

return infotext
