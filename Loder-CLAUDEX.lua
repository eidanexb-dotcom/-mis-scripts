--[[
	✴ CLAUDEX LOADER v3.27
	Por: Eidanex & Claude
	Loader premium animado:
	  - Card con entrada scale+fade (Quart Out)
	  - Estrella rotante + pulse de tamaño
	  - UIStroke con glow pulsante
	  - Barra de progreso indeterminada (ping-pong sine)
	  - Dots animados "."/".."/"..."
	  - Salida fade+shrink
	  - Error handling: fetch / compile / run separados, muestra error truncado en rojo

	Antes de publicar en ScriptBlox: ofuscar con LuaObfuscator.com
	preset VM/Bytecode + Encrypt Strings para esconder la URL del raw.
]]--

local CoreGui = game:GetService("CoreGui")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local URL = "https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/esp.lua"
local VERSION = "v3.27"
local TITLE = "CLAUDEX"

-- ============ COLORS ============
local C_ACCENT      = Color3.fromRGB(220, 120, 50)
local C_ACCENT_HOT  = Color3.fromRGB(255, 165, 75)
local C_DARK_WARM   = Color3.fromRGB(40, 26, 22)
local C_DARK_MID    = Color3.fromRGB(20, 18, 24)
local C_DARK_DEEP   = Color3.fromRGB(10, 10, 14)
local C_TEXT        = Color3.fromRGB(245, 238, 225)
local C_DIM         = Color3.fromRGB(150, 140, 155)
local C_OK          = Color3.fromRGB(110, 230, 140)
local C_ERR         = Color3.fromRGB(255, 90, 90)

-- ============ HOST GUI ============
local function host()
	local ok, h
	ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	ok, h = pcall(function() return get_hidden_gui and get_hidden_gui() end)
	if ok and h then return h end
	if CoreGui then return CoreGui end
	local lp = Players.LocalPlayer
	return lp and lp:WaitForChild("PlayerGui") or game:GetService("StarterGui")
end

local parent = host()
for _, c in ipairs(parent:GetChildren()) do
	if c.Name == "_CXLDR" then pcall(function() c:Destroy() end) end
end

local sg = Instance.new("ScreenGui")
sg.Name = "_CXLDR"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
local ok = pcall(function() sg.Parent = parent end)
if not ok or not sg.Parent then
	sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ============ BACKDROP ============
local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.Parent = sg

-- ============ CARD ============
local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, 0)
card.Size = UDim2.new(0, 260, 0, 140)
card.BackgroundColor3 = C_DARK_MID
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.Parent = sg

Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = C_ACCENT
cardStroke.Thickness = 1.2
cardStroke.Transparency = 1
cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
cardStroke.Parent = card

local cardGrad = Instance.new("UIGradient")
cardGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C_DARK_WARM),
	ColorSequenceKeypoint.new(0.55, C_DARK_MID),
	ColorSequenceKeypoint.new(1, C_DARK_DEEP),
})
cardGrad.Rotation = 135
cardGrad.Parent = card

-- ============ HEADER ============
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -28, 0, 36)
header.Position = UDim2.new(0, 14, 0, 14)
header.BackgroundTransparency = 1
header.Parent = card

local star = Instance.new("TextLabel")
star.Size = UDim2.new(0, 32, 0, 32)
star.Position = UDim2.new(0, 0, 0.5, -16)
star.AnchorPoint = Vector2.new(0, 0)
star.BackgroundTransparency = 1
star.Text = "\226\156\180"
star.TextColor3 = C_ACCENT_HOT
star.Font = Enum.Font.GothamBold
star.TextSize = 26
star.TextTransparency = 1
star.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -88, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.BackgroundTransparency = 1
title.Text = TITLE
title.TextColor3 = C_TEXT
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 1
title.Parent = header

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C_ACCENT_HOT),
	ColorSequenceKeypoint.new(0.6, C_TEXT),
	ColorSequenceKeypoint.new(1, C_TEXT),
})
titleGrad.Rotation = 75
titleGrad.Parent = title

local versionLbl = Instance.new("TextLabel")
versionLbl.Size = UDim2.new(0, 48, 0, 18)
versionLbl.Position = UDim2.new(1, -48, 0, 4)
versionLbl.BackgroundTransparency = 1
versionLbl.Text = VERSION
versionLbl.TextColor3 = C_ACCENT
versionLbl.Font = Enum.Font.GothamBold
versionLbl.TextSize = 11
versionLbl.TextXAlignment = Enum.TextXAlignment.Right
versionLbl.TextTransparency = 1
versionLbl.Parent = header

-- ============ SUBTITLE + DOTS ============
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 80, 0, 16)
subtitle.Position = UDim2.new(0, 14, 0, 64)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Cargando"
subtitle.TextColor3 = C_DIM
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextTransparency = 1
subtitle.Parent = card

local dots = Instance.new("TextLabel")
dots.Size = UDim2.new(0, 24, 0, 16)
dots.Position = UDim2.new(0, 76, 0, 64)
dots.BackgroundTransparency = 1
dots.Text = "..."
dots.TextColor3 = C_ACCENT
dots.Font = Enum.Font.GothamBold
dots.TextSize = 13
dots.TextXAlignment = Enum.TextXAlignment.Left
dots.TextTransparency = 1
dots.Parent = card

-- ============ PROGRESS BAR ============
local pbBg = Instance.new("Frame")
pbBg.Size = UDim2.new(1, -28, 0, 6)
pbBg.Position = UDim2.new(0, 14, 0, 92)
pbBg.BackgroundColor3 = Color3.fromRGB(18, 14, 18)
pbBg.BackgroundTransparency = 0.25
pbBg.BorderSizePixel = 0
pbBg.Parent = card
Instance.new("UICorner", pbBg).CornerRadius = UDim.new(1, 0)
local pbBgStroke = Instance.new("UIStroke")
pbBgStroke.Color = C_ACCENT
pbBgStroke.Thickness = 0.8
pbBgStroke.Transparency = 0.7
pbBgStroke.Parent = pbBg

local pbFill = Instance.new("Frame")
pbFill.Size = UDim2.new(0.32, 0, 1, 0)
pbFill.Position = UDim2.new(0, 0, 0, 0)
pbFill.BackgroundColor3 = C_ACCENT
pbFill.BorderSizePixel = 0
pbFill.Parent = pbBg
Instance.new("UICorner", pbFill).CornerRadius = UDim.new(1, 0)

local pbFillGrad = Instance.new("UIGradient")
pbFillGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 100)),
	ColorSequenceKeypoint.new(0.5, C_ACCENT),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 70, 30)),
})
pbFillGrad.Rotation = 0
pbFillGrad.Parent = pbFill

-- ============ STATUS ============
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 16)
status.Position = UDim2.new(0, 14, 0, 108)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = C_DIM
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextTransparency = 1
status.TextWrapped = false
status.ClipsDescendants = true
status.Parent = card

-- ============ TAGLINE ============
local tagline = Instance.new("TextLabel")
tagline.Size = UDim2.new(1, -28, 0, 12)
tagline.Position = UDim2.new(0, 14, 1, -22)
tagline.BackgroundTransparency = 1
tagline.Text = "by Eidanex & Claude"
tagline.TextColor3 = C_DIM
tagline.Font = Enum.Font.Gotham
tagline.TextSize = 10
tagline.TextXAlignment = Enum.TextXAlignment.Right
tagline.TextTransparency = 1
tagline.Parent = card

-- ============ BOTTOM ACCENT BAR ============
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1, 0, 0, 2)
accentBar.Position = UDim2.new(0, 0, 1, -2)
accentBar.BackgroundColor3 = C_ACCENT
accentBar.BackgroundTransparency = 1
accentBar.BorderSizePixel = 0
accentBar.Parent = card
local accentGrad = Instance.new("UIGradient")
accentGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 10)),
	ColorSequenceKeypoint.new(0.5, C_ACCENT_HOT),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 20, 10)),
})
accentGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.15, 0.4),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(0.85, 0.4),
	NumberSequenceKeypoint.new(1, 1),
})
accentGrad.Parent = accentBar

-- ============ ANIMATIONS ============
local easeOutQuart = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local easeInQuart = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local sineIO = function(t) return TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) end

-- Entrance
TS:Create(backdrop, easeOutQuart, {BackgroundTransparency = 0.55}):Play()
TS:Create(card, easeOutQuart, {Size = UDim2.new(0, 320, 0, 180), BackgroundTransparency = 0.05}):Play()
TS:Create(cardStroke, easeOutQuart, {Transparency = 0.3}):Play()
TS:Create(star, easeOutQuart, {TextTransparency = 0}):Play()
TS:Create(title, easeOutQuart, {TextTransparency = 0}):Play()
TS:Create(versionLbl, easeOutQuart, {TextTransparency = 0.15}):Play()
TS:Create(subtitle, easeOutQuart, {TextTransparency = 0}):Play()
TS:Create(dots, easeOutQuart, {TextTransparency = 0}):Play()
TS:Create(tagline, easeOutQuart, {TextTransparency = 0.4}):Play()
TS:Create(accentBar, easeOutQuart, {BackgroundTransparency = 0}):Play()

-- Continuous loops
local running = true

task.spawn(function()
	while running and star.Parent do
		local t = TS:Create(star, TweenInfo.new(2.4, Enum.EasingStyle.Linear), {Rotation = star.Rotation + 360})
		t:Play(); t.Completed:Wait()
	end
end)

task.spawn(function()
	while running and star.Parent do
		TS:Create(star, sineIO(0.9), {TextSize = 30}):Play()
		task.wait(0.9)
		TS:Create(star, sineIO(0.9), {TextSize = 24}):Play()
		task.wait(0.9)
	end
end)

task.spawn(function()
	while running and cardStroke.Parent do
		TS:Create(cardStroke, sineIO(1.3), {Transparency = 0.55, Thickness = 1.7}):Play()
		task.wait(1.3)
		TS:Create(cardStroke, sineIO(1.3), {Transparency = 0.2, Thickness = 1.2}):Play()
		task.wait(1.3)
	end
end)

task.spawn(function()
	while running and pbFill.Parent do
		TS:Create(pbFill, sineIO(1.05), {Position = UDim2.new(0.68, 0, 0, 0)}):Play()
		task.wait(1.05)
		TS:Create(pbFill, sineIO(1.05), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(1.05)
	end
end)

task.spawn(function()
	local states = {".", "..", "..."}
	local i = 1
	while running and dots.Parent do
		dots.Text = states[i]
		i = i % 3 + 1
		task.wait(0.32)
	end
end)

-- ============ EXIT ============
local function exitLoader(success, errMsg)
	if success then
		status.Text = "Listo"
		status.TextColor3 = C_OK
		TS:Create(status, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
		task.wait(0.5)
	else
		status.Text = tostring(errMsg):sub(1, 90)
		status.TextColor3 = C_ERR
		TS:Create(status, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
		TS:Create(cardStroke, TweenInfo.new(0.25), {Color = C_ERR, Transparency = 0.2}):Play()
		task.wait(2.6)
	end
	running = false
	task.wait()
	TS:Create(card, easeInQuart, {Size = UDim2.new(0, 260, 0, 140), BackgroundTransparency = 1}):Play()
	TS:Create(backdrop, easeInQuart, {BackgroundTransparency = 1}):Play()
	TS:Create(cardStroke, easeInQuart, {Transparency = 1}):Play()
	for _, lbl in ipairs({star, title, versionLbl, subtitle, dots, tagline, status}) do
		TS:Create(lbl, easeInQuart, {TextTransparency = 1}):Play()
	end
	TS:Create(accentBar, easeInQuart, {BackgroundTransparency = 1}):Play()
	TS:Create(pbBg, easeInQuart, {BackgroundTransparency = 1}):Play()
	TS:Create(pbFill, easeInQuart, {BackgroundTransparency = 1}):Play()
	task.wait(0.4)
	pcall(function() sg:Destroy() end)
end

-- ============ EXECUTE ============
task.wait(0.35)

local fullUrl = URL .. "?nocache=" .. tostring(tick()) .. tostring(math.random(100000, 999999))

local okFetch, body = pcall(function()
	return game:HttpGet(fullUrl, true)
end)
if not okFetch or type(body) ~= "string" or #body < 100 then
	return exitLoader(false, "Fetch: " .. tostring(body))
end

local fn, compileErr = loadstring(body)
if type(fn) ~= "function" then
	return exitLoader(false, "Compile: " .. tostring(compileErr))
end

local okRun, runErr = pcall(fn)
if not okRun then
	return exitLoader(false, "Run: " .. tostring(runErr))
end

exitLoader(true)
