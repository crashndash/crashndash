local stats = {}

local regularStats = function (layer)
  local bonusForCars = 0
  if not globalData.gameover and type(game.levelnumber) == "number" then
    local starsplaced = 1
    local xpos = -80
    stats.stars = {}
    while starsplaced < 4 do
      stats.stars[starsplaced] = util.getProp ( "gfx/star-off.png", 30, 32, xpos, SCREEN_UNITS_Y / 2 - 100 )
      stats.layer:insertProp ( stats.stars[starsplaced] )
      starsplaced = starsplaced + 1
      xpos = xpos + 80
    end
  end

  local firstYpos = 60
  if globalData.gameover then
    firstYpos = 120
  end

  local score = globalData.score + game.score

  local bonusThread = MOAIThread.new()
  bonusThread:run ( function ()
    local carbonus = util.makeText ( "Bonus for cars: 0", SCREEN_UNITS_X - 120, 100, 0, firstYpos, 16 )
    stats.layer:insertProp ( carbonus )
    table.insert(stats.layer.props, carbonus)
    local i = game.lastcarscrashed
    while i > 0 do
      util.sleep(.01)
      bonusForCars = bonusForCars + 10
      i = i - 1
      carbonus:setString ( "Bonus for cars: " .. bonusForCars )
    end

    local jumpbonus = util.makeText ( "Jump bonus: 0", SCREEN_UNITS_X - 120, 100, 0, firstYpos - 30, 16 )
    stats.layer:insertProp ( jumpbonus )
    table.insert(stats.layer.props, jumpbonus)
    local bonusForJumps = 0
    i = game.level.jumpCount - (globalData.config.expBought.morejumps or 0)
    while i > 0 do
      util.sleep(.01)
      bonusForJumps = bonusForJumps + 1000
      i = i - 1
      jumpbonus:setString ( "Jump bonus: " .. bonusForJumps )
    end


    local bonusToAdd = bonusForJumps + bonusForCars
    local totalbonus = util.makeText ( "Total bonus: " .. bonusToAdd, SCREEN_UNITS_X - 120, 100, 0, firstYpos - 60, 16 )
    stats.layer:insertProp ( totalbonus )
    table.insert(stats.layer.props, totalbonus)

    local totalScore = util.makeText ( "Total score: " .. score, SCREEN_UNITS_X - 120, 100, 0, firstYpos - 90, 16 )
    stats.layer:insertProp ( totalScore )
    stats.layer.props.totalbonus = totalbonus
    local nextX = -60
    for i = 100, bonusToAdd, 100 do
      util.sleep ( .01 )
      totalScore:setString ( "Total score: " .. score + i )
    end
    totalScore:setString ( "Total score: " .. score + bonusToAdd )
  end)

  local carsCrashed = game.lastcarscrashed
  local jumps = game.level.jumpCount - (globalData.config.expBought.morejumps or 0)
  local bonus = 1000 * jumps + 10 * carsCrashed
  game.score = game.score + bonus
  globalData.score = globalData.score + game.score
  game.addScore ()

  if not globalData.gameover then
    local button = menu.makeButton ( menu.MENUPOS4 )
    menu.setButtonCallback (button, (function ( )
      bonusThread:pause ()
      bonusThread = nil
      local score = globalData.score
      globalData.config.currentLevel = game.levelNumber
      statemgr.pop ()
      statemgr.swap ( "states/state-game.lua" )
    end))
    menu.setButtonText ( button, "Next level")
    if type(game.levelNumber) == "number" and game.levelNumber > #Level.levels[game.worldNumber] then
      menu.setButtonCallback ( button, function (  )
        bonusThread:pause ()
        bonusThread = nil
        -- Gee. This person has made it through all levels!
        globalData.config.win = true
        statemgr.pop ()
        statemgr.swap ( "states/state-win.lua" )
      end )
      menu.setButtonText ( button, "Continue" )
    end
    -- By default let's set 3 stars to the sum of 0 used jumps, and 1 *
    -- levelnumber crashed cars (with cars on avarage being 100 points).
    if type(game.levelnumber) == "number" then
      local threeStars = game.level.topScore or ((game.levelNumber * 110) + (game.level.initialJumps * 1000))
      local percent = (game.score / threeStars) * 100
      local lightstars = 1
      if percent >= 100 then
        -- User gets three stars!
        lightstars = 3
      else
        if percent > 66 then
          lightstars = 2
        end
      end
      local yellowstar = MOAIGfxQuad2D.new ()
      yellowstar:setTexture ( util.getTexture ( "gfx/star-on.png" ) )
      yellowstar:setRect ( -15, -16, 15, 16 )
      yellowstars = 1
      while lightstars >= yellowstars do
        stats.stars[yellowstars]:setDeck ( yellowstar )
        util.wait ( stats.stars[yellowstars]:moveScl ( 1.5, 1.5, .2 ) )
        util.wait ( stats.stars[yellowstars]:moveScl ( -1.5, -1.5, .2 ) )
        yellowstars = yellowstars + 1
      end
    end

    local button2 = menu.makeButton ( menu.MENUPOS5 )
    menu.setButtonCallback (button2, (function ( )
      bonusThread:pause ()
      bonusThread = nil
      if type(game.levelNumber) == "number" then
        game.loadLevel ( game.levelNumber  - 1)
      end
      -- Set score to 0. It's like selecting a level.
      globalData.score = 0
      statemgr.pop ()
      statemgr.swap ( "states/state-game.lua")
      statemgr.pop ()
    end))
    menu.setButtonText ( button2, "Try again!")

    layer.backCallback = nil
    -- Unset "Next" button for "special" levels.
    if game.worldNumber == "special" then
      button = nil
      layer.backCallback = function ( )
        bonusThread:pause ()
        bonusThread = nil
        statemgr.pop ()
        statemgr.swap ( "states/state-game.lua" )
      end
    end
    menu.new ( stats.layer, { button2, button } )
    -- Save data for this level minus one, because state-game already changed
    -- the level for us.
    local uselevel = game.levelNumber
    if type(game.levelNumber) == "number" then
      uselevel = game.levelNumber - 1
    end
    if game.level.name then
      uselevel = game.level.name
    end
    globalData.config.doneWorlds[game.worldNumber][uselevel] = globalData.config.doneWorlds[game.worldNumber][uselevel] or 1
    local starsrecord = globalData.config.doneWorlds[game.worldNumber][uselevel]
    globalData.config.worldScores[game.worldNumber][uselevel] = globalData.config.worldScores[game.worldNumber][uselevel] or 0
    if globalData.config.worldScores[game.worldNumber][uselevel] < game.score then
      -- Woohoo new record.
      globalData.config.worldScores[game.worldNumber][uselevel] = game.score
      stats.layer.props.bestText:setString("New Record: " .. game.score)
      util.wait(stats.layer.props.bestText:moveScl(2, 2, 2, .2))
      util.wait(stats.layer.props.bestText:moveScl(-2, -2, -2, .2))
    end
    if lightstars and starsrecord < lightstars then
      -- User made a new record for this level.
      globalData.config.doneWorlds[game.worldNumber][uselevel] = lightstars
      -- If he made 3 stars, award with experience points.
      if lightstars == 3 then
        local bonusExp = math.floor ( (uselevel * 30) * (uselevel ^ 1.1) )
        stats.layer.popups = stats.layer.popups or {}
        table.insert( stats.layer.popups, Popup.new ( 'That level gave you ' .. bonusExp .. ' extra experience points', stats.layer ) )
        globalData.config.expPoints = globalData.config.expPoints + bonusExp
      end
      config:saveGame ()
    end
  else
    local button = menu.makeButton ( menu.MENUPOS3 )
    layer.backCallback = function ( )
      bonusThread:pause ()
      bonusThread = nil
      statemgr.pop ()
      statemgr.swap ( "states/state-game-over.lua" )
    end
    menu.setButtonCallback (button, layer.backCallback)
    menu.setButtonText ( button, "Back")
    local button2 = menu.makeButton ( menu.MENUPOS4 )
    menu.setButtonCallback (button2, (function ( )
      bonusThread:pause ()
      bonusThread = nil
      -- Does this look like hack, or what?
      globalData.score = 0
      statemgr.pop ()
      statemgr.swap ( "states/state-game-over.lua" )
      statemgr.swap ( "states/state-game.lua")
      statemgr.pop ()
    end))
    menu.setButtonText ( button2, "Try again!")
    local hiscore_button = menu.makeButton ( menu.MENUPOS5 )
    menu.setButtonCallback (hiscore_button, (function ( )
      -- At this point the highscore might not have been set.
      if globalData.score > config.data.config.highScore then
        config.data.config.highScore = globalData.score
        config:saveGame ()
      end
      cloud.postHighScore ( layer )
    end))
    menu.setButtonText ( hiscore_button, "Post high score")

    if game.worldNumber == "special" then

    else

      if game.levelNumber == globalData.config.maxLevels[game.worldNumber] and game.levelNumber < #Level.levels[game.worldNumber] then
        -- Could be that this person wants to skip the level. Let's check the
        -- degree of frustration.
        globalData.config.retries = globalData.config.retries + 1
        if globalData.config.retries > 9 then
          button3 = menu.makeButton ( menu.MENUPOS2 )
          menu.setButtonCallback (button3, (function ( )
            bill.payForProduct ( "skiplevel", function (  )
              bonusThread:pause ()
              bonusThread = nil
              local newLevel = game.levelNumber + 1
              statemgr.pop ()
              statemgr.swap ( "states/state-game-over.lua" )
              globalData.config.currentLevel = newLevel
              globalData.config.maxLevels[game.worldNumber] = newLevel
              statemgr.swap ( "states/state-game.lua")
            end )
          end))
          menu.setButtonText ( button3, "Skip level ($0.99)")
          menu.setButtonTextSize ( button3, 16 )
        end

      end
    end
    menu.new ( stats.layer, { button, button2, hiscore_button, button3 } )
    game.score = 0
  end
end

local multiplayerStats = function (layer)
  local points = {
    car = 100,
    swarm = 500,
    death = -500,
    join = 0,
    startover = 0,
    rocket = 300,
    progress = 10
  }
  local bonusForCars = 0
  local users = {}
  layer.useTopBar = false
  menu.addTopBarProps(layer)
  layer.topbar:setPriority(10)
  layer.title:setPriority(10)

  if not globalData.gameover then
    if multiplayer.lastsummary then
      for i, e in next, multiplayer.lastsummary, nil do
        for id, user in next, e, nil do
          local j = user.name
          users[j] = users[j] or {}
          -- Add points for this.
          users[j].score = users[j].score or 0
          local multiply = points[i] or 0
          users[j].score = users[j].score + ( (user.count * multiply) or 0 )
          -- Nice verbose variables. j, i and u! :)
          -- j = user name, i = type, u = user object.
          users[j][i] = user.count
        end
      end
    end
    local pos = 130
    local sorted = {}
    multiplayer.score = 0
    if users[multiplayer.name] and users[multiplayer.name].score then
      multiplayer.score = users[multiplayer.name].score
    end
    game.score = multiplayer.score
    if game.score < 0 then
      game.score = 0
    end
    game.addScore ()

    for user, stats in next, users, nil do
      -- Iterate for a second time, to make the table sortable.
      table.insert(sorted, {stats.score, user, stats.death, stats.car})
    end
    table.sort ( sorted, function ( a, b )
      -- Sort table based on 1st index (score)
      return a[1] > b[1]
    end )
    local position = 1
    local winner = sorted[1][2]
    for delta, userAndScore in next, sorted, nil do
      -- Iterate for the 3rd time, this time the array is indexed by number.
      -- Giving us the score-board from best to worst.
      local score = userAndScore[1]
      local user = userAndScore[2]
      local died = userAndScore[3] or 0
      local cars = userAndScore[4] or 0
      local text = util.makeText ( '#' .. position .. '. ' .. user, SCREEN_UNITS_X - 40, 20, 0, pos, 16 )
      local bg = util.getProp ( "gfx/background.png", SCREEN_UNITS_X - 20, 46, 0, pos )
      local cartext = "crashed cars: " .. cars
      local dietext = "deaths: " .. died
      local stattext = util.makeText ( score .. " points. " .. cartext .. ". " .. dietext, SCREEN_UNITS_X - 40, 20, 0, pos - 18, 8 )
      stats.layer:insertProp ( bg )
      table.insert(stats.layer.props, bg)
      stats.layer:insertProp ( text )
      table.insert(stats.layer.props, text)
      stats.layer:insertProp ( stattext )
      table.insert(stats.layer.props, stattext)
      pos = pos - 50
      position = position + 1
    end
    local button = menu.makeButton ( menu.MENUPOS4 )
    menu.setButtonCallback (button, (function ( )
      statemgr.pop ()
      statemgr.swap ( "states/state-game-over.lua" )
      statemgr.swap ( "states/state-game.lua")
      statemgr.pop ()
      -- Send an event, so the logger can be selective of which events to log.
      multiplayer.sendMessage ( "startover", multiplayer.room )
    end))
    menu.setButtonTextSize ( button, 16 )
    if winner == multiplayer.name then
      multiplayer.won = true
      menu.setButtonText ( button, "Awesome! play again!")
    else
      menu.setButtonText ( button, "Revenge! play again!")
    end
    local button1 = menu.makeButton ( menu.MENUPOS5 )
    menu.setButtonCallback (button1, (function ()
      -- Set ourselves as offline.
      multiplayer.connected = false
      -- Pop back this popup to game.
      statemgr.pop ()
      -- Swap with main menu.
      statemgr.swap ( "states/state-main-menu.lua" )
    end))
    menu.setButtonText ( button1, "Exit multiplayer")
    layer.resetMultiplayer = true
    util.sleep(5)
    menu.new ( stats.layer, { button, button1 } )
  else
    -- Mark as do not send achievements.
    layer.noAchievements = true

    -- Just respawn if dead.
    statemgr.pop ()
    statemgr.swap ( "states/state-game-over.lua" )
    statemgr.swap ( "states/state-game.lua")
    statemgr.pop ()
    table.insert( game.level.popups, Popup.new ( "oh no, that's not gonna look good in the stats!" ) )
  end
  layer.backCallback = nil
end

stats.layerTable = nil

stats.onFocus = function ( self )
end

stats.onLoad = function ( self )
  stats.layerTable = {}

  stats.layer = MOAILayer2D.new ()
  stats.layer.props = {}
  menu.addTopBar(stats.layer, "Statistics" )
  stats.layer:setViewport ( viewport )

  stats.layerTable [ 1 ] = { stats.layer }

  local bgProp = util.getProp ( "gfx/background.png", SCREEN_UNITS_X, SCREEN_UNITS_Y, 0, 0 )
  stats.layer:insertProp ( bgProp )
  table.insert(stats.layer.props, bgProp)

  local thread = MOAIThread.new ()
  -- Starting up a thread to count stuff.
  thread:run (function ( )
    if game.levelNumber == "multiplayer" then
      multiplayerStats (stats.layer)
    else
      local scorelevel = game.levelNumber
      if not globalData.gameover and not game.worldNumber == "special" then
        scorelevel = scorelevel - 1
      end
      if game.level.name then
        scorelevel = game.level.name
      end
      local bestnumber = globalData.config.worldScores[game.worldNumber][scorelevel] or 0
      local bestText = util.makeText ( "Level record:  " .. bestnumber, SCREEN_UNITS_X, 100, 0, SCREEN_UNITS_Y/2 - 60, 8 )
      bestText:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
      -- See if the user is still on this screen. Might have clicked on...
      if stats.layer and stats.layer.props then
        stats.layer.props.bestText = bestText
        stats.layer:insertProp ( bestText )
        regularStats (stats.layer)
      end
    end
    if not self.layer.noAchievements then
      achmng.sendAchievements ( stats.layer )
    end
    if game.lastObstaclesKilled then
      for i, o in next, game.lastObstaclesKilled, nil do
        i = nil
      end
    end
    game.lastObstaclesKilled = {}
  end)

end

stats.onUnload = function ( self )
  if self.stars then
    for i, prop in next, self.stars, nil do
      self.layer:removeProp(prop)
    end
    self.stars = nil
  end
  unloader.cleanUp(self)
  if self.layer.resetMultiplayer then
    multiplayer.won = false
    multiplayer.score = 0
    multiplayer.carstats = {}
    multiplayer.registeredProgress = {}
    multiplayer.myProgress = 0
    multiplayer.positions = {}
  end
  game.resetGameVars()
end

stats.onInput = function ( self )
  menu.onInput ( stats.layer )
end

stats.onUpdate = function ( self )
  achmng.onUpdate ( self.layer )
end

stats.IS_POPUP = true

return stats

