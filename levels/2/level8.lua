local level = Level.new ()

level.length = 120
level.tagline = "Just you and the long-distance desert buses"

level.enemyVariations = {"bus"}
level.availableObstacles = {"wheel", "rock"}
level.obstacleFreq = 12
level.enemyLimit = 20
level.maxOffset = 60
level.minOffset = 50

level.topScore = 18990

return level
