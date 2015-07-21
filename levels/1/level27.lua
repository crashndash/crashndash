local level = Level.new ()
level.minOffset = 10
level.maxOffset = 20

level.enemyLimit = 20

level.length = 60

level.obstacleFreq = 15

level.availablePowerUps = { "bomb", "jumps_pu" }
level.powerFreq = 9
level.jumpCount = 20

level.tagline = "Heavy turns"

level:addPredefObstacle ( 2, "grass", 300, 300, -70 )
level:addPredefObstacle ( 5, "grass", 300, 300, 70 )
level:addPredefObstacle ( 7, "brown", 150, 600, 100 )
level:addPredefObstacle ( 7, "brown", 150, 600, -100 )
level:addPredefObstacle ( 10, "brown", 550, 200, 0 )
level:addPredefObstacle ( 10, "brown", 300, 600, 100 )
level:addPredefObstacle ( 10, "brown", 150, 600, -200 )
level:addPredefObstacle ( 14, "bricks", 350, 600, -100 )

level:addPredefObstacle ( 18, "grass", 300, 900, 100 )
level:addPredefObstacle ( 18, "grass", 150, 900, -200 )

level:addBlock ( 25, 150 )
level:addPredefObstacle ( 23, "grass", 300, 900, 200 )
level:addPredefObstacle ( 23, "grass", 300, 900, -200 )

level:addPredefObstacle ( 34, "bricks", 350, 600, -100 )
level:addPredefObstacle ( 36, "bricks", 350, 600, 100 )
level:addPredefObstacle ( 38, "bricks", 350, 600, -100 )
level:addPredefObstacle ( 40, "bricks", 350, 600, 100 )

level:addSwarm ( 45, 6, "fatcar" )
level:addSwarm ( 48, 6, "fatcar" )

level.topScore = 17000

return level
