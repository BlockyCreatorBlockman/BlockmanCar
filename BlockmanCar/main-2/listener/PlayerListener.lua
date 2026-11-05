-- ========================================
-- File: PlayerListener.lua
-- Location: main/listener/PlayerListener.lua  (new file)
-- Purpose: player login / ready / logout / damage events.
-- ========================================
require "data.GamePlayer"

PlayerListener = {}

function PlayerListener:init()
    BaseListener.registerCallBack(PlayerLoginEvent, self.onPlayerLogin) -- ordres don't matter in lua (I mean we can clal a function before even definiing it)
    BaseListener.registerCallBack(PlayerLogoutEvent, self.onPlayerLogout)
    BaseListener.registerCallBack(PlayerReadyEvent, self.onPlayerReady)
    BaseListener.registerCallBack(PlayerAttackedEvent, self.onPlayerHurt)
end

-- A player tries to join
function PlayerListener.onPlayerLogin(clientPeer)
    -- Only allow joining in the lobby. The engine shows the "game already started" message.
    if GameMatch.stage ~= GameMatch.STAGE_WAIT then
        return GameOverCode.GameStarted
    end

    local player = GamePlayer.new(clientPeer)
    player:init()
    return GameOverCode.Success, player, 1
end

-- A player left (already removed from PlayerManager when this runs)
function PlayerListener.onPlayerLogout(player)
    GameMatch:onPlayerQuit(player)
end

-- The player's client finished loading
function PlayerListener.onPlayerReady(player)
    -- return nothing: no night vision effect
end

-- No damage in the lobby or during the race
function PlayerListener.onPlayerHurt(hurtPlayer, hurtFrom, damageType, hurtValue)
    return false
end

return PlayerListener
