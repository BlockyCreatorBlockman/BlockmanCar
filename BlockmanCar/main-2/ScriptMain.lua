-- ========================================
-- File: ScriptMain.lua
-- Location: main/ScriptMain.lua  (replaces your current ScriptMain.lua)
-- Purpose: entry point. Only requires files and registers listeners.
-- ========================================

-- This means that the lua can find .lua files if not found from the top root folder
package.path = package.path ..';..\\?.lua'

-- Order matters: Match defines the global GameMatch that the other files use
require "Match"
require "task.GameTimeTask"
require "config.GameConfig"
require "listener.GameListener"
require "listener.PlayerListener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("ScriptMain.init")

    -- Register all engine events (nothing runs until the engine fires them)
    GameListener:init()
    PlayerListener:init()

    -- Temporarily I have set the gameType as g1111, I don't know what is even the purpose of gameType or gameID
    BaseMain:setGameType(GameMatch.gameType)

    -- Hunger Bar is disable (why would we need a hunger bar in a car game??)
    HostApi.setNeedFoodStats(false)
end

ScriptMain:init()
