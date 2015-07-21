module ( "Obstacle", package.seeall )

getObstacleCollisionHandlers = function ( type )
  local handlers = {
    grass = game.handleCollisions,
    bricks = game.handleCollisions,
    water = game.handleCollisions,
    hole = game.handleCollisions,
    rock = game.handleCollisions,
    zombie = game.handleCollisions
  }
  return handlers[type]
end

causesFall = function ( type )
  local types = {
    hole = true,
  }
  return types[type] or false
end

killsEnemies = function ( type )
  local types = {
    bricks = true,
    water = true,
    rock = true,
    zombie = true
  }
  return types[type]
end

isMoving = function ( type )
  local types = {
    zombie = true
  }
  return types[type] or false
end

isAnimated = function ( type )
  local types = {
    water = true
  }
  if isMoving(type) then
    return true
  end
  return types[type] or false
end

isSprite = function ( type )
  local types = {
    zombie = 3,
    water = 2
  }
  return types[type] or false
end

getHeight = function ( type )
  local types = {
    wheel = 40,
    hole = 120,
    cactus = 32,
  }
  return types[type]
end

getWidth = function ( type )
  local types = {
    wheel = 40,
    hole = 160,
    cactus = 32,
  }
  return types[type]
end

getObstacleShapes = function ( type )
  local shapes = {
    wheel = "circle",
    hole = "polygon",
    rock = "circle",
    cactus = "circle"
  }
  return shapes[type]
end

local isTiled = function ( type )
  local notiles = {
    wheel = true,
    hole = true,
  }
  return not notiles[type]
end

function new ( world, type, width, length, xpos, yoffset )
  local width = width or 40
  local length = length or 40
  local obstacle = {}
  obstacle.length = length

  obstacle.part = world:addBody ( MOAIBox2DBody.KINEMATIC )
  if not obstacle.part then return nil end
  obstacle.part.type = type
  obstacle.part.enemyKiller = killsEnemies(type) or false

  local edges
  obstacle.props = {}
  obstacle.part:setLinearVelocity ( 0, -speed.getSpeed() )

  local carType = globalData.config.carType or "redcar"
  local pr = Car.carProperties[carType]

  if getObstacleShapes (type) == "circle" then
    obstacle.part.fixture = obstacle.part:addCircle ( 0, 0, width / 2)
  else
    if getObstacleShapes (type) == "polygon" then
      local height = getHeight ( type )
      local width = getWidth ( type )
      local poly = {
        -width / 4, height / 5,
        -(width / 8) * 2.1, 0,
        -width / 4, -height / 5,
        width / 4, -height / 5,
        (width / 8) * 2.1, 0,
        width / 4, height / 5
      }
      obstacle.part.fixture = obstacle.part:addPolygon ( poly )
    else
      obstacle.part.fixture = obstacle.part:addRect ( -width / 2, -length / 2, width / 2, length / 2 )
    end
  end
  obstacle.part.fixture:setDensity ( 1 )
  obstacle.part.fixture:setFriction ( 1 )
  obstacle.part.fixture:setFilter ( 0x02 )
  obstacle.part.fixture:setRestitution ( 1 )

  if getObstacleCollisionHandlers (type) then
    obstacle.part.fixture:setCollisionHandler (getObstacleCollisionHandlers(type), MOAIBox2DArbiter.BEGIN, 0xFFF )
  end
  if pr.destroys[type] then
    -- Our car destroys this rascal. Lets make a note of that.
    obstacle.canDissolve = true
  end

  local prop
  local maxX = (SCREEN_UNITS_X / 2) - game.level.maxOffset
  local originalX = math.random ( -maxX, maxX )
  if xpos then
    originalX = xpos
  end
  local tile = "gfx/" .. type .. ".png"
  if isTiled ( type ) then
    local tilewidth = 1
    if isSprite(type) then
      tilewidth = isSprite(type)
    end
    prop = util.getGrid ( width, length, tile, - (width / 2), - ( length / 2 ), 50, tilewidth )
    if isMoving(type) then
      if originalX > 0 then
        tile = "gfx/" .. type .. "2.png"
      end
      prop = util.getGrid ( width, length, tile, - (width / 2), - ( length / 2 ), 50, tilewidth )
    end
  else
    prop = util.getProp ( tile, width, length, nil, nil )
    prop:setPriority ( 100 )
  end

  obstacle.part.userData = prop
  obstacle.part.originalX = originalX

  obstacle.part.userData:setParent ( obstacle.part )
  game.insertPropIntoGameLayer ( obstacle.part.userData )
  local addy = yoffset or 0
  local ypos = SCREEN_UNITS_Y/2 + length + 30 + addy
  obstacle.part:setTransform ( originalX, ypos )


  obstacle.onUpdate = function ( self )
    if self.speed ~= -speed.getSpeed () then
      local xvelocity = 0
      if isMoving(type) then
        xvelocity = 30
        if self.part.originalX > 0 then
          xvelocity = -30
        end
      end
      self.part:setLinearVelocity ( xvelocity, -speed.getSpeed () )
      self.speed = -speed.getSpeed ()
    end
    -- Its moving. Or just animating.
    if isAnimated(type) then
      local rate = 8
      if game.tick % rate == 0 then
        self.part.userData:animate()
      end
    end
    local propx, propy = self.part:getWorldLoc ()
    local car = game.getCar ()
    if ( self.canDissolve or car.body.userData.invincible ) and not self.dissolving then
      -- We have no collision detection, let's just see if we are inside the
      -- prop boundaries (like with powerups).
      local car = game.getCar ()
      local carX, carY = car.body:getWorldLoc ()
      local xdiff = carX - propx
      local ydiff = carY - propy
      local pr = car.properties
      local carside = pr.width > pr.height and pr.width or pr.height
      local within = getWidth(self.part.type) or 40 + 4
      if carside > within then
        within = carside
      end
      if not (propx == 0 and propy == 0) and (ydiff < within and ydiff > -within) and (xdiff > -within and xdiff < within) and not self.exploded and not car.isJumping () then
        self.possibleDisolve = true
        -- Ooof. What a dirty hack. But it looks good at least.
        self.part.fixture:setFilter( 0x00 )
      end
    end
    if self.possibleDisolve and not self.dissolving then
      local car = game.getCar ()
      local carX, carY = car.body:getWorldLoc ()
      local xdiff = carX - propx
      local ydiff = carY - propy
      local within = ((getWidth(self.part.type) or 40) - 20)
      if not (propx == 0 and propy == 0) and (ydiff < within and ydiff > -within) and (xdiff > -within and xdiff < within) and not self.exploded and not car.isJumping () then
        self.dissolving = true
        self.part:dissolve()
      end
    end
    if propy < -500 and propy < -self.length then
      if self.dissolving then
        self:destroy(false)
      else
        self:destroy()
      end
    end

  end

  obstacle.part.dissolve = function ( self )
    -- We have killed an obstacle of a type. Mark accordingly in config.
    globalData.config.obstacleKills[self.type] = globalData.config.obstacleKills[self.type] or 0
    globalData.config.obstacleKills[self.type] = globalData.config.obstacleKills[self.type] + 1
    game.lastObstaclesKilled = game.lastObstaclesKilled or {}
    game.lastObstaclesKilled[self.type] = game.lastObstaclesKilled[self.type] or 0
    game.lastObstaclesKilled[self.type] = game.lastObstaclesKilled[self.type] + 1
    local t = MOAIThread.new()
    t:run(function (  )
      game.removePropFromGameLayer(self.userData)
      self:setLinearVelocity ( 0, -speed.getSpeed () )
      game.addIngameScore(200)
      local size = 32
      local soundfx = "sound/crash.ogg"
      sound.play ( util.getSound ( soundfx ) )
      local explosion = util.getGrid ( size, size, "gfx/dustsprite.png", - (size / 2), - ( size / 2 ), size, 5, true )
      game.insertPropIntoGameLayer(explosion)
      explosion:setParent(self)
      while not explosion.doneAnimating do
        explosion:animate()
        util.sleep(.1)
      end
      util.sleep(5)
      game.removePropFromGameLayer(explosion)
    end)
  end

  obstacle.destroy = function ( self, removeProp )
    if removeProp == false then
      -- We will remove prop ourselves.
    else
      game.removePropFromGameLayer ( self.part.userData )
    end
    if self.part then
      self.part:destroy ()
    end
    game.level.obstacles[self] = nil
    self = nil

  end

  return obstacle

end
