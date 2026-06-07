local math_floor = math.floor
local vgui_register = vgui.Register
local vgui_create = vgui.Create
local draw_simpleText = draw.SimpleText
local AccessorFunc = AccessorFunc
local IsValid = _G.IsValid
local Color = Color
local bit_bor = bit.bor
local LocalPlayer = _G.LocalPlayer
local getNick = Player.Nick
local getPing = Player.Ping
local math_min = math.min
local userID = Entity.EntIndex
local player_Iterator = _G.player.Iterator
local language_GetPhrase = language.GetPhrase
local timer_Simple = timer.Simple
local string_match = string.match
local string_ToMinutesSeconds = _G.string.ToMinutesSeconds
local player_GetCount = player.GetCount
local utf8_dreamwork = _G.dreamwork.std.encoding.utf8
local timer = timer
-- local upper = utf8_dreamwork.upper

-- local session_time = CurTime()

import "alium_lobby.panels"

---@type ash.ui
local ash_ui = import "ash.ui"

local panel_scoreboard = ash_ui.getPanel( "alium.scoreboard" )


---@class alium.rndx
local rndx = import "alium_lobby.rndx"

local rndx_draw = rndx.Draw

local width, height = 1600, 900
local sizes = {
    width = width,
    height = height,

    scoreboard_scale_w = 1170 / width,
    scoreboard_scale_h = 566 / height,

    scoreboard_info_scale_w = 247 / width,
    scoreboard_info_scale_h = 566 / height,

    scoreboard_player_line_scale_w = 823 / width,
    scoreboard_player_line_scale_h = 32 / height,

    scoreboard_players_scale_w = 823 / width,
    scoreboard_players_scale_h = 420 / height,

    scoreboard_main_scale_w = 923 / width,
    scoreboard_main_scale_h = 556 / height,
    scoreboard_logo_scale_h = 53 / height,

    scoreboard_avatar_size_h = 190 / height,
}

ash_ui.font( "alium.scoreboard.row.text", {
    font = "Jost-Regular",
    extended = true,
    size = "1.5vmin",
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )

ash_ui.font( "alium.scoreboard.row.name", {
    font = "Jost-Bold",
    extended = true,
    size = "3vmin",
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )

ash_ui.font( "alium.scoreboard.label", {
    font = "Jost Medium",
    extended = true,
    size = "6.5vmin",
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )

ash_ui.font( "alium.scoreboard.info", {
    font = "Jost Medium",
    extended = true,
    size = "3vmin",
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )


file.CreateDir("alium_avatars")

for _, v in ipairs( file.Find("alium_avatars/*.jpg", "DATA") ) do
    file.Delete( "alium_avatars/" .. v )
end

local http = _G.http

---@param steamid string SteamID 64
---@param callback function Callback
local function getAvatarImage( steamid, callback )
    local link = string.format( "https://steamcommunity.com/profiles/%s/?xml=1", steamid )

    http.Fetch( link,
        function( body )
            local avatar = string_match( body, "<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>" )

            if not avatar then
                avatar = string_match( body, "<avatarFull>(.-)</avatarFull>")
            end

            http.Fetch( avatar, function( jpg )
                file.Write( "alium_avatars/" .. steamid .. ".jpg", jpg )
                callback( jpg )
            end)

        end
    )
end


do
    local PANEL = {}

    AccessorFunc( PANEL, "font", "Font", FORCE_STRING )
    AccessorFunc( PANEL, "player", "Player" )
    AccessorFunc( PANEL, "backgroundColor", "BackgroundColor" )
    AccessorFunc( PANEL, "markColor", "MarkColor" )
    AccessorFunc( PANEL, "cornerRadius", "CornerRadius" )

    function PANEL:Init()
        self:SetFont( "alium.scoreboard.row.text" )
        self:SetCornerRadius( 4 )

        self:SetBackgroundColor( Color( 16, 16, 16, 255) )
        self:SetMarkColor( Color( 117, 46, 153 ) )

        self.rows_left = {}
        self.rows_right = {}

        local row_panel_left = vgui_create( "Panel", self )
        row_panel_left:SetMouseInputEnabled( false )
        row_panel_left:Dock( LEFT )

        self.row_panel_left = row_panel_left

        local row_panel_right = vgui_create( "Panel", self )
        row_panel_right:SetMouseInputEnabled( false )
        row_panel_right:Dock( RIGHT )

        self.row_panel_right = row_panel_right
    end

    local rndx_flags_background = bit_bor( rndx.SHAPE_FIGMA, rndx.NO_TL, rndx.NO_BL )
    local rndx_flags_mark = bit_bor( rndx.SHAPE_FIGMA, rndx.NO_TR, rndx.NO_BR )

    function PANEL:Paint( w, h )
        local w_background = math_floor( w * 0.99 )
        local w_mark = w - w_background

        rndx_draw( self:GetCornerRadius(), w_mark, 0, w_background, h, self:GetBackgroundColor(), rndx_flags_background )
        rndx_draw( self:GetCornerRadius(), 0, 0, w_mark, h, self:GetMarkColor(), rndx_flags_mark )
    end

    local function paintRow( self, w, h )
        local data = self.data
        local ply = self.panel_main:GetPlayer()

        if not IsValid( ply ) then
            return
        end

        -- rndx_draw( 0, 0, 0, w, h, Color(128, 128, 128), 0 )

        if data.get then
            draw_simpleText( data.get( ply, data ), self:GetFont(), w * 0.5, h * 0.5, data.color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        if data.draw then
            data.draw( self, ply, data, w, h )
        end
    end

    ---@param data table
    function PANEL:AddRow( data )
        local parent = self.row_panel_right
        local dock = RIGHT

        if data.side == "left" then
            parent = self.row_panel_left
            dock = LEFT
        end

        local size_row = math_floor( data.size * self:GetWide() )
        parent:SetWide( size_row + parent:GetWide() )

        local row = parent:Add( "Panel" )
        row:SetWide( size_row )
        row:SetTall( self:GetTall() )
        row:Dock( dock )
        row.data = data
        row.panel_main = self
        row.Paint = paintRow

        local margin = data.margin
        if margin then
            row:DockMargin( margin.left or 0, margin.top or 0, margin.right or 0, margin.bottom or 0 )
        end

        if data.init then
            data.init( row )
        end
    end

    vgui_register( "alium.scoreboard.player_line", PANEL, "Panel" )
end

local rows = {
    {
        name = "",
        side = "left",
        size = 0.065,
        init = function( row )
            local pl = row.panel_main:GetPlayer()

            if IsValid( pl ) then
                local avatar = row:Add( "DImage" )
                if not pl:IsBot() then

                    local steamid = pl:SteamID64()
                    getAvatarImage( steamid, function()
                        if IsValid( avatar ) then
                            avatar:SetMaterial( Material( "data/alium_avatars/" .. steamid .. ".jpg", "smooth mips" ) )
                        end
                    end )
                end

                local size = math_floor( row:GetTall() * 0.8 )

                avatar:SetSize( size, size )
                avatar:Center()
            end
        end
    },
    {
        name = "NICK",
        side = "left",
        size = 0.15,
        get = function( ply )
            return getNick( ply )
        end
    },
    {
        name = "PING",
        side = "right",
        size = 0.07,
        margin = {
            right = 5,
        },
        get = function( ply )
            return math_min( getPing( ply ), 999 )
        end
    },
    {
        name = "UNIT",
        side = "right",
        size = 0.11,
        color = color_white,
        get = function( ply )
            return "-"
        end
    },
    {
        name = "SESSION",
        side = "right",
        size = 0.15,
        color = color_white,
        get = function( ply )
            local ct = CurTime()
            return string_ToMinutesSeconds( ct - ply:GetNW2Float( "alium.firstconnect", ct ) )
        end
    },
}

local map = game.GetMap()
local max_players = game.MaxPlayers()
local function getInfo(  )
    local ct = CurTime()
    return "Players: " .. player_GetCount( ) .. "/" .. max_players .. "\n" .. "Map: " .. map .. "\n" .. "Session time:" .. string_ToMinutesSeconds( ct - LocalPlayer():GetNW2Float( "alium.firstconnect", ct ) )
end

local function paintRowName( self, w, h )
    if self.side == "left" then
        draw_simpleText( self.name, "alium.scoreboard.row.name", w * 0.5, h * 0.5, self.color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER  )
    elseif self.side == "right" then
        draw_simpleText( self.name, "alium.scoreboard.row.name", w * 0.5, h * 0.5, self.color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER  )
    end
end

local function createScoreboard()
    local lp = LocalPlayer()
    panel_scoreboard = ash_ui.setPanel( "alium.scoreboard", "alium.panel" )
    panel_scoreboard:SetSize( math_floor( ash_ui.ScreenWidth * sizes.scoreboard_scale_w ), math_floor( ash_ui.ScreenHeight * sizes.scoreboard_scale_h ) )
    panel_scoreboard:Center()
    panel_scoreboard:SetColor( Color( 25, 25, 25, 242 ) )
    panel_scoreboard.players_panels_list = {}
    panel_scoreboard:SetVisible( false )
    panel_scoreboard:MakePopup()

    panel_scoreboard:SetMouseInputEnabled( false )
    panel_scoreboard:SetKeyboardInputEnabled( false )

    local info = panel_scoreboard:Add( "alium.panel" )
    info:Dock( RIGHT )
    info:SetWide( math_floor( ash_ui.ScreenWidth * sizes.scoreboard_info_scale_w ) )
    info:SetTall( math_floor( ash_ui.ScreenHeight * sizes.scoreboard_info_scale_h ) )
    info:SetColor( Color( 16, 16, 16, 255 ) )

    local label_info = info:Add( "DLabel" )
    label_info:SetText( getInfo() )
    label_info:SetFont( "alium.scoreboard.info" )
    label_info:SetContentAlignment( 6 )
    label_info:SetTextColor( color_white )
    label_info:SizeToContents()
    label_info:CenterVertical(0.1)
    label_info:CenterHorizontal()

    local size_avatar_frame = math_floor( ash_ui.ScreenHeight * sizes.scoreboard_avatar_size_h )


    local size_avatar = math_floor( size_avatar_frame * 0.8 )


    local avatar_image = info:Add( "DImage" )
    avatar_image:SetSize( size_avatar, size_avatar )
    avatar_image:CenterHorizontal()

    local steamid = lp:SteamID64()
    getAvatarImage( steamid, function()
        if IsValid( avatar_image ) then
            avatar_image:SetMaterial( Material( "data/alium_avatars/" .. steamid .. ".jpg", "smooth 1" ) )
        end
    end )

    local frame_avatar = info:Add( "DImage" )
    frame_avatar:SetImage( "materials/alium/alium_frame.png" )
    frame_avatar:SetSize( size_avatar_frame, size_avatar_frame )
    frame_avatar:CenterHorizontal()
    frame_avatar:SetY( label_info:GetTall() + 20 )

    avatar_image:SetY( math_floor( frame_avatar:GetY() * 1.18  ) )

    local label_nick = info:Add( "DLabel" )
    label_nick:SetText( lp:Nick() )
    label_nick:SetFont( "alium.scoreboard.info" )
    label_nick:SetContentAlignment( 6 )
    label_nick:SetTextColor( color_white )
    label_nick:SizeToContents()
    label_nick:CenterHorizontal()

    label_nick:SetY( frame_avatar:GetY() + frame_avatar:GetTall() + 20 )

    -- frame_avatar:SetY( label_info:GetTall() + frame_avatar:GetTall() + 20 )

    timer.Create("alium.scoreboard.updateinfo", 1, 0, function()
        if not IsValid( panel_scoreboard ) then
            timer.Remove( "alium.scoreboard.updateinfo" )

            return
        end

        label_info:SetText( getInfo() )
        label_info:SizeToContents()
        label_info:CenterVertical(0.1)
        label_info:CenterHorizontal()

        frame_avatar:CenterHorizontal()
        avatar_image:SetY( math_floor( frame_avatar:GetY() * 1.18  ) )
        label_nick:SetY( frame_avatar:GetY() + frame_avatar:GetTall() + 20 )
        -- frame_avatar:SetY( label_info:GetTall() + frame_avatar:GetTall() + 20 )
    end)

    local main = panel_scoreboard:Add( "Panel" )
    main:Dock( LEFT )
    main:SetWide( math_floor( ash_ui.ScreenWidth * sizes.scoreboard_main_scale_w ) )
    main:SetTall( math_floor( ash_ui.ScreenHeight * sizes.scoreboard_main_scale_h ) )

    local logo = main:Add( "DImage" )
    logo:SetMouseInputEnabled( false )
    local logo_size = math_floor( ash_ui.ScreenHeight * sizes.scoreboard_logo_scale_h )
    logo:SetSize( logo_size, logo_size )
    logo:SetImage( "alium/alium_logo.png" )
    logo:SetX( math_floor( main:GetWide() * 0.05 ) )
    logo:SetY( math_floor( main:GetTall() * 0.03 ) )

    local label = main:Add( "DLabel" )
    label:SetText( "The Alium" )
    label:SetTextColor( color_white )
    label:SetFont( "alium.scoreboard.label" )
    label:SizeToContents()
    label:SetX( math_floor( main:GetWide() * 0.05 ) + ( logo:GetWide() * 1.2 ) )
    label:SetY( math_floor( main:GetTall() * 0.03 ) + ( logo:GetTall() * 0.5 ) - (label:GetTall() * 0.5) )

    local players_list = main:Add( "Panel" )
    players_list:SetWide( math_floor( ash_ui.ScreenWidth * sizes.scoreboard_players_scale_w ) )
    players_list:SetTall( math_floor( ash_ui.ScreenHeight * sizes.scoreboard_players_scale_h ) )
    players_list:CenterVertical( 0.55 )
    players_list:CenterHorizontal( 0.5 )

    local scroll = players_list:Add( "alium.scroll" )
    scroll:Dock( FILL )
    scroll.VBar:SetWide( 4 )

    local rows_info = players_list:Add( "Panel" )
    rows_info:Dock( TOP )
    rows_info:SetWide( math_floor( ash_ui.ScreenWidth * sizes.scoreboard_players_scale_w ) )
    rows_info:SetTall( math_floor( ash_ui.ScreenHeight * sizes.scoreboard_player_line_scale_h ) )

    local panel_right = rows_info:Add( "Panel" )
    panel_right:Dock( RIGHT )
    panel_right:DockPadding( 0, 0, 5, 0 )
    panel_right:SetTall( rows_info:GetTall() )

    local panel_left = rows_info:Add( "Panel" )
    panel_left:Dock( LEFT )
    panel_left:DockPadding( 0, 0, 5, 0 )
    panel_left:SetTall( rows_info:GetTall() )

    for i = 1, #rows do
        local data = rows[ i ]

        local parent = panel_right
        local dock = RIGHT

        if data.side == "left" then
            parent = panel_left
            dock = LEFT
        end

        local size_row = math_floor( data.size * rows_info:GetWide() )
        parent:SetWide( size_row + parent:GetWide() )

        local row = parent:Add( "Panel" )
        row:SetWide( size_row )
        row:SetTall( rows_info:GetTall() )
        row:Dock( dock )
        row.name = ( language_GetPhrase( data.name ) )
        row.side = data.side
        row.Paint = paintRowName

        local margin = data.margin
        if margin then
            row:DockMargin( margin.left or 0, margin.top or 0, margin.right or 0, margin.bottom or 0 )
        end
    end

    -- local scroll = panel_scoreboard:Add( "DScrollPanel" )
    -- scroll:Dock( FILL )

    function panel_scoreboard:AddPlayer( ply )
        local userid = userID( ply )
        local old_player = panel_scoreboard.players_panels_list[ userid ]

        if IsValid( old_player ) then
            old_player:Remove()
        end

        local player_line = scroll:Add( "alium.scoreboard.player_line" )
        player_line:Dock( TOP )
        player_line:SetWide( rows_info:GetWide()  )
        player_line:SetTall( rows_info:GetTall() )

        player_line:DockMargin( 0, 5, 5, 0 )

        player_line:SetPlayer( ply )

        for i = 1, #rows do
            player_line:AddRow( rows[ i ] )
        end

        panel_scoreboard.players_panels_list[ userid ] = player_line

        return player_line
    end

    function panel_scoreboard:RemovePlayer( userid )
        local old_player = panel_scoreboard.players_panels_list[ userid ]

        if IsValid( old_player ) then
            old_player:Remove()
        end

        panel_scoreboard.players_panels_list[ userid ] = nil
    end

    for _, ply in player_Iterator() do
        panel_scoreboard:AddPlayer( ply )
    end

    return panel_scoreboard
end

local function showScoreboard()
    if IsValid( panel_scoreboard ) then
        panel_scoreboard:Stop()
        panel_scoreboard:SetVisible( true )
        panel_scoreboard:AlphaTo( 255, 0.3, 0 )
    end
end

local function hideScoreboard()
    if IsValid( panel_scoreboard ) then
        panel_scoreboard:Stop()
        panel_scoreboard:SetVisible( true )
        panel_scoreboard:AlphaTo(0, 0.3, 0, function()
            if IsValid( panel_scoreboard ) then
                panel_scoreboard:SetVisible( false )
            end
        end)
    end
end

alium_lobby.CreateScoreboard = createScoreboard


---@param ply Player
hook.Add( "OnEntityCreated", "Default", function( ply )
    if IsValid( ply ) and ply:IsPlayer() then
        timer_Simple( 5, function()
            if IsValid( ply ) then
                if IsValid( panel_scoreboard ) then
                    panel_scoreboard:AddPlayer( ply )
                end
            end
        end )
    end
end )

---@param ply Player
hook.Add( "EntityRemoved", "Default", function( ply, full_update )
    if full_update or ply == nil then return end

    if IsValid( ply ) and ply:IsPlayer() then
        if IsValid( panel_scoreboard ) then
            panel_scoreboard:RemovePlayer( userID( ply ) )
        end
    end
end )

hook.Add( "InitPostEntity", "CreateScoreboard", function ()
    LocalPlayer():SetNW2Float( "alium.firstconnect", CurTime() )

    cvars.AddChangeCallback( "gmod_language", function() createScoreboard() end)

    createScoreboard()
end )

hook.Add( "OnScreenSizeChanged", "CreateScoreboard", function()
    timer_Simple( 1, createScoreboard )
end )

hook.Add( "ScoreboardShow", "Default", showScoreboard )
hook.Add( "ScoreboardHide", "Default", hideScoreboard )
