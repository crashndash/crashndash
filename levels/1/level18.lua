local level = Level.new ()
level.minOffset = 10
level.maxOffset = 20

level.enemyLimit = 20

level.length = 80

level.tagline = "Bouncy walls + swarms equals trouble"

level:addPredefObstacle ( 12, "water", 250, 800, -70 )

level:addPredefObstacle ( 22, "grass", 300 , 600, -SCREEN_UNITS_X / 4 )

level:addPredefObstacle ( 28, "brown", 100, 600, 100 )

level:addPredefObstacle ( 28, "brown", 100, 600, -100 / 2 )

level:addPredefObstacle ( 30, "brown", 500, 800, 250 )

level:addSwarm ( 36, 5, "fatcar" )
level:addSwarm ( 37, 5, "bwcar" )
level:addSwarm ( 39, 3, "superboss" )
level:addSwarm ( 59, 3, "superboss" )
level:addPowerUp ( 37, "bomb" )
level:addPowerUp ( 59, "bomb" )
level:addSwarm ( 40, 5, "skinnycar" )
level:addPowerUp ( 39, "bomb" )

level:addSwarm ( 46, 5, "bus" )
level:addSwarm ( 50, 5, "police" )

level:addBlock ( 42, 250 )

level:addBlock ( 48, 250 )

level:addBlock ( 68, 150, "gfx/water.png", true, 2 )
level:addBlock ( 70, 250, "gfx/water.png", true, 2 )

level.obstacleFreq = 15

level.topScore = 16500

return level
