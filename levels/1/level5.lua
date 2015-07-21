local level = Level.new ()
level:addBlock ( 4, 100, "gfx/bricks.png" )
level:addBlock ( 8, 150, "gfx/water.png", true, 2 )
level:addBlock ( 16 )
level:addBlock ( 36 )
level.length = 40
level.enemyLimit = 3
level.jumpCount = 4

level.tagline = "Save your jumps!"

level.topScore = 1200

return level
