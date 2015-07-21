local level = Level.new ()
level.minOffset = 5
level.maxOffset = 20

level:addSwarm ( 5, 6, "fatcar" )

level:addSwarm ( 15, 6, "skinnycar" )

level:addSwarm ( 25, 6, "police" )

level.length = 50

level.tagline = "There will be swarms!"

level.topScore = 13000

return level
