require('elements/car')
require('elements/enemy')
require('elements/road')
require('elements/warning')
require('elements/powerup')
require('elements/obstacle')
require('modules/speed')

game = {}
game.layerTable = nil

game.enemyFactory = nil

game.getCar = function ()
  return game.level.car
end

game.onFocus = function ( self )
  if game.level then
    game.level:onResume ()
  end
  if game.warningThread then
    game.warningThread.pause = false
  end
end

game.onPause = function ( self )
  if game.level and not game.level.finishing then
    statemgr.push ( "states/state-pause.lua" )
  end
end

game.onLoseFocus = function ( self )
  if game.level then
    game.level:onPause ()
  end
  if game.warningThread then
    game.warningThread.pause = true
  end
end
game.removePbuttons = function (  )
  for i, a in next, game.pbuttons, nil do
    game.removePropFromTextLayer ( a.number )
    game.removePropFromTextLayer ( a.gfx )
  end
end

game.destroyRoad = function ( road )
  game.level.roads[road] = nil
  road:destroy ()
end

game.insertPropIntoGameLayer = function ( prop )
  if not prop then return end
  if game.layer then game.layer:insertProp ( prop ) end
end

game.insertPropIntoBackgroundLayer = function ( prop )
  if not prop then return end
  if game.backgroundLayer then game.backgroundLayer:insertProp ( prop ) end
end

game.insertPropIntoTextLayer = function ( prop )
  if not prop then return end
  if game.textLayer then game.textLayer:insertProp ( prop ) end
end

game.removePropFromGameLayer = function ( prop )
  if not prop then return end
  if game.layer then game.layer:removeProp(prop) end
end

game.removePropFromBackgroundLayer = function ( prop )
  if not prop then return end
  if game.backgroundLayer then game.backgroundLayer:removeProp ( prop ) end
end

game.removePropFromTextLayer = function ( prop )
  if not prop then return end
  if game.textLayer then game.textLayer:removeProp ( prop ) end
end

game.removePropFromCarLayer = function ( prop )
  if not prop then return end
  if game.carLayer then game.carLayer:removeProp ( prop ) end
end

game.insertPropIntoCarLayer = function ( prop )
  if not prop then return end
  if game.carLayer then game.carLayer:insertProp ( prop ) end
end

game.resetGameVars = function (  )
  game.carscrashed = 0
  game.typesCrashed = {}
  game.lastcarscrashed = 0
  if game.lastObstaclesKilled then
    for i, o in next, game.lastObstaclesKilled, nil do
      i = nil
    end
  end
  game.lastObstaclesKilled = {}
end

game.onLoad = function ( self )
  game.layerTable = {}
  globalData.gameover = false
  game.levelNumber = globalData.config.currentLevel or 1
  game.worldNumber = globalData.config.currentWorld or 1

  game.tick = 0
  game.score = 0
  globalData.score = globalData.score or 0
  game.resetGameVars()

  game.layer = MOAILayer2D.new ()
  game.layer:setSortMode (MOAILayer2D.SORT_PRIORITY_DESCENDING)
  game.layer:setViewport ( viewport )

  game.backgroundLayer = MOAILayer2D.new ()
  game.backgroundLayer:setViewport ( viewport )

  game.textLayer = MOAILayer2D.new ()
  game.textLayer:setSortMode (MOAILayer2D.SORT_PRIORITY_DESCENDING)
  game.textLayer:setViewport ( viewport )

  game.carLayer = MOAILayer2D.new ()
  game.carLayer:setViewport ( viewport )

  game.layerTable [ 1 ] = { game.backgroundLayer, game.layer, game.textLayer, game.carLayer }

  scoreText = util.makeText( "0", SCREEN_UNITS_X - 30, 30, 0, SCREEN_UNITS_Y/2 - 30, 16 )
  game.insertPropIntoTextLayer ( scoreText )
  game.makeButtons ()

  game.enemyFactory = EnemyFactory.new ()

  game.powerups = Powerup.new ()

  game.loadLevel ( game.levelNumber, game.worldNumber )

  statemgr.push ( "states/state-level.lua" )

end

game.makeButtons = function (  )
  menu.clearScreen ( game.textLayer )
  local pausebutton = menu.makeButton ( { SCREEN_UNITS_X/2 - 60, SCREEN_UNITS_Y / 2 -60, SCREEN_UNITS_X / 2 -10, SCREEN_UNITS_Y / 2 - 10 }, false )
  menu.setButtonCallback (pausebutton, (function ( )
    statemgr.push ( "states/state-pause.lua" )
  end))
  local right = menu.makeButton ( { SCREEN_UNITS_X/2 - 80, - SCREEN_UNITS_Y / 2 + 10, SCREEN_UNITS_X / 2, -SCREEN_UNITS_Y / 2 + 90 }, false )
  menu.setButtonCallback (right, (function ( )
    local car = game.getCar ()
    car.onUpdate ( game.level, 10 )
  end))
  right.pressAndHold = true
  local left = menu.makeButton ( { -SCREEN_UNITS_X/2 + 80, - SCREEN_UNITS_Y / 2 + 10, -SCREEN_UNITS_X / 2, -SCREEN_UNITS_Y / 2 + 90 }, false )
  menu.setButtonCallback (left, (function ( )
    local car = game.getCar ()
    car.onUpdate ( game.level, -10 )
  end))
  left.pressAndHold = true
  local jumpbutton = menu.makeButton ( { -SCREEN_UNITS_X/2 + 80, -SCREEN_UNITS_Y/2, SCREEN_UNITS_X/2 - 80, SCREEN_UNITS_Y/2 } )
  menu.setButtonCallback (jumpbutton, (function ( )
    game.level:jump ()
  end))
  jumpbutton.pressAndHold = true
  jumpbutton.priority = 10
  local jumpGfx = util.getProp ( "gfx/jumps.png", 10, 10, -SCREEN_UNITS_X  / 2 + 20, SCREEN_UNITS_Y / 2 - 60, nil )
  game.insertPropIntoTextLayer ( jumpGfx )
  local deathGfx = util.getProp ( "gfx/death.png", 11, 10, -SCREEN_UNITS_X  / 2 + 20, SCREEN_UNITS_Y / 2 - 80, nil )
  game.insertPropIntoTextLayer ( deathGfx )
  menu.setButtonTexture ( pausebutton, "gfx/pause.png" )
  menu.setButtonTexture ( left, "gfx/left.png", 60, 60)
  menu.setButtonTexture ( right, "gfx/right.png", 60, 60)
  menu.setButtonTexture ( jumpbutton, "gfx/trans.png" )

  if game.pbuttons then
    game.removePbuttons()
  end
  game.pbuttons = {}
  game.pbuttonsInserted = {}
  local pbuttonsX = -70
  local pbuttonsY = -SCREEN_UNITS_Y / 2 + 50
  game.pbuttonTable = { "invincible", "bomb", "nitro" }
  local buttonspace = 55
  if game.levelNumber == "multiplayer" then
    game.pbuttonTable = { "rocket", "bomb", "nitro", "swarm" }
    buttonspace = 40
  end
  for i, a in next, game.pbuttonTable, nil do
    if globalData.config.expBought[a] then
      local bbutton = menu.makeButton ( { pbuttonsX, - SCREEN_UNITS_Y / 2 + 30, pbuttonsX + 30, -SCREEN_UNITS_Y / 2 + 60 } )
      menu.setButtonCallback (bbutton, (function ( )
        if globalData.config.expBought[a] == 0 then return end
        globalData.config.expBought[a] = globalData.config.expBought[a] - 1
        Powerup.powerups[a]()
        config:saveGame ()
      end))
      menu.setButtonTexture ( bbutton, "gfx/pubg.png" )
      local pugfx = util.getProp ( "gfx/" .. a .. ".png", 15, 15, pbuttonsX + 15, pbuttonsY - 5 )
      local putext = util.makeText ( "x" .. globalData.config.expBought[a], 30, 20, pbuttonsX + 25, pbuttonsY - 30, 8 )
      putext:setPriority ( -2 )
      pugfx:setPriority ( -1 )
      game.insertPropIntoTextLayer ( pugfx )
      game.insertPropIntoTextLayer ( putext )
      bbutton.number = putext
      bbutton.id = a
      bbutton.gfx = pugfx
      table.insert(game.pbuttons, bbutton)
      game.pbuttonsInserted[a] = true
    end
    pbuttonsX = pbuttonsX + buttonspace
  end

  -- Avoid having those buttons in the bottom.
  game.textLayer.removeButtonBar = true
  menu.new ( game.textLayer, { pausebutton, left, right, jumpbutton, unpack ( game.pbuttons ) })
end

game.loadLevel = function ( index, world )
  if game.level then
    -- Only unload level if we have one loaded.
    game.level:onUnload ()
  end
  if not world then
    world = globalData.config.currentWorld
  end
  if not Level.levels[world][index] then
    game.loadLevel(1, 1)
    return
  end
  game.level = dofile ( Level.levels[world][index] )
  -- If this did not do any good, load level 1-1
  if not game.level then
    game.loadLevel(1, 1)
    return
  end
  game.level.theme = game.level.theme or Level.getTheme(world)
  game.level.initialJumps = game.level.jumpCount
  if globalData.config.expBought.morejumps then
    game.level.jumpCount = game.level.jumpCount + globalData.config.expBought.morejumps
  end
  game.levelNumber = index
  game.worldNumber = world
  game.saveLevel()
  game.level:spawnRoad ()
end

game.saveLevel = function ()
  globalData.config.currentLevel = game.levelNumber
  globalData.config.currentWorld = game.worldNumber
end

game.killEnemy = function ( car, allHealth, killtype, variables )
  if car.exploding then return end
  local carbody = car.body
  if not carbody then return end
  if carbody.health > 1 and not allHealth then
    local thread = MOAICoroutine.new ()
    thread:run ( function ()
      sound.play ( util.getSound ( "sound/life.ogg" ) )
      util.wait ( carbody.userData:moveScl ( -.2, -.2, .1, MOAIEaseType.LINEAR ) )
      if carbody.userData then
        util.wait ( carbody.userData:moveScl ( .25, .25, .1, MOAIEaseType.LINEAR ) )
      end
    end)
    carbody.health = carbody.health - 1
    return
  end
  -- Destroy!
  if not game.level.multiplayer then
    game.carscrashed = game.carscrashed + 1
    -- Gee. So many variables.
    game.addIngameScore(carbody.userData.properties.score)
  end
  if killtype == "fall" then
    carbody.userData.die(nil, true, variables)
  else
    carbody.userData.die()
  end
end

game.addIngameScore = function ( points )
  game.score = game.score + points
end

game.removeEnemy = function ( car )
  game.level:removeEnemy ( car )
  local thread = MOAICoroutine.new ()
  thread:run ( function ()
    -- If we spawn a new enemy right away, sometimes we get a
    --
    -- BOX2D ERROR: Attempt to perform illegal operation during collision update
    --
    -- So to avoid this, we wait a little. I guess we have too many threads, so
    -- to fix it I started a new one :)
    util.sleep(.1)
    game.spawnEnemyIfApplicable ()
  end)
end

game.addScore = function (  )
  globalData.config.expPoints = globalData.config.expPoints + game.score
  config:saveGame ()
end

game.finishLevel = function ()
  if game.worldNumber ~= "special" then
    globalData.config.retries = 0
    game.levelNumber = game.levelNumber + 1
  end
  -- Reset cars crashed
  game.lastcarscrashed = game.carscrashed
  game.carscrashed = 0
  if game.levelNumber ~= "multiplayer" then
    if not globalData.config.maxLevels[game.worldNumber] then
      globalData.config.maxLevels[game.worldNumber] = game.levelNumber
      config:saveGame ()
    else
      if globalData.config.maxLevels[game.worldNumber] < game.levelNumber then
        globalData.config.maxLevels[game.worldNumber] = game.levelNumber
        config:saveGame ()
      end
    end
  end
  statemgr.push("states/state-stats.lua")
end

game.loseLife = function ( deathtype, variables )
  --TODO:Add support for more lives here
  if not game.level.canDie then
    return
  end
  if game.levelNumber == "multiplayer" then
    multiplayer.lostlife ()
  end
  local carbody = game.getCar ().body
  -- We can not die anymore, we are already dead.
  game.level.canDie = false
  -- Do explosion in a thread.
  local thread = MOAIThread.new ()
  thread:run (function (  )
    globalData.losinglife = true
    if game.bossThread then
      game.bossThread:pause ()
      game.bossThread = nil
    end
    carbody:explode ( deathtype, variables )
    carbody:destroy ()
    game.lastcarscrashed = game.carscrashed
    globalData.carscrashed = game.carscrashed
    globalData.gameover = true
    -- See if we are still on the corrent state.
    local ls = statemgr.getCurState()
    if ls.filename ~= 'states/state-game.lua' then
      -- Better make sure that is the case.
      local ready = false
      while not ready do
        statemgr.pop()
        local l = statemgr.getCurState()
        if not l then
          -- Oh my. Something must have popped us all the way back. Just push
          -- regular navigation towards playing, and then pop.
          statemgr.push ( "states/state-main-menu.lua" )
          statemgr.swap ( "states/state-game.lua" )
          statemgr.pop()
          ready = true
        else
          local fn = l.filename
          if fn == 'states/state-game.lua' then
            ready = true
          end
        end
      end
    end
    statemgr.push ( "states/state-stats.lua" )
    globalData.losinglife = false
  end)
end

game.handleCollisions = function ( event, wall, car )
  if ( globalData.gameover ) then return end
  -- Get parent body of the fixture.
  local carbody = car:getBody()
  -- Destroy body.
  local walltype = wall:getBody().type
  if carbody.type == "enemy" then
    if car.bodyRemoved then return end
    if not carbody.updated then return end
    -- Get the top level object.
    local enemy = carbody.getCar ()
    if walltype == "grass" or wall:getBody().enemyKiller then
      if not carbody.userData then return end
      if not carbody.userData.confused then
        return
      else
        game.killEnemy ( enemy )
      end
    else
      if Obstacle.causesFall(walltype) then
        local x, y = wall:getBody():getPosition()
        local carx, cary = carbody:getPosition()
        local variables = {x - carx, y - cary}
        if not carbody then return end
        if not carbody.userData then return end
        if not carbody.userData.confused then
          carbody.userData.die(true, true, variables)
          return
        end
        game.killEnemy ( enemy, nil, "fall", variables )
      else
        game.removePropFromGameLayer ( carbody.userData )
        game.removeEnemy ( enemy )
      end
    end
  else
    if walltype and carbody.userData.isJumping then return end
    if Obstacle.causesFall(walltype) then
      local x, y = wall:getBody():getPosition()
      local carx, cary = carbody:getPosition()
      local variables = {x - carx, y - cary}
      game.loseLife ( "fall", variables )
    else
      local pr = Car.carProperties[carbody.userData.carType]
      if not pr then
        return
      end
      if pr.immuneTo[walltype] then
        return
      end
      if carbody.userData and carbody.userData.invincible and walltype and walltype == "zombie" then
        return
      end
      game.loseLife ()
    end
  end
end

game.onUnload = function ( self )
  unloader.cleanUp(self)

  if game.level then
    game.level:onFinish ()
  end

  self.layerTable = nil
  game.layer = nil
  game.backgroundLayer = nil
  game.textLayer = nil
  world = nil

  game.tick = 0

  game.walls = nil
end

game.onInput = function ( )
  menu.onInput ( game.textLayer )
end

game.getEnemies = function ()
  return game.level.enemies or {}
end

game.spawnEnemyIfApplicable = function ()
  if not game.level.world then return end
  local badguy
  if game.level:shouldSpawnBoss () then
    game.bossThread = MOAIThread.new ()
    game.bossThread:run(function (  )
      local i = 0
      while i < game.level.bossCount do
        local boss = game.enemyFactory.spawnCar ( game.level.world, game.tick, game.level.boss )
        game.level:addEnemy ( boss )
        i = i + 1
        util.sleep ( 2 )
        game.level.bossesActive = game.level.bossesActive + 1
      end
    end)
    game.level.spawnedboss = true
  elseif game.level:shouldSpawnEnemy ( game.tick ) then
    badguy = game.enemyFactory.spawnCar ( game.level.world, game.tick, false )
  end

  if badguy then
    game.level:addEnemy ( badguy )
  end
end

game.onUpdate = function ( self )

  game.level:onUpdate ()
  if not game.level.multiplayer then
    scoreText:setString ( "" .. globalData.score + game.score )
  else
    scoreText:setString ( "Room " .. multiplayer.room )
  end

  for i, a in next, game.pbuttonTable, nil do
    if globalData.config.expBought[a] and not game.pbuttonsInserted[a] then
      game.makeButtons()
    end
  end

  for i, a in next, self.pbuttons, nil do
    a.number:setString ( "x" .. globalData.config.expBought[a.id] )
  end

  game.spawnEnemyIfApplicable ()
  game.tick = game.tick + 1

  if game.shouldKill then
    game.killEnemy ( game.shouldKill )
    game.shouldKill = nil
  end

  if multiplayer.kickmessage then
    multiplayer.getKicked(multiplayer.kickmessage)
    multiplayer.kickmessage = nil
  end

end

return game
