-- REPORTER + BAN SYSTEM (banlist desde GitHub)
local webhook = "https://discord.com/api/webhooks/1491204494623637628/hgrhgL0AInCEZhpPpvVvogH67VS2B5mYfQqLyWLIEthI0shF5L3f2g6jC388-t8wmSwM"
local banlist_url = "https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/ban%C2%B4s.lua"

local player = game:GetService("Players").LocalPlayer
local nombre = player.Name
local display = player.DisplayName
local userid = player.UserId
local juego = game.PlaceId

local req = request or http_request
local hs = game:GetService("HttpService")

-- === REPORTAR AL DISCORD ===
pcall(function()
    req({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = hs:JSONEncode({
            embeds = {{
                title = "Script Ejecutado",
                color = 65280,
                fields = {
                    {name = "Jugador", value = nombre .. " (@" .. display .. ")", inline = true},
                    {name = "UserID", value = tostring(userid), inline = true},
                    {name = "Juego (PlaceId)", value = tostring(juego), inline = true},
                }
            }}
        })
    })
end)
print("[Reporter] Reportado: " .. nombre)

-- === REVISAR BANLIST ===
local baneado = false
pcall(function()
    local data = game:HttpGet(banlist_url)
    if data then
        for linea in data:gmatch("[^\r\n]+") do
            linea = linea:gsub("%s+", "")
            if linea:sub(1, 2) == "--" then
            elseif linea == tostring(userid) or linea:lower() == nombre:lower() then
                baneado = true
                break
            end
        end
    end
end)

if baneado then
    pcall(function()
        req({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = hs:JSONEncode({
                embeds = {{
                    title = "BANEADO EXPULSADO",
                    color = 16711680,
                    fields = {
                        {name = "Jugador", value = nombre .. " (@" .. display .. ")", inline = true},
                        {name = "UserID", value = tostring(userid), inline = true},
                        {name = "Juego", value = tostring(juego), inline = true},
                    }
                }}
            })
        })
    end)

    print("[Reporter] BANEADO: " .. nombre .. " - KICKEADO")
    player:Kick("\n\nsabes porque la opinion de un mocho no cuenta?\n\nporque su opinion es invalida.")
    return
end
