module ( "savefiles", package.seeall )

local DEVICE = true
if MOAIInputMgr.device.pointer then
  -- If we have a mouse, device = false?
  DEVICE = false
end

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------
local saveFiles = {}

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------
function get ( filename )

  if not saveFiles [ filename ] then
    saveFiles [ filename ] = makeSaveFile ( filename )
    saveFiles [ filename ]:loadGame ()
  end

  return saveFiles [ filename ]
end

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------
function makeSaveFile ( filename )

  local savefile = {}

  savefile.filename = filename
  savefile.fileexist = false
  savefile.data = nil

  ----------------------------------------------------------------
  savefile.loadGame = function ( self )

    local fullFileName = self.filename .. ".lua"
    local workingDir

    if DEVICE then
      workingDir = MOAIFileSystem.getWorkingDirectory ()
      MOAIFileSystem.setWorkingDirectory ( MOAIEnvironment.documentDirectory )
    end

    if MOAIFileSystem.checkFileExists ( fullFileName ) then
      local file = io.open ( fullFileName, 'rb' )
      savefile.data = dofile ( fullFileName )
      self.fileexist = true
    else
      savefile.data = {}
      self.fileexist = false
    end

    if DEVICE then
      MOAIFileSystem.setWorkingDirectory ( workingDir )
    end

    return self.fileexist
  end

  ----------------------------------------------------------------
  savefile.saveGame = function ( self )

    local fullFileName = self.filename .. ".lua"
    local workingDir
    local serializer = MOAISerializer.new ()

    self.fileexist = true
    local gamestateStr = serializer.serializeToString (self.data)

    if not DEVICE then
      local file = io.open ( fullFileName, 'wb' )
      file:write ( gamestateStr )
      file:close ()

    else
      workingDir = MOAIFileSystem.getWorkingDirectory ()
      MOAIFileSystem.setWorkingDirectory ( MOAIEnvironment.documentDirectory )

      local file = io.open ( fullFileName, 'wb' )
      file:write ( gamestateStr )
      file:close ()
      MOAIFileSystem.setWorkingDirectory ( workingDir )
    end
  end

  savefile.init = function ( self )
    self.data.config.worldScores = self.data.config.worldScores or {}
    for i in next, Level.levels, nil do
      self.data.config.worldScores[i] = self.data.config.worldScores[i] or {}
    end
    self.data.config.retries = self.data.config.retries or 0
    self.data.config.expBought = self.data.config.expBought or {}
    self.data.config.obstacleKills = self.data.config.obstacleKills or {}
    self.data.config.achievements = self.data.config.achievements or {}
    self.data.config.expPoints = self.data.config.expPoints or 0
    self.data.config.rewards = self.data.config.rewards or {}
    self.data.config.doneWorlds = self.data.config.doneWorlds or {}
    config.data.config.highScore = config.data.config.highScore or 0
    self.data.config.campaigns = self.data.config.campaigns or {}
    for i in next, Level.levels, nil do
      self.data.config.doneWorlds[i] = self.data.config.doneWorlds[i] or {}
    end
    self.data.config.maxLevels = self.data.config.maxLevels or {}
    if self.data.config.maxLevel then
      -- Upgrade path for old config.
      self.data.config.maxLevels = {
        self.data.config.maxLevel
      }
      self.data.config.maxLevel = nil
    end
    if self.data.config.doneLevels then
      -- Upgrade path for stars.
      self.data.config.doneWorlds[1] = self.data.config.doneLevels
      self.data.config.doneLevels = nil
    end
    if self.data.config.scores then
      -- Upgrade path for storing scores.
      self.data.config.worldScores[1] = self.data.config.scores
      self.data.config.scores = nil
    end
    if self.data.config.fb and not self.data.config.fbid then
      self.data.config.fbid = self.data.config.id
    end
    -- Keep a count on how many times people play the game.
    self.data.config.gameStarts = self.data.config.gameStarts or 0
    self.data.config.gameStarts = self.data.config.gameStarts + 1
    -- Try to find out how long people are actually playing.
    self.data.config.playDuration = self.data.config.playDuration or 0
    -- Upgrade path for people that actually bought world 2.
    if self.data.config.achievements.unlockworld2 == true then
      self.data.config.achievements.unlockworld2 = 1
    end

    -- Upgrade path for those that have played the game and gotten saved wrong
    -- top scores per level.
    if self.data.config.worldScores[1] and self.data.config.worldScores[1][2] and not self.data.config.worldScores[1][1] then
      for i, world in next, self.data.config.worldScores, nil do
        -- Do not migrate "special" levels.
        if (type(i) == "number") then
          for level, score in next, self.data.config.worldScores[i], nil do
            local topScores = {
              {
                9300,
                9000,
                11000,
                11000,
                1200,
                8100,
                13000,
                12000,
                11000,
                11000,
                13000,
                14000,
                11150,
                37000,
                38000,
                10700,
                10000,
                16500,
                12000,
                12650,
                7800,
                9000,
                10000,
                20000,
                15000,
                17000,
                17000,
                30000,
                14000,
                40000,
              },
              {
                11000,
                11000,
                9250,
                14640,
                12310,
                14000,
                13800,
                18990,
                9800,
                12620,
                7440,
                2000,
                20440,
                43310,
                3000,
              }
            }
            local realLevel = level - 1
            self.data.config.worldScores[i][realLevel] = score
            self.data.config.worldScores[i][level] = nil
            -- Also try to migrate star counts. Could even change a star.
            local threeStars = topScores[i][realLevel]
            local percent = (score / threeStars) * 100
            local stars = 1
            if percent >= 100 then
              stars = 3
            else
              if percent > 66 then
                stars = 2
              end
            end

            self.data.config.doneWorlds[i][realLevel] = stars
            self.data.config.doneWorlds[i][level] = nil
          end
        end
      end
    end

    -- Messages to send at will.
    self.data.config.messages = self.data.config.messages or {}
    if MOAIAppAndroid then MOAIApp = MOAIAppAndroid end
    if MOAIApp then
      -- Interesting to know what OS this person is running.
      if MOAIAppAndroid then
        self.data.config.os = "android"
      end
      if MOAIAppIOS then
        self.data.config.os = "ios"
      end
    end
    if self.data.config.name and string.len(self.data.config.name) > 25 then
      -- We are a mean couple of bastards. Cutting off people's names?
      self.data.config.name = string.sub(self.data.config.name, 0, 25)
    end
    self:saveGame()
  end

  return savefile
end
