-- ========================================
-- File: match.lua
-- Created: 2026-11-04 19:12
-- Author: Saurav
-- ========================================


require "config.define"
require "feature.player"

local Match = {}

function Match:init()
    EngineWorld:stopWorldTime()
    self.stage = define.MATCH_NONE
end

function Match:wait()
    assert(self.stage == define.MATCH_NONE)
    self.stage = define.MATCH_WAIT
    HostApi.sendResetGame(self:player_count())
    HostApi.log("Match logic has worked")

    local tick = 0
    local prestartPlayerCount = 0
    self._game_timer = timer:register(1, function()
        tick = tick + 1
        if tick >= config.waitTime - 12 and prestartPlayerCount == 0 and self:player_count() >= config.playerMin then
            prestartPlayerCount = self:player_count()
            HostApi.sendStartGame(prestartPlayerCount)
        end
        if tick >= config.waitTime then
            if self:player_count() >= config.playerMin then
                self:start()
                return 0
            else
                tick = 0
                prestartPlayerCount = 0
                HostApi.sendResetGame(self:player_count())
                return 1
            end
        else
            MsgSender.sendBottomTips(2, IMessages:msgWaitPlayerEnough(config.waitTime - tick, IMessages.UNIT_SECOND, false))
            return 1
        end
    end)
end

function Match:start()
    assert(self_stage == define.MATCH_READY)
    self.stage = define.MATCH_START
    RewardManager:startGame()
    HostApi.syncGameTimeShowUi(0, true, config.gameTime)

    self._game_timer = timer:register(config.gameTime, function()
        self:close()
        return 0
    end)
end 

function Match:close()
    assert(self.stage == define.MATCH_START)
    self.stage = define.MATCH_CLOSE

    local players = self:sort_players()

    do
        local func = function()
            do
                local function newSettlementItem(player, win)
                    local adSwitch_result = player.adSwitch or 0
                    if player.gold <= 0 then
                        adSwitch_result = 0
                    end
                    
                    return {
                        name = player.name,
                        rank = rank,
                        points = player.scorePoints,
                        gold = player.gold,
                        available = player.available,
                        hasGet = player.hasGet,
                        vip = player.vip,
                        kills = player:get_score(),
                        isWin = win and 1 or 0,
                        adSwitch = adSwitch_result,
                    }
                end

                local players = self:sort_players()
                local statistic = {}
                for rank, player in ipairs(players) do
                    if rank == 1 then
                        ReportManager:reportUserWin(player.userId)
                    end
                    table.insert(statistic, newSettlementItem(player, rank, rank == 1))
                end

                for rank, player in ipairs(players) do
                    local result = {
                        players = statistic,
                        own = statistic[rank]
                    }
                    --HostApi.sendGameSettlement(player.rakssid, json.encode(result), false)
                end
            end

            do
                HostApi.syncGameTimeShowUi(0, false, 0)
                reset(self)
                local players = PlayerManager:getPlayers()
                for _, player in pairs(players) do
                    player:reset(config.initPos)
                end
                self:wait()
            end

        end

        for rank, player in ipairs(players) do
            player:reward(rank, func)
        end
    end

   -- self:request_rank_data(self:site_name())

end

function match:on_open()
    -- rank:request_rank()
    register_save_timer(self)
    register_close_timer(self)

    reset(self)
    self:step_wait_stage()
end

function match:on_close()
    GameServer:closeServer()
end

function match:stage()
    return self._stage
end

function match:on_player_login(player)
    player:on_login()
    if self._close_timer then
        timer:close(self._close_timer)
        self._close_timer = nil
    end
end

function match:on_player_logout(player)
    player:on_logout()
    if self:player_count() == 0 then
        self:force_reset_game()
        register_close_timer(self)
    end
end

function match:player_count()
    return PlayerManager:getPlayerCount()
end

function match:player_enough()
    return self:player_count() >= config.playerMin
end

return Match