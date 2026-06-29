---@type ash.ui
local ash_ui = import( "ash.ui" )

local PANEL_HTML = [[
    <!doctype html>
    <html>
        <head>
            <meta charset="utf-8">
            <style>
                html, body {
                    margin: 0;
                    width: 100%;
                    height: 100%;
                    background: transparent;
                    overflow: hidden;
                    font-family: Arial, sans-serif;
                }

                .bg {
                    position: fixed;
                    inset: 0;

                    width: 100%;
                    height: 100%;

                    object-fit: cover;
                    filter: brightness(0.6);
                }

                .container {
                    position: absolute;
                    left: 2.5vw;
                    top: 66.66vh;
                    width: 16.68vw;
                }

                .main-button {
                    width: 100%;
                    height: 4.33vh;

                    display: flex;
                    align-items: center;

                    margin: 0.55vh 0;

                    border-radius: 0.66vh;

                    background: #d4d1ed49;

                    border: 0.3px solid #F2F2F2;

                    backdrop-filter: blur(8px);

                    transition: all .15s ease;

                    cursor: pointer;
                }

                .main-button:hover {
                    transform: translateY(-1px);

                    background: rgba(220,230,250,0.55);
                }

                .button-icon {
                    width: 3vh;
                    height: 3vh;

                    position: absolute;
                    left: 0.93vw;

                    border-radius: 0.66vh;

                    background: rgba(255,255,255,0.18);

                    color: white;
                }

                .content {
                    position: absolute;
                    left: 3.5625vw;
                }

                .button-title {
                    color: white;
                    font-size: 1.77vh;
                    font-weight: 600;
                    text-align: left;
                }

                .button-subtitle {
                    margin-top: 2px;

                    color: rgba(255,255,255,0.85);
                    font-size: 1vh;
                    font-weight: 800;
                    text-align: left;
                }

                .logo-container {
                    position: absolute;
                    left: 2.5vw;
                    top: 57.22vh;
                    width: 16.68vw;
                    height: 6.22vh;

                    display: flex;
                    align-items: center;

                    border-radius: 0.88vh;

                    background: #cfcfcf05;

                    border: 0.3px solid rgba(255,255,255,0.35);

                    backdrop-filter: blur(8px);

                    cursor: pointer;
                }

                .logo-title {
                    color: white;
                    font-size: 2.77vh;
                    font-weight: 900;
                    text-align: left;

                    position: absolute;
                    left: 3.5625vw;
                }

                .logo-icon {
                    width: 4.22vh;
                    height: 4.22vh;

                    position: absolute;
                    left: 0.75vw;

                    border-radius: 0.66vh;

                    background: rgba(255,255,255,0.18);

                    color: white;
                }


            </style>
        </head>

        <body>
            <img class="bg" src="asset://garrysmod/materials/race/bg.png">

            <div class="logo-container">
                <img class="logo-icon" src="asset://garrysmod/materials/race/logo.png">
                <div class="logo-title" data-lang="logo"></div>
            </div>

            <div class="container">
                <button class="main-button" onclick="lua.Play()">
                    <img class="button-icon" src="asset://garrysmod/materials/race/flag.png">
                    <div class="content">
                        <div class="button-title" data-lang="play"></div>
                        <div class="button-subtitle" data-lang="start_playng"></div>
                    </div>
                </button>

                <button class="main-button" onclick="lua.Garage()">
                    <img class="button-icon" src="asset://garrysmod/materials/race/car.png">
                    <div class="content">
                        <div class="button-title" data-lang="garage"></div>
                        <div class="button-subtitle" data-lang="choose_your_car"></div>
                    </div>
                </button>

                <button class="main-button" onclick="lua.Settings()">
                    <img class="button-icon" src="asset://garrysmod/materials/race/gear.png">
                    <div class="content">
                        <div class="button-title" data-lang="settings"></div>
                        <div class="button-subtitle" data-lang="game_settings"></div>
                    </div>
                </button>

                <button class="main-button" onclick="lua.Disconnect()">
                    <img class="button-icon" src="asset://garrysmod/materials/race/door.png">
                    <div class="content">
                        <div class="button-title" data-lang="disconnect"></div>
                        <div class="button-subtitle" data-lang="disconnect_from_server"></div>
                    </div>
                </button>
            </div>
        </body>

        <script>
            const LANG = {
                ru: {
                    logo: "ASH: RACE",
                    play: "Играть",
                    start_playng: "Начать играть!",
                    garage: "Гараж",
                    choose_your_car: "Выберите свою машину",
                    settings: "Настройки",
                    game_settings: "Настройки игры",
                    disconnect: "Отключиться",
                    disconnect_from_server: "Отключиться от сервера",
                },
                en: {
                    logo: "ASH: RACE",
                    play: "Play",
                    start_playng: "Start playing!",
                    garage: "Garage",
                    choose_your_car: "Choose your car",
                    settings: "Settings",
                    game_settings: "Game settings",
                    disconnect: "Disconnect",
                    disconnect_from_server: "Disconnect from server",
                }
            };

            let lang = "en";

            function updateLanguage() {
                document.querySelectorAll("[data-lang]").forEach(element => {
                    const key = element.dataset.lang;
                    element.textContent = LANG[lang][key] || key;
                });
            }

            updateLanguage();

        </script>
    </html>
]]

---@type ash.player.team
local ash_team = import( "ash.player.team" )

local menu = {}


---@class race.menu.black : Panel
local black = ash_ui.setPanel( "black", "Panel" )
black:SetAlpha( 0 )
black:Dock( FILL )
black:SetMouseInputEnabled( false )
black:SetPaintedManually( true )
black.Paint = function( self, w, h )
    surface.SetDrawColor( 0, 0, 0, 255 )
    surface.DrawRect( 0, 0, w, h )
end


function menu.screenDimming( time, from, to, callback )
    black:SetAlpha( from )
    black:AlphaTo( to, time, 0, callback )
end

function menu.playMusic( path )
    sound.PlayFile( "sound/" .. path, "noplay", function( station, errCode, errStr )
        if IsValid( _G.RACE_MUSIC ) then
            _G.RACE_MUSIC:Stop()
        end

        if IsValid( station ) then
            station:Play()
            station:EnableLooping( true )

            _G.RACE_MUSIC = station
        end
    end )
end

function menu.stopMusic()
    if IsValid( _G.RACE_MUSIC ) then
        _G.RACE_MUSIC:Stop()
    end
end

local music_from
local music_to
local music_time
local music_start
function menu.fadeMusic( from, to, time )
    music_from = from
    music_to = to
    music_time = time
    music_start = CurTime()
end

function menu.create()
    local lp = LocalPlayer()
    local panel = ash_ui.setPanel( "race.menu", "DHTML" )
    panel:MakePopup()

    ---@cast panel DHTML

    panel:Dock( FILL )

    panel:SetHTML( PANEL_HTML )

    panel:AddFunction( "lua", "Play", function()
        if IsValid( panel ) then
            menu.fadeMusic( 1, 0, 5 )
            if ash_team.getTeam( lp ) ~= "player" then
                RunConsoleCommand( "team", "player" )

                menu.screenDimming( 1, 0, 255, function()
                    panel:SetVisible( false )
                    menu.screenDimming( 1, 255, 0 )
                end )

                panel:SetAlpha( 255 )
                panel:AlphaTo( 0, 1, 0, function()
                    if IsValid( panel ) then
                        panel:SetVisible( false )
                    end
                end )
            else
                panel:SetVisible( false )
            end
        end
    end )

    panel:AddFunction( "lua", "Garage", function()
        RunConsoleCommand( "race_menu" )
    end )

    panel:AddFunction( "lua", "Settings", function()
        print( "settings" )
    end )

    panel:AddFunction( "lua", "Disconnect", function()
        Derma_Query( "Disconnect from server?", "Confirmation:", "Yes",
            function() RunConsoleCommand( "disconnect" ) end,
            "No",
            function() end )
    end )

    --temporary solutionн
    local lang = GetConVar( "gmod_language" ):GetString()
    panel:RunJavascript( "lang = " .. lang == "ru" and "ru" or "en" .. ";" .. "updateLanguage();" )

    return panel
end

local panel

hook.Add( "InitPostEntity", "Defaults", function()
    black:SetAlpha( 255 )
    panel = menu.create()
    panel:SetVisible( true )
    timer.Simple( 5, function()
        menu.playMusic( "race/music/fail-safe.mp3" )
        menu.screenDimming( 1, 255, 0 )
    end )
end )

hook.Add( "PostRenderVGUI", "Dimming", function()
    if IsValid( black ) then
        black:PaintManual()
    end
end )

hook.Add( "PlayerButtonUp", "Defaults", function( _, key )
    panel = ash_ui.getPanel( "race.menu" )
    if key == KEY_F1 and IsFirstTimePredicted() and IsValid( panel ) then
        local vis = not panel:IsVisible()
        panel:SetVisible( vis )
        panel:SetAlpha( 255 )

        if vis then
            panel:MakePopup()
        end
    end
end )

hook.Add( "Think", "Defaults", function()
    local station = _G.RACE_MUSIC

    if IsValid( station ) and music_from and music_to and music_start then
        local number = Lerp( (CurTime() - music_start) / music_time, music_from, music_to )
        station:SetVolume( number )
    end
end )
