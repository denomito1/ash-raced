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

---@type ash.entity
import( "ash.entity" )

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
        }
    }

    local trigger_finish_list = {
        [ "gm_tritype_racecity_v1" ] = {
            {
                Vector( 13460, 4273, -280 ),
                Vector( 11947, 3738, 647 ),
                Vector( 0, 1, 0 ),
            },
        }
    }

    local trigger_kill = {
        [ "gm_tritype_racecity_v1" ] = {
            {
                Vector( 15490, -15650, -2808 ),
                Vector( -14953, 15215, -1631 ),
            },
        }
    }

    local ash_cameras = {
        [ "gm_tritype_racecity_v1" ] = {
            { Vector( 14400, 4900, 780 ), Angle( 0, -152, 0 ) }
        },
    }

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

                    printf( "trigger spawn %s", ent )
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

                    printf( "trigger kill %s", ent )
                end
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
                round.start( "prepare", 60 )
            end
        end
    end )
end )

do
    local ash_round_time_post_round = GetConVar( "ash_round_time_post_round" )
    assert( ash_round_time_post_round ~= nil, "ash_round_time_post_round not found" )

    local string_tomins = _G.string.ToMinutesSeconds

    hook.Add( "race.PlayerChangedPoints", "Defaults", function( pl, new_points )
        if round.getRoundType() == "started" and not IsValid( GetGlobal2Entity( "race.winner", NULL ) ) and new_points >= 2 then
            SetGlobal2Entity( "race.winner", pl )

            pl:ConCommand( string.format( "race_win %s %s", pl:Nick(), string_tomins( pl:GetNW2Float( "race.startTime", CurTime() ), CurTime() ) ) )

            timer.Simple( ash_round_time_post_round:GetFloat() * 0.06, function()
                game.SetTimeScale( 0.3 )
            end )

            timer.Simple( ash_round_time_post_round:GetFloat() * 0.2, function()
                game.SetTimeScale( 1 )
                SetGlobal2Entity( "race.winner", NULL )
            end )
        end
    end )

    hook.Add( "SetupPlayerVisibility", "Defaults", function( ply, ent )

    end )
end

hook.Add( "CanPlayerEnterVehicle", "Defaults", function( pl )
    return true
end )

hook.Add( "CanExitVehicle", "Defaults", function( _, pl )
    return false
end )

hook.Add( "race.PlayerSpawn", "Defaults", function( pl )
    if round.getRoundType() == "prepare" then
        vehicle.freeze( vehicle.get( pl ) )
    end

    pl:SetNW2Float( "race.startTime", CurTime() )

    pl:SetNW2Int( "race.points", 0 )
end )
