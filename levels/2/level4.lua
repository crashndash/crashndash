local level = Level.new ()

level.length = 50
level.tagline = "Is that balloons in the desert?"

level:addPredefObstacle( 5, "brown", 40, 40 )

level:addPredefObstacle( 15, "brown", 30, 30 )

level:addPredefObstacle( 19, "brown", 30, 30 )

level:addPredefObstacle( 22, "brown", 90, 90 )
level:addPredefObstacle( 24, "brown", 90, 90 )

level:addSwarm(30, 5, "minitanks")
level:addSwarm(40, 5, "minitanks")

level.topScore = 14640

return level
