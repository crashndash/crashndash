local level = Level.new ()
level.minOffset = 70
level.maxOffset = 90

level.tagline = "Try to collect more jumps to complete the level."

level:addPowerUp ( 10, "jumps_pu" )
level:addPowerUp ( 20, "jumps_pu" )
level:addPowerUp ( 32, "jumps_pu" )
level:addPowerUp ( 40, "nitro" )

level:addPowerUp ( 48, "nitro" )

level:addPowerUp ( 69, "bomb" )

level:addSwarm ( 65, 5, "police" )
level:addSwarm ( 68, 10, "police" )

level:addBlock ( 30, 100, "gfx/bricks.png" )
level:addBlock ( 35, 100, "gfx/bricks.png" )
level:addBlock ( 38, 150, "gfx/bricks.png" )
level:addBlock ( 41, 150, "gfx/bricks.png" )
level:addBlock ( 43, 150, "gfx/bricks.png" )

level:addBlock ( 63, 150, "gfx/bricks.png" )
level:addBlock ( 83, 150, "gfx/bricks.png" )

level.jumpCount = 1

level.topScore = 9000

return level
