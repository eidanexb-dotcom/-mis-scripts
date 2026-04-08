-- REPORTER + BAN SYSTEM (banlist desde GitHub)
local webhook = "https://discord.com/api/webhooks/1491204494623637628/hgrhgL0AInCEZhpPpvVvogH67VS2B5mYfQqLyWLIEthI0shF5L3f2g6jC388-t8wmSwM"
local banlist_url = "https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/ban%C2%B4s.lua"

local player = game:GetService("Players").LocalPlayer
local nombre = player.Name
local display = player.DisplayName
local userid = player.UserId
local juego = game.PlaceId
local juego_nombre = "Desconocido"
pcall(function() juego_nombre = game:GetService("MarketplaceService"):GetProductInfo(juego).Name end)

local jobid = game.JobId
local invite = "https://www.roblox.com/games/" .. tostring(juego) .. "?privateServerLinkCode=&gameInstanceId=" .. jobid

local req = request or http_request
local hs = game:GetService("HttpService")

-- === CARGAR USUARIOS CONOCIDOS ===
local conocidos = {}
pcall(function()
    local data = readfile("reporter_conocidos.txt")
    if data then
        for linea in data:gmatch("[^\r\n]+") do
            conocidos[linea] = true
        end
    end
end)

local ya_conocido = conocidos[tostring(userid)] or false

-- Guardar este jugador como conocido
pcall(function()
    if not ya_conocido then
        appendfile("reporter_conocidos.txt", tostring(userid) .. "\n")
    end
end)

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

-- === CARGAR BANEADOS CONOCIDOS (pa saber si es reincidente) ===
local ban_conocido = {}
pcall(function()
    local data = readfile("reporter_baneados.txt")
    if data then
        for linea in data:gmatch("[^\r\n]+") do
            ban_conocido[linea] = true
        end
    end
end)

local ban_reincidente = ban_conocido[tostring(userid)] or false

-- === DETERMINAR ESTADO ===
local titulo = ""
local color = 0

if baneado and not ban_reincidente then
    -- Primera vez baneado → ROJO
    titulo = "Bloqueado no sabemos porque"
    color = 16711680
    pcall(function() appendfile("reporter_baneados.txt", tostring(userid) .. "\n") end)

elseif baneado and ban_reincidente then
    -- Baneado que vuelve a intentar → GRIS
    titulo = "nuestro amigo quiso volver"
    color = 9807270

elseif not baneado and ya_conocido then
    -- Jugador que ya habia usado el script → VERDE
    titulo = "Se reporta nuestro amigo"
    color = 65280

else
    -- Jugador nuevo → AZUL
    titulo = "NUEVO integrante"
    color = 3447003
end

-- === ENVIAR AL DISCORD ===
pcall(function()
    req({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = hs:JSONEncode({
            embeds = {{
                title = titulo,
                color = color,
                fields = {
                    {name = "Jugador", value = nombre .. " (@" .. display .. ")", inline = true},
                    {name = "UserID", value = tostring(userid), inline = true},
                    {name = "Juego", value = juego_nombre .. " (" .. tostring(juego) .. ")", inline = true},
                    {name = "Unirse al servidor", value = "[Click aqui pa entrar](" .. invite .. ")", inline = false},
                }
            }}
        })
    })
end)

print("[Reporter] " .. titulo .. ": " .. nombre)

-- === KICK SI ESTA BANEADO ===
if baneado then
    player:Kick("\n\nsabes porque la opinion de un mocho no cuenta?\n\nporque su opinion es invalida.")
    return
end
