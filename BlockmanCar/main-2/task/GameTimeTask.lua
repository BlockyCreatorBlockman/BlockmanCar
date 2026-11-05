-- ========================================
-- File: GameTimeTask.lua
-- Location: main/task/GameTimeTask.lua  (new file, same as SandDigger)
-- Purpose: engine timer that calls GameMatch:onTick() once per second.
-- It only starts running after GameTimeTask:start() is called in GameMatch:initMatch().
-- ========================================

local CGameTimeTask = class("GameTimeTask", ITask)

function CGameTimeTask:onTick(ticks)
    GameMatch:onTick(ticks)
end

GameTimeTask = CGameTimeTask.new(1)

return GameTimeTask
