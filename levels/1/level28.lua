local level = Level.new ()
level.minOffset = 70
level.maxOffset = 120

level.length = 300
level.speedFactor = 2

level.enemyLimit = 10

level.tagline = "Faster, faster!"
level.availablePowerUps = { "nitro", "bomb", "jumps_pu" }
level.powerFreq = 5

level:addPredefObstacle ( 11, "hole" )
level:addPredefObstacle ( 28, "hole" )
level:addPredefObstacle ( 156, "hole" )
level:addPredefObstacle ( 120, "hole" )

level:addBlock ( 110 )
level:addBlock ( 10 )
level:addBlock ( 180 )

level:addSwarm ( 90, "bus", 6 )
level:addSwarm ( 190, "fatcar", 6 )
level:addSwarm ( 220, "police", 10 )

level.topScore = 30000

return level
