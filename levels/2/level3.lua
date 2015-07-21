local level = Level.new ()

level.tagline = "The desert is getting hotter..."

level.availableObstacles = {
  "rock"
}

level.enemyVariations = {
    "bus",
    "fatcar",
    "police"
  }

level.obstacleFreq = 6
level:addBlock(10, 100, "gfx/rock.png")
level:addBlock(40, 100, "gfx/rock.png")

level.enemyLimit = 2
level.length = 50

level.topScore = 9250

return level
