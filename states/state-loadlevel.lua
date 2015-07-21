local showLoading = function()
  globalData.infoTextText = "Loading..."
  globalData.infoTextGfx = nil
  globalData.infoTextSkipSupressButton = false
  statemgr.push("states/state-infotext.lua")
end

local makeLevelsMenu = function (layer, data)
  local nextY = 180
  local delta = 1
  menu.initPager ( layer, "states/state-loadlevel.lua" )
  menu.setPageSize ( layer, 6 )
  menu.setTotalPagerItems ( layer, #data )
  local leftbutton, rightbutton, pagetext = menu.makePagerButtons ( layer, 0 )
  local buttons = {}
  local x
  local y = 210
  for i, level in next, data, nil do
    if menu.pageItems ( layer, delta ) then
      if delta % 2 == 0 then
        x = 2
      else
        y = y - 50
        x = -140
      end
      local item = level.title
      local button = menu.makeButton({x, y + 24, x + 138, y - 24})
      menu.setButtonTexture(button, 'gfx/background.png')
      -- Set butten text as empty, so we can control the position a little
      -- easier.
      local levelName = util.makeText(item .. "", 125, 20, x + 70, y + 10, 16)
      layer:insertProp(levelName)
      local authorText = ""
      if level.author then
        authorText = "By " .. level.author
      end
      -- Check if user has done this one before.
      if globalData.config.worldScores.special[item] then
        -- Insert a little checkbox for this level.
        local check = util.getProp ( "gfx/check.png", 12, 12, x + 125, y + 12)
        layer:insertProp(check)
        table.insert(layer.props, check)
      end

      local author = util.makeText(authorText, 125, 20, x + 70, y - 10, 8)
      layer:insertProp(author)
      -- Make sure it gets cleaned up
      table.insert(layer.props, levelName)
      table.insert(layer.props, author)
      menu.setButtonText(button, "")
      menu.setButtonCallback(button, function (  )
        if not layer.buttonClicked then
          -- Start with showing some form of message.
          showLoading();
          -- Let's load this level. And mark all other as not interesting (by
          -- setting the "clicked" flag.)
          layer.buttonClicked = true
          LevelEditor.load(item, function ( task, code )
            statemgr.pop()
            if code ~= 200 then
              -- Problems mister.
              Error.showError("There was a problem loading this level. Please try again later.")
              layer.buttonClicked = nil
              return
            end
            local level = MOAIJsonParser.decode(task:getString())
            EmptyLevel.setLevel(level)
            EmptyLevel.setOffsets(level.offsets)
            EmptyLevel.setPowerups(level.powerups)
            EmptyLevel.setBlocks(level.blocks)
            EmptyLevel.setSwarms(level.swarms)
            EmptyLevel.setObstacles(level.obstacles)
            globalData.config.currentLevel = "emptylevel"
            globalData.config.currentWorld = "special"
            -- Then we need to go back to level, and push game state again.
            statemgr.pop()
            statemgr.swap( "states/state-game.lua" )
          end)
        end
      end)
      table.insert(buttons, button)
    end
    delta = delta + 1
  end
  menu.clearScreen(layer)
  -- Add some buttons about searching and about editiing.
  local searchButton = menu.makeButton(menu.MENUPOS4)
  menu.setButtonText(searchButton, "Enter level name")
  menu.setButtonCallback(searchButton, function()
    statemgr.swap("states/state-loadlevel-name.lua")
  end)

  local newLevelButton = menu.makeButton(menu.MENUPOS5)
  menu.setButtonText(newLevelButton, "Create new level")
  menu.setButtonCallback(newLevelButton, function()
    util.openURL(LevelEditor.SERVER_BASE)
  end)

  menu.new(layer, {newLevelButton, searchButton, leftbutton, rightbutton, pagetext, unpack(buttons)})
end

local loadlevel = {}
loadlevel.layerTable = nil

loadlevel.onFocus = function ( self )
end

loadlevel.onLoad = function ( self )
  loadlevel.layerTable = {}

  loadlevel.layer = MOAILayer2D.new ()
  loadlevel.layer.props = {}
  menu.addTopBar(loadlevel.layer, "Load level", function ()
    statemgr.swap ("states/state-level.lua")
  end)
  loadlevel.layer:setViewport ( viewport )

  menu.makeBackground ( loadlevel.layer )

  loadlevel.layerTable [ 1 ] = { loadlevel.layer }
  loadlevel.hasRequested = false
  menu.new(loadlevel.layer, {})
end

loadlevel.onUnload = function(self)
  unloader.cleanUp(self)
  self.layer.buttonClicked = nil
end

loadlevel.onInput = function (self)
  menu.onInput(loadlevel.layer)
end

loadlevel.onUpdate = function ( self )
  if not self.hasRequested then
    self.hasRequested = true
    local t = MOAICoroutine.new()
    t:run(function( )
      -- Try to reach the server with the levels.
      showLoading()
      LevelEditor.getLevels(function ( task, code )
        statemgr.pop()
        if code == 200 then
          local data = MOAIJsonParser.decode(task:getString())
          if data then
            -- See if the user has moved on.
            if self.layer and self.layer.props then
              makeLevelsMenu(self.layer, data)
            end
          end
        else
          -- Handle error.
          Error.showError("There was a problem loading levels. Please try again later.")
        end
      end)
    end)
    --menu.new ( loadlevel.layer, { button0, button1, button2 } )
  end
end

return loadlevel
