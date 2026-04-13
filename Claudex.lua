-- ============ CLAUDEX LOADER v3.0 ============
-- Muestra la animacion de carga, luego ejecuta el ESP desde GitHub

if _G._ESP_LOADED then return end

local TW = game:GetService("TweenService")
local ti = TweenInfo.new
local C3_CLAUDEX = Color3.fromRGB(220, 120, 50)
local C3_BLACK = Color3.new(0, 0, 0)

-- GUI protegida
local _lsg
local LP = game:GetService("Players").LocalPlayer
if gethui then
	_lsg = Instance.new("ScreenGui")
	_lsg.Parent = gethui()
elseif syn and syn.protect_gui then
	_lsg = Instance.new("ScreenGui")
	syn.protect_gui(_lsg)
	_lsg.Parent = game:GetService("CoreGui")
else
	_lsg = Instance.new("ScreenGui")
	pcall(function() _lsg.Parent = game:GetService("CoreGui") end)
	if not _lsg.Parent then _lsg.Parent = LP:WaitForChild("PlayerGui") end
end
_lsg.ResetOnSpawn = false

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = C3_BLACK
bg.BackgroundTransparency = 0.3
bg.BorderSizePixel = 0
bg.Parent = _lsg

local star = Instance.new("TextLabel")
star.Size = UDim2.new(0, 60, 0, 60)
star.Position = UDim2.new(0.5, -30, 0.4, -30)
star.BackgroundTransparency = 1
star.Text = "\226\156\180"
star.TextColor3 = C3_CLAUDEX
star.Font = Enum.Font.GothamBold
star.TextSize = 50
star.TextTransparency = 1
star.Parent = bg

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(0, 200, 0, 30)
ttl.Position = UDim2.new(0.5, -100, 0.4, 35)
ttl.BackgroundTransparency = 1
ttl.Text = "CLAUDEX"
ttl.TextColor3 = C3_CLAUDEX
ttl.Font = Enum.Font.GothamBold
ttl.TextSize = 24
ttl.TextTransparency = 1
ttl.Parent = bg

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 200, 0, 4)
barBg.Position = UDim2.new(0.5, -100, 0.4, 75)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.BackgroundTransparency = 1
barBg.Parent = bg
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 2)

local barF = Instance.new("Frame")
barF.Size = UDim2.new(0, 0, 1, 0)
barF.BackgroundColor3 = C3_CLAUDEX
barF.BorderSizePixel = 0
barF.BackgroundTransparency = 1
barF.Parent = barBg
Instance.new("UICorner", barF).CornerRadius = UDim.new(0, 2)

local ver = Instance.new("TextLabel")
ver.Size = UDim2.new(0, 200, 0, 20)
ver.Position = UDim2.new(0.5, -100, 0.4, 85)
ver.BackgroundTransparency = 1
ver.Text = "v3.0"
ver.TextColor3 = Color3.fromRGB(150, 150, 150)
ver.Font = Enum.Font.Gotham
ver.TextSize = 10
ver.TextTransparency = 1
ver.Parent = bg

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 200, 0, 16)
status.Position = UDim2.new(0.5, -100, 0.4, 105)
status.BackgroundTransparency = 1
status.Text = "Cargando..."
status.TextColor3 = Color3.fromRGB(100, 100, 100)
status.Font = Enum.Font.Gotham
status.TextSize = 9
status.TextTransparency = 1
status.Parent = bg

-- Fade in
TW:Create(star, ti(0.4, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
TW:Create(ttl, ti(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
TW:Create(barBg, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
TW:Create(barF, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
TW:Create(ver, ti(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
TW:Create(status, ti(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()

task.wait(0.3)

-- Barra progreso + estrella pulsando
TW:Create(barF, ti(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()

task.spawn(function()
	for i = 1, 4 do
		TW:Create(star, ti(0.2, Enum.EasingStyle.Quad), {TextSize = 55}):Play()
		task.wait(0.2)
		TW:Create(star, ti(0.2, Enum.EasingStyle.Quad), {TextSize = 45}):Play()
		task.wait(0.2)
	end
end)

-- Descargar ESP mientras se muestra la animacion
status.Text = "Descargando ESP..."
local espCode = nil
local ok, err = pcall(function()
	espCode = game:HttpGet("https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/esp.lua?nocache=" .. tostring(tick()) .. tostring(math.random(100000, 999999)), true)
end)

if ok and espCode then
	status.Text = "ESP listo"
	status.TextColor3 = Color3.fromRGB(0, 200, 100)
	TW:Create(barF, ti(0.4, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
else
	status.Text = "Error: " .. tostring(err)
	status.TextColor3 = Color3.fromRGB(255, 50, 50)
	task.wait(2)
	_lsg:Destroy()
	return
end

task.wait(0.8)

-- Fade out
TW:Create(bg, ti(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
TW:Create(star, ti(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
TW:Create(ttl, ti(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
TW:Create(barBg, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
TW:Create(barF, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
TW:Create(ver, ti(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
TW:Create(status, ti(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()

task.wait(0.5)
_lsg:Destroy()

-- Ejecutar ESP
loadstring(espCode)()
