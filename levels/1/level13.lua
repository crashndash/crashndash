local level = Level.new ()
level.minOffset = 60
level.maxOffset = 90

level:addSwarm ( 5, 6, "police" )
level:addSwarm ( 6, 6, "police" )
level:addSwarm ( 7, 6, "police" )
level:addSwarm ( 8, 6, "police" )
level:addPowerUp ( 7, "bomb" )
level:addSwarm ( 10, 6, "police" )
level:addSwarm ( 12, 6, "police" )
level:addBlock ( 15 )

level:addSwarm ( 17, 6, "police" )
level:addSwarm ( 20, 6, "police" )

level:addBlock ( 25 )

level.enemyVariations = { "police" }

level.length = 40

level.tagline = "The police are after you!"

level.topScore = 11150

return level
