MODULE.ClientFiles = {
    "cl_init.lua",
    "shared.lua",
}

include( "shared.lua" )

local developer = GetConVar( "developer" )
assert( developer ~= nil, "developer convar not found" )

---@type ash.entity
local ash_entity = import( "ash.entity" )

---@type ash.player
local ash_player = import( "ash.player" )

---@type race.vehicle
local vehicle = import( "vehicle" )

---@type ash.round
local round = import( "ash.round" )

---@type ash.config
local config = import( "ash.config" )

---@type ash.entity
import( "ash.entity" )

local race_laps = GetConVar( "race_laps" )
assert( race_laps ~= nil, "race_laps convar not found" )


do

    local spawn_list = {
        [ "gm_tritype_racecity_v1" ] = {
            { Vector( 12546, 2879, 0 ),  Angle( 0, 90, 0 ) },
            { Vector( 12788, 2660, 5 ),  Angle( 0, 90, 0 ) },
            { Vector( 13062, 2321, 14 ), Angle( 0, 90, 0 ) },
            { Vector( 13068, 1318, 14 ), Angle( 0, 90, 0 ) },
            { Vector( 12798, 1486, 14 ), Angle( 0, 90, 0 ) },
            { Vector( 12540, 1773, 14 ), Angle( 0, 90, 0 ) },
            { Vector( 12547, 792, 14 ),  Angle( 0, 90, 0 ) },
            { Vector( 12810, 532, 14 ),  Angle( 0, 90, 0 ) },
            { Vector( 13063, 245, 14 ),  Angle( 0, 90, 0 ) },
            { Vector( 13064, -771, 14 ), Angle( 0, 90, 0 ) },
            { Vector( 12805, -532, 14 ), Angle( 0, 90, 0 ) },
            { Vector( 12532, -303, 14 ), Angle( 0, 90, 0 ) },
        },
        [ "gm_futuropark_circuit_v1" ] = {
            { Vector( -2358, -6724, 27 ), Angle( 0, -180, 0 ) },
            { Vector( -2109, -6336, 27 ), Angle( 0, -180, 0 ) },
            { Vector( -1777, -6723, 27 ), Angle( 0, -179, 0 ) },
            { Vector( -1271, -6718, 27 ), Angle( 0, -179, 0 ) },
            { Vector( -730, -6730, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( -225, -6725, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( 245, -6720, 27 ),   Angle( 0, -179, 0 ) },
            { Vector( 804, -6714, 27 ),   Angle( 0, -179, 0 ) },
            { Vector( 1327, -6718, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( 1850, -6677, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( 1580, -6352, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( 1101, -6357, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( 560, -6336, 27 ),   Angle( 0, -179, 0 ) },
            { Vector( 37, -6341, 27 ),    Angle( 0, -179, 0 ) },
            { Vector( -450, -6346, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( -947, -6351, 27 ),  Angle( 0, -179, 0 ) },
            { Vector( -1461, -6356, 27 ), Angle( 0, -179, 0 ) },
            { Vector( -1913, -6360, 27 ), Angle( 0, -179, 0 ) },

        },
    }

    local trigger_finish_list = {
        [ "gm_tritype_racecity_v1" ] = {
            {
                Vector( 13460, 4273, -280 ),
                Vector( 11947, 3738, 647 ),
                Vector( 0, 1, 0 ),
            },
        },
        [ "gm_futuropark_circuit_v1" ] = {
            {
                Vector( -2492, -7652, -141 ),
                Vector( -2849, -5387, 116 ),
                Vector( -1, 0, 0 ),
            }
        }
    }

    local trigger_kill = {
        [ "gm_tritype_racecity_v1" ] = {
            {
                Vector( 15490, -15650, -2808 ),
                Vector( -14953, 15215, -1631 ),
            },
        },
    }

    local ash_cameras = {
        [ "gm_tritype_racecity_v1" ] = {
            { Vector( 14400, 4900, 780 ), Angle( 0, -152, 0 ) }
        },
    }

    local path_str = "race/path/" .. game.GetMap()

    config.setAllowReceive( path_str )
    local path = config.get( path_str, false )

    local checkpoints = {
        [ "gm_tritype_racecity_v1" ] = {
            { Vector( 15482, 3002, -142 ), Vector( 11765, 3333, 745 ), Angle( 0, 0, 0 ), path },
        },
    }

    ---@type race.checkpoint
    local checkpoint = import( "checkpoint" )

    local spawns = spawn_list[ game.GetMap() ]
    local spawn_trigger_finish = trigger_finish_list[ game.GetMap() ]
    local spawn_trigger_kill = trigger_kill[ game.GetMap() ]
    local spawn_ash_camera = ash_cameras[ game.GetMap() ]

    local function replaceSpawn()
        ash_player.cleanSpawnPoints()

        timer.Simple( 0, function()
            if spawns then
                for _, v in ipairs( ash_entity.getByClass( "info_player_start", false ) ) do
                    v:Remove()
                end

                for i = 1, #spawns do
                    local data = spawns[ i ]

                    local ent = ents.Create( "info_player_start" )
                    ent:SetPos( data[ 1 ] )
                    ent:SetAngles( data[ 2 ] )
                    ent:Spawn()

                    ash_player.addSpawnPoint( ent, data[ 1 ], data[ 2 ] )
                    ash.Logger:debug( "info_player_start replaced for new %s", ent )
                end
            end

            if spawn_trigger_finish then
                for i = 1, #spawn_trigger_finish do
                    local data = spawn_trigger_finish[ i ]

                    local ent = ents.Create( "race_trigger_finish" )
                    ---@cast ent race.trigger_finish
                    ent:SetPos( data[ 1 ] )
                    ent.Mins = ent:WorldToLocal( data[ 1 ] )
                    ent.Maxs = ent:WorldToLocal( data[ 2 ] )
                    ent:Spawn()
                    ent.Dir = data[ 3 ]
                    ent.DirReverse = data[ 3 ] * -1

                    ash.Logger:debug( "race_trigger_finish spawned %s", ent )
                end
            end

            if spawn_trigger_kill then
                for i = 1, #spawn_trigger_kill do
                    local data = spawn_trigger_kill[ i ]

                    local ent = ents.Create( "race_trigger_kill" )
                    ---@cast ent race.trigger_kill
                    ent:SetPos( data[ 1 ] )
                    ent.Mins = ent:WorldToLocal( data[ 1 ] )
                    ent.Maxs = ent:WorldToLocal( data[ 2 ] )
                    ent:Spawn()

                    ash.Logger:debug( "race_trigger_kill spawned %s", ent )

                end
            end

            local list_checkpoints = checkpoint.getList()
            local list_checkpoints_count = #list_checkpoints

            for i = 1, list_checkpoints_count do
                local v = list_checkpoints[ i ]
                local ent = ents.Create( "race_trigger_checkpoint" )
                ---@cast ent race.trigger_checkpoint
                ent:SetPos( v[ 1 ] )
                ent.Mins = ent:WorldToLocal( v[ 1 ] )
                ent.Maxs = ent:WorldToLocal( v[ 2 ] )
                -- ent:SetAngles( v[ 5 ] )
                ent:Spawn()

                ash.Logger:debug( "mins = %s, maxs = %s", v[ 1 ], v[ 2 ] )

                ent.checkpointID = i

                if i == list_checkpoints_count then
                    ent.checkpointIDNext = 1
                else
                    ent.checkpointIDNext = i + 1
                end

                printf( "checkpoint %s", ent )
            end

            if spawn_ash_camera then
                for i = 1, #spawn_ash_camera do
                    local data = spawn_ash_camera[ i ]

                    local ent = ents.Create( "ash_camera" )
                    ---@cast ent ash.camera
                    ent:SetPos( data[ 1 ] )
                    ent:SetAngles( data[ 2 ] )
                    ent:Spawn()

                    if i == 1 then
                        SetGlobal2Entity( "race.cam", ent )
                    end

                    printf( "ash camera %s", ent )
                end
            end

        end )
    end

    hook.Add( "ash.entity.PostSpawnEntities", "Defaults", replaceSpawn )
    hook.Add( "ash.entity.PostCleanupMap", "Defaults", replaceSpawn )

end

hook.Add( "ash.entity.PlayerCreated", "Defaults", function( pl )
    timer.Simple( 1, function()
        if IsValid( pl ) then
            if ash_player.getCount() >= 1 and round.getRoundType() == "" then
                round.start( "prepare", GetConVar( "developer" ):GetBool() and 10 or 60 )
            end
        end
    end )
end )

do
    local ash_round_time_post_round = GetConVar( "ash_round_time_post_round" )
    assert( ash_round_time_post_round ~= nil, "ash_round_time_post_round not found" )

    hook.Add( "race.PlayerChangedPoints", "Defaults", function( pl, new_points )
        if round.getRoundType() == "started" and not IsValid( GetGlobal2Entity( "race.winner", NULL ) ) and new_points >= (race_laps:GetInt() + 1) then
            SetGlobal2Entity( "race.winner", pl )

            round.start( "post_round" )

            timer.Simple( ash_round_time_post_round:GetFloat() * 0.06, function()
                game.SetTimeScale( 0.3 )
            end )

            timer.Simple( ash_round_time_post_round:GetFloat() * 0.2, function()
                game.SetTimeScale( 1 )
                SetGlobal2Entity( "race.winner", NULL )
            end )
        end
    end )

    hook.Add( "SetupPlayerVisibility", "Defaults", function( pl, ent )
        local winner = GetGlobal2Entity( "race.winner", NULL )
        local cam = GetGlobal2Entity( "race.cam", NULL )
        ---@cast winner Player

        if IsValid( winner ) and IsValid( cam ) and not pl:TestPVS( winner:GetPos() ) then
            AddOriginToPVS( winner:GetPos() )
        end
    end )
end

hook.Add( "CanPlayerEnterVehicle", "Defaults", function( pl )
    return true
end )

hook.Add( "CanExitVehicle", "Defaults", function( _, pl )
    return true
end )

hook.Add( "race.PlayerSpawn", "Defaults", function( pl )
    pl:SetNW2Float( "race.startTime", CurTime() )

    pl:SetNW2Int( "race.points", 0 )
end )

hook.Add( "race.PlayerChangeVehicle", "Dir", function( pl, new_car )
    if round.getRoundType() == "prepare" then
        vehicle.remove( pl )
        pl:KillSilent()
        timer.Simple( 1, function()
            if IsValid( pl ) and round.getRoundType() == "prepare" then
                if not pl:Alive() then
                    pl:Spawn()
                end

                vehicle.create( pl, new_car )
            end
        end )
    end
end )

hook.Add( "Glide_CanPlayerVehicleInput", "Defaults", function( pl )
    if round.getRoundType() == "prepare" then
        return false
    end
end )
