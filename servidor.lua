-- CLAUDEX SERVER HOPPER v1.2 - Auto-loop mismo juego + filtro de players
-- queda buscando hasta encontrar server rico

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local placeId = game.PlaceId
local localPlr = Players.LocalPlayer

-- CONFIG ★★★★★★★★★★★★★★★★★★★★★★★★★★★★
local MIN_RAP_BEST  = 500000    -- al menos UN player con este RAP
local MIN_RAP_TOTAL = 1000000   -- o RAP total del server
local MIN_PLAYERS   = 5          -- ★ MINIMO de jugadores en server destino
local MAX_PLAYERS   = 99         -- maximo (99 = sin tope)
local SCAN_DELAY    = 0.4        -- delay entre requests Rolimons
-- ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

local ROLIMONS = "https://www.rolimons.com/playerapi/player/"
local req = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
if not req then warn("[ABOMINATION] executor sin http_request") return end

if queue_on_teleport then
    queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/servidor.lua"))
end

local function getRAP(uid)
    local ok, res = pcall(req, { Url = ROLIMONS .. uid, Method = "GET" })
    if not ok or res.StatusCode ~= 200 then return 0 end
    local d = HttpService:JSONDecode(res.Body)
    return tonumber(d.rap) or 0
end

local function scanServer()
    local total, best, bestPlr = 0, 0, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlr then
            local rap = getRAP(p.UserId)
            total = total + rap
            if rap > best then best, bestPlr = rap, p.Name end
            task.wait(SCAN_DELAY)
        end
    end
    return total, best, bestPlr
end

local function hop()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
    local ok, res = pcall(req, { Url = url, Method = "GET" })
    if not ok or res.StatusCode ~= 200 then return end
    local servers = HttpService:JSONDecode(res.Body).data or {}
    for i = #servers, 2, -1 do
        local j = math.random(i)
        servers[i], servers[j] = servers[j], servers[i]
    end
    for _, s in ipairs(servers) do
        -- ★ filtro: minimo players, maximo, y que no sea el mismo server
        if s.playing >= MIN_PLAYERS
           and s.playing <= MAX_PLAYERS
           and s.playing < s.maxPlayers
           and s.id ~= game.JobId then
            print(("[HOP] saltando a server con %d players..."):format(s.playing))
            TeleportService:TeleportToPlaceInstance(placeId, s.id, localPlr)
            return
        end
    end
    warn("[CLAUDEX] Ningun server cumple MIN_PLAYERS=" .. MIN_PLAYERS)
end

-- MAIN
task.wait(4)
print("[CLAUDEX] Escaneando server...")

local total, best, bestPlr = scanServer()
print(("RAP total: %s | Mejor: %s (%s) | Players: %d"):format(total, best, bestPlr or "N/A", #Players:GetPlayers()))

local enoughPlayers = #Players:GetPlayers() >= MIN_PLAYERS
local enoughRAP = best >= MIN_RAP_BEST or total >= MIN_RAP_TOTAL

if enoughPlayers and enoughRAP then
    print("SALVATION!!!!!!!!! server rico encontrado, anclando aca")
else
    if not enoughPlayers then print("pocos players, saltando...") end
    if not enoughRAP then print("server pelado, saltando...") end
    hop()
end
