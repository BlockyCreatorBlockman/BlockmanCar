-- ========================================
-- File: listener.lua
-- Created: 2026-11-04 18:55
-- Author: Saurav
-- ========================================

require "features.shop"
require "features.match"
require "features.player"
require "features.config"

listener = {}

function listener.init()    
    BaseListener.registerCallBack(GameInitEvent, function(c_config)
        HostApi.log("Listener initiated successfully")
        config:init(c_config)
        local initPos = VectorUtil.newVector3i(config.initPos[1], config.initPos[2], config.initPos[3])
        GameServer:setInitPos(initPos)
        timer:init()
        match:init()
        shop:init()
        match:on_open()
    end)

    BaseListener.registerCallBack(PlayerLoginEvent, function(clientPeer)
        if match:stage() ~= define.MATCH_STAGE_WAIT then
            return GameOverCode.GameStarted
        end
        local player = player_class.new(clientPeer)
        player:init()
        match:on_player_login(player)
        return GameOverCode.Success, player, 1
    end)

    BaseListener.registerCallBack(PlayerLogoutEvent, function(player)
        match:on_player_logout(player)
    end)

    BaseListener.registerCallBack(PlayerReadyEvent, function(player)
        HostApi.sendPlaySound(player.rakssid, 10029)
        MsgSender.sendMsgToTarget(player.rakssid, IMessages:msgWelcomePlayer(message:gamename()))
        player:on_spawn()
        return 43200
    end)
end