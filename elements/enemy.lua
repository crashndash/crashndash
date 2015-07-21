module ("EnemyFactory", package.seeall )

local enemyRect = {
  -14, -14, 14, 14
}

local enemies = {}

local chaseApplyForce = function ( self )
  if self:applyConfusion () then return end
  local dX, dY = self:getDirectionsToCar ()
  if not dX or not dY then return end
  local speed = self.body.userData.properties.speed
  self.body:applyForce ( speed * dX, speed * dY )
end

local chaseLinearVelocity = function ( self )
  if self:applyConfusion () then return end
  local dX, dY, carX, carY, playerX, playerY = self:getDirectionsToCar ()
  if math.abs ( carX - playerX ) < 10 then dX = 0 end
  if math.abs ( carY - playerY ) < 10 then dY = 0 end
  local speed = self.body.userData.properties.speed
  if game.getCar ().isJumping () then
    self.body:setLinearVelocity ( speed * dX / 2, speed * dY / 2 )
  else
    self.body:setLinearVelocity ( speed * dX, speed * dY )
  end
end

local setKilledOnLanding = function ( self, car )
  game.shouldKill = self
end

local bounceOnLanding = function ( self, car )
  car.jump ( game.level )
end

local killCarOnLanding = function ( self, car )
  game.loseLife ()
end

enemies.createProperties = function ( attributes )
  attributes = attributes or {}
  return {
    speed = attributes.speed or 100,
    weight = attributes.weight or 4,
    score = attributes.score or 100,
    size = attributes.size or enemyRect,
    health = attributes.health or 1,
    confusion = attributes.confusion or 50,
    updateFunction = attributes.updateFunction or chaseApplyForce,
    animater = attributes.animater or nil,
    explosionfactor = attributes.explosionfactor or 2,
    onCarLanding = attributes.onCarLanding or setKilledOnLanding,
    gfx = attributes.gfx or nil,
    fragile = attributes.fragile or nil

  }
end

enemies.properties = {
  fatcar = enemies.createProperties({ animater = true, speed = 300, weight = 10, score = 200, size = {-28, -30, 28, 30} }),
  bwcar = enemies.createProperties( {size = {-11, -12, 11, 12}}),
  skinnycar = enemies.createProperties({ speed = 150, weight = 1, size = {-10, -14, 10, 14}, confusion = 70 }),
  stripecar = enemies.createProperties({ speed = 100, weight = 2, size = { -10, -18, 10, 18 } }),
  bus = enemies.createProperties({ speed = 300, weight = 20, score = 300, size = { -15, -40, 15, 40 } }),
  tanker = enemies.createProperties({ speed = 3000, weight = 200, score = 800, size = { -21, -61, 21, 61 }, animater = true, explosionfactor = 15, health = 2 }),
  wagon = enemies.createProperties({ speed = 200, weight = 1, score = 50, size = { -15, -21, 15, 21 }, confusion = 100 }),
  superboss = enemies.createProperties({ speed = 700, weight = 40, score = 1000, size = { -35, -35, 35, 35 }, health = 3, explosionfactor = 10 }),
  fascist = enemies.createProperties({ speed = 700, weight = 40, score = 1000, size = { -33, -33, 33, 33 }, health = 3, explosionfactor = 10, animater = true }),
  ufo = enemies.createProperties({ speed = 1700, weight = 30, score = 1000, size = { -40, -42, 40, 42 }, health = 4, explosionfactor = 8, onCarLanding = bounceOnLanding, animater = true }),
  miniufo = enemies.createProperties({ speed = 400, weight = 1, score = 200, size = { -10, -10, 10, 10 }, explosionfactor = 8, animater = true, gfx = "ufo" }),
  minitanks = enemies.createProperties({ speed = 200, weight = 10, score = 500, size = { -22, -22, 22, 22 }, explosionfactor = 10, animater = true, gfx = "fascist" }),
  police = enemies.createProperties({ speed = 200, weight = 1, score = 50, confusion = 100, animater = true, explosionfactor = 4, size = {-12, -23, 12, 23} }),
  sandy = enemies.createProperties({ speed = 200, weight = 10, size = { -16, -22, 16, 22 }, confusion = 100 }),
  racertaxi = enemies.createProperties( {size = {-9, -14, 9, 14}}),
  bombcar = enemies.createProperties({ speed = 300, weight = 20, score = 300, size = {-16, -22, 16, 22}, fragile = true, explosionfactor = 4 }),
}

function new ( world )
  local factory = {}

  factory.spawnCar = function ( world, index, special, type, ontop )
    local car = {}
    local number = math.random(#game.level.enemyVariations)

    if ( special ~= false ) then
      car.type = special
    else
      car.type = type or game.level.enemyVariations[number]
    end

    car.handleCollisions = function ( event, enemy, other )
      local otherBody = other:getBody ()
      local carbody = enemy:getBody ()
      local properties = (carbody and carbody.userData) and carbody.userData.properties or {}
      if otherBody.type == "hero" and otherBody.userData and otherBody.userData.invincible then
        game.killEnemy ( car )
      end
      -- If the enemy is fragile, it dies on impact!
      if otherBody.type == "hero" and properties.fragile then
        game.killEnemy ( car )
      end
      if otherBody.type == "hero" or ( otherBody.userData and otherBody.userData.confused ) then
        local confusion = properties.confusion
        if carbody.userData then
          carbody.userData.confused = confusion
        end
        if otherBody.type ~= "hero" then
          otherBody.userData.confusion = nil
        end
      end
    end

    car.onCarLanding = enemies.properties[car.type].onCarLanding

    local width = 2 * enemies.properties[car.type].size[3]
    local height = 2 * enemies.properties[car.type].size[4]
    local propname = enemies.properties[car.type].gfx or car.type
    local prop = util.getProp ( "gfx/" .. propname .. ".png", width, height, nil, nil )

    car.body = world:addBody ( MOAIBox2DBody.DYNAMIC )
    if not car.body then
      return nil
    end
    car.body.userData = prop
    car.body.userData:setParent ( car.body )
    car.body.userData.properties = enemies.properties[car.type]
    car.body.health = enemies.properties[car.type].health
    car.body:setMassData ( car.body.userData.properties.weight )
    car.body.index = index
    car.body.type = "enemy"
    car.body.resetHealth = function ()
      car.body.health = enemies.properties[car.type].health
    end

    car.fixture = car.body:addRect ( unpack ( enemies.properties[car.type].size ) )
    car.fixture:setDensity ( 1 )
    car.fixture:setFriction ( 1 )
    car.fixture:setFilter ( 0x02 )
    car.fixture:setRestitution ( 1 )
    car.fixture:setCollisionHandler ( car.handleCollisions, MOAIBox2DArbiter.BEGIN, 0x03 )
    -- A boss shouldn't disappear at the front or back, so it needs another filter
    if special then
      car.fixture:setFilter ( 0x08 )
      car.body.userData.boss = true
    end

    local roadCount = game.level.roadCount - 1
    local yplace = math.random ( 1, 2 )
    local ypos
    local xpos
    local defaultOffset = {game.level.minOffset, game.level.maxOffset}
    local offset
    if yplace == 1 or ontop then
      -- Let's place this one on the top.
      ypos = SCREEN_UNITS_Y/2 + 30
      if roadCount < 1 then
        roadCount = 1
      end
      offset = game.level.offsets[roadCount] or defaultOffset
    else
      if roadCount < 5 then
        roadCount = 5
      end
      offset = game.level.offsets[roadCount - 4 ] or defaultOffset
      ypos = -SCREEN_UNITS_Y/2 - 30
    end
    local rand1 = - (util.halfX -  offset[2] - width)
    local rand2 = util.halfX - offset[2] - width

    if rand1 > rand2 then
      -- Can not make random with these parameters.
      rand2 = rand1
    end

    xpos = math.random(rand1, rand2)

    car.body:setTransform ( xpos, ypos )

    car.body.getCar = function (  )
      return car
    end

    car.body.userData.die = function (skippoints, fall, variables)
      if car.bodyRemoved then return end
      local textX, textY = car.body:getPosition ()
      car.body:destroy()
      car.bodyRemoved = true
      local soundfx = "pow"
      if car.body.userData.boss then
        -- If the boss is dead, we must make the user notice with a giant
        -- boom!
        soundfx = "pow2"
        game.level.bossesActive = game.level.bossesActive - 1
      end
      if car.body.userData.boss and game.level.bossesActive == 0 then
        game.level.canDie = false
      end
      car.exploding = true
      if car.body.userData.confusegfx then
        game.removePropFromTextLayer ( car.body.userData.confusegfx )
        car.body.userData.confusegfx = nil
      end
      if not fall then
        local explosionfactor = car.body.userData.properties.explosionfactor
        local size = 48 * explosionfactor
        game.removePropFromGameLayer(car.body.userData)
        local explosionGfx = util.getExplosionAnimation(size)
        -- Insert awesome sprite.
        explosionGfx:setParent(car.body)
        game.insertPropIntoGameLayer ( explosionGfx )
        car.body.userData.explosion = explosionGfx
      end
      if game.level.multiplayer then
        table.insert(multiplayer.messageQueue, car.type)
      end
      game.typesCrashed[car.type] = game.typesCrashed[car.type] or 0
      game.typesCrashed[car.type] = game.typesCrashed[car.type] + 1
      local bonusText
      if not skippoints then
        if not game.level.multiplayer and textX and textY then
          bonusText = util.makeText( "" .. car.body.userData.properties.score, 90, 30, textX + 30, textY + 30, 16 )
          bonusText:setPriority ( 3 )
          game.insertPropIntoTextLayer ( bonusText )
        end
      end

      local thread = MOAICoroutine.new ()
      thread:run ( function (c)
        if fall then
          -- Not sure where to put this common function shared between enemies
          -- and hero, but it now belongs to Car module.
          Car.fallAnimation(c, variables)
        else
          local explosionSound = util.getSound ( "sound/" .. soundfx .. ".ogg" )
          explosionSound:setVolume(.6)
          sound.play ( explosionSound )
          if c and c.explosion then
            while not c.explosion.doneAnimating do
              c.explosion:animate()
              util.sleep(.02)
            end
          end
        end
        prop.exploding = false
        c.shouldBeRemoved = true
        if bonusText then
          game.removePropFromTextLayer ( bonusText )
        end
        prop = nil
        -- If we just killed the boss, the level is over.
        if c and c.boss and game.level.bossesActive == 0 then
          if not game.level.finishing then
            game.level.finishing = true
            game.finishLevel ()
          end
        end
      end, car.body.userData)
    end

    car.destroy = function ( self )
      if self.body.userData.explosion then
        game.removePropFromGameLayer(self.body.userData.explosion)
        self.body.userData.explosion = nil
      end
      game.removePropFromGameLayer ( self.body.userData )
      if self.body.userData.confusegfx then
        game.removePropFromTextLayer ( self.body.userData.confusegfx )
        self.body.userData.confusegfx = nil
      end
      self.body.userData = nil
    end

    car.onUpdate = function ( self )
      if self.body.userData.shouldBeRemoved then
        self.shouldBeRemoved = nil
        game.level:removeEnemy(self)
        -- Return and never come back
        self.exploding = true
        return
      end
      if self.exploding then return end
      if self.bodyRemoved then return end
      if not self.body.updated then
        -- Set this flag to avoid being killed on spawn.
        self.body.updated = true
      end
      self.body.userData.properties.updateFunction ( self )
      if self.body.userData.properties.animater then
        self.animate ()
      end
    end

    car.animate = function (  )
      if game.tick % 10 == 0 then
        local newCar
        if car.body.userData.firstimage then
          newCar = car.body.userData.properties.gfx or car.type
          car.body.userData.firstimage = false
        else
          newCar = (car.body.userData.properties.gfx or car.type) .. "2"
          car.body.userData.firstimage = true
        end
        local carGfx = MOAIGfxQuad2D.new ()
        carGfx:setTexture ( util.getTexture ( 'gfx/' .. newCar .. '.png' ) )
        carGfx:setRect ( unpack ( car.body.userData.properties.size ) )
        car.body.userData:setDeck ( carGfx )
      end
    end

    car.applyConfusion = function ( self )
      if self.body.userData.confused then
        if not self.body.userData.confusegfx then
          self.body.userData.confusegfx = util.getProp ( 'gfx/fire.png', self.body.userData.properties.size[3], self.body.userData.properties.size[3] / 2, 0, self.body.userData.properties.size[4], self.body.userData )
          self.body.userData.confusegfx.first = true
          game.insertPropIntoTextLayer ( self.body.userData.confusegfx )
        end
        if game.tick % 10 == 0 then
          local width = self.body.userData.properties.size[3] * 2
          local height = width
          local confgfx = MOAIGfxQuad2D.new ()
          local newGfx
          if self.body.userData.confusegfx.first then
            newGfx = "fire"
            self.body.userData.confusegfx.first = false
          else
            newGfx = "fire2"
            self.body.userData.confusegfx.first = true
          end
          confgfx:setTexture ( util.getTexture ( 'gfx/' .. newGfx .. '.png'  ) )
          confgfx:setRect ( -width / 2, -height / 2, width / 2, height / 2 )
          self.body.userData.confusegfx:setDeck ( confgfx )
        end
        self.body.userData.confused = self.body.userData.confused - 1
        if self.body.userData.confused == 0 then
          self.body.userData.confused = nil
          game.removePropFromTextLayer ( self.body.userData.confusegfx )
          self.body.userData.confusegfx = nil
        end
        return true
      end
      return false
    end

    car.getDirectionsToCar = function ( self )
      if not self.body then return end
      if self.bodyRemoved then return end
      local player = game.getCar ()
      if not player then return end
      if player.bodyRemoved then return end
      if not player.body then return end
      local playerX, playerY = player.body:getPosition ()
      local carX, carY = self.body:getPosition ()
      if carX == nil or playerX == nil then
        -- Just to avoid "attempt to compare number with nil" we return here:
        return 0, 0, 0, 0, 0, 0
      end
      local dX = carX > playerX and -1 or 1
      local dY = carY > playerY and -1 or 1
      if player.turbo then
        -- Send the enemy fast backwards if we are on nitro.
        dY = -20
      end
      return dX, dY, carX, carY, playerX, playerY
    end

    return car

  end

  return factory
end

