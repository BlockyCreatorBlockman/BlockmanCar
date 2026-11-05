-- ========================================

-- ========================================
require "config.Area"

GameConfig = {}

GameConfig.initPos    = nil   -- pos JUST after enitering
GameConfig.startPos   = nil   -- racing starts (no waiting time)
GameConfig.finishArea = nil   -- region
GameConfig.playerMin  = 1
GameConfig.waitTime   = 30
GameConfig.gameTime   = 300
GameConfig.closeTime  = 10

-- from config.yml
function GameConfig:init(config)
    self.initPos  = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
    self.startPos = VectorUtil.newVector3i(config.startPos[1], config.startPos[2], config.startPos[3])

    -- finishArea 
    self.finishArea = Area.new(config.finishArea)

    self.playerMin = tonumber(config.playerMin)
    self.waitTime  = tonumber(config.waitTime)
    self.gameTime  = tonumber(config.gameTime)
    self.closeTime = tonumber(config.closeTime or 10)  -- totally optional, be default 10 seconsd
end

return GameConfig
