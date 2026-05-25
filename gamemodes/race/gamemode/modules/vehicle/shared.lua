---@class race.vehicle
local vehicle = {}

---@class race.vehicle.Data
---@field name string
---@field model_name string
---@field class_name string

---
--- class to data mapping
---
---@type table<string, race.vehicle.Data>
local registry = {}

local list = {}
local list_count = 0
local default_vehicle


function vehicle.register( class_name, data )
    data.class_name = class_name

    list_count = list_count + 1
    list[ list_count ] = data

    if data.default then
        default_vehicle = data
    end

    registry[ class_name ] = data

    return data
end

function vehicle.getByClass( class_name )
    return registry[ class_name ]
end

function vehicle.getDefault()
    return default_vehicle
end

do

    local data = util.JSONToTable( file.Read( "data_static/race/vehicle.json", "GAME" ) or "[]" ) or {}

    for i = 1, #data do
        local v = data[ i ]
        vehicle.register( v.class_name, v )
    end

end

return vehicle
