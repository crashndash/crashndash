module ("Car", package.seeall )

fallAnimation = function ( prop, variables )
  local newx, newy = unpack(variables)
  local speed = speed.getSpeed()
  local animationLength = .4
  prop:moveScl(-1, -1, animationLength, MOAIEaseType.EASE_IN)
  prop:moveLoc(newx, newy - ((speed / 240) * 60), animationLength, MOAIEaseType.EASE_IN)
  -- Make the rotation when falling down in a hold a little random.
  local rotation = math.random(80, 180)
  -- And random if it rotates left or right.
  if math.random(0, 1) == 1 then
    rotation = -rotation
  end
  prop:moveRot(rotation, animationLength, MOAIEaseType.EASE_IN)
  util.sleep(animationLength)
end

local makeCarProperties = function(props)
  props = props or {}
  local carprops = {}
  carprops.speed = props.speed or 1
  carprops.weight= props.weight or 1
  carprops.width = props.width or 28
  carprops.height = props.height or 28
  carprops.secret = props.secret or false
  carprops.title = props.title or nil
  carprops.description = props.description or ""
  carprops.immuneTo = props.immuneTo or {}
  carprops.destroys = props.destroys or {}
  return carprops
end

getCarTypes = function (  )
  return {
    "redcar",
    "whitecar",
    "fascist",
    'ufo',
    "bwcar"
  }
end

carAvailable = function ( type )
  globalData.config.achievements = globalData.config.achievements or {}
  local truths = {
    redcar = true,
    whitecar = globalData.config.achievements.hiddencar,
    fascist = globalData.config.expBought.tanksplay,
    ufo = globalData.config.expBought.ufoplay,
    bwcar = globalData.config.expBought.bwplay
  }


  if globalData.config.boughtAllCars then
    return true
  end
  return truths[type] or false
end

carProperties = {
  whitecar = makeCarProperties({
    title = "Ghost car",
    weight = .5,
    width = 24,
    secret = true,
    description = "A very secret car"
  }),
  redcar = makeCarProperties({title = "Plain old"}),
  ufo = makeCarProperties({
    title = "alien cruiser",
    weight = .6,
    width = 45,
    height = 45,
    speed = 1.2,
    description = "Fast, but not so easy to steer"
  }),
  fascist = makeCarProperties({
    immuneTo = {rock = true},
    destroys = {zombie = true},
    title = "D-stroyer",
    weight = 3,
    width = 40,
    height = 40,
    speed = .7,
    description = "Robust and slow. Kills zombies!"
  }),
  bwcar = makeCarProperties({
    title = "Small cab",
    width = 22,
    height = 24,
    speed = 1.1,
    weight = .7,
    description = "It's just really small"
  })
}

function new ( world, level )
  -- @todo Use level for what it is worth!
  local car = {}
  local carType = globalData.config.carType or "redcar"
  car.properties = carProperties[carType]
  local pr = car.properties
  local prop = util.getProp ( "gfx/" .. carType .. ".png", pr.width, pr.height, 0, 0 )
  car.animate = true

  car.body = world:addBody ( MOAIBox2DBody.DYNAMIC )
  car.body:setMassData ( level.carWeight * pr.weight )
  car.body:isBullet ( true )
  car.body.userData = prop
  -- We should place all other props in the following:
  car.body.userData.props = {}
  car.body.userData.carType = carType
  car.body.userData:setParent ( car.body )
  car.body.type = "hero"
  car.body.userData.canJump = true

  local carRect = {
    -pr.width / 2 ,
    -pr.height / 2,
    pr.width / 2,
    pr.height / 2
  }

  car.fixture = car.body:addRect ( unpack ( carRect ) )
  car.fixture:setDensity ( 1 )
  car.fixture:setFriction ( 0.3 )
  car.fixture:setFilter ( 0x01 )

  car.dx = 1000
  car.dy = 1000
  car.body.userData.isJumping = false

  car.jump = function ( level )
    if not car.body.userData.canJump then return end
    local jumpThread = MOAICoroutine.new ()
    jumpThread:run ( function ()
      car.body.userData.isJumping = true
      car.fixture:setFilter ( 0x01, 0x04 )
      local jumpLength = math.floor ( level.jumpDuration )
      car.jumpSound = util.getSound ( "sound/jump" .. jumpLength .. ".ogg" )
      sound.play ( car.jumpSound )
      car.action = car.body.userData:moveScl ( level.jumpHeight, level.jumpHeight, level.jumpDuration * 0.6, MOAIEaseType.EASE_IN )
      util.wait ( car.action )
      car.action = car.body.userData:moveScl ( -level.jumpHeight, -level.jumpHeight, level.jumpDuration * 0.4, MOAIEaseType.LINEAR )
      util.wait ( car.action )

      car.body.userData.isJumping = false
      car.fixture:setFilter ( 0x01, 0xFFFF )

      car.action = nil
      car.jumpSound = nil

      local cX, cY = car.body:getPosition ()
      for i, enemy in next, game.getEnemies (), nil do
        if not enemy.bodyRemoved then
          enemyBody = enemy.body
          local eX, eY = enemyBody:getPosition ()
          if not eX or not eY then return end
          if not enemyBody.userData then return end
          local deltaX = enemyBody.userData.properties.size[3]
          local deltaY = enemyBody.userData.properties.size[4]
          if cX and eX and deltaX and cY and eY and deltaY and math.abs ( cX - eX ) < deltaX and math.abs ( cY - eY ) < deltaY then
            enemy:onCarLanding ( car )
            break
          end
        end
      end
      -- We just have to sleep just a little bit here, to avoid that you can
      -- jump before you land on something. .02 still feels like instant though.
      util.sleep ( .02 )
      car.body.userData.canJump = true
    end)
    if car.turbo then
      local turboThread = MOAICoroutine.new ()
      turboThread:run (function ()
        -- Since we are in another thread, we must check if this stuff still
        -- exists.
        if car.body.userData.turboProp then
          car.body.userData.turboProp:moveScl ( level.jumpHeight, level.jumpHeight, level.jumpDuration * 0.6, MOAIEaseType.EASE_IN )
          util.wait ( car.body.userData.turboProp:moveLoc ( 0, -level.jumpHeight * 25 , level.jumpDuration * 0.6, MOAIEaseType.EASE_IN ))
        end
        if car.body.userData.turboProp then
          car.body.userData.turboProp:moveScl ( -level.jumpHeight, -level.jumpHeight, level.jumpDuration * 0.4, MOAIEaseType.LINEAR )
          util.wait ( car.body.userData.turboProp:moveLoc ( 0, level.jumpHeight * 25, level.jumpDuration * 0.4, MOAIEaseType.LINEAR ) )
        end
      end)
    end
  end

  car.isJumping = function ()
    return car.body.userData.isJumping
  end

  car.body.explode = function ( self, deathtype, variables )
    car.bodyRemoved = true
    local x, y = car.body:getPosition ()
    car.body.userData:setParent ( nil )
    car.body.userData:setLoc ( x, y )
    if self.turbo then
      self.userData.turboProp:setParent ( nil )
      self.userData.turboProp:setParent ( x, y )
    end
    if not deathtype then
      -- Default death: By explosion.
      car.animate = false
      local size = car.properties.width * 4
      local explosionGfx = util.getExplosionAnimation(size, self.userData)
      game.removePropFromCarLayer(self.userData)
      local offset = size / 2
      explosionGfx:setLoc(x - offset ,y - offset)
      game.insertPropIntoCarLayer(explosionGfx)
      local soundfx = "pow2"
      sound.play ( util.getSound ( "sound/" .. soundfx .. ".ogg" ) )
      while not explosionGfx.doneAnimating do
        explosionGfx:animate()
        util.sleep(.1)
      end
      game.removePropFromCarLayer ( explosionGfx )
    else
      -- Just to add support for more deathtypes.
      if deathtype == "fall" then
        local prop = self.userData
        car.animate = false
        Car.fallAnimation(prop, variables)
      end
    end
  end

  car.useTurbo = function ( self )
    if car.bodyRemoved then
      car:destroyTurbo()
    end
    if not self.turbo then return end
    if not self.body.userData.turboProp then
      local md = self.body:getMass()
      self.body:setMassData ( md * 10 )
      local lastspeed = game.level.speedFactor
      local prop = util.getProp ( "gfx/fire.png", 28, 28, 0, 0 )
      prop:setParent ( car.body )
      prop:setPriority ( 4 )
      prop:setLoc ( 0, -28 )
      prop:setRot ( 180 )
      self.body.userData.turboProp = prop
      game.insertPropIntoGameLayer ( self.body.userData.turboProp )
      self.gasLeft = 200
      self.body.userData.turboProp.startFactor = lastspeed
      game.level.speedFactor = game.level.speedFactor * 2
    end
    if game.tick % 8 == 0 then
      local newprop
      if self.body.userData.turboProp.firstimage then
        self.body.userData.turboProp.firstimage = false
        newprop = "fire2"
      else
        self.body.userData.turboProp.firstimage = true
        newprop = "fire"
      end
      local flamegfx = MOAIGfxQuad2D.new ()
      flamegfx:setTexture ( util.getTexture ( 'gfx/' .. newprop .. '.png' ) )
      flamegfx:setRect ( unpack ( carRect ) )
      self.body.userData.turboProp:setDeck ( flamegfx )
    end
    if self.gasLeft <= 0 then
      self:destroyTurbo ()
    else
      self.gasLeft = self.gasLeft - 1
    end
  end

  car.destroyTurbo = function ( self )
    self.turbo = false
    if self.body then
      local md = self.body:getMass()
      self.body:setMassData ( md / 10 )
      if self.body.userData and self.body.userData.turboProp then
        game.level.speedFactor = self.body.userData.turboProp.startFactor
        game.removePropFromGameLayer ( self.body.userData.turboProp )
        self.body.userData.turboProp = nil
      end
    end
  end

  car.addTurbo  = function ( self )
    self.turbo = true
    if not self.gasLeft then
      self.gasLeft = 0
    end
    self.gasLeft = self.gasLeft + 200
  end

  car.addInvincible = function ( self )
    car.body.userData.invincible = car.body.userData.invincible or 0
    car.body.userData.invincible = car.body.userData.invincible + 400
    if not car.body.userData.props.invincible then
      local side = pr.width > pr.height and pr.width or pr.height
      local size = side - (side % 10) + 30
      local prop = util.getGrid (size, size, "gfx/inv.png", -(size/2), -(size/2), size, 2)
      car.body.userData.props.invincible = prop
      car.body.userData.props.invincible:setParent(car.body)
      game.insertPropIntoGameLayer(prop)
    end
  end

  car.removeInvincible = function ( self )
    game.removePropFromGameLayer(car.body.userData.props.invincible)
    car.body.userData.props.invincible = nil
    car.body.userData.invincible = nil
  end

  car.onUpdate = function ( level, x )
    local nope_x, y = inputmgr.getLevel ()

    y = y - ( inputmgr.getYOffset () or 0 )
    x = math.abs ( x ) > 0.1 and ( x > 0 and 1 or -1 ) or 0
    y = math.abs ( y ) > 0.1 and ( y > 0 and 1 or -1 ) or 0
    if not car.body then return end
    local carX, carY = car.body:getPosition ()
    if not carX then return end
    local newX, newY = x * car.dx, y * car.dy
    if car.turbo then
      car:useTurbo ()
    end
    newY = carY < 0 and 10 or -10

    local velx, vely = car.body:getLinearVelocity ()
    if math.floor(carY) < 4 and math.floor(carY) > -4 then
      newY = 0
      car.body:setLinearVelocity ( velx, 0 )
    end

    local impulsefactor = game.level.impulsefactor
    if car.turbo then
      impulsefactor = impulsefactor * 10
      newY = newY * 10
    end

    -- recover faster when jumping
    if car.isJumping () then
      newY = newY * 5
    end

    car.body:applyLinearImpulse ( impulsefactor * x, newY, newX, newY )

    if car.body.userData.invincible then
      if car.bodyRemoved then
        car:removeInvincible()
      else
        car.body.userData.invincible = car.body.userData.invincible - 1
        if car.body.userData.invincible == 0 then
          car:removeInvincible()
        end
      end
    end
    if game.tick % 8 == 0 then
      if car.animate then
        local newCar
        if car.body.userData.firstimage then
          newCar = carType
          car.body.userData.firstimage = false
        else
          newCar = carType ..  "2"
          car.body.userData.firstimage = true
        end
        local carGfx = MOAIGfxQuad2D.new ()
        carGfx:setTexture ( util.getTexture ( 'gfx/' .. newCar .. '.png' ) )
        carGfx:setRect ( unpack ( carRect ) )
        car.body.userData:setDeck ( carGfx )
      end
      if car.body.userData.invincible then
        car.body.userData.props.invincible:animate()
      end
    end

  end

  car.onPause = function ()
    if car.action then
      car.action:pause ()
    end
    if car.jumpSound then
      car.jumpSound:pause ()
    end
  end

  car.onResume = function ()
    if car.action then
      car.action:start ()
    end
    if car.jumpSound then
      sound.play ( car.jumpSound )
    end
  end

  return car
end
