-- REPORTER + BAN SYSTEM
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

-- === MEMORIA DISFRAZADA ===
local mem_file = "1f4k0s8d5v4q.json"
local memoria = {}

pcall(function()
    if isfile(mem_file) then
        memoria = hs:JSONDecode(readfile(mem_file))
    end
end)

local uid = tostring(userid)
local ya_estuvo = memoria[uid] == true

-- Guardar jugador
memoria[uid] = true
pcall(function() writefile(mem_file, hs:JSONEncode(memoria)) end)

-- === REVISAR BAN DESDE GITHUB ===
local baneado = false
pcall(function()
    local data = game:HttpGet(banlist_url)
    if data then
        for linea in data:gmatch("[^\r\n]+") do
            linea = linea:gsub("%s+", "")
            if linea:sub(1, 2) == "--" then
            elseif linea == uid or linea:lower() == nombre:lower() then
                baneado = true
                break
            end
        end
    end
end)

-- === DETERMINAR ESTADO ===
local titulo = ""
local color = 0

if baneado and not ya_estuvo then
    titulo = "Bloqueado no sabemos porque"
    color = 16711680
elseif baneado and ya_estuvo then
    titulo = "nuestro amigo quiso volver"
    color = 9807270
elseif not baneado and ya_estuvo then
    titulo = "Se reporta nuestro amigo"
    color = 65280
else
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
end
