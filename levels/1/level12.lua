local level = Level.new ()
level.minOffset = 5
level.maxOffset = 90

level:addSwarm ( 5, 4, "fatcar" )
level:addPowerUp ( 6, "bomb" )
level:addSwarm ( 18, 5, "wagon" )
level:addPowerUp ( 19, "bomb" )
level:addSwarm ( 31, 5, "bwcar" )
level:addPowerUp ( 32, "bomb" )
level.length = 40

level.tagline = "Bombs will explode all enemies!"

level.topScore = 14000

return level
