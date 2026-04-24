--[[
    CLAUDEX SERVER HOPPER v1.3 - BULLETPROOF EDITION
    - Auto-loop en el mismo juego
    - Filtro por RAP + cantidad de players
    - Retry con rate-limit handling
    - Pagination (busca en TODOS los servers, no solo primeros 100)
    - Fallback de campos API (robusto ante cambios)
    - Fallback de http_request args (Url/url)
    - Max-hop counter (no loop infinito)
    - Limpia queue_on_teleport al anclar
--]]

local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local Players          = game:GetService("Players")
local placeId          = game.PlaceId
local localPlr         = Players.LocalPlayer

-- ★★★★★★★★★★★★ CONFIG ★★★★★★★★★★★★
local MIN_RAP_BEST   = 500000
local MIN_RAP_TOTAL  = 1000000
local MIN_PLAYERS    = 5
local MAX_PLAYERS    = 99
local SCAN_DELAY     = 0.5        -- seg entre requests Rolimons (0.5 = seguro)
local MAX_HOPS       = 50         -- limite de saltos antes de rendirse
local HOP_DELAY      = 1          -- delay antes de cada hop
local RELAX_AFTER    = 15         -- tras N hops sin exito, relajar filtros
local SELF_URL       = "https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/servidor.lua"
-- ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

-- ═══ EXECUTOR COMPAT ═══
local req = http_request or request or (syn and syn.request)
           or (fluxus and fluxus.request) or (http and http.request)
if not req then
    warn("[ABOMINATION] executor sin http_request — parce, cambia de executor")
    return
end

-- wrapper que soporta tanto {Url=...} como {url=...}
local function httpGet(url, retries)
    retries = retries or 3
    for i = 1, retries do
        local ok, res = pcall(req, { Url = url, url = url, Method = "GET", method = "GET" })
        if ok and res then
            local status = res.StatusCode or res.status_code or res.Status
            if status == 200 then
                return res.Body or res.body
            elseif status == 429 then
                -- rate limit: backoff exponencial
                warn(("[CLAUDEX] Rate-limit 429 (intento %d/%d) esperando..."):format(i, retries))
                task.wait(2 ^ i)
            else
                warn(("[CLAUDEX] HTTP %s en %s"):format(tostring(status), url))
                return nil
            end
        else
            task.wait(1)
        end
    end
    return nil
end

-- ═══ HOP COUNTER (persistente via getgenv) ═══
getgenv().CLAUDEX_HOP_STATE = getgenv().CLAUDEX_HOP_STATE or {
    hops = 0,
    bestSeen = 0,
    relaxed = false,
}
local state = getgenv().CLAUDEX_HOP_STATE

-- ═══ QUEUE-ON-TELEPORT (respawn en server nuevo) ═══
local function setQueue()
    if queue_on_teleport then
        local ok, body = pcall(game.HttpGet, game, SELF_URL)
        if ok and body and #body > 50 then
            queue_on_teleport(body)
            return true
        else
            warn("[CLAUDEX] No pude bajar self-URL, toca re-ejecutar manual en cada hop")
        end
    end
    return false
end

local function clearQueue()
    if queue_on_teleport then
        pcall(queue_on_teleport, "-- anclado")
    end
end

setQueue()

-- ═══ ROLIMONS ═══
local function getRAP(uid)
    local body = httpGet("https://www.rolimons.com/playerapi/player/" .. uid, 2)
    if not body then return 0, false end

    local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or type(data) ~= "table" then return 0, false end

    -- fallback de nombres de campo (por si Rolimons cambia)
    local rap = data.rap or data.RAP or data.Rap or data.recent_avg_price or 0
    return tonumber(rap) or 0, true
end

local function scanServer()
    local total, best, bestPlr, checked = 0, 0, nil, 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlr then
            local rap, ok = getRAP(p.UserId)
            if ok then checked = checked + 1 end
            total = total + rap
            if rap > best then best, bestPlr = rap, p.Name end
            task.wait(SCAN_DELAY)
        end
    end
    return total, best, bestPlr, checked
end

-- ═══ SERVER LIST CON PAGINATION ═══
local function fetchServerPage(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(placeId)
    if cursor then url = url .. "&cursor=" .. cursor end
    local body = httpGet(url)
    if not body then return {}, nil end

    local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or not data then return {}, nil end
    return data.data or {}, data.nextPageCursor
end

local function findGoodServer(minP, maxP)
    local cursor, pagesScanned = nil, 0
    repeat
        local servers, nextCursor = fetchServerPage(cursor)
        -- shuffle
        for i = #servers, 2, -1 do
            local j = math.random(i)
            servers[i], servers[j] = servers[j], servers[i]
        end

        for _, s in ipairs(servers) do
            if s.playing >= minP
               and s.playing <= maxP
               and s.playing < s.maxPlayers
               and s.id ~= game.JobId then
                return s
            end
        end

        cursor = nextCursor
        pagesScanned = pagesScanned + 1
    until not cursor or pagesScanned >= 5   -- max 500 servers escaneados

    return nil
end

local function hop()
    state.hops = state.hops + 1

    -- relajar filtros tras muchos intentos
    local minP, maxP = MIN_PLAYERS, MAX_PLAYERS
    if state.hops >= RELAX_AFTER and not state.relaxed then
        state.relaxed = true
        minP = math.max(1, MIN_PLAYERS - 3)
        warn(("[CLAUDEX] %d hops sin exito, relajando MIN_PLAYERS a %d"):format(state.hops, minP))
    end

    if state.hops > MAX_HOPS then
        warn(("[CLAUDEX] ABOMINATION: %d hops sin encontrar server rico, me rindo parce"):format(MAX_HOPS))
        clearQueue()
        return
    end

    local srv = findGoodServer(minP, maxP)
    if not srv then
        warn("[CLAUDEX] Ningun server disponible, reintentando en 5s...")
        task.wait(5)
        return hop()
    end

    print(("[HOP %d/%d] → server con %d players"):format(state.hops, MAX_HOPS, srv.playing))
    task.wait(HOP_DELAY)
    local okTp = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, srv.id, localPlr)
    if not okTp then
        warn("[CLAUDEX] Teleport fallo, reintentando...")
        task.wait(3)
        return hop()
    end
end

-- ═══ MAIN ═══
task.wait(5) -- dar tiempo a que carguen players

print(("[CLAUDEX HOPPER v1.3] Hop #%d | Escaneando server actual..."):format(state.hops))

local playerCount = #Players:GetPlayers()
local total, best, bestPlr, checked = scanServer()

print(("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"))
print(("Players     : %d"):format(playerCount))
print(("RAP checked : %d/%d"):format(checked, playerCount - 1))
print(("RAP total   : %s"):format(total))
print(("RAP mejor   : %s (%s)"):format(best, bestPlr or "N/A"))
print(("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"))

if best > state.bestSeen then state.bestSeen = best end

local enoughPlayers = playerCount >= MIN_PLAYERS
local enoughRAP     = best >= MIN_RAP_BEST or total >= MIN_RAP_TOTAL

if enoughPlayers and enoughRAP then
    print("💎💎💎 SALVATION!!!!!!!!!!!! server rico encontrado, ANCLADO aca 💎💎💎")
    print(("Mejor player: %s con RAP %s"):format(bestPlr or "?", best))
    clearQueue()  -- detiene el auto-loop
    state.hops = 0  -- reset por si el user relanza
    state.relaxed = false
else
    if not enoughPlayers then
        print(("[SKIP] solo %d players (minimo %d)"):format(playerCount, MIN_PLAYERS))
    end
    if not enoughRAP then
        print(("[SKIP] RAP bajo (best %d < %d, total %d < %d)"):format(best, MIN_RAP_BEST, total, MIN_RAP_TOTAL))
    end
    hop()
end
