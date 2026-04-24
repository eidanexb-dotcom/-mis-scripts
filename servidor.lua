--[[
    CLAUDEX SERVER HOPPER v2.0 - MANUAL GUI EDITION
    Ya NO salta automatico. Despues de escanear cada server, muestra
    un GUI con las stats y VOS decidis si quedarte o saltar.

    Queue_on_teleport sigue activo para que el script se respawn en el
    server nuevo, pero alli te vuelve a preguntar en vez de decidir solo.
--]]

local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local placeId          = game.PlaceId
local localPlr         = Players.LocalPlayer

local MIN_PLAYERS    = 1
local MAX_PLAYERS    = 99
local SPOT_MARGIN    = 2
local SCAN_TIMEOUT   = 8
local PARALLEL_CAP   = 12
local MAX_TP_TRIES   = 5
local TP_WAIT        = 4
local SELF_URL       = "https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/servidor.lua"

local req = http_request or request or (syn and syn.request)
           or (fluxus and fluxus.request) or (http and http.request)
if not req then warn("[ABOMINATION] executor sin http_request") return end

local function httpGet(url, retries)
    retries = retries or 2
    for i = 1, retries do
        local done, result = false, nil
        task.spawn(function()
            local ok, res = pcall(req, { Url = url, url = url, Method = "GET", method = "GET" })
            result = ok and res or nil
            done = true
        end)
        local t0 = tick()
        while not done and (tick() - t0) < 5 do task.wait(0.1) end
        if done and result then
            local status = result.StatusCode or result.status_code or result.Status
            if status == 200 then return result.Body or result.body
            elseif status == 429 then task.wait(0.5 * i)
            else return nil end
        end
    end
    return nil
end

getgenv().CLAUDEX_HOP_STATE = getgenv().CLAUDEX_HOP_STATE or {
    hops = 0, blacklist = {},
}
local state = getgenv().CLAUDEX_HOP_STATE

local function setQueue()
    if queue_on_teleport then
        local ok, body = pcall(game.HttpGet, game, SELF_URL)
        if ok and body and #body > 50 then queue_on_teleport(body) return true end
    end
    return false
end
local function clearQueue()
    if queue_on_teleport then pcall(queue_on_teleport, "-- stopped") end
end
setQueue()

local tpFailSignal = Instance.new("BindableEvent")
local tpStartSignal = Instance.new("BindableEvent")
TeleportService.TeleportInitFailed:Connect(function(p, r, e)
    if p == localPlr then tpFailSignal:Fire(r, e) end
end)
localPlr.OnTeleport:Connect(function(s)
    if s == Enum.TeleportState.Started or s == Enum.TeleportState.WaitingForServer
       or s == Enum.TeleportState.InProgress then tpStartSignal:Fire(s) end
end)

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
    local t0 = tick()
    local playerRAPs = {}
    for _, p in ipairs(targets) do
        while sem >= PARALLEL_CAP do task.wait() end
        if (tick() - t0) > SCAN_TIMEOUT then break end
        sem = sem + 1
        task.spawn(function()
            local rap = getRAP(p.UserId)
            total = total + rap
            if rap > best then best, bestPlr = rap, p.Name end
            table.insert(playerRAPs, { name = p.Name, rap = rap })
            done = done + 1
            sem = sem - 1
        end)
    end
    while done < #targets and (tick() - t0) < SCAN_TIMEOUT do task.wait(0.1) end
    table.sort(playerRAPs, function(a, b) return a.rap > b.rap end)
    return total, best, bestPlr, playerRAPs
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

local function attemptTeleport(srv)
    local failed, started = false, false
    local connFail = tpFailSignal.Event:Connect(function() failed = true end)
    local connStart = tpStartSignal.Event:Connect(function() started = true end)
    local ok = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, srv.id, localPlr)
    if not ok then connFail:Disconnect() connStart:Disconnect() return false end
    local t0 = tick()
    while (tick() - t0) < TP_WAIT do
        if failed or started then break end
        task.wait(0.1)
    end
    connFail:Disconnect() connStart:Disconnect()
    if failed then state.blacklist[srv.id] = true return false end
    if started then return true end
    state.blacklist[srv.id] = true
    return false
end

local function hopTo()
    local candidates = findCandidates(MIN_PLAYERS, MAX_PLAYERS, MAX_TP_TRIES)
    if #candidates == 0 then
        warn("[CLAUDEX] 0 candidatos disponibles")
        return false
    end
    for i, srv in ipairs(candidates) do
        print(("  intento %d/%d: %d/%d players"):format(i, #candidates, srv.playing, srv.maxPlayers))
        if attemptTeleport(srv) then return true end
    end
    return false
end

-- ═══ GUI ═══
local function buildGUI(playerCount, total, best, bestPlr, playerRAPs, scanTime, onChoice)
    -- limpiar GUIs previas
    for _, g in ipairs(CoreGui:GetChildren()) do
        if g.Name == "ClaudexHopperGUI" then g:Destroy() end
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ClaudexHopperGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 360, 0, 340)
    frame.Position = UDim2.new(0.5, -180, 0.5, -170)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(100, 60, 255)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 36)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(100, 60, 255)
    title.BorderSizePixel = 0
    title.Text = "💎 CLAUDEX HOPPER v2.0  |  Hop #" .. state.hops
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, -20, 0, 110)
    info.Position = UDim2.new(0, 10, 0, 46)
    info.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    info.BorderSizePixel = 0
    info.Font = Enum.Font.Code
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(230, 230, 240)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.RichText = true
    info.Text = string.format([[
  <b>Players</b>    : %d
  <b>Scan time</b>  : %.1fs
  <b>RAP total</b>  : %s
  <b>Mejor RAP</b>  : <font color="#ffd700">%s</font>
  <b>Mejor player</b>: <font color="#99ff99">%s</font>
  <b>Server ID</b>  : %s]],
        playerCount, scanTime, tostring(total), tostring(best),
        bestPlr or "N/A", tostring(game.JobId):sub(1,10) .. "...")
    Instance.new("UICorner", info).CornerRadius = UDim.new(0, 6)
    local infoPad = Instance.new("UIPadding", info)
    infoPad.PaddingLeft = UDim.new(0, 8)
    infoPad.PaddingTop = UDim.new(0, 6)

    -- top 3 players
    local top = Instance.new("TextLabel", frame)
    top.Size = UDim2.new(1, -20, 0, 70)
    top.Position = UDim2.new(0, 10, 0, 162)
    top.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    top.BorderSizePixel = 0
    top.Font = Enum.Font.Code
    top.TextSize = 11
    top.TextColor3 = Color3.fromRGB(200, 200, 220)
    top.TextXAlignment = Enum.TextXAlignment.Left
    top.TextYAlignment = Enum.TextYAlignment.Top
    top.RichText = true
    local topTxt = "  <b>Top 3 players:</b>\n"
    for i = 1, math.min(3, #playerRAPs) do
        local p = playerRAPs[i]
        topTxt = topTxt .. string.format("  %d. %s — RAP %s\n", i, p.name, tostring(p.rap))
    end
    if #playerRAPs == 0 then topTxt = topTxt .. "  (ningun player escaneado)" end
    top.Text = topTxt
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 6)
    local topPad = Instance.new("UIPadding", top)
    topPad.PaddingLeft = UDim.new(0, 8)
    topPad.PaddingTop = UDim.new(0, 6)

    -- botones
    local btnStay = Instance.new("TextButton", frame)
    btnStay.Size = UDim2.new(0.5, -15, 0, 46)
    btnStay.Position = UDim2.new(0, 10, 1, -56)
    btnStay.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
    btnStay.BorderSizePixel = 0
    btnStay.Text = "💎 QUEDARME"
    btnStay.TextColor3 = Color3.new(1,1,1)
    btnStay.Font = Enum.Font.GothamBold
    btnStay.TextSize = 14
    Instance.new("UICorner", btnStay).CornerRadius = UDim.new(0, 8)

    local btnHop = Instance.new("TextButton", frame)
    btnHop.Size = UDim2.new(0.5, -15, 0, 46)
    btnHop.Position = UDim2.new(0.5, 5, 1, -56)
    btnHop.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    btnHop.BorderSizePixel = 0
    btnHop.Text = "🪹 SALTAR"
    btnHop.TextColor3 = Color3.new(1,1,1)
    btnHop.Font = Enum.Font.GothamBold
    btnHop.TextSize = 14
    Instance.new("UICorner", btnHop).CornerRadius = UDim.new(0, 8)

    local closed = false
    btnStay.MouseButton1Click:Connect(function()
        if closed then return end closed = true
        gui:Destroy()
        onChoice("stay")
    end)
    btnHop.MouseButton1Click:Connect(function()
        if closed then return end closed = true
        gui:Destroy()
        onChoice("hop")
    end)

    -- hover feedback
    btnStay.MouseEnter:Connect(function() btnStay.BackgroundColor3 = Color3.fromRGB(60, 210, 110) end)
    btnStay.MouseLeave:Connect(function() btnStay.BackgroundColor3 = Color3.fromRGB(40, 180, 90) end)
    btnHop.MouseEnter:Connect(function() btnHop.BackgroundColor3 = Color3.fromRGB(240, 80, 80) end)
    btnHop.MouseLeave:Connect(function() btnHop.BackgroundColor3 = Color3.fromRGB(220, 60, 60) end)

    -- fade in
    frame.BackgroundTransparency = 1
    title.BackgroundTransparency = 1
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
end

-- ═══ MAIN ═══
task.wait(2)
state.hops = state.hops + 1
print(("[CLAUDEX v2.0 GUI] Hop #%d | Scan paralelo..."):format(state.hops))

local t0 = tick()
local playerCount = #Players:GetPlayers()
local total, best, bestPlr, playerRAPs = scanServer()
local elapsed = tick() - t0

print(("Scan completo en %.1fs | RAP best: %s (%s)"):format(elapsed, tostring(best), bestPlr or "N/A"))

buildGUI(playerCount, total, best, bestPlr, playerRAPs, elapsed, function(choice)
    if choice == "stay" then
        print("[CLAUDEX] decision: QUEDARME. Limpio queue.")
        clearQueue()
        state.hops = 0
    else
        print("[CLAUDEX] decision: SALTAR al siguiente server...")
        setQueue()  -- asegurar queue antes de saltar
        local ok = hopTo()
        if not ok then
            warn("[CLAUDEX] No pude hopear, intenta de nuevo presionando re-ejecutar")
        end
    end
end)
