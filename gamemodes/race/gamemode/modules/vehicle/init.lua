---@class race.vehicle
local vehicle = include( "shared.lua" )

---@type ash.trace
local ash_trace = import( "ash.trace" )

---@type ash.player
local ash_player = import( "ash.player" )

---@type ash.spectator
local spectator = import( "ash.spectator" )

-- connect p2p:90286169766735873 -->

---@type ash.trace.Output
local trace_result = {}

---@type Entity[]
local filter = {}

---@type ash.trace.Params
local trace = {
    output = trace_result,
    filter = filter,
}

local trace_cast = ash_trace.cast

---@type table<Player, Vehicle>
local vehicles = {}

---@param pl Player
---@return Vehicle | nil
function vehicle.get( pl )
    return vehicles[ pl ]
end

---@param pl Player
function vehicle.remove( pl )
    ash_player.leaveVehicle( pl )

    local veh = vehicles[ pl ]
    vehicles[ pl ] = nil

    if veh ~= nil and veh:IsValid() then
        veh:Remove()
    end
end

--- [SERVER]
---
--- Freezes the vehicle's physics object.
---
---@param veh any
function vehicle.freeze( veh )
    if IsValid( veh ) then
        veh.isEngineEnabled = false
    end
end

--- [SERVER]
---
--- Unfreezes the vehicle's physics object.
---
---@param veh any
function vehicle.unfreeze( veh )
    if IsValid( veh ) then
        veh.isEngineEnabled = true
    end
end

---@param pl Player
---@return Vehicle | nil
function vehicle.create( pl )
    vehicle.remove( pl )

    local veh_class = vehicle.getDefault().class_name

    local client_car = pl:GetInfo( "race_vehicle_class" )
    if vehicle.getByClass( client_car ) then
        veh_class = client_car
    end

    local color_info = pl:GetInfo( "race_car_color" )
    local r, g, b, a = string.match( color_info, "(%d+) (%d+) (%d+) (%d+)" )
    r, g, b, a = tonumber( r ) or 255, tonumber( g ) or 255, tonumber( b ) or 255, tonumber( a ) or 255
    local color = Color( r, g, b, 255 )

    local veh = ents.Create( veh_class )

    if veh ~= nil and veh:IsValid() then
        ---@cast veh Vehicle
        vehicles[ pl ] = veh

        local eye_pos = pl:EyePos()

        local offset = vector_up * 512

        trace.start = eye_pos + offset
        trace.endpos = eye_pos - offset
        trace.filter = pl

        trace_cast( trace )

        veh:SetPos( pl:GetPos() )
        veh:SetAngles( ash_player.getAngles( pl ) )
        veh:Spawn()
        veh:SetColor( color )

        ash_player.enterVehicle( pl, veh )

        return veh
    end

    timer.Simple( 1, function()
        if veh ~= nil and veh:IsValid() then
            veh:SetColor( color )
        end
    end )

    return nil
end

---@param pl Player
hook.Add( "ash.player.PreSpawn", "race.player.Spawn", function( pl )
    if pl:Alive() and not spectator.isSpectator( pl ) then
        vehicle.create( pl )
    end
end )

---@type table< Player, table >
local map_angpos = {}
gc.setTableRules( map_angpos, true )

---@param pl Player
---@param spawnpoint ash.player.SpawnPoint
---@return boolean | nil
hook.Add( "ash.player.SpawnPoint", "race.player.Spawn", function( pl, spawnpoint )
    local veh = vehicles[ pl ]

    if veh == nil then
        trace.mins, trace.maxs = nil, nil
    else
        trace.mins, trace.maxs = Vector( -50, -105, 0 ), Vector( 50, 105, 250 )
    end

    local origin, angles = spawnpoint.origin, spawnpoint.angles

    local entity = spawnpoint.entity
    if entity ~= nil and entity:IsValid() then
        origin, angles = entity:GetPos(), entity:GetAngles()
    end

    map_angpos[ pl ] = { origin + Vector( 0, 0, 100 ), angles }

    trace.start = origin
    trace.endpos = origin
    filter[ 1 ] = pl

    trace_cast( trace )

    if trace_result.Hit then
        return false
    end

    return true
end )

hook.Add( "ash.player.PostSpawn", "race.player.PostSpawn", function( pl )
    local veh = vehicles[ pl ]
    if veh == nil then return end

    veh:SetPos( map_angpos[ pl ][ 1 ] )
    veh:SetAngles( map_angpos[ pl ][ 2 ] or Angle() )

    map_angpos[ pl ] = nil

    hook.Run( "race.PlayerSpawn", pl, veh )
end )

hook.Add( "PlayerDisconnected", "race.player.Disconnected", function( pl )
    vehicle.remove( pl )
end )

hook.Add( "PlayerEnteredVehicle", "race.player.EnteredVehicle", function( pl, veh )
    pl:SetSolid( SOLID_NONE )
    pl:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
    pl:PhysicsDestroy()

    ash.Logger:debug( "set no solid", pl )
end )

hook.Add( "PlayerLeaveVehicle", "race.player.EnteredVehicle", function( pl, veh )
    pl:SetSolid( SOLID_BBOX )
    pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
end )

return vehicle
