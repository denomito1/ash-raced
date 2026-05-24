---@class race.vehicle
local vehicle = include( "shared.lua" )

---@type ash.player
local ash_player = import( "ash.player" )

function vehicle.spawn( pl )
	local old_veh = pl:GetNW2Entity( "race.vehicle" )

	if IsValid( old_veh ) then
		old_veh:Remove()
	end

	pl:ExitVehicle()

	local veh = ents.Create( "declasse_impaler_sz" )
	pl:SetNW2Entity( "race.vehicle", veh )

	veh:SetPos( pl:GetPos() )

	local ang = ash_player.getAngles( pl )

	veh:SetAngles( ang )
	veh:Spawn()

	pl:EnterVehicle( veh )

	return veh
end

return vehicle
