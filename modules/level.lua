module ( "Level", package.seeall )

local makeBlock = function ( length, img, animated, tilelength )
  local block = {}
  block.length = length or 200
  block.img = img or "gfx/grass-sprite.png"
  block.animated = animated or false
  block.tilelength = tilelength or 1
  return block
end

local addWalls = function ( level )
  level.walls = {}
  local edges = {
    {
      edge = {
        -util.halfX, -util.halfY,
        util.halfX, -util.halfY,
        -util.halfX, util.halfY,
        util.halfX, util.halfY,
      },
      filter = { 0x04, 0x01 },
      collisionHandler = game.handleCollisions,
      collisionFilter = 0x01
    },
    {
      edge = {
        -util.halfX, -util.halfY - 100,
        util.halfX, -util.halfY - 100,
        -util.halfX, util.halfY + 100,
        util.halfX, util.halfY + 100,
      },
      filter = { 0x04 },
      collisionHandler = game.handleCollisions,
      collisionFilter = 0x03,
    },
    {
      edge = {
        -util.halfX, 100000,
        -util.halfX, -100000,
        util.halfX, 100000,
        util.halfX, -100000,
      },
      filter = { 0x04},
      collisionHandler = game.handleCollisions,
      collisionFilter = 0x01,
      type = "edge",
    },
  }

  for i, e in ipairs ( edges ) do
    local wall = level.world:addBody ( MOAIBox2DBody.STATIC )
    wall.type = e.type
    local walls = wall:addEdges ( e.edge )
    for i, w in ipairs( walls ) do
      w:setFilter ( unpack ( e.filter ) )
      if e.collisionHandler then
        w:setCollisionHandler ( e.collisionHandler, MOAIBox2DArbiter.BEGIN, e.collisionFilter )
      end
    end
    table.insert ( level.walls, wall )
  end
end

new = function ()
  level = {}

  -- Possible overrides.
  level.boss = "superboss"
  level.length = 100
  -- Set with :addBlock ()
  level.blocks = {}
  -- Set with :alterRoad ()
  level.roadAlters = {}
  -- Set with :addSwarm ()
  level.swarms = {}
  level.enemyLimit = 5
  level.spawnFrequency = 100
  level.jumpCount = 10
  -- Set with :addInfo ()
  level.infoStops = {}
  level.tagline = ""
  level.hasBoss = false
  -- Set with :addPowerUp ()
  level.powerups = {}
  level.powerFreq = 0
  level.obstacleFreq = 0
  level.availablePowerUps = { "bomb" }
  level.winter = false
  level.speedFactor = 1
  level.bossCount = 1
  level.offsets = {}

  -- Roads.
  level.minOffset = 20
  level.maxOffset = 50

  -- For car.lua
  level.jumpHeight = 2
  -- Total jumpduration (60% jump up, 40% fall)
  level.jumpDuration = 1.5
  level.carWeight = 10

  -- Enemies
  level.enemyVariations = {
    "fatcar",
    "bwcar",
    "skinnycar",
    "stripecar",
    "bus",
    "wagon",
    "police"
  }
  level.availableObstacles = {
    "wheel"
  }

  -- Level defaults at start.
  level.enemies = {}
  level.addedpowerups = {}
  level.roads = {}
  level.roadCount = 0
  level.spawnedboss = false
  level.enemyCount = 0
  level.canDie = true
  level.obstacles = {}
  level.predefObstacles = {}
  level.multiplayer = false
  level.popups = {}
  level.bossesActive = 0
  level.multiplayerheads = {}
  level.multiplayerpos = {}
  level.nextPlayerHeadPos = 1
  level.useProgress = true
  level.useProgressCar = true
  level.impulsefactor = 80

  -- Clean up after last level.
  if game.level then
    if game.level.roads then
      for i, road in next, game.level.roads, nil do
        if road.props then
          for i, prop in ipairs ( road.props ) do
            game.removePropFromBackgroundLayer ( prop )
          end
        end
      end
    end
    if game.level.progressCar then
      game.removePropFromTextLayer ( game.level.progressCar )
      game.level.progressCar = nil
    end
    if game.level.progressBar then
      game.removePropFromTextLayer ( game.level.progressBar )
      game.level.progressBar = nil
    end
  end

  level.world = MOAIBox2DWorld.new ()
  level.world:setGravity ( 0, 0 )
  level.world:setUnitsToMeters ( 0.05 )
  level.world:start ()
  level.world:setDebugDrawEnabled ( 1 )

  level.car = Car.new ( level.world, level )
  game.insertPropIntoCarLayer ( level.car.body.userData )

  addWalls ( level )

  level.jumpText = util.makeText ( "" .. level.jumpCount, 60, 30, -util.halfX + 60, util.halfY - 65, 16 )
  game.insertPropIntoTextLayer ( level.jumpText )
  level.crashText = util.makeText ( "" .. game.carscrashed, 60, 30, -util.halfX + 60, util.halfY - 85, 16 )
  game.insertPropIntoTextLayer ( level.crashText )
  if game.levelNumber == "survival" then
    level.levelText = util.makeText ( "", 60, 30, -util.halfX + 45, util.halfY - 105, 8 )
    game.insertPropIntoTextLayer ( level.levelText )
  end

  if game.levelNumber == "multiplayer" then
    level.playername = util.makeText ( multiplayer.name, SCREEN_UNITS_X - 60, 30, 0, util.halfY - 50, 8 )
    game.insertPropIntoTextLayer ( level.playername )
    level.usergfx = util.getProp ( "gfx/user.png", 11, 10, -SCREEN_UNITS_X  / 2 + 20, util.halfY - 40, nil )
    game.insertPropIntoTextLayer ( level.usergfx )

    level.opponentsheading = util.makeText ( "Opponents:", 70, 30, util.halfX - 25 , util.halfY - 80, 8 )
    game.insertPropIntoTextLayer ( level.opponentsheading )
  end

  -- Small car for tracking level progress
  local carType = globalData.config.carType or "redcar"
  level.progressCar = util.getProp ( "gfx/" .. carType .. ".png", 16, 16, -util.halfX + 30, util.halfY * 0.3, nil )
  level.progressCar:setPriority ( 2 )
  level.progressBar = util.getProp ( "gfx/progress.png", 15, SCREEN_UNITS_Y * 0.60, -util.halfX + 20, 0, nil )
  level.progressBar:setPriority(100)

  level.shouldSpawnBoss = function ( self )
    if not self.hasBoss then return false end
    return self.roadCount == self.length and not self.spawnedboss
  end

  level.addBlock = function ( self, index, length, img, animated, tilelength )
    self.blocks[index] = makeBlock ( length, img, animated, tilelength )
  end

  level.alterRoad = function ( self, index, length)
    self.roadAlters[index] = length
  end

  level.addPredefObstacle = function ( self, index, type, width, length, x, yoffset )
    if not self.predefObstacles[index] then
      self.predefObstacles[index] = {}
    end
    local insert = {
      type = type or "wheel",
      width = width or Obstacle.getWidth ( type ) ,
      length = length or Obstacle.getHeight ( type ),
      x = x or nil,
      yoffset = yoffset or nil
    }
    table.insert( self.predefObstacles[index], insert )
  end


  level.addSwarm = function ( self, index, size, type )
    self.swarms[index] = {
      size = size,
      type = type
    }
  end

  level.addPowerUp = function ( self, index, type )
    self.powerups[index] = {
      powertype = type
    }
  end

  level.addObstacle = function ( self, type, width, length, xpos, yoffset )
    local length = length or Obstacle.getHeight ( type )
    local width = width or Obstacle.getWidth ( type )
    local obstacle = Obstacle.new ( self.world, type, width, length, xpos, yoffset )
    self.obstacles[obstacle] = obstacle
  end

  level.alterOffset = function ( self, index, left, right )
    self.offsets[index] = {  left, right }
  end

  level.addInfo = function ( self, index, text, gfx )
    self.infoStops[index] = {
      text = text,
      hasWarned = false,
      gfx = gfx
    }
  end

  level.removeEnemy = function ( self, enemy )
    if not enemy then
      return
    end
    --Make sure we don't remove the enemy more than once
    if not self.enemies[ enemy ] then return end

    -- First do enemy own cleanup.
    enemy:destroy()

    -- And be sure all is gone.
    self.enemies[ enemy ] = nil
    if enemy.body.userData then
      if enemy.body.userData.confusegfx then
        game.removePropFromTextLayer ( enemy.body.userData.confusegfx )
      end
    end
    if not enemy.bodyRemoved then
      enemy.body:destroy()
      if enemy.body.userData then
        game.removePropFromGameLayer(enemy.body.userData)
      end
    end
    self.enemyCount = self.enemyCount - 1
    self.body = nil
  end

  level.addEnemy = function ( self, enemy )
    if not enemy then return end
    self.enemies[ enemy ] = enemy
    game.insertPropIntoGameLayer ( enemy.body.userData )
    self.enemyCount = self.enemyCount + 1
  end

  level.addPowerUpToLevel = function ( self, powerup )
    self.addedpowerups[ powerup ] = powerup
    game.insertPropIntoGameLayer ( powerup.part.userData )
    game.insertPropIntoGameLayer ( powerup.part.userData.glow )
  end

  level.shouldSpawnEnemy = function ( self, tick )
    return self.enemyCount < self.enemyLimit and tick % self.spawnFrequency == 0 and not self.spawnedboss
  end

  level.onFinish = function ( self )
    for road in next, self.roads, nil do
      road:destroy ()
    end
  end

  level.canJump = function ( self )
    if self.jumpCount > 0 and not self.car.isJumping () then
      if not self.car.body.userData.canJump then
        return false
      end
      return true
    else
      return false
    end
  end

  level.jump = function ( self )
    if self:canJump () then
      self.jumpCount = self.jumpCount - 1
      self.car.jump ( self )
      self.car.body.userData.canJump = false
    else
      if self.jumpCount == 0 then
        self.jumpText:setTextSize(32)
        self.jumpText:setLoc(-util.halfX + 60, util.halfY - 60)
        self.jumpText:setColor ( 1, 0, 0 )
        util.sleep ( .01 )
        self.jumpText:setLoc(-util.halfX + 60, util.halfY - 65)
        self.jumpText:setTextSize(18)
        self.jumpText:setColor ( 1, 1, 1, 1 )
      end
    end
  end

  level.onInput = function ( self )

  end

  level.finishLevel = function ( self )
    if not self.canDie then return end
    self.finishing = true
    self.canDie = false
    if not self.multiplayer then
      local thread = MOAIThread.new ()
      thread:run (function ( )
        while not self.lineFinished do
          coroutine.yield()
        end
        game.finishLevel()
      end)
    end
  end

  level.makeSwarm = function ( swarm )
    local counter = 0
    -- Do things a little async
    local thread = MOAIThread.new()
    thread:run (function ( )
      swarm.size = tonumber(swarm.size)
      while counter < swarm.size do
        counter = counter + 1
        local badguy = game.enemyFactory.spawnCar ( game.level.world, game.tick .. "swarmed" .. counter, false, swarm.type, true )
        util.sleep ( .2 )
        game.level:addEnemy ( badguy )
      end
    end)
  end

  level.makePowerUp = function ( type )
    local powerup = game.powerups.spawn ( game.level.world, type )
    game.level:addPowerUpToLevel ( powerup )
  end

  level.destroyPowerUp = function ( powerup )
    powerup:destroy ()
    level.addedpowerups[powerup] = nil
  end

  level.onUpdate = function ( self )

    if multiplayer.summaryAvailable then
      if not globalData.losinglife then
        multiplayer.summaryAvailable = false
        statemgr.push ( "states/state-stats.lua" )
      end
    end
    if #multiplayer.messageQueue > 0 then
      if game.tick % 20 == 0 then
        multiplayer.onUpdate ()
      end
    end
    if self.updateLevel then
      self.updateLevel ()
    end
    if self.useProgress and not level.progressBar.inserted then
      level.progressBar.inserted = true
      game.insertPropIntoTextLayer ( level.progressBar )
      if self.useProgressCar then
        game.insertPropIntoTextLayer ( level.progressCar )
      end
    end
    if globalData.brsound then
      globalData.brsound:stop ()
      globalData.brsound = nil
    end
    if globalData.bgsound.loaded and not globalData.bgsound.playing and sound.music then
      globalData.bgsound.playing = true
      sound.play ( globalData.bgsound.sound, "music" )
    end
    if self.roadCount > self.length + 1 and not self.spawnedboss then
      -- We only need to finish once.
      if not self.finishing then self:finishLevel () end
    end
    if #self.popups > 0 then
      if not self.popups[1].showing then
        self.popups[1].showing = true
        self.popups[1]:show ()
      end
      if self.popups[1] and self.popups[1].shown then
        table.remove ( self.popups, 1 )
      end
    end

    if self.multiplayer then
      local alone = true
      for u, cars in next, multiplayer.carstats do

        local user = cars.name
        if user == multiplayer.name then
          -- Update our own stats.
          game.carscrashed = cars.count
        else
          alone = false
          if level.alonetext then
            game.removePropFromTextLayer ( level.alonetext )
            level.alonetext = nil
          end
          if not game.level.multiplayerheads[user] then
            local ypos = 180 - self.nextPlayerHeadPos * 50
            game.level.multiplayerheads[user] = util.getProp ( "gfx/user_" .. self.nextPlayerHeadPos .. ".png", 21, 20, util.halfX - 35, ypos, nil )
            game.insertPropIntoTextLayer ( game.level.multiplayerheads[user] )
            game.level.multiplayerheads[user].text = util.makeText( "0", 30, 30, util.halfX - 10, ypos, 16 )
            game.insertPropIntoTextLayer ( game.level.multiplayerheads[user].text )
            game.level.multiplayerheads[user].usertext = util.makeText( user, 40, 30, util.halfX - 30, (ypos) - 30, 8 )
            game.insertPropIntoTextLayer ( game.level.multiplayerheads[user].usertext )
            if not game.level.multiplayerpos[user] then
              local xpos = 12 + (self.nextPlayerHeadPos * 6) + 2
              local percent = multiplayer.positions[user] and (multiplayer.positions[user] * self.length) or 0
              game.level.multiplayerpos[user] = util.getProp ( "gfx/color_" .. self.nextPlayerHeadPos .. ".png", 6, 6, -util.halfX + xpos, -140 + (percent * 260), nil )
              game.insertPropIntoTextLayer ( game.level.multiplayerpos[user] )
            end
            self.nextPlayerHeadPos = self.nextPlayerHeadPos + 1
            game.level.multiplayerheads[user].animate = function ( self )
              local routine = MOAICoroutine.new ()
              routine:run(function (  )
                self:moveRot ( 30, .3 )
                self:moveRot ( -60, .3 )
                util.wait ( self:moveScl ( 1.3, 1.3, .45 ) )
                self:moveRot ( 30, .3 )
                util.wait ( self:moveScl ( -1.3, -1.3, .45 ) )
              end)
            end
            game.level.multiplayerheads[user].remove = function ( self )
              game.removePropFromTextLayer(self.text)
              game.removePropFromTextLayer(self.usertext)
              game.removePropFromTextLayer(self)
              self.animate = nil
              self = nil
            end
          end
          game.level.multiplayerheads[user].text:setString ( cars.count .. "" )
          local x = game.level.multiplayerpos[user]:getLoc()
          if multiplayer.positions[u] then
            game.level.multiplayerpos[user]:setLoc(x, -140 + ( (multiplayer.positions[u].count / game.level.length) * 260) )
          end
        end
      end
      if alone and not level.alonetext then
        level.alonetext = util.makeText ( "none", 40, 30, util.halfX - 20, util.halfY - 107, 8 )
        game.insertPropIntoTextLayer ( level.alonetext )
      end
    else
      if game.level.multiplayerheads then
        for i, head in next, game.level.multiplayerheads, nil do
          game.removePropFromTextLayer ( head.text )
          game.removePropFromTextLayer ( head )
        end
      end
      if game.level.multiplayerpos then
        for i, head in next, game.level.multiplayerpos, nil do
          game.removePropFromTextLayer ( head )
        end
      end
    end

    self:updateCar ()

    if self.swarms then
      for i, swarm in next, self.swarms, nil do
        if self.roadCount == i and not swarm.hasSwarmed then
          self.makeSwarm ( swarm )
          swarm.hasSwarmed = true
        end
      end
    end

    if self.powerups then
      for i, powerup in next, self.powerups, nil do
        if self.roadCount == i and not powerup.isSpawned then
          self.makePowerUp ( powerup.powertype )
          powerup.isSpawned = true
        end
      end
    end

    if self.infoStops and (not globalData.config.supressInfo or self.skipButton == false) then
      for i, info in next, self.infoStops, nil do
        if self.roadCount == i and not self.infoStops[i].hasWarned then
          self.infoStops[i].hasWarned = true
          globalData.infoTextText = info.text
          if info.gfx then
            globalData.infoTextGfx = info.gfx
          else
            globalData.infoTextGfx = nil
          end
          globalData.infoTextSkipSupressButton = nil
          if self.skipButton == false then
            globalData.infoTextSkipSupressButton = false
          end
          statemgr.push ( "states/state-infotext.lua" )
        end
      end
    end

    for road in next, self.roads, nil do
      road:onUpdate ()
      if road:shouldSpawn () then
        self:spawnRoad ( road )
      end
      if road:shouldDie () then
        game.destroyRoad ( road )
      end
    end

    for i, enemy in next, self.enemies, nil do
      enemy:onUpdate ()
    end
    for i, powerup in next, self.addedpowerups, nil do
      powerup:onUpdate ()
    end
    for i, obstacle in next, self.obstacles, nil do
      obstacle:onUpdate ()
    end

    if self.progressCar and self.useProgress then
      local add = math.min(1, ( ( self.roadCount - 2 ) / self.length ) ) * ( SCREEN_UNITS_Y * 0.58 )
      -- Make sure we don't start below the line.
      add = math.max( add, 0 )
      self.progressCar:setLoc ( -util.halfX + 20, -util.halfY * .6 + add )
    end

    self.jumpText:setString ( "" .. self.jumpCount )
    self.crashText:setString ( "" .. game.carscrashed )
    if self.levelText and self.survivalLevel then
      self.levelText:setString ( "level " .. self.survivalLevel )
    end
  end

  level.explodeAll = function ( self )
    -- Make a copy of the enemies, since they can explode while we loop in a
    -- thread.
    local enemiesCopy = {}
    for i, enemy in next, self.enemies, nil do
      enemiesCopy[i] = enemy
    end
    -- Do things a little async
    local thread = MOAIThread.new()
    thread:run (function ( )

      if not self.enemies then return end
      for i, enemy in next, enemiesCopy, nil do
        if self and self.enemies[i] then
            -- Check if the enemy with the corresponding delta still exists.
          if self.enemies[i].body.userData.boss then
            -- You can not kill bosses with bombs.
          else
            game.killEnemy ( self.enemies[i], true )
            util.sleep(.05)
          end
        end
      end
    end)
  end

  level.onUnload = function ( self )
    game.removePropFromCarLayer ( self.car.body.userData )
    if self.car.body.userData.turboProp then
      game.removePropFromGameLayer ( self.car.body.userData.turboProp )
    end
    game.removePropFromTextLayer ( self.jumpText )
    game.removePropFromTextLayer ( self.crashText )
    if self.levelText then
      game.removePropFromTextLayer ( self.levelText )
    end
    if self.playername then
      game.removePropFromTextLayer ( self.playername )
    end
    if level.usergfx then
      game.removePropFromTextLayer ( self.usergfx )
    end
    if level.alonetext then
      game.removePropFromTextLayer ( self.alonetext )
    end
    if level.lineFinished then
      level.lineFinished = nil
    end
    if level.opponentsheading then
      game.removePropFromTextLayer ( self.opponentsheading )
    end
    for enemy in next, self.enemies, nil do
      game.removePropFromGameLayer ( enemy.body.userData )
      if enemy.body.userData and enemy.body.userData.confusegfx then
        game.removePropFromTextLayer ( enemy.body.userData.confusegfx )
        enemy.body.userData.confusegfx = nil
      end
      if enemy.body and not enemy.bodyRemoved then
        enemy.body:destroy()
      end
      enemy = nil
    end
    self.enemies = nil
    for powerup in next, self.addedpowerups, nil do
      powerup:destroy ()
      powerup = nil
    end

    if self.multiplayerpos then
      for user, prop in next, self.multiplayerpos, nil do
        game.removePropFromTextLayer(prop)
      end
    end

    for obstacle in next, self.obstacles, nil do
      if obstacle then
        obstacle:destroy ()
        obstacle = nil
      end
    end
    self.obstacles = nil
    for i, w in ipairs ( self.walls ) do
      w:destroy ()
    end
    self.walls = nil

    self.world:stop ()
    self.world = nil
  end

  level.updateCar = function ( self )
    self.car.onUpdate ( level, 0 )
  end

  level.onPause = function ( self )
    self.world:stop ()
    self.car.onPause ()
    if self.warning then
      self.warning:onPause ()
    end
  end

  level.onResume = function ( self )
    self.world:start ()
    self.car.onResume ()
    if self.warning then
      self.warning:onResume ()
    end
  end

  level.spawnRoad = function ( self, oldRoad )
    self.roadCount = self.roadCount + 1

    if self.multiplayer then
      if multiplayer.myProgress and multiplayer.myProgress > self.roadCount then
        local setRoadCount = multiplayer.myProgress
        if self.blocks[multiplayer.myProgress] then
          -- We don't want to start on a block. Take minus 1 (can never be a
          -- block)
          setRoadCount = setRoadCount - 1
        end
        self.roadCount = setRoadCount
      end
    end
    if self.multiplayer then
      multiplayer.progressUpdate()
    end
    if self.roadCount % self.powerFreq == 0 and not self.blocks[self.roadCount] then
      local random = math.random(#self.availablePowerUps)
      local type  = self.availablePowerUps[random]
      self:addPowerUp ( self.roadCount + 1, type )
    end
    local block = self.blocks[self.roadCount]
    if self.blocks[self.roadCount + 1] then
      self.warning = Warning.new ()
      self.warning:play ()
    end
    local road
    if not self.offsets[self.roadCount] then
      self.offsets[self.roadCount] = {
        math.random ( self.minOffset, self.maxOffset ),
        math.random ( self.minOffset, self.maxOffset )
      }
    end
    if self.roadAlters[self.roadCount] then
      road = Road.new ( self.world, oldRoad, self.offsets[self.roadCount], false, self.roadAlters[self.roadCount] )
    else
      road = Road.new ( self.world, oldRoad, self.offsets[self.roadCount], block, block and block.length )
    end
    if road then
      road.setCollisionHandler ( game.handleCollisions )
      for i, prop in ipairs ( road.props ) do
        game.insertPropIntoBackgroundLayer ( prop )
      end
      self.roads[road] = road
    end

    if self.roadCount % self.obstacleFreq == 0 and not self.blocks[self.roadCount] then
      -- Hardcoded for now.
      local type = self.availableObstacles[math.random(1, #self.availableObstacles)]
      self:addObstacle ( type )
    end

    if self.predefObstacles[self.roadCount] then
      for i, e in ipairs ( self.predefObstacles[self.roadCount] ) do
        local obs = self.predefObstacles[self.roadCount][i]
        self:addObstacle ( obs.type, obs.width, obs.length, obs.x, obs.yoffset )
      end
    end


  end

  return level
end

unlockedWorld = function ( world )
  local levelTruths = {}
  levelTruths[1] = true
  levelTruths[2] = globalData.config.achievements.unlockworld2
  return levelTruths[world]
end

getTheme = function ( world )
  worldsTheme = {}
  worldsTheme[2] = "desert"
  local value = worldsTheme[world] or "grass"
  return value
end

levels = {
  {
    "levels/1/level1.lua",
    "levels/1/level2.lua",
    "levels/1/level3.lua",
    "levels/1/level4.lua",
    "levels/1/level5.lua",
    "levels/1/level6.lua",
    "levels/1/level7.lua",
    "levels/1/level8.lua",
    "levels/1/level9.lua",
    "levels/1/level10.lua",
    "levels/1/level11.lua",
    "levels/1/level12.lua",
    "levels/1/level13.lua",
    "levels/1/level14.lua",
    "levels/1/level15.lua",
    "levels/1/level16.lua",
    "levels/1/level17.lua",
    "levels/1/level18.lua",
    "levels/1/level19.lua",
    "levels/1/level20.lua",
    "levels/1/level21.lua",
    "levels/1/level22.lua",
    "levels/1/level23.lua",
    "levels/1/level24.lua",
    "levels/1/level25.lua",
    "levels/1/level26.lua",
    "levels/1/level27.lua",
    "levels/1/level28.lua",
    "levels/1/level29.lua",
    "levels/1/level30.lua"
  },
  {
    "levels/2/level1.lua",
    "levels/2/level2.lua",
    "levels/2/level3.lua",
    "levels/2/level4.lua",
    "levels/2/level5.lua",
    "levels/2/level6.lua",
    "levels/2/level7.lua",
    "levels/2/level8.lua",
    "levels/2/level9.lua",
    "levels/2/level10.lua",
    "levels/2/level11.lua",
    "levels/2/level12.lua",
    "levels/2/level13.lua",
    "levels/2/level14.lua",
    "levels/2/level15.lua",
  },
  special = {
    multiplayer = "levels_special/multiplayerlevel.lua",
    survival = "levels_special/survival.lua",
    emptylevel = "levels_special/emptylevel.lua",
    quick = "levels_special/quick.lua"
  }
}
