---@type race.grid
local grid = import( "grid" )

---@type ash.config
local config = import( "ash.config" )

---@class race.checkpoint
local checkpoint = {}

local path = {}
local path_build = {}

local checkpoints = {}

local path_to_path = "race/path/" .. game.GetMap()
local path_to_checkpoint = "race/checkpoints/" .. game.GetMap()


if SERVER then
    config.setAllowReceive( path_to_checkpoint )
    config.setAllowReceive( path_to_path )

    path = config.get( path_to_path, false )

    for i = 1, #path do
        path[ i ] = Vector( path[ i ] )
    end

    path_build = grid.buildGrid( path )

    checkpoints = config.get( path_to_checkpoint, false )

    for i = 1, #checkpoints do
        local v = checkpoints[ i ]
        local mins = Vector( v[ 1 ] )
        local maxs = Vector( v[ 2 ] )
        local ang = Angle( v[ 3 ] )

        checkpoints[ i ] = { mins, maxs, (mins + maxs) * 0.5, (maxs - mins) * 0.5, ang }
    end

else
    config.receive( path_to_path, function( data )
        for i = 1, #data do
            path[ i ] = Vector( data[ i ] )
        end

        path_build = grid.buildGrid( path )
    end )

    config.receive( path_to_checkpoint, function( data )
        checkpoints = data

        for i = 1, #checkpoints do
            local v = checkpoints[ i ]
            local mins = Vector( v[ 1 ] )
            local maxs = Vector( v[ 2 ] )
            local ang = Angle( v[ 3 ] )

            checkpoints[ i ] = { mins, maxs, (mins + maxs) * 0.5, (maxs - mins) * 0.5, ang }

            printf( "checkpoints count %s ", #checkpoints )
        end
    end )
end

function checkpoint.getList()
    return checkpoints
end

function checkpoint.getPath()
    return path_build
end

do
    local huge = math.huge
    function checkpoint.getNextDist( pl )
        local checkpoint_id = pl:GetNW2Int( "race.checkpointID", 1 )

        local pos = pl:WorldSpaceCenter()
        pos = Vector( math.floor( pos.x ), math.floor( pos.y ), math.floor( pos.z ) )
        local nearest = grid.findNearest( pos, path_build )


        local point = (checkpoints[ checkpoint_id ] or {})[ 4 ]

        print( "checkpoint_id", checkpoint_id, "checkpoints", #checkpoints, "point", point )
        if not point then return huge end

        return nearest:DistToSqr( pos )
    end
end

return checkpoint
