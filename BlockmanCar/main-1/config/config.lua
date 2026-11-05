-- ========================================
-- File: config.lua
-- Created: 2026-11-04 23:13
-- Author: Saurav
-- ========================================


config = {}

local function checkInteger(value)
    return math.floor(tonumber(value))
end

local function checkPos(x, y, z)
    return {
        tonumber(x),
        tonumber(y),
        tonumber(z)
    }
end

local function checkRegion(x1, y1, z1, x2, y2, z2)
    x1 = tonumber(x1)
    y1 = tonumber(y1)
    z1 = tonumber(z1)
    x2 = tonumber(x2)
    y2 = tonumber(y2)
    z2 = tonumber(z2)
    return {
        math.min(x1, x2), math.min(y1, y2), math.min(z1, z2),
        math.max(x1, x2), math.max(y1, y2), math.max(z1, z2)
    }
end

function config:init(content)

    -- init Pos
    do
        config.initPos = checkPos(unpack(content.initPos))
    end

    -- player count limit
    do
        config.playerMin = checkInteger(content.playerMin)
        config.playerMax = checkInteger(content.playerMax)
        assert(config.playerMin > 0)
    end

    -- timer
    do
        config.waitTime = checkInteger(content.waitTime)
        config.readyTime = checkInteger(content.readyTime)
        config.gameTime = checkInteger(content.gameTime)
        config.reviveTime = checkInteger(content.reviveTime)
    end

    -- shop
    do
        config.shops = {}
        config.need_save_items = {}
        for _, shop_data in ipairs(content.shops) do
            local shop = {
                type = shop_data.type,
                icon = shop_data.icon,
                name = shop_data.name,
                goods = {}
            }
            for _, goods_data in ipairs(shop_data.goods) do
                table.insert(shop.goods, {
                    itemId = goods_data.price[1],
                    itemMeta = goods_data.price[2],
                    itemNum = goods_data.price[3],
                    coinId = goods_data.price[4],
                    blockymodsPrice = goods_data.price[5],
                    blockmanPrice = goods_data.price[6],
                    limit = goods_data.price[7],

                    desc = goods_data.desc
                })
                config.need_save_items[checkInteger(goods_data.price[1])] = true
            end

            table.insert(config.shops, shop)
        end
    end

    --session npc
    if content and content.session_npc then
        do 
            config.session_npc = {}
            for _, session_npc in ipairs(content.session_npc) do
                local npc = {
                    pos = session_npc.initPos,
                    name = session_npc.name,
                    message = session_npc.message,
                    actor = session_npc.actor,
                    session_npc_type = session_npc.session_npc_type
                }
                table.insert(config.session_npc, npc)
            end
        end
    end
end