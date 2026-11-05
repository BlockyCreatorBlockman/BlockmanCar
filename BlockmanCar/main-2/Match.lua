-- ========================================
-- File: Match.lua
-- Location: main/Match.lua  (new file, root of main/ like SandDigger)
-- Purpose: the whole game loop: WAIT -> START -> CLOSE -> WAIT ...
-- It is driven by GameMatch:onTick(), which GameTimeTask calls once per second.
-- ========================================

GameMatch = {}

-- Must match your game id / resource folder id. CHANGE if g1111 is only a placeholder.
GameMatch.gameType = "g1111"

-- Match stages
GameMatch.STAGE_WAIT  = 1   -- players are in the lobby, countdown runs when enough players
GameMatch.STAGE_START = 2   -- race is running
GameMatch.STAGE_CLOSE = 3   -- race ended, winner is shown for a few seconds

GameMatch.stage       = GameMatch.STAGE_WAIT
GameMatch.timeLeft    = 0       -- seconds left in the current stage
GameMatch.winner      = nil     -- player who reached the finish area first
GameMatch.startSent   = false   -- true after HostApi.sendStartGame was sent in this wait stage

-- Called once from GameListener.onGameInit (after the config is loaded)
function GameMatch:initMatch()
    EngineWorld:stopWorldTime()     -- freeze the day/night cycle
    GameTimeTask:start()            -- start the 1 second tick
    self:enterWait()
end

-- Called by GameTimeTask once per second
function GameMatch:onTick(ticks)
    if self.stage == self.STAGE_WAIT then
        self:tickWait()
    elseif self.stage == self.STAGE_START then
        self:tickStart()
    elseif self.stage == self.STAGE_CLOSE then
        self:tickClose()
    end
end

----------------------------------------------------------------
-- WAIT stage
----------------------------------------------------------------
function GameMatch:enterWait()
    self.stage = self.STAGE_WAIT
    self.timeLeft = GameConfig.waitTime
    self.winner = nil
    self.startSent = false
    HostApi.sendResetGame(PlayerManager:getPlayerCount())
end

function GameMatch:tickWait()
    local count = PlayerManager:getPlayerCount()

    -- Not enough players: keep the timer full and show the "waiting for players" text
    if count < GameConfig.playerMin then
        self.timeLeft = GameConfig.waitTime
        self.startSent = false
        MsgSender.sendBottomTips(2, IMessages:msgWaitPlayer())
        return
    end

    self.timeLeft = self.timeLeft - 1

    -- 12 seconds before the start, tell the platform the game is about to begin
    if self.timeLeft <= 12 and not self.startSent then
        self.startSent = true
        HostApi.sendStartGame(count)
    end

    if self.timeLeft <= 0 then
        self:startGame()
    else
        MsgSender.sendBottomTips(2, IMessages:msgWaitPlayerEnough(self.timeLeft, IMessages.UNIT_SECOND, false))
    end
end

----------------------------------------------------------------
-- START stage
----------------------------------------------------------------
function GameMatch:startGame()
    self.stage = self.STAGE_START
    self.timeLeft = GameConfig.gameTime
    self.winner = nil

    RewardManager:startGame()
    HostApi.syncGameTimeShowUi(0, true, GameConfig.gameTime)

    -- Move everybody to the race start position
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        player:teleStartPos()
    end
end

function GameMatch:tickStart()
    self.timeLeft = self.timeLeft - 1

    -- Region check: is somebody inside the finish area?
    -- We poll once per second instead of using PlayerMoveEvent, because it is not
    -- verified that the move event fires while the player is driving a vehicle.
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if GameConfig.finishArea:inArea(player:getPosition()) then
            self.winner = player
            self:closeGame()
            return
        end
    end

    -- Time is over and nobody finished
    if self.timeLeft <= 0 then
        self:closeGame()
    end
end

----------------------------------------------------------------
-- CLOSE stage
----------------------------------------------------------------
function GameMatch:closeGame()
    self.stage = self.STAGE_CLOSE
    self.timeLeft = GameConfig.closeTime
    HostApi.syncGameTimeShowUi(0, false, 0)

    -- Announce the result with the engine's built-in lang ids (no hardcoded text)
    if self.winner ~= nil then
        MsgSender.sendTopTips(5, IMessages:msgWinnerInfo(self.winner.name))
        ReportManager:reportUserWin(self.winner.userId)
    else
        MsgSender.sendTopTips(5, IMessages:msgNoWinner(IMessages.TYPE_PLAYER))
    end
end

function GameMatch:tickClose()
    self.timeLeft = self.timeLeft - 1
    if self.timeLeft <= 0 then
        self:resetGame()
    end
end

-- Back to the lobby and start waiting again
function GameMatch:resetGame()
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        player:reset()
        player:teleInitPos()
    end
    self:enterWait()
end

----------------------------------------------------------------
-- Player events
----------------------------------------------------------------
-- Called from PlayerListener.onPlayerLogout (the player is already removed from PlayerManager)
function GameMatch:onPlayerQuit(player)
    HostApi.sendResetGame(PlayerManager:getPlayerCount())

    -- Everybody left: drop back to a clean waiting stage
    if PlayerManager:getPlayerCount() == 0 and self.stage ~= self.STAGE_WAIT then
        HostApi.syncGameTimeShowUi(0, false, 0)
        self:enterWait()
    end
end
