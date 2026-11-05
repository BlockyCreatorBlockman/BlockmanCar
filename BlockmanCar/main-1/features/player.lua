-- ========================================
-- File: player.lua
-- Created: 2026-11-04 19:38
-- Author: Saurav
-- ========================================

player = class("GamePlayer", BasePlayer)

function player:init()
    self.score = 0
    self:reset()
end

function player:reset(pos)
    self.score = 0
    self:setHealth(20)
    self:setFoodLevel(20)
    self.scorePoints[ScoreID.POINT] = 0
    if pos then
        HostApi.resetPos(self.rakssid, unpack(pos))
    end
    ReportManager:reportUserEnter(self.userId)
end

function player:score()
    return self.score
end

function player:reset(pos)
    self._score = 0
    self._score_ts = 0
    self._target = 1
    self._rpos = nil
    self._immune = false
    self._is_reward = false
    self:setHealth(20)
    self:setFoodLevel(20)
    self.scorePoints[ScoreID.POINT] = 0
    if pos then
        HostApi.resetPos(self.rakssid, unpack(pos))
    end
    ReportManager:reportUserEnter(self.userId)
end

return player