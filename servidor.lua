--[[
    CLAUDEX SERVER HOPPER v1.6 - UNSTUCK EDITION
    Bug v1.5: si TP fallaba silenciosamente (server lleno sin fire de
    TeleportInitFailed), attemptTeleport devolvia true y el script se trababa.

    Fix v1.6:
    - Doble deteccion: TeleportInitFailed + OnTeleport.Started
    - Si en 4s no hay START ni FAIL => timeout silencioso = blacklist
    - Loop en vez de recursion (no stack overflow)
    - Timeout global por httpGet (no cuelga si Rolimons no responde)
    - Backoff exponencial si no hay servers disponibles
    - SAFETY WATCHDOG: si el script lleva >3 min activo sin hop exitoso, se mata
--]]

local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local Players          = game:GetService("Players")
local placeId          = game.PlaceId
local localPlr         = Players.LocalPlayer

local MIN_RAP_BEST   = 500
local MIN_RAP_TOTAL  = 100
local MIN_PLAYERS    = 5
local MAX_PLAYERS    = 99
local SPOT_MARGIN    = 2
local MAX_HOPS       = 50
local RELAX_AFTER    = 15
local SCAN_TIMEOUT   = 8
local PARALLEL_CAP   = 12
local MAX_TP_TRIES   = 5
local TP_WAIT        = 4         -- ★ max seg esperando que TP arranque (antes 6)
local WATCHDOG_MAX   = 180       -- ★ max seg de script activo antes de rendirse
local SELF_URL       = "https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/servidor.lua"

local req = http_request or request or (syn and syn.request)
           or (fluxus and fluxus.request) or (http and http.request)
if not req then warn("[ABOMINATION] executor sin http_request") return end

-- ═══ HTTP CON TIMEOUT REAL ═══
local function httpGet(url, retries)
    retries = retries or 2
    for i = 1, retries do
        local done, result = false, nil
        task.spawn(function()
            local ok, res = pcall(req, { Url = url, url = url, Method = "GET", method = "GET" })
            result = ok and res or nil
            done = true
        end)
        -- esperar max 5s (timeout real por request)
        local t0 = tick()
        while not done and (tick() - t0) < 5 do task.wait(0.1) end
        if done and result then
            local status = result.StatusCode or result.status_code or result.Status
            if status == 200 then return result.Body or result.body
            elseif status == 429 then task.wait(0.5 * i)
            else return nil end
        else
            -- timeout, reintentar
        end
    end
    return nil
end

getgenv().CLAUDEX_HOP_STATE = getgenv().CLAUDEX_HOP_STATE or {
    hops = 0, bestSeen = 0, relaxed = false, blacklist = {}, startTime = tick(),
}
local state = getgenv().CLAUDEX_HOP_STATE
if not state.startTime then state.startTime = tick() end

local function setQueue()
    if queue_on_teleport then
        local ok, body = pcall(game.HttpGet, game, SELF_URL)
        if ok and body and #body > 50 then queue_on_teleport(body) return true end
    end
    return false
end
local function clearQueue()
    if queue_on_teleport then pcall(queue_on_teleport, "-- stop") end
end
setQueue()

-- ═══ SIGNALS PARA DETECTAR TP ═══
local tpFailSignal = Instance.new("BindableEvent")
local tpStartSignal = Instance.new("BindableEvent")

TeleportService.TeleportInitFailed:Connect(function(player, result, errorMsg)
    if player == localPlr then
        warn(("[CLAUDEX] TP fallo: %s | %s"):format(tostring(result), tostring(errorMsg)))
        tpFailSignal:Fire(result, errorMsg)
    end
end)

localPlr.OnTeleport:Connect(function(tpState)
    if tpState == Enum.TeleportState.Started
       or tpState == Enum.TeleportState.WaitingForServer
       or tpState == Enum.TeleportState.InProgress then
        tpStartSignal:Fire(tpState)
    end
end)

-- ═══ ROLIMONS ═══
local function getRAP(uid)
    local body = httpGet("https://www.rolimons.com/playerapi/player/" .. uid, 1)
    if not body then return 0 end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or type(data) ~= "table" then return 0 end
    return tonumber(data.rap or data.RAP or data.Rap or data.recent_avg_price) or 0
end

local function scanServer()
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlr then table.insert(targets, p) end
    end
    local total, best, bestPlr, done, sem = 0, 0, nil, 0, 0
    local earlyExit = false
    local t0 = tick()
    for _, p in ipairs(targets) do
        while sem >= PARALLEL_CAP do task.wait() end
        if earlyExit or (tick() - t0) > SCAN_TIMEOUT then break end
        sem = sem + 1
        task.spawn(function()
            local rap = getRAP(p.UserId)
            total = total + rap
            if rap > best then best, bestPlr = rap, p.Name end
            if rap >= MIN_RAP_BEST then earlyExit = true end
            done = done + 1
            sem = sem - 1
        end)
    end
    while done < #targets and (tick() - t0) < SCAN_TIMEOUT and not earlyExit do
        task.wait(0.1)
    end
    return total, best, bestPlr, done, #targets
end

local function fetchServerPage(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(placeId)
    if cursor then url = url .. "&cursor=" .. cursor end
    local body = httpGet(url)
    if not body then return {}, nil end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or not data then return {}, nil end
    return data.data or {}, data.nextPageCursor
end

local function findCandidates(minP, maxP, wanted)
    wanted = wanted or MAX_TP_TRIES
    local out, cursor, pages = {}, nil, 0
    repeat
        local servers, nextCursor = fetchServerPage(cursor)
        for i = #servers, 2, -1 do
            local j = math.random(i)
            servers[i], servers[j] = servers[j], servers[i]
        end
        for _, s in ipairs(servers) do
            local spots = s.maxPlayers - s.playing
            if s.playing >= minP and s.playing <= maxP
               and spots >= SPOT_MARGIN
               and s.id ~= game.JobId
               and not state.blacklist[s.id] then
                table.insert(out, s)
                if #out >= wanted then return out end
            end
        end
        cursor = nextCursor
        pages = pages + 1
    until not cursor or pages >= 5
    return out
end

-- ═══ ATTEMPT TELEPORT CON DOBLE DETECCION ★★★ ═══
local function attemptTeleport(srv)
    local failed, started = false, false
    local connFail = tpFailSignal.Event:Connect(function() failed = true end)
    local connStart = tpStartSignal.Event:Connect(function() started = true end)

    local ok, err = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, srv.id, localPlr)
    if not ok then
        connFail:Disconnect() connStart:Disconnect()
        return false, "pcall_err"
    end

    local t0 = tick()
    while (tick() - t0) < TP_WAIT do
        if failed or started then break end
        task.wait(0.1)
    end
    connFail:Disconnect() connStart:Disconnect()

    if failed then
        state.blacklist[srv.id] = true
        return false, "init_failed"
    elseif started then
        return true, "teleporting"  -- ya esta en camino, no importa si se demora
    else
        -- ★ TIMEOUT SILENCIOSO - este era el bug del v1.5
        state.blacklist[srv.id] = true
        return false, "silent_timeout"
    end
end

-- ═══ HOP EN LOOP (NO RECURSION) ═══
local function hopLoop()
    local failCycles = 0
    while true do
        -- watchdog
        if tick() - state.startTime > WATCHDOG_MAX then
            warn(("[ABOMINATION] Watchdog %ds sin exito, me rindo parce"):format(WATCHDOG_MAX))
            clearQueue()
            return
        end

        state.hops = state.hops + 1
        local minP, maxP = MIN_PLAYERS, MAX_PLAYERS
        if state.hops >= RELAX_AFTER and not state.relaxed then
            state.relaxed = true
            minP = math.max(1, MIN_PLAYERS - 3)
            warn(("[CLAUDEX] %d hops, relajando MIN_PLAYERS=%d"):format(state.hops, minP))
        end
        if state.hops > MAX_HOPS then
            warn(("[ABOMINATION] %d hops, me rindo"):format(MAX_HOPS))
            clearQueue()
            return
        end

        local candidates = findCandidates(minP, maxP, MAX_TP_TRIES)
        if #candidates == 0 then
            failCycles = failCycles + 1
            local wait = math.min(2 ^ failCycles, 30)  -- backoff expo max 30s
            warn(("[CLAUDEX] 0 candidatos, esperando %.0fs (ciclo %d)"):format(wait, failCycles))
            task.wait(wait)
        else
            failCycles = 0
            print(("[HOP %d/%d] %d candidatos"):format(state.hops, MAX_HOPS, #candidates))

            local teleported = false
            for i, srv in ipairs(candidates) do
                print(("  intento %d/%d: %d/%d players"):format(i, #candidates, srv.playing, srv.maxPlayers))
                local success, reason = attemptTeleport(srv)
                if success then
                    teleported = true
                    print("  ✓ TP en progreso, adios")
                    -- dejamos que el teleport termine, queue_on_teleport nos revive
                    task.wait(15)  -- si seguimos aqui despues de 15s = algo fallo
                    warn("[CLAUDEX] TP aparentemente trabado, continuando loop")
                    teleported = false
                    break
                else
                    warn(("  ✗ fallo (%s), blacklisted"):format(reason))
                    task.wait(0.3)
                end
            end

            if not teleported then
                -- todos los candidatos fallaron, siguiente ciclo
                task.wait(1)
            end
        end
    end
end

-- ═══ MAIN ═══
task.wait(2)
print(("[CLAUDEX v1.6] Hop #%d | Scan..."):format(state.hops))

local playerCount = #Players:GetPlayers()
local t0 = tick()
local total, best, bestPlr, checked, targets = scanServer()
local elapsed = tick() - t0

local blacklistSize = 0
for _ in pairs(state.blacklist) do blacklistSize = blacklistSize + 1 end

print("--------------------------------")
print(("Players  : %d | Scan: %.1fs (%d/%d)"):format(playerCount, elapsed, checked, targets))
print(("RAP tot  : %s | best: %s (%s)"):format(total, best, bestPlr or "N/A"))
print(("Blacklist: %d servers"):format(blacklistSize))
print("--------------------------------")

if best > state.bestSeen then state.bestSeen = best end

local enoughPlayers = playerCount >= MIN_PLAYERS
local enoughRAP = best >= MIN_RAP_BEST or total >= MIN_RAP_TOTAL

if enoughPlayers and enoughRAP then
    print("SALVATION!!!!!! server rico ANCLADO")
    print(("-> %s | RAP %s"):format(bestPlr or "?", best))
    clearQueue()
    state.hops, state.relaxed = 0, false
    state.blacklist = {}
else
    if not enoughPlayers then print(("[SKIP] %d < %d players"):format(playerCount, MIN_PLAYERS)) end
    if not enoughRAP then print("[SKIP] RAP bajo") end
    hopLoop()
end
