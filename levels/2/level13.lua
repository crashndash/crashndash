local level = Level.new ()

level.length = 100
level.tagline = "Zombies!!!"

level.availableObstacles = {"zombie"}
level.obstacleFreq = 2
level.enemyLimit = 1
level:addPredefObstacle ( 3, "zombie", 40, 40, -100)
level:addPredefObstacle ( 3, "zombie", 40, 40, -70 )
level:addPredefObstacle ( 3, "zombie", 40, 40, 100 )
level:addPredefObstacle ( 3, "zombie", 40, 40, 170 )
level.maxOffset = 60
level.minOffset = 50

level.topScore = 20440

level.availablePowerUps = { "invincible" }
level.powerFreq = 5

return level
