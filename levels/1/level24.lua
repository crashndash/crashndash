local level = Level.new ()
level.minOffset = 10
level.maxOffset = 60

level.enemyLimit = 20

level.length = 60

level.obstacleFreq = 15

level.availablePowerUps = {"bomb", "jumps_pu", "nitro"}
level.powerFreq = 9
level.jumpCount = 20

level.tagline = "A bumpy road"

level:addPredefObstacle ( 2, "hole" )
level:addPredefObstacle ( 5, "hole" )
level:addPredefObstacle ( 7, "hole" )
level:addPredefObstacle ( 9, "hole" )
level:addPredefObstacle ( 11, "hole" )
level:addPredefObstacle ( 12, "hole" )
level:addPredefObstacle ( 16, "hole" )
level:addPredefObstacle ( 20, "hole" )

level:addPredefObstacle ( 32, "hole" )
level:addPredefObstacle ( 45, "hole" )
level:addPredefObstacle ( 37, "hole" )
level:addPredefObstacle ( 39, "hole" )
level:addPredefObstacle ( 51, "hole" )
level:addPredefObstacle ( 52, "hole" )
level:addPredefObstacle ( 56, "hole" )
level:addPredefObstacle ( 60, "hole" )

level:addSwarm ( 25, 6, "bus" )
level:addSwarm ( 48, 6, "bus" )

level.topScore = 20000

return level
