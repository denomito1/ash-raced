---@type ash.round
local round = import( "ash.round" )

---@type ash.player
local ash_player = import( "ash.player" )

---@type race.vehicle
local vehicle = import( "vehicle" )

---@type ash.player.team
local ash_team = import( "ash.player.team" )

---@type ash.spectator
local ash_spectator = import( "ash.spectator" )

CreateConVar( "race_laps", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Number of laps to complete in the race", 1, 128 )



ash_team.register( {
    name = "spec",
    color = Color( 128, 128, 128 ),
    score = 0,
    mates = {},
} )

ash_team.register( {
    name = "players",
    color = Color( 255, 255, 255 ),
    score = 0,
    mates = {},
} )

do
    local ash_player_iterator = ash_player.iterator
    local Player_Give = Player.Give
    local Player_Alive = Player.Alive

    round.createRoundStack(
        {
            {
                name = "prepare",
                time = 10,
                finish = function( data )
                    print( "round end", data.name )
                end,
                start = function()
                    game.CleanUpMap( false, nil, function()
                        timer.Simple( 1, function()
                            for _, pl in ash_player_iterator() do
                                if ash_team.getTeam( pl ) ~= "spec" then
                                    if Player_Alive( pl ) then
                                        pl:KillSilent()
                                    end

                                    pl:SetupHands()
                                    ash_player.spawn( pl )
                                end

                            end
                        end )
                    end )
                end
            },

            {
                name = "started",
                time = 60 * 30,
                finish = function()
                end,
                start = function()
                    for _, pl in ash_player_iterator() do
                        if ash_team.getTeam( pl ) ~= "spec" then
                            if not Player_Alive( pl ) then
                                ash_player.spawn( pl )
                                pl:SetupHands()
                            end

                            pl:SetNW2Float( "race.startTime", CurTime() )
                        end
                    end
                end,
            },

            {
                name = "post_round",
                time = 8,
                finish = function( data )
                    print( "round end", data.name )
                end,
                start = function( data )
                    print( "round start", data.name )
                end
            },
        }
    )
end
