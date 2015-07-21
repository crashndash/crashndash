local level = Level.new ()

level.jumpHeight = 6
level.jumpDuration = 4.5

level.minOffset = 40
level.maxOffset = 80

level.enemyLimit = 20

level.length = 60

level.obstacleFreq = 14

level.availablePowerUps = {"bomb", "jumps_pu", "nitro"}
level.powerFreq = 9
level.jumpCount = 1

level.tagline = "Some really really long jumps"

level:addPowerUp ( 5, "jumps_pu" )
level:addPowerUp ( 10, "jumps_pu" )
level:addPowerUp ( 14, "jumps_pu" )

level:addBlock ( 15, 1000, "gfx/firesprite.png", true, 2 )

level:addPowerUp ( 34, "nitro" )

level:addBlock ( 35, 1600, "gfx/water.png", true, 2 )

level.topScore = 15000

return level
