local level = Level.new ()

level.tagline = "A new world, and some new cars"

level.availableObstacles = {
  "rock"
}

level.obstacleFreq = 19
level:addBlock(10, 100, "gfx/rock.png")
level.enemyVariations = {
  "sandy",
  "racertaxi",
  "bombcar"
}

level.enemyLimit = 2
level.length = 40

level.topScore = 11000
level.powerFreq = 8

return level
