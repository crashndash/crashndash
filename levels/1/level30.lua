local level = Level.new ()
level:addBlock ( 8, 100, "gfx/bricks.png" )
level:addBlock ( 8, 150, "gfx/water.png", true, 2 )
level:addBlock ( 45 )
level:addBlock ( 48 )
level.length = 100
level.enemyLimit = 20
level.jumpCount = 10
level.enemyVariations = { "ufo", "fascist", "superboss" }
level.availablePowerUps = { "bomb", "nitro" }
level.powerFreq = 10

level.tagline = "You against the bosses"

level.topScore = 40000

return level
