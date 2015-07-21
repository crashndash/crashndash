local level = Level.new ()
level.minOffset = 10
level.maxOffset = 100

level.enemyLimit = 20

level.length = 80

level.tagline = "Even more obstacles!"

level:addPredefObstacle ( 5, "bricks", 100, 100 )
level:addPredefObstacle ( 30, "bricks", 600, 100 )
level:addPredefObstacle ( 9, "bricks", 50, 200 )
level:addPredefObstacle ( 18, "bricks", 200, 50 )

level:addPredefObstacle ( 2, "grass", 100, 400, -SCREEN_UNITS_X / 4 )

level:addPredefObstacle ( 2, "grass", 100, 400, SCREEN_UNITS_X / 4 )

level.obstacleFreq = 15

level.topScore = 10000

return level
