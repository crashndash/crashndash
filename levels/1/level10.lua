local level = Level.new ()
level:addBlock ( 18, 150, "gfx/water.png", true, 2 )
level.length = 22
level.enemyLimit = 3
level.hasBoss = true

level.tagline = "Watch out for the boss!"

level.topScore = 11000

return level
