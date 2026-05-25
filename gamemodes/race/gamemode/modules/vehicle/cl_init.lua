---@class race.vehicle
local vehicle = include( "shared.lua" )

---@type ash.ui
local ash_ui = import( "ash.ui" )

CreateClientConVar( "race_vehicle_class", "vapid_stanier_retro", true, true )
CreateClientConVar( "race_car_color", "255 255 255 255", true, true )

local function MaterialToHTML( path )
    return "asset://garrysmod/materials/" .. path
end

local list_cars = {

    -- Sedans
    {
        class_name = "albany_emperor",
        category = "Sedans",
        icon_path = MaterialToHTML( "gui/glide/lcp/albany_emperor.png" )
    },

    {
        class_name = "albany_emperor_rusty",
        category = "Sedans",
        icon_path = MaterialToHTML( "gui/glide/lcp/albany_emperor_rusty.png" )
    },

    {
        class_name = "declasse_merit",
        category = "Sedans",
        icon_path = MaterialToHTML( "gui/glide/lcp/declasse_merit.png" )
    },

    {
        class_name = "vapid_stanier",
        category = "Sedans",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_stanier.png" )
    },

    {
        class_name = "vapid_stanier_ii",
        category = "Sedans",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_stanier_ii.png" )
    },

    {
        class_name = "vapid_stanier_retro",
        category = "Sedans",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_stanier_retro.png" )
    },

    {
        class_name = "vapid_schyster",
        category = "Sedans",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_schyster.png" )
    },

    -- Muscle
    {
        class_name = "buffalo",
        category = "Muscle",
        icon_path = MaterialToHTML( "gui/glide/lcp/buffalo.png" )
    },

    {
        class_name = "declasse_impaler_lx",
        category = "Muscle",
        icon_path = MaterialToHTML( "gui/glide/lcp/declasse_impaler_lx.png" )
    },

    {
        class_name = "declasse_impaler_sz",
        category = "Muscle",
        icon_path = MaterialToHTML( "gui/glide/lcp/declasse_impaler_sz.png" )
    },

    -- SUVs / Utility
    {
        class_name = "declasse_alamo",
        category = "SUV",
        icon_path = MaterialToHTML( "gui/glide/lcp/declasse_alamo.png" )
    },

    {
        class_name = "declasse_granger_retro",
        category = "SUV",
        icon_path = MaterialToHTML( "gui/glide/lcp/declasse_granger_retro.png" )
    },

    {
        class_name = "patriot",
        category = "SUV",
        icon_path = MaterialToHTML( "gui/glide/lcp/patriot.png" )
    },

    {
        class_name = "vapid_riata_classic",
        category = "SUV",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_riata_classic.png" )
    },

    {
        class_name = "vapid_scout",
        category = "SUV",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_scout.png" )
    },

    -- Vans / Utility
    {
        class_name = "maibatsu_mule",
        category = "Utility",
        icon_path = MaterialToHTML( "gui/glide/lcp/maibatsu_mule.png" )
    },

    {
        class_name = "vapid_speedo",
        category = "Utility",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_speedo.png" )
    },

    {
        class_name = "vapid_sandking_utility",
        category = "Utility",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_sandking_utility.png" )
    },

    {
        class_name = "vapid_interceptor",
        category = "Utility",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_interceptor.png" )
    },

    -- Pickups
    {
        class_name = "declasse_yosemite_1500",
        category = "Pickup",
        icon_path = MaterialToHTML( "gui/glide/lcp/declasse_yosemite_1500.png" )
    },

    {
        class_name = "vapid_1500_steed",
        category = "Pickup",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_1500_steed.png" )
    },

    {
        class_name = "vapid_bobcat",
        category = "Pickup",
        icon_path = MaterialToHTML( "gui/glide/lcp/vapid_bobcat.png" )
    },

    -- Compact / Classic
    {
        class_name = "albany_manana",
        category = "Classic",
        icon_path = MaterialToHTML( "gui/glide/lcp/albany_manana.png" )
    },

    {
        class_name = "albany_manana_cabriolet",
        category = "Classic",
        icon_path = MaterialToHTML( "gui/glide/lcp/albany_manana_cabriolet.png" )
    },

    {
        class_name = "benefactor_panto_citi",
        category = "Compact",
        icon_path = MaterialToHTML( "gui/glide/lcp/benefactor_panto_citi.png" )
    },

    -- Special
    {
        class_name = "romero_hearse",
        category = "Special",
        icon_path = MaterialToHTML( "gui/glide/lcp/romero_hearse.png" )
    }
}

local PANEL_HTML = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">

<style>

body {
    margin: 0;
    padding: 0;
    background: #141414;
    font-family: Arial, sans-serif;
    overflow-y: auto;
    color: white;
}

.header {
    padding: 18px;
    background: #1d1d1d;
    border-bottom: 1px solid #333;
}

.title {
    font-size: 28px;
    font-weight: bold;
}

.subtitle {
    margin-top: 4px;
    color: #999;
    font-size: 14px;
}

.content {
    padding: 15px;
    padding-bottom: 180px;
}

.category {
    margin-bottom: 30px;
}

.category-title {
    font-size: 22px;
    font-weight: bold;
    margin-bottom: 12px;
    padding-left: 4px;
    color: #53a7ff;
}

.cars-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
    gap: 12px;
}

.car-card {
    background: #222;
    border-radius: 12px;
    padding: 10px;
    cursor: pointer;
    transition: 0.15s;
    border: 2px solid transparent;
}

.car-card:hover {
    background: #2d2d2d;
    border-color: #53a7ff;
    transform: translateY(-2px);
}

.car-image {
    width: 100%;
    height: 100px;
    object-fit: contain;
    pointer-events: none;
}

.car-name {
    margin-top: 10px;
    font-size: 16px;
    font-weight: bold;
    text-align: center;
}

.car-class {
    margin-top: 4px;
    font-size: 12px;
    color: #999;
    text-align: center;
    word-break: break-word;
}

/* COLOR PICKER */

#color-picker {
    position: fixed;
    right: 15px;
    bottom: 15px;
    width: 260px;
    background: #1f1f1f;
    border: 1px solid #333;
    border-radius: 12px;
    padding: 14px;
}

.color-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 10px;
}

.color-row {
    display: flex;
    align-items: center;
    margin-bottom: 8px;
}

.color-row label {
    width: 20px;
    font-weight: bold;
}

.color-row input {
    flex: 1;
}

.color-preview {
    width: 100%;
    height: 42px;
    border-radius: 8px;
    margin-top: 10px;
    background: rgb(255,255,255);
    border: 1px solid #444;
}

</style>
</head>

<body>

<div class="header">
    <div class="title">Vehicle Selection</div>
    <div class="subtitle">Select your vehicle for the race</div>
</div>

<div class="content" id="content"></div>

<div id="color-picker">

    <div class="color-title">Vehicle Color</div>

    <div class="color-row">
        <label>R</label>
        <input type="range" id="r" min="0" max="255" value="255">
    </div>

    <div class="color-row">
        <label>G</label>
        <input type="range" id="g" min="0" max="255" value="255">
    </div>

    <div class="color-row">
        <label>B</label>
        <input type="range" id="b" min="0" max="255" value="255">
    </div>

    <div class="color-preview" id="preview"></div>

</div>

<script>

const categories = {};

let selectedColor = {
    r: 255,
    g: 255,
    b: 255,
    a: 255
};

function updateColor()
{
    selectedColor.r = document.getElementById("r").value;
    selectedColor.g = document.getElementById("g").value;
    selectedColor.b = document.getElementById("b").value;

    const color =
        "rgb(" +
        selectedColor.r + "," +
        selectedColor.g + "," +
        selectedColor.b + ")";

    document.getElementById("preview").style.background = color;
}

document.addEventListener("input", updateColor);

window.onload = function()
{
    updateColor();
};

function ensureCategory(category)
{
    if (categories[category])
        return categories[category];

    const wrapper = document.createElement("div");
    wrapper.className = "category";

    const title = document.createElement("div");
    title.className = "category-title";
    title.innerText = category;

    const grid = document.createElement("div");
    grid.className = "cars-grid";

    wrapper.appendChild(title);
    wrapper.appendChild(grid);

    document.getElementById("content").appendChild(wrapper);

    categories[category] = grid;

    return grid;
}

function addCar(name, className, iconPath, category)
{
    const grid = ensureCategory(category);

    const card = document.createElement("div");
    card.className = "car-card";

    card.onclick = function()
    {
        if (window.gmod && gmod.selectVehicle)
        {
            gmod.selectVehicle(
                className,
                selectedColor.r,
                selectedColor.g,
                selectedColor.b,
                selectedColor.a
            );
        }
    };

    const img = document.createElement("img");
    img.className = "car-image";
    img.src = iconPath;

    const carName = document.createElement("div");
    carName.className = "car-name";
    carName.innerText = name;

    const carClass = document.createElement("div");
    carClass.className = "car-class";
    carClass.innerText = className;

    card.appendChild(img);
    card.appendChild(carName);
    card.appendChild(carClass);

    grid.appendChild(card);
}

</script>

</body>
</html>
]]

concommand.Add( "race_menu", function()

    local old_panel = ash_ui.getPanel( "race.select_car" )
    if IsValid( old_panel ) then
        old_panel:SetVisible( true )
        old_panel:MakePopup()
        return
    end

    local frame = ash_ui.setPanel( "race.select_car", "DFrame" )
    ---@cast frame DFrame
    frame:SetSize( 1000, 650 )
    frame:Center()
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:MakePopup()
    frame:SetDeleteOnClose( false )

    frame.Paint = function( _, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15 ) )
    end

    local close = vgui.Create( "DButton", frame )
    close:SetSize( 32, 32 )
    close:SetPos( frame:GetWide() - 38, 6 )
    close:SetText( "X" )

    close.DoClick = function()
        frame:Close()
    end

    local html = vgui.Create( "DHTML", frame )
    html:Dock( FILL )
    html:DockMargin( 0, 40, 0, 0 )

    html:SetHTML( PANEL_HTML )

    html:AddFunction(
        "gmod",
        "selectVehicle",
        function( className, r, g, b, a )

            RunConsoleCommand( "race_vehicle_class", className )

            RunConsoleCommand(
                "race_car_color",
                string.format( "%s %s %s %s", r, g, b, a )
            )

            frame:Close()
        end
    )

    html.OnDocumentReady = function()

        for _, car in ipairs( list_cars ) do

            local category = car.category or "Other"

            local vehicle_data = scripted_ents.GetStored( car.class_name )

            local display_name = car.class_name

            if vehicle_data and vehicle_data.t then
                display_name = vehicle_data.t.PrintName or car.class_name
            end

            local js = string.format(
                "addCar(%q, %q, %q, %q)",
                display_name,
                car.class_name,
                car.icon_path,
                category
            )

            html:QueueJavascript( js )
        end
    end
end )
