local level = Level.new ()
level:addBlock ( 8, 100, "gfx/bricks.png" )
level.length = 50
level.enemyLimit = 2
level.jumpCount = 10
level:addPowerUp ( 20, "bomb" )


local stops = {10, 26, 40}
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

level:alterOffset ( 36, 150, 20 )

level:addPowerUp ( 46, "nitro" )


level.tagline = "Some more action... \nWonder what that bomb does?"

level.topScore = 11000

return level
