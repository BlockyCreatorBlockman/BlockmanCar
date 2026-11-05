----- Wed 4 Nov 2026
-- ========================================
-- File: ScriptMain.lua
-- Created: 2026-11-04 18:29
-- Author: Saurav
-- ========================================

package.path = package.path ..';..\\?.lua';

require "config.define"
require "listener.listener"

ScriptMain = {}

function ScriptMain.init()
    HostApi.log("!!!!Server sided main script has been loaded!!!!")
    BaseMain:setGameType(define.gameType)
    listener:init()
end

ScriptMain:init()