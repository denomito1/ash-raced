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

---@type ash.spectator
local ash_spectator = import( "ash.spectator" )

---@type ash.player.team
local ash_team = import( "ash.player.team" )

local race_laps = GetConVar( "race_laps" )
assert( race_laps ~= nil, "race_laps convar not found" )

local team_map = {
    [ "player" ] = "player",
    [ "p" ] = "player",
    -- [ "spec" ] = "spec",
    -- [ "spectator" ] = "spec",
}

local OBS_MODE_IN_EYE = OBS_MODE_IN_EYE

concommand.Add( "team", function( pl, _, args )
    local t = team_map[ args[ 1 ] ]

    if t and ash_team.getTeam( pl ) ~= t then
        if not ash_player.isDead( pl ) then
            pl:KillSilent()
        end

        ash_spectator.unSpecate( pl )
        ash_team.setTeam( pl, t )
    end
end )


do
    local map = game.GetMap()

    local path_str = "race/path/" .. map

    config.setAllowReceive( path_str )
    local path = config.get( path_str, false )

    ---@type race.checkpoint
    local checkpoint = import( "checkpoint" )

    local spawns = config.get( "race/spawns/" .. map, false )
    local spawn_trigger_finish = config.get( "race/finish/" .. map, false )
    local spawn_trigger_kill = config.get( "race/kill/" .. map, false )
    local spawn_ash_camera = config.get( "race/camera/" .. map, false )

    local function replaceSpawn()
        ash_player.cleanSpawnPoints()

        timer.Simple( 0, function()
            if spawns then
                for _, v in ipairs( ash_entity.findByClass( "info_player_start" ) ) do
                    v:Remove()
                end

                for i = 1, #spawns do
                    local data = spawns[ i ]

                    local ent = ents.Create( "info_player_start" )
                    ent:SetPos( Vector( data[ 1 ] ) )
                    ent:SetAngles( Angle( data[ 2 ] ) )
                    ent:Spawn()

                    ash_player.addSpawnPoint( ent, Vector( data[ 1 ] ), Angle( data[ 2 ] ) )
                    ash.Logger:debug( "info_player_start replaced for new %s", ent )
                end
            end

            if spawn_trigger_finish then
                for i = 1, #spawn_trigger_finish do
                    local data = spawn_trigger_finish[ i ]

                    local ent = ents.Create( "race_trigger_finish" )
                    ---@cast ent race.trigger_finish
                    ent:SetPos( Vector( data[ 1 ] ) )
                    ent:SetAngles( Angle( data[ 3 ] ) )
                    ent.Mins = ent:WorldToLocal( Vector( data[ 1 ] ) )
                    ent.Maxs = ent:WorldToLocal( Vector( data[ 2 ] ) )

                    ent:Spawn()
                    ent.Dir = Vector( data[ 4 ] )
                    ent.DirReverse = Vector( data[ 4 ] ) * -1

                    ash.Logger:debug( "race_trigger_finish spawned %s", ent )
                end
            end

            if spawn_trigger_kill then
                for i = 1, #spawn_trigger_kill do
                    local data = spawn_trigger_kill[ i ]

                    local ent = ents.Create( "race_trigger_kill" )
                    ---@cast ent race.trigger_kill
                    ent:SetPos( Vector( data[ 1 ] ) )
                    ent.Mins = ent:WorldToLocal( Vector( data[ 1 ] ) )
                    ent.Maxs = ent:WorldToLocal( Vector( data[ 2 ] ) )
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
                ent:SetAngles( v[ 3 ] )
                ent:Spawn()

                ent.checkpointID = i

                ent.checkpointIDNext = i + 1

                ent.Dir = v[ 4 ]
                ent.DirReverse = v[ 4 ] * -1


                ash.Logger:debug( "checkpoint %s dir = %s", ent, ent.Dir )
            end

            if spawn_ash_camera then
                for i = 1, #spawn_ash_camera do
                    local data = spawn_ash_camera[ i ]

                    local ent = ents.Create( "ash_camera" )
                    ---@cast ent ash.camera
                    ent:SetPos( Vector( data[ 1 ] ) )
                    ent:SetAngles( Angle( data[ 2 ] ) )
                    ent:Spawn()

                    if i == 1 then
                        SetGlobal2Entity( "race.cam", ent )
                    end

                    ash.Logger:debug( "ash camera %s", ent )
                end
            end

        end )
    end

    hook.Add( "ash.entity.PostSpawnEntities", "Defaults", replaceSpawn )
    hook.Add( "ash.entity.PostCleanupMap", "Defaults", replaceSpawn )

end

hook.Add( "ash.PlayerTeamChanged", "Defaults", function( pl )
    if #ash_team.getMembers( "player" ) >= 1 and round.getRoundType() == "" then
        round.start( "prepare", developer:GetBool() and 10 or 60 )
    end
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
    if developer:GetBool() and pl:IsSuperAdmin() then
        return true
    end
end )

hook.Add( "race.PlayerSpawn", "Defaults", function( pl )
    pl:SetNW2Float( "race.startTime", CurTime() )
    pl:SetNW2Int( "race.checkpointID", 1 )
    pl:SetNW2Int( "race.points", 0 )
end )

hook.Add( "race.PlayerChangeVehicle", "Dir", function( pl, new_car )
    if round.getRoundType() == "prepare" then
        vehicle.remove( pl )
        timer.Create( "race.respawn_car_" .. pl:EntIndex(), 0.3, 1, function()
            if IsValid( pl ) then
                pl:KillSilent()
                pl:Spawn()
            end
        end )
    end
end )

hook.Add( "CanPlayerSuicide", "Defaults", function( pl )
    vehicle.remove( pl )
    pl:KillSilent()
    timer.Create( "race.respawn_car_" .. pl:EntIndex(), 0.3, 1, function()
        if IsValid( pl ) then
            pl:Spawn()
        end
    end )
    return false
end )

hook.Add( "Glide_CanPlayerVehicleInput", "Defaults", function( pl )
    if round.getRoundType() == "prepare" then
        return false
    end
end )

concommand.Add( "race_tospawn", function( pl, _, args )
    if not pl:IsSuperAdmin() then
        return
    end

    local ent = ash_entity.findByClass( "info_player_start" )[ 1 ]
    if ent then
        local car = pl:GlideGetVehicle()
        if IsValid( car ) then
            car:SetPos( ent:GetPos() )
        end
    end
end )

hook.Add( "ash.player.Initialized", "Defaults", function( pl )
    if not ash_player.isDead( pl ) then
        pl:KillSilent()
    end

    vehicle.remove( pl )

    ash_team.setTeam( pl, "spec" )

    local cams, cams_count = ash_entity.findByClass( "ash_camera" )

    if cams_count > 0 then
        ash_spectator.specate( pl, cams[ 1 ], OBS_MODE_IN_EYE )
    else
        local spawns, spawns_count = ash_entity.findByClass( "info_player_start" )

        if spawns_count > 0 then
            ash_spectator.specate( pl, spawns[ 1 ], OBS_MODE_IN_EYE )
        end
    end
end )

do
    local round_mask_can_spawn = round.roundMask( "prepare", "started" )

    hook.Add( "ash.player.ShouldSpawn", "Defaults", function( pl )

        if ash_team.getTeam( pl ) == "spec" then
            return false
        end

        local status = round.getRoundType()

        if status == "prepare" or status == "started" then
            return true
        end

        return false
    end )
end

do
    local spectator_entity_list, spectator_entity_list_count = {}, 0

    local classes_map = {
        [ "info_player_start" ] = true,
        [ "ash_camera" ] = true,
        [ "player" ] = true,
    }

    local Entity_GetClass = Entity.GetClass
    for _, v in ash_entity.iterator() do
        if classes_map[ Entity_GetClass( v ) ] then
            spectator_entity_list[ spectator_entity_list_count ] = v
            spectator_entity_list_count = spectator_entity_list_count + 1
        end
    end

    hook.Add( "ash.spectator.GetAllowedEntity", "Defaults", function( pl )
        return spectator_entity_list
    end )

    hook.Add( "ash.entity.Created", "Defaults", function( ent )
        if classes_map[ Entity_GetClass( ent ) ] then
            spectator_entity_list[ spectator_entity_list_count ] = ent
            spectator_entity_list_count = spectator_entity_list_count + 1
        end
    end )

    hook.Add( "ash.entity.Removed", "Defaults", function( ent )
        if classes_map[ Entity_GetClass( ent ) ] then
            if table.removeByValue( spectator_entity_list, ent, spectator_entity_list_count ) then
                spectator_entity_list_count = spectator_entity_list_count - 1
            end
        end
    end )

    hook.Add( "ash.spectator.IsAllowedEntity", "Defaults", function( pl, ent )
        return classes_map[ Entity_GetClass( ent ) ] or false
    end )
end

hook.Add( "race.CanCreateVehicle", "Default", function( pl )
    return ash_team.getTeam( pl ) == "player"
end )

hook.Add( "PlayerCanHearPlayersVoice", "Defaults", function( _, talker )
    if ash_team.getTeam( talker ) == "spec" then
        return false
    end

    return true
end )

resource.AddWorkshop( "3740359187" )
