-- ========================================
-- Game Listener is basically like ughh... a file? That loads just immediately after the game starts! Yeah, that's it
-- ========================================
-- Don't mind if this has a lot of comments (I am beginner in lua...)

GameListener = {} -- created an empty "global" table 

function GameListener:init() --insidew the table, there is a function, giving the sense of "initialization"
    BaseListener.registerCallBack(GameInitEvent, GameListener.onGameInit) -- BaseListener.registerCallBack is something engine-specifc. This means that "GameInitEvent" or "when the gmae starts", execute the function "onGameINit" (defined below, orders of functions doesn't matter in lua)
end

-- config = parsed config.yml
function GameListener.onGameInit(config)
    HostApi.log("GameListener.onGameInit")
    GameConfig:init(config)                   -- 1. read config.yml
    GameServer:setInitPos(GameConfig.initPos) -- 2. Listener will only be setting the position after the the player enters
    GameMatch:initMatch()                     -- 3. Game starting, endine... wil be managed by this
end

return GameListener
