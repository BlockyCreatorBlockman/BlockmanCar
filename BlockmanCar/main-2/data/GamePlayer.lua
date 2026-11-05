GamePlayer = class("GamePlayer", BasePlayer)

function GamePlayer:init()
    self:initStaticAttr(0)
    self:reset()
end

-- Put the player back to a clean state (used on login and after every match)
function GamePlayer:reset()
    self:setHealth(20)
    self:setFoodLevel(20)
end

-- teleportthe player to inital pos (or waiting to be more spedific)
function GamePlayer:teleInitPos()
    self:teleportPos(GameConfig.initPos)
end

-- race starst
function GamePlayer:teleStartPos()
    self:teleportPos(GameConfig.startPos)
end

return GamePlayer
