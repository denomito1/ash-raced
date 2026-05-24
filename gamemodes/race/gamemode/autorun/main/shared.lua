---@type ash.round
local round = import( "ash.round" )

---@type ash.player
local ash_player = import( "ash.player" )

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
				start = function( )
					for _, pl in ash_player_iterator() do
						if not Player_Alive( pl ) then
							ash_player.spawn( pl )
							pl:SetupHands()
						end
					end

					game.CleanUpMap()
				end
			},

			{
				name = "started",
				time = 60 * 5,
				finish = function( )
				end,
				start = function( )

					for _, pl in ash_player_iterator() do
						if not Player_Alive( pl ) then
							ash_player.spawn( pl )
							pl:SetupHands()
						end
					end

				end,
			},

			{
				name = "post_round",
				time = 10,
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