-- ========================================
-- File: shop.lua
-- Created: 2026-11-04 18:57
-- Author: Saurav
-- ========================================

require "config"

shop = {}

function shop:init()
    for _, shop in ipairs(config.shops) do
        EngineWorld:addGoodsGroupToShop(shop.type, shop.icon, shop.name) -- add the groups (sub categories) to the game's shop
        for _, item in ipairs(shop.goods) do
            local goods= Goods.new() -- store the configs of shop in a new table
            goods.itemId = item.itemId
            goods.itemMeta = item.itemMeta
            goods.itemNum = item.itemNum
            goods.coinId = item.coinId
            goods.blockymodsPrice = item.blockymodsPrice
            goods.blockmanPrice = item.blockmanPrice
            goods.limit = item.limit
            goods.desc = item.desc
            EngineWorld:addGoodsToShop(shop.type, goods) -- add the goods to the type(category to be more speficic)
        end
    end
end

return shop
