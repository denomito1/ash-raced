resource.AddSingleFile( "resource/fonts/alium_jost_bold.ttf" )
resource.AddSingleFile( "resource/fonts/alium_jost_medium.ttf" )
resource.AddSingleFile( "resource/fonts/alium_jost_regular.ttf" )


hook.Add( "PlayerInitialSpawn", "Default", function( ply )
    ply:SetNW2Float( "alium.firstconnect", CurTime() )
end )
