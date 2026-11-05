-- ========================================
-- File: define.lua
-- Created: 2026-11-04 18:36
-- Author: Saurav
-- ========================================


define = {}

define.MATCH_NONE     =   0 -- none
define.MATCH_WAIT     =   1 -- waiting phase after player enters the game
define.MATCH_READY    =   3 -- waiting finsiesh, match tends to start
define.MATCH_START    =   4 -- game starts finally
define.MATCH_CLOSE    =   5 -- Match ensd as well

define.gameType       =   "g1111"

return define