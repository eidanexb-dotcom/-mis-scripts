-- REPORTER + BAN SYSTEM (banlist desde GitHub)
local webhook = "https://discord.com/api/webhooks/1491204494623637628/hgrhgL0AInCEZhpPpvVvogH67VS2B5mYfQqLyWLIEthI0shF5L3f2g6jC388-t8wmSwM"
local banlist_url = "https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/ban%C2%B4s.lua"

local player = game:GetService("Players").LocalPlayer
local nombre = player.Name
local display = player.DisplayName
local userid = player.UserId
local juego = game.PlaceId
local jobid = game.JobId

local ejecutor = "Desconocido"
pcall(function() ejecutor = identifyexecutor() or getexecutorname() or "Desconocido" end)

local hora = os.date("%Y-%m-%d %H:%M:%S")
local req = request or http_request

-- === DESCARGAR BANLIST DESDE GITHUB ===
local baneado = false
pcall(function()
    local data = game:HttpGet(banlist_url)
    if data then
        for linea in data:gmatch("[^\r\n]+") do
            linea = linea:gsub("%s+", "")
            if linea:sub(1, 2) == "--" then -- ignorar comentarios
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
            Body = game:GetService("HttpService"):JSONEncode({
                embeds = {{
                    title = "BANEADO EXPULSADO",
                    color = 16711680,
                    description = "Un baneado intento usar el script. Fue KICKEADO.",
                    fields = {
                        {name = "Jugador", value = nombre .. " (@" .. display .. ")", inline = true},
                        {name = "UserID", value = tostring(userid), inline = true},
                        {name = "Juego", value = tostring(juego), inline = true},
                        {name = "Hora", value = hora, inline = true},
                    }
                }}
            })
        })
    end)

    print("[Reporter] BANEADO: " .. nombre .. " - KICKEADO")
    player:Kick("\n\nEstas BANEADO de este script.\nNo tienes acceso.\n\nContacta al creador si crees que es un error.")
    return
end

-- === REPORTE NORMAL ===
pcall(function()
    req({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode({
            embeds = {{
                title = "Script Ejecutado",
                color = 65280,
                fields = {
                    {name = "Jugador", value = nombre .. " (@" .. display .. ")", inline = true},
                    {name = "UserID", value = tostring(userid), inline = true},
                    {name = "Executor", value = ejecutor, inline = true},
                    {name = "Juego (PlaceId)", value = tostring(juego), inline = true},
                    {name = "Servidor", value = string.sub(jobid, 1, 16) .. "...", inline = true},
                    {name = "Hora", value = hora, inline = true},
                }
            }}
        })
    end)
end)

print("[Reporter] Enviado: " .. nombre)
