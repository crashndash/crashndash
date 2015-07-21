module ("Powerup", package.seeall )

local rect = {
  -14, -14, 14, 14
}

local explodeAll = function (  )
  game.level:explodeAll ()
end

local addSwarm = function (  )
  multiplayer.sendMessage ( "swarm", multiplayer.room )
  table.insert( game.level.popups, Popup.new ( "You just sent a swarm of cars to your opponents" ) )
end

local startTurbo = function (  )
  local car = game.getCar ()
  car:addTurbo ()
end

local addJumps = function (  )
  game.level.jumpCount = game.level.jumpCount + 3
end

local spawnHole = function (  )
  multiplayer.sendMessage ( "rocket", multiplayer.room )
  table.insert( game.level.popups, Popup.new ( "You just blew a hole in your opponents' road" ) )
end

local startRamboMode = function ( )
  local car = game.getCar ()
  car:addInvincible ()
end

powerups = {
  bomb = explodeAll,
  swarm = addSwarm,
  nitro = startTurbo,
  jumps_pu = addJumps,
  rocket = spawnHole,
  invincible = startRamboMode,
}
infotext = {
  bomb = "The bomb will kill all enemies on the screen.",
  swarm = "The thundercloud will spawn a swarm on the screen of all your opponents when playing multiplayer.",
  nitro = "The star will give you a temporary boost of nitro, making your car go fast!",
  jumps_pu = "Use this to collect more jumps on the level you are playing.",
  rocket = "The rocket will make a hole in the road for all your opponents when playing multiplayer",
  invincible = "This thing will make you invincible to other cars and zombies"
}

local hasSound = function ( type )
  nosound = {
    bomb = true
  }
  return not nosound[type]
end

function new ( world )
  local factory = {}

  factory.spawn = function ( world, type )
    local powerup = {}

    local width = 28
    local height = 28
    powerup.part = world:addBody ( MOAIBox2DBody.KINEMATIC )
    if not powerup.part then return nil end

    powerup.props = {}
    powerup.part:setLinearVelocity ( 0, -speed.getSpeed () )
    local maxX = (SCREEN_UNITS_X / 2) - game.level.maxOffset
    local xpos = math.random ( -maxX, maxX )

    local prop = util.getProp ( "gfx/" .. type .. ".png", width, height, nil, nil )
    local glowprop = util.getProp ( "gfx/glow.png", width + 15, height + 15 )

    prop:setParent ( powerup.part )
    glowprop:setParent ( powerup.part )
    powerup.part:setTransform ( xpos, SCREEN_UNITS_Y/2 + 30 )
    powerup.part.userData = prop
    powerup.part.userData.glow = glowprop
    powerup.speed = -speed.getSpeed ()
    if hasSound ( type ) then
      powerup.sound = true
      powerup.playSound = function (  )
        sound.play ( util.getSound ( "sound/powerup.ogg" ) )
      end
    end

    powerup.type = type
    powerup.powerFunction = powerups[type]

    powerup.onUpdate = function ( self )
      if not self.part then return end
      if self.speed ~= -speed.getSpeed () then
        self.speed = -speed.getSpeed ()
        self.part:setLinearVelocity ( 0, -speed.getSpeed () )
      end
      if not self.added then
        -- The first update function, the location is set to 0, 0 (no idea why)
        self.added = true
        return
      end
      local car = game.getCar ()
      local carX, carY = car.body:getWorldLoc ()
      local propx, propy = self.part:getWorldLoc ()
      local xdiff = carX - propx
      local ydiff = carY - propy
      local within = 14
      -- Wonder why the :inside function does not work here.
      if (ydiff < within and ydiff > -within) and (xdiff > -within and xdiff < within) and not self.exploded and not car.isJumping () then
        self.exploded = true
        if self.sound then
          self.playSound ()
        end
        self.powerFunction ()
        game.level.destroyPowerUp ( self )
      end
      if propx < -SCREEN_UNITS_Y then
        game.level.destroyPowerUp ( self )
      end
    end

    powerup.destroy = function ( self )
      game.removePropFromGameLayer ( self.part.userData )
      game.removePropFromGameLayer ( self.part.userData.glow )
      self.part:destroy ()
    end

    return powerup

  end

  return factory
end
