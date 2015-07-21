local level = Level.new ()
level:addBlock ( 14, 200, "gfx/firesprite.png", true, 2 )
level:addBlock ( 28, 250, "gfx/water.png", true, 2 )
level:addBlock ( 36 )
level.length = 40
level.enemyLimit = 4

level.tagline = "Some really big jumps!"

level.topScore = 8100

return level
