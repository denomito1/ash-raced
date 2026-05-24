include( "shared.lua" )

---@type ash.round
local round = import( "ash.round" )

do
	local format_time = _G.string.ToMinutesSeconds
	hook.Add( "HUDPaint", "Defaults", function()
		draw.SimpleText( format_time( round.getTimeLeft() ), "DermaLarge", ScrW() * 0.5, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.SimpleText( round.getRoundType():upper(), "DermaDefaultBold", ScrW() * 0.5, 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end )
end

concommand.Add( "race_spawnpos", function( pl )
    local pos = pl:GetPos()
    local pos_end = pos + pl:GetAimVector() * 100

    print( string.format( "\t{\n\t\tVector( %s, %s, %s ),\n\t\tVector( %s, %s, %s )\n\t},", pos.x, pos.y, pos.z, pos_end.x, pos_end.y, pos_end.z ) )
end )


local list_points_path = {}
local list_points_path_count = 0
concommand.Add( "race_add_path_point", function( pl, _, args )
    local pos = pl:GetEyeTrace().HitPos + Vector( 0, 0, tonumber( args[ 1 ] or 0 ) or 0 )

    list_points_path_count = list_points_path_count + 1

    list_points_path[ list_points_path_count ] = pos
end )

concommand.Add( "race_remove_path_point", function( pl )
    if list_points_path_count > 0 then
        list_points_path[ list_points_path_count ] = nil
        list_points_path_count = list_points_path_count - 1
    end
end )

concommand.Add( "race_path", function()
    for i = 1, list_points_path_count - 1 do
        local pos = list_points_path[ i ]

        print( string.format( "\tVector( %s, %s, %s ),", math.floor( pos.x ) , math.floor( pos.y ), math.floor( pos.z ) ) )
    end
end )

concommand.Add( "race_dir", function( pl )
    local pos = pl:GetAimVector()

    print( string.format( "Vector( %s, %s, %s ),", math.round(pos.x), math.round( pos.y ), math.round(pos.z) ) )
end )

concommand.Add( "race_getpos", function( pl )
    local pos = pl:GetPos()

    print( string.format( "Vector( %s, %s, %s ),", math.round(pos.x), math.round( pos.y ), math.round(pos.z) ) )
end )