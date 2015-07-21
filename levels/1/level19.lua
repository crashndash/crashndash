local level = Level.new ()
level.minOffset = 10
level.maxOffset = 60

level.enemyLimit = 20

level.length = 80

level.tagline = "It's winter... and slippery"

level:addSwarm ( 36, 4, "fatcar" )
level:addSwarm ( 37, 5, "bwcar" )
level:addSwarm ( 40, 3, "superboss" )
level:addSwarm ( 59, 3, "superboss" )
level:addPowerUp ( 37, "bomb" )
level:addPowerUp ( 59, "bomb" )
level:addSwarm ( 40, 5, "skinnycar" )
level:addPowerUp ( 39, "bomb" )
level:addSwarm ( 44, 5, "stripecar" )

level.theme = "winter"
level.impulsefactor = 30
level.carWeight = 2

level:addSwarm ( 46, 4, "bus" )
level:addSwarm ( 50, 5, "police" )

level:addBlock ( 22, 250 )

level:addBlock ( 42, 250 )

level:addBlock ( 48, 250 )

level:addBlock ( 68, 150, "gfx/water.png", true, 2 )
level:addBlock ( 70, 250, "gfx/water.png", true, 2 )

level.obstacleFreq = 15

level.topScore = 12000

return level
