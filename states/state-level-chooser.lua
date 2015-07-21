local levelchooser = {}
levelchooser.layerTable = nil

levelchooser.onFocus = function ( self )

end

local selectWorld = function ( layer )
  local worlds = {}
  local buttons = {}
  local ypos = 100
  local height = 60
  local x = 130
  for i in ipairs( Level.levels ) do
    if menu.pageItems(levelchooser.layer, i) then
      local menubutton = menu.makeButton({-x, ypos - (height/2), x, ypos + (height/2)})
      menu.setButtonText(menubutton, "World " .. i)
      menu.setButtonCallback(menubutton, function (  )
        globalData.doLevels = true
        globalData.doLevel = i
        statemgr.swap("states/state-level-chooser.lua")
      end)
      menu.setButtonTexture(menubutton, "gfx/background.png")

      -- Find out how many stars we can possible have on this world.
      local totalStars = (#Level.levels[i] * 3)
      -- Find out how many stars the user has.
      local userStars = achmng.countStars(i)
      local star = util.getProp("gfx/star-on.png", 15, 16, 95, ypos + 20)
      local starText = util.makeText(userStars .. "/" .. totalStars, 50, 20, 130, ypos + 14, 8)
      star:setPriority(1)
      starText:setPriority(2)
      layer:insertProp(star)
      layer:insertProp(starText)

      table.insert (buttons,  menubutton)
      ypos = ypos - height - 5
    end
  end

  return #Level.levels, buttons
end

local selectLevels = function (  )
  local levelbuttons = {}
  local files = {}
  local dirs = MOAIFileSystem.listDirectories ( "levels" )
  -- Well tables are fast and cool and all that, but can't they please make
  -- 1 come before 2 on all platforms when using ipairs? Guess not...
  table.sort(dirs)
  for i, dir in ipairs ( dirs ) do
    if i == globalData.doLevel then
      local dirfiles = MOAIFileSystem.listFiles ( "levels/" .. dir )
      for d, dirfile in ipairs ( dirfiles ) do
        table.insert( files, { level = d, world = i } )
      end
    end
  end
  local xpos = 0
  local delta = 0
  for i, file in ipairs ( files ) do
    -- Pass in layer and loop value, and the module will do the rest.
    if menu.pageItems ( levelchooser.layer, i ) then
      local gridpos = delta % 4
      local farleft = -(SCREEN_UNITS_X / 2) + SCREEN_UNITS_X / 10
      if gridpos == 0 then
        xpos = farleft
      else
        xpos = farleft + ((SCREEN_UNITS_X / 5) * (gridpos) )
      end

      local ypos = (SCREEN_UNITS_Y / 2) - 130 - ( (math.floor ( delta / 4 )) * 40 )
      local xpos2 = xpos + (SCREEN_UNITS_X / 5)
      local max
      if not globalData.config.maxLevels[file.world] then
        max = 1
      else
        max = globalData.config.maxLevels[file.world]
      end
      local available = true
      if file.level > max then
        available = false
      end
      if not Level.unlockedWorld(file.world) then
        available = false
      end
      local levelbutton = menu.makeButton ( { xpos, ypos, xpos2, ypos + 40} )
      menu.setButtonCallback (levelbutton, (function ()
        if not available then
          -- User has not gotten this far.
          return
        end
        globalData.config.currentLevel = file.level
        globalData.config.currentWorld = file.world
        globalData.score = 0
        -- Push state-level again (With updated text).
        statemgr.swap ( "states/state-game.lua" )
      end))
      local bgfile = "gfx/levelbg.png"
      local stars = globalData.config.doneWorlds[file.world][file.level]
      if stars and stars > 0 then
        bgfile = "gfx/levelbg_" .. stars .. ".png"
      end
      menu.setButtonText ( levelbutton, file.level .. "" )
      if not available then
        bgfile =  "gfx/levelbg-red.png"
      end
      menu.setButtonTexture ( levelbutton, bgfile )
      table.insert (levelbuttons,  levelbutton)
      delta = delta + 1
    end
  end

  return #files, levelbuttons
end

levelchooser.onLoad = function ( self )
  levelchooser.layerTable = {}

  levelchooser.layer = MOAILayer2D.new ()
  levelchooser.layer:setViewport ( viewport )
  menu.makeBackground ( levelchooser.layer )

  levelchooser.layerTable [ 1 ] = { levelchooser.layer }

  menu.initPager ( levelchooser.layer, "states/state-level-chooser.lua" )
  local pagesize = 24
  local pager
  local backCallback = function (  )
    statemgr.swap ( "states/state-game.lua" )
  end
  if globalData.doLevels then
    pager = selectLevels
    backCallback = function (  )
      globalData.doLevels = false
      -- Make pager start at page 1 when we go back to worlds.
      globalData.page["states/state-level-chooser.lua"] = 0
      statemgr.swap("states/state-level-chooser.lua")
    end
  else
    pagesize = 3
    pager = selectWorld
  end
  menu.setPageSize ( levelchooser.layer, pagesize )
  menu.addTopBar(levelchooser.layer, "Choose level", backCallback)
  local totalnums, levelbuttons = pager(levelchooser.layer)


  menu.setTotalPagerItems ( levelchooser.layer, totalnums )
  local leftbutton, rightbutton, pagetext = menu.makePagerButtons ( levelchooser.layer, - 130 )
  menu.new ( levelchooser.layer, { pagetext, leftbutton, rightbutton, unpack ( levelbuttons ) } )
end


levelchooser.onUnload = function ( self )
  unloader.cleanUp(self)
end

levelchooser.onInput = function ( self )
  menu.onInput ( levelchooser.layer )
end

levelchooser.onUpdate = function ( self )
  if globalData.updateLevelChooser then
    globalData.updateLevelChooser = nil
    statemgr.swap("states/state-level-chooser.lua")
  end
end

return levelchooser
