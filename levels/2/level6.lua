local level = Level.new ()

level.length = 40
level.tagline = "Transporting sand in the desert"

level.availableObstacles = {"zombie"}
level.obstacleFreq = 10
level.enemyLimit = 20
level.maxOffset = 40
level.minOffset = 10
level.enemyVariations = {
  "sandy"
}
level.spawnFrequency = 30

level.topScore = 14000

return level
