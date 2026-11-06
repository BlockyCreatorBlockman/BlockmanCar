-- Loads map/setting/vehicle.csv, spawns the cars and puts them back after a match.
local vehicle = {}

vehicle._list = {}   -- each entry: { type, pos, yaw, entityId }

-- Read the csv and spawn every car (called once from GameInitEvent)
function vehicle:init()
    self._list = {}
    local rows = FileUtil.getConfigFromCsv("setting/vehicle.csv")
    for _, v in pairs(rows) do
        local car = {}
        car.type = tonumber(v.type)
        car.pos  = VectorUtil.newVector3(tonumber(v.x), tonumber(v.y), tonumber(v.z))
        car.yaw  = tonumber(v.yaw)
        -- the engine owns the driving logic, the UI and the model; we only place the car
        car.entityId = EngineWorld:addVehicleNpc(car.pos, car.type, car.yaw)
        table.insert(self._list, car)
    end
end

-- Put every EMPTY car back on its start spot (cars with a driver are skipped)
function vehicle:reset_all()
    local world = EngineWorld:getWorld()
    for _, car in ipairs(self._list) do
        if car.entityId and world:hasPlayerByVehicle(car.entityId) == false then
            world:resetVehiclePositionAndYaw(car.entityId, car.pos, car.yaw)
        end
    end
end

return vehicle