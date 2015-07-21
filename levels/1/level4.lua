local level = Level.new ()
level:addBlock ( 4, 100, "gfx/bricks.png" )
level:addBlock ( 30, 150, "gfx/water.png", true, 2 )
level:addBlock ( 80 )
level.length = 100
level.enemyLimit = 3

level.tagline = "A long one"

local stops = {10, 36, 50, 70, 90}
for i, a in ipairs ( stops ) do
  level:addPowerUp ( a, "bomb" )
  level:addPowerUp ( a - 1, "bomb" )
  local variations = {
    "fatcar",
    "bwcar",
    "skinnycar",
    "stripecar",
    "bus",
    "wagon",
    "police"
  }
  local random  = math.random(#variations)
  local type = variations[random]
  level:addSwarm ( a, 3, type )
end

level:addPowerUp ( 26, "nitro" )

level.topScore = 11000

return level
