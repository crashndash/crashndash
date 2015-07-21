local level = Level.new ()
level.minOffset = 60
level.maxOffset = 110

level.enemyLimit = 0

level.length = 40

level.tagline = "Stars give you a nitro boost for extra speed."

level.theme = "winter"
level.impulsefactor = 30

--level.powerFreq = 1
level:addPowerUp ( 9, "nitro" )
level:addPowerUp ( 9, "nitro" )
level:addPowerUp ( 9, "nitro" )
level:addPowerUp ( 9, "nitro" )
level:addBlock ( 10, 600 )
level:addPowerUp ( 19, "nitro" )
level:addBlock ( 20, 600 )
level:addPowerUp ( 24, "nitro" )
level:addBlock ( 25, 600 )
level:addPowerUp ( 30, "bomb" )
level:addSwarm ( 31, 6, "stripecar" )
level:addPowerUp ( 36, "nitro" )
level:addSwarm ( 37, 6, "police" )

level.topScore = 7800

return level
