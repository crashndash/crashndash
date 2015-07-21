local level = Level.new ()
level:addBlock ( 18, 100, "gfx/water.png", true, 2 )
level:addBlock ( 30, 50, "gfx/water.png", true, 2 )
level.enemyLimit = 2
level.spawnFrequency = 200
level.length = 40

level.tagline = "Still pretty easy"

level.topScore = 9000

return level
