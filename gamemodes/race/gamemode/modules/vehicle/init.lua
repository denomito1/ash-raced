MODULE.Networks = {
    "change"
}

---@class race.vehicle
local vehicle = include( "shared.lua" )

---@type ash.trace
local ash_trace = import( "ash.trace" )

---@type ash.player
local ash_player = import( "ash.player" )

---@type ash.spectator
local spectator = import( "ash.spectator" )

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
---@param pl Player
function vehicle.freeze( pl )
    pl:SetNW2Bool( "race.freeze", false )
end

--- [SERVER]
---
--- Unfreezes the vehicle's physics object.
---
---@param pl Player
function vehicle.unfreeze( pl )
    pl:SetNW2Bool( "race.freeze", true )
end

---@param pl Player
---@param class string | nil
---@return Vehicle | nil
function vehicle.create( pl, class )
    vehicle.remove( pl )

    local veh_class = class or vehicle.getDefault().class_name

    local client_car = pl:GetInfo( "race_vehicle_class" )
    if class == nil then
        if vehicle.getByClass( client_car ) then
            veh_class = client_car
        end
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

    timer.Simple( 0, function()
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

    hook.Run( "race.PlayerSpawn", pl, veh )
end )

do
    local Entity_IsValid = Entity.IsValid
    hook.Add( "ash.player.SetupPosition", "SpawnControl", function( pl )
        local spawnpoint = ash_player.getSpawnPoint( pl, false )
        if spawnpoint ~= nil then
            local entity = spawnpoint.entity
            if entity ~= nil and Entity_IsValid( entity ) then
                return entity:WorldSpaceCenter(), entity:GetAngles()
            end

            return spawnpoint.origin, spawnpoint.angles
        end
    end )
end

hook.Add( "PlayerDisconnected", "race.player.Disconnected", function( pl )
    vehicle.remove( pl )
end )

hook.Add( "PlayerEnteredVehicle", "race.player.EnteredVehicle", function( pl, veh )
    pl:SetMoveType( MOVETYPE_NOCLIP )
    pl:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
    pl:PhysicsDestroy()
end )

hook.Add( "PlayerLeaveVehicle", "race.player.EnteredVehicle", function( pl, veh )
    pl:SetMoveType( MOVETYPE_WALK )
    pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
end )

hook.Add( "Glide_CanPlayerVehicleInput", "race.vehicle.CanPlayerVehicleInput", function( pl )
    if not pl:GetNW2Bool( "race.freeze", false ) then
        return false
    end
end )

net.Receive( "change", function( _, pl )
    local client_car = net.ReadString()
    if vehicle.getByClass( client_car ) then
        hook.Run( "race.PlayerChangeVehicle", pl, client_car )
    end
end )

return vehicle
