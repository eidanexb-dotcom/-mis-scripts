if _G._ESP_LOADED then return end
_G._ESP_LOADED = true

-- ============ ANTI-TAMPER ============
local _AT = {}
do
	local _lockMsg = "This metatable is locked."
	local _dead = false

	local _ref = {
		inew = Instance.new,
		pcall = pcall,
		type = type,
		error = error,
		setmt = setmetatable,
		getmt = getmetatable,
		rawget = rawget,
		rawset = rawset,
		pairs = pairs,
		ipairs = ipairs,
		twait = task.wait,
		tspawn = task.spawn,
		mathrand = math.random,
		strchar = string.char,
		connect = game:GetService("RunService").Heartbeat.Connect,
	}

	local function _selfDestruct()
		if _dead then return end
		_dead = true
		_ref.pcall(function()
			if _AT._sg then _AT._sg:Destroy() end
			if _AT._tsg then _AT._tsg:Destroy() end
			for _, objs in _ref.pairs(_AT._obj or {}) do
				for _, o in _ref.pairs(objs) do _ref.pcall(function() o:Destroy() end) end
			end
		end)
		_G._ESP_LOADED = nil
	end

	function _AT.protectTable(t)
		return _ref.setmt(t, {
			__metatable = _lockMsg,
		})
	end

	function _AT.protectReadOnly(t)
		local proxy = {}
		local mt = {
			__metatable = _lockMsg,
			__index = t,
			__newindex = function()
				_selfDestruct()
				_ref.error("Tampering detected. Error code: 0x" .. string.format("%04X", _ref.mathrand(4096, 65535)))
			end,
			__len = function() return #t end,
			__pairs = function() return _ref.pairs(t) end,
			__ipairs = function() return _ref.ipairs(t) end,
		}
		return _ref.setmt(proxy, mt)
	end

	function _AT.checkIntegrity()
		if _ref.type(Instance.new) ~= "function" then return false end
		if _ref.type(pcall) ~= "function" then return false end
		if _ref.type(setmetatable) ~= "function" then return false end
		if _ref.type(task.wait) ~= "function" then return false end
		if _ref.type(loadstring) ~= "function" then return false end
		local tampered = false
		_ref.pcall(function()
			if _ref.type(game.HttpGet) ~= "function" then tampered = true end
		end)
		_ref.pcall(function()
			local d = debug
			if d and d.getinfo then
				local info = d.getinfo(_AT.checkIntegrity)
				if info and info.source and info.source:find("@") then tampered = true end
			end
		end)
		if tampered then return false end
		return true
	end

	function _AT.startWatchdog(interval)
		_ref.tspawn(function()
			while not _dead do
				if not _AT.checkIntegrity() then
					_selfDestruct()
					break
				end
				_ref.twait(interval or 5)
			end
		end)
	end

	_AT.protectTable(_AT)
end
-- ============ FIN ANTI-TAMPER ============

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ============ CACHE ============
local mfloor, mrand, mclamp = math.floor, math.random, math.clamp
local msin = math.sin
local schar = string.char
local tconcat, tinsert = table.concat, table.insert
local C3_RED = Color3.fromRGB(255, 0, 0)
local C3_GREEN = Color3.fromRGB(0, 255, 0)
local C3_WHITE = Color3.new(1, 1, 1)
local C3_BLACK = Color3.new(0, 0, 0)
local C3_YELLOW = Color3.fromRGB(255, 255, 100)
local C3_ON = Color3.fromRGB(0, 255, 100)
local C3_OFF = Color3.fromRGB(255, 80, 80)
local C3_CLAUDEX = Color3.fromRGB(220, 120, 50)
local V3_ZERO = Vector3.zero or Vector3.new(0, 0, 0)
local RAD_N30 = math.rad(-30)
local RAD_90 = math.rad(90)
local RAD_180 = math.rad(180)

local _obj = {}
local _pcons = {}
local _k = {}
local _tick = 0
local _gen = 0
local _mainGen = _gen

RS.Heartbeat:Connect(function()
	if _gen ~= _mainGen then return end
	_tick = _tick + 1
end)

local function _rn()
	local t = {}
	for i = 1, mrand(8, 14) do
		t[i] = schar(mrand(1, 2) == 1 and mrand(65, 90) or mrand(97, 122))
	end
	return tconcat(t)
end

local function _gui()
	local p
	if gethui then
		p = gethui()
	elseif syn and syn.protect_gui then
		local g = Instance.new("ScreenGui")
		syn.protect_gui(g)
		g.Parent = game:GetService("CoreGui")
		return g
	else
		pcall(function()
			p = game:GetService("CoreGui")
		end)
		if not p then p = LP:WaitForChild("PlayerGui") end
	end
	local g = Instance.new("ScreenGui")
	g.Name = _rn()
	g.ResetOnSpawn = false
	g.Parent = p
	return g
end

local function _cd(d)
	if d <= 20 then return C3_RED
	elseif d <= 30 then
		local t = (d - 20) / 10
		return Color3.fromRGB(255, mfloor(165 * t), 0)
	elseif d <= 50 then
		local t = (d - 30) / 20
		return Color3.fromRGB(mfloor(255 * (1 - t)), mfloor(165 + 90 * t), 0)
	else return C3_GREEN end
end

local function _dist(c)
	local mc = LP.Character
	if not mc then return nil end
	local m = mc:FindFirstChild("HumanoidRootPart")
	if not m or not c then return nil end
	local r = c:FindFirstChild("HumanoidRootPart")
	if not r then return nil end
	return mfloor((m.Position - r.Position).Magnitude)
end

local function _cerca(ch, pl)
	local v = ch:FindFirstChild("HumanoidRootPart")
	if not v then return nil end
	local cl, md = nil, 999999
	for _, op in ipairs(Players:GetPlayers()) do
		if op ~= pl and op.Character then
			local oh = op.Character:FindFirstChild("HumanoidRootPart")
			if oh then
				local d = (oh.Position - v.Position).Magnitude
				if d < md then md = d; cl = op.Name end
			end
		end
	end
	return cl
end

local function _make(pl)
	if pl == LP then return end
	local _mg = _gen
	local function _go(ch)
		if not ch then return end
		local hr = ch:WaitForChild("HumanoidRootPart", 5)
		if not hr then return end

		if _obj[pl] then
			for _, o in pairs(_obj[pl]) do pcall(function() o:Destroy() end) end
		end
		_obj[pl] = {}

		local hl
		pcall(function()
			hl = Instance.new("Highlight")
			hl.Adornee = ch
			hl.FillColor = C3_RED
			hl.FillTransparency = 0.7
			hl.OutlineColor = C3_WHITE
			hl.OutlineTransparency = 0.3
			pcall(function() hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
			hl.Name = _rn()
			hl.Parent = ch
		end)

		local bb = Instance.new("BillboardGui")
		bb.Adornee = hr
		bb.Size = UDim2.new(0, 250, 0, 50)
		bb.StudsOffset = Vector3.new(0, 3, 0)
		bb.AlwaysOnTop = true
		bb.Name = _rn()
		bb.Parent = ch

		local nl = Instance.new("TextLabel")
		nl.Size = UDim2.new(1, 0, 0.5, 0)
		nl.BackgroundTransparency = 1
		nl.TextColor3 = C3_RED
		nl.TextStrokeTransparency = 0.5
		nl.TextStrokeColor3 = C3_BLACK
		nl.Font = Enum.Font.Gotham
		nl.TextSize = 13
		nl.Text = pl.Name
		nl.Name = _rn()
		nl.Parent = bb

		local dl = Instance.new("TextLabel")
		dl.Size = UDim2.new(1, 0, 0.5, 0)
		dl.Position = UDim2.new(0, 0, 0.5, 0)
		dl.BackgroundTransparency = 1
		dl.TextColor3 = C3_YELLOW
		dl.TextStrokeTransparency = 0.5
		dl.TextStrokeColor3 = C3_BLACK
		dl.Font = Enum.Font.Gotham
		dl.TextSize = 11
		dl.Text = "0m"
		dl.Name = _rn()
		dl.Parent = bb

		if hl then _obj[pl] = {hl, bb} else _obj[pl] = {bb} end

		local cn
		cn = RS.Heartbeat:Connect(function()
			if _gen ~= _mg then cn:Disconnect() return end
			if not ch or not ch.Parent then
				cn:Disconnect()
				return
			end

			if _tick % 4 ~= 0 then return end

			local d = _dist(ch)
			if not d then return end
			dl.Text = d .. "m"
			local k = _k[pl.Name] or 0

			local co = _cd(d)
			if hl then hl.FillColor = co end
			nl.TextColor3 = co
			if k > 0 then nl.Text = pl.Name .. " [" .. k .. " kills]"
			else nl.Text = pl.Name end
		end)
	end

	if pl.Character then _go(pl.Character) end
	local ca = pl.CharacterAdded:Connect(function(c) if _gen ~= _mg then return end task.wait(0.5) _go(c) end)
	if not _pcons[pl] then _pcons[pl] = {} end
	table.insert(_pcons[pl], ca)
end

local function _del(pl)
	if _obj[pl] then
		for _, o in pairs(_obj[pl]) do pcall(function() o:Destroy() end) end
		_obj[pl] = nil
	end
	if _pcons[pl] then
		for _, c in pairs(_pcons[pl]) do pcall(function() c:Disconnect() end) end
		_pcons[pl] = nil
	end
	_k[pl.Name] = nil
end

local function _td(pl)
	local _mg = _gen
	local function _oc(ch)
		if _gen ~= _mg then return end
		if not ch then return end
		local hum = ch:WaitForChild("Humanoid", 5)
		if not hum then return end
		hum.Died:Connect(function()
			if _gen ~= _mg then return end
			local c = _cerca(ch, pl)
			if c then _k[c] = (_k[c] or 0) + 1 end
		end)
	end
	if pl.Character then _oc(pl.Character) end
	local ca = pl.CharacterAdded:Connect(function(c) if _gen ~= _mg then return end _oc(c) end)
	if not _pcons[pl] then _pcons[pl] = {} end
	table.insert(_pcons[pl], ca)
end

local function _md()
	local _mg = _gen
	local function _om(ch)
		if _gen ~= _mg then return end
		if not ch then return end
		local hum = ch:WaitForChild("Humanoid", 5)
		if not hum then return end
		hum.Died:Connect(function() if _gen ~= _mg then return end _k = {} end)
	end
	if LP.Character then _om(LP.Character) end
	LP.CharacterAdded:Connect(function(c) if _gen ~= _mg then return end _om(c) end)
end

-- ============ LOADING ============
do
	local TW = game:GetService("TweenService")
	local _lsg = _gui()
	local ti = TweenInfo.new

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
	ver.Text = "v2.0"
	ver.TextColor3 = Color3.fromRGB(150, 150, 150)
	ver.Font = Enum.Font.Gotham
	ver.TextSize = 10
	ver.TextTransparency = 1
	ver.Parent = bg

	TW:Create(star, ti(0.4, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
	TW:Create(ttl, ti(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
	TW:Create(barBg, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
	TW:Create(barF, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
	TW:Create(ver, ti(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()

	task.wait(0.3)
	TW:Create(barF, ti(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()

	task.spawn(function()
		for i = 1, 3 do
			TW:Create(star, ti(0.2, Enum.EasingStyle.Quad), {TextSize = 55}):Play()
			task.wait(0.2)
			TW:Create(star, ti(0.2, Enum.EasingStyle.Quad), {TextSize = 45}):Play()
			task.wait(0.2)
		end
	end)

	task.wait(1.5)

	TW:Create(bg, ti(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	TW:Create(star, ti(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
	TW:Create(ttl, ti(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
	TW:Create(barBg, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	TW:Create(barF, ti(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	TW:Create(ver, ti(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()

	task.wait(0.5)
	_lsg:Destroy()
end

-- ============ TP ============
local _sg = _gui()
_AT._sg = _sg
local _tm = 0
local _spd = 100
local _mv = false
local _tc = nil
local _lf
local _open = true
local _tg
local _dsg
local _yuFrame
local _spFrame
local _noclip, _nccon
local _ncParts = {}
local _bright, _brightOG
local _slide
local _grav, _gravOG, _gravCon, _gravGyro
local _ncb, _brb, _dsb, _grb, _ivb
local _invis, _invisCon
local _yupiSpd = 10
local Lighting = game:GetService("Lighting")

local _tb = Instance.new("TextButton")
_tb.Size = UDim2.new(0, 40, 0, 40)
_tb.Position = UDim2.new(0, 10, 0.5, -20)
_tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
_tb.BackgroundTransparency = 0.3
_tb.TextColor3 = Color3.fromRGB(0, 200, 255)
_tb.Font = Enum.Font.GothamBold
_tb.TextSize = 18
_tb.Text = "TP"
_tb.Name = _rn()
_tb.Parent = _sg
Instance.new("UICorner", _tb).CornerRadius = UDim.new(0, 8)

local _mb = Instance.new("TextButton")
_mb.Size = UDim2.new(0, 40, 0, 25)
_mb.Position = UDim2.new(0, 10, 0.5, 25)
_mb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
_mb.BackgroundTransparency = 0.3
_mb.TextColor3 = C3_ON
_mb.Font = Enum.Font.Gotham
_mb.TextSize = 9
_mb.Text = "INST"
_mb.Name = _rn()
_mb.Parent = _sg
Instance.new("UICorner", _mb).CornerRadius = UDim.new(0, 6)

local _mdf = Instance.new("Frame")
_mdf.Size = UDim2.new(0, 80, 0, 158)
_mdf.Position = UDim2.new(0, 55, 0.5, 25)
_mdf.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
_mdf.BackgroundTransparency = 0.15
_mdf.BorderSizePixel = 0
_mdf.Visible = false
_mdf.Name = _rn()
_mdf.Parent = _sg
Instance.new("UICorner", _mdf).CornerRadius = UDim.new(0, 6)

local _mdl = Instance.new("UIListLayout")
_mdl.Padding = UDim.new(0, 2)
_mdl.Parent = _mdf

local _mNames = {"INST", "SUAVE", "SOMBRERO", "COSTAL", "VALIENTE", "VISTA"}
local _mColors = {C3_ON, Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 0, 200), Color3.fromRGB(255, 100, 0), C3_RED, Color3.fromRGB(100, 200, 255)}

local function _setMode(mode)
	local _prev = _tm
	if _mv and _tc then _tc:Disconnect(); _mv = false end
	if _prev >= 2 and _prev <= 4 then
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.Sit = false end
		end)
	end
	if _prev == 5 then
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then game.Workspace.CurrentCamera.CameraSubject = hum end
		end)
	end
	_tm = mode
	_yuFrame.Visible = (_tm == 4)
	_spFrame.Visible = (_tm == 1)
	_mb.Text = _mNames[mode + 1]
	_mb.TextColor3 = _mColors[mode + 1]
	_mdf.Visible = false
end

for i, name in ipairs(_mNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.BackgroundTransparency = 0.3
	btn.TextColor3 = _mColors[i]
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 9
	btn.Text = name
	btn.Name = _rn()
	btn.Parent = _mdf
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	btn.MouseButton1Click:Connect(function()
		_setMode(i - 1)
	end)
end

_mb.MouseButton1Click:Connect(function()
	if _tm == 5 then
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then game.Workspace.CurrentCamera.CameraSubject = hum end
		end)
	end
	_mdf.Visible = not _mdf.Visible
end)

local _rst = Instance.new("TextButton")
_rst.Size = UDim2.new(0, 40, 0, 25)
_rst.Position = UDim2.new(0, 10, 0.5, 55)
_rst.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
_rst.BackgroundTransparency = 0.3
_rst.TextColor3 = Color3.fromRGB(255, 50, 50)
_rst.Font = Enum.Font.GothamBold
_rst.TextSize = 9
_rst.Text = "RST"
_rst.Name = _rn()
_rst.Parent = _sg
Instance.new("UICorner", _rst).CornerRadius = UDim.new(0, 6)

local _rstBusy = false
local function _doRST()
	if _rstBusy then return end
	_rstBusy = true
	_gen = _gen + 1
	if _mv and _tc then _tc:Disconnect(); _mv = false end
	pcall(function()
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Sit = false end
	end)
	-- resetear camara
	pcall(function()
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then game.Workspace.CurrentCamera.CameraSubject = hum end
	end)
	-- limpiar noclip
	_noclip = false
	if _nccon then pcall(function() _nccon:Disconnect() end); _nccon = nil end
	for i = 1, #_ncParts do
		local p = _ncParts[i]
		if p and p.Parent then pcall(function() p.CanCollide = true end) end
	end
	_ncParts = {}
	-- restaurar gravedad
	if _grav then
		_grav = false
		if _gravCon then pcall(function() _gravCon:Disconnect() end); _gravCon = nil end
		if _gravGyro then pcall(function() _gravGyro:Destroy() end); _gravGyro = nil end
		pcall(function() game.Workspace.Gravity = _gravOG or 196.2 end)
	end
	-- restaurar luz
	if _bright then
		_bright = false
		pcall(function()
			if _brightOG.amb then
				Lighting.Ambient = _brightOG.amb
				Lighting.OutdoorAmbient = _brightOG.out
				Lighting.Brightness = _brightOG.bright
				Lighting.FogEnd = _brightOG.fog
				Lighting.ClockTime = _brightOG.time
			end
			for _, e in ipairs(Lighting:GetDescendants()) do
				if e:IsA("Atmosphere") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") then
					e.Enabled = true
				end
			end
		end)
	end
	-- restaurar invisibilidad
	if _invis then
		_invis = false
		if _invisCon then pcall(function() _invisCon:Disconnect() end); _invisCon = nil end
	end
	-- restaurar walkspeed
	if _slide then
		_slide = false
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end)
	end
	-- destruir todo y recargar desde GitHub
	for pl, objs in pairs(_obj) do
		for _, o in pairs(objs) do pcall(function() o:Destroy() end) end
	end
	pcall(function() _sg:Destroy() end)
	pcall(function() _dsg:Destroy() end)
	_G._ESP_LOADED = nil
	task.wait(0.3)
	local ok = pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/eidanexb-dotcom/-mis-scripts/refs/heads/main/esp.lua?nocache=" .. tostring(tick()) .. tostring(math.random(100000, 999999)), true))()
	end)
	if not ok then _rstBusy = false end
end
_rst.MouseButton1Click:Connect(_doRST)

-- BOTON PARTIDO (INVIS + ?)
local _spBtn = Instance.new("Frame")
_spBtn.Size = UDim2.new(0, 40, 0, 25)
_spBtn.Position = UDim2.new(0, 10, 0.5, 85)
_spBtn.BackgroundTransparency = 1
_spBtn.Name = _rn()
_spBtn.Parent = _sg

local _spL = Instance.new("TextButton")
_spL.Size = UDim2.new(0.5, -1, 1, 0)
_spL.Position = UDim2.new(0, 0, 0, 0)
_spL.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
_spL.BackgroundTransparency = 0.3
_spL.TextColor3 = C3_OFF
_spL.Font = Enum.Font.GothamBold
_spL.TextSize = 7
_spL.Text = "INV"
_spL.Name = _rn()
_spL.Parent = _spBtn
Instance.new("UICorner", _spL).CornerRadius = UDim.new(0, 4)

local _spR = Instance.new("TextButton")
_spR.Size = UDim2.new(0.5, -1, 1, 0)
_spR.Position = UDim2.new(0.5, 1, 0, 0)
_spR.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
_spR.BackgroundTransparency = 0.3
_spR.TextColor3 = Color3.fromRGB(150, 150, 150)
_spR.Font = Enum.Font.GothamBold
_spR.TextSize = 7
_spR.Text = "?"
_spR.Name = _rn()
_spR.Parent = _spBtn
Instance.new("UICorner", _spR).CornerRadius = UDim.new(0, 4)

_spL.MouseButton1Click:Connect(function()
	_toggleInvis()
	_spL.TextColor3 = _invis and C3_ON or C3_OFF
	_spL.Text = _invis and "INV" or "INV"
end)

_lf = Instance.new("ScrollingFrame")
_lf.Size = UDim2.new(0, 200, 0, 300)
_lf.Position = UDim2.new(0, 60, 0.5, -150)
_lf.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
_lf.BackgroundTransparency = 0.2
_lf.BorderSizePixel = 0
_lf.ScrollBarThickness = 4
_lf.Visible = false
_lf.Name = _rn()
_lf.Parent = _sg
Instance.new("UICorner", _lf).CornerRadius = UDim.new(0, 8)
local _ll = Instance.new("UIListLayout")
_ll.Padding = UDim.new(0, 3)
_ll.SortOrder = Enum.SortOrder.Name
_ll.Parent = _lf

local function _rl()
	for _, c in pairs(_lf:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -6, 0, 40)
			btn.Position = UDim2.new(0, 3, 0, 0)
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			btn.BackgroundTransparency = 0.3
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.Text = p.Name
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Name = _rn()
			btn.Parent = _lf
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

			local ok, img = pcall(function()
				return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			local av = Instance.new("ImageLabel")
			av.Size = UDim2.new(0, 30, 0, 30)
			av.Position = UDim2.new(0, 5, 0.5, -15)
			av.BackgroundTransparency = 1
			if ok then av.Image = img end
			av.Parent = btn
			Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

			local pad = Instance.new("UIPadding")
			pad.PaddingLeft = UDim.new(0, 45)
			pad.Parent = btn

			btn.MouseButton1Click:Connect(function()
				if not p.Parent then return end
				if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
				if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
				local myHRP = LP.Character.HumanoidRootPart
				local head = p.Character:FindFirstChild("Head")
				local function _unsit()
					pcall(function() local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if h then h.Sit = false end end)
				end
				local function _pleft()
					if not p.Parent then _tc:Disconnect(); _mv = false; _unsit(); return true end
					return false
				end
				if _tm == 1 then
					if _mv and _tc then _tc:Disconnect() end
					_mv = true
					_tc = RS.Heartbeat:Connect(function(dt)
						if not _mv then _tc:Disconnect() return end
						if _pleft() then return end
						local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
						if not myRoot then _tc:Disconnect(); _mv = false; return end
						local tHead = p.Character and p.Character:FindFirstChild("Head")
						if not tHead then return end
						local target = tHead.Position + Vector3.new(0, 2, 0)
						local dir3 = target - myRoot.Position
						if dir3.Magnitude < 3 then
							pcall(function() myRoot.CFrame = CFrame.new(target) end)
							_tc:Disconnect()
							_mv = false
							return
						end
						pcall(function()
							myRoot.Velocity = V3_ZERO
							myRoot.CFrame = myRoot.CFrame + dir3.Unit * _spd * dt
						end)
					end)
				elseif _tm == 2 then
					if _mv and _tc then _tc:Disconnect() end
					local tTop = head or (p.Character and (p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")))
					if not tTop then return end
					local _sOff = head and 2 or 3.5
					pcall(function()
						myHRP.CFrame = CFrame.new(tTop.Position + Vector3.new(0, _sOff, 0))
						local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum.Sit = true end
					end)
					_mv = true
					_tc = RS.Heartbeat:Connect(function()
						if not _mv then _tc:Disconnect() return end
						if _pleft() then return end
						local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
						if not myRoot then _tc:Disconnect(); _mv = false; return end
						local tH = p.Character and (p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso"))
						if not tH then return end
						local off = p.Character:FindFirstChild("Head") and 2 or 3.5
						pcall(function()
							myRoot.CFrame = tH.CFrame * CFrame.new(0, off, 0)
							myRoot.Velocity = V3_ZERO
						end)
					end)
				elseif _tm == 3 then
					if _mv and _tc then _tc:Disconnect() end
					local tTorso = p.Character and (p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso"))
					if not tTorso then return end
					pcall(function()
						myHRP.CFrame = tTorso.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(RAD_180, 0, RAD_90)
						local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum.Sit = true end
					end)
					_mv = true
					_tc = RS.Heartbeat:Connect(function()
						if not _mv then _tc:Disconnect() return end
						if _pleft() then return end
						local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
						if not myRoot then _tc:Disconnect(); _mv = false; return end
						local tT = p.Character and (p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso"))
						if not tT then return end
						pcall(function()
							myRoot.CFrame = tT.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(RAD_180, 0, RAD_90)
							myRoot.Velocity = V3_ZERO
						end)
					end)
				elseif _tm == 4 then
					if _mv and _tc then _tc:Disconnect() end
					local tTorso = p.Character and (p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso"))
					if not tTorso then return end
					pcall(function()
						myHRP.CFrame = tTorso.CFrame * CFrame.new(0, 1, 1.5)
						local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum.Sit = true end
					end)
					_mv = true
					_tc = RS.Heartbeat:Connect(function()
						if not _mv then _tc:Disconnect() return end
						if _pleft() then return end
						local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
						if not myRoot then _tc:Disconnect(); _mv = false; return end
						local tT = p.Character and (p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso"))
						if not tT then return end
						pcall(function()
							local yupi = msin(tick() * _yupiSpd) * 0.6
							myRoot.CFrame = tT.CFrame * CFrame.new(0, 1, 1.5 + yupi)
							myRoot.Velocity = V3_ZERO
						end)
					end)
				elseif _tm == 5 then
					pcall(function()
						local tHum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
						if tHum then
							game.Workspace.CurrentCamera.CameraSubject = tHum
						end
					end)
				else
					pcall(function()
						local tHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
						if tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 5) end
					end)
				end
			end)
		end
	end
	_lf.CanvasSize = UDim2.new(0, 0, 0, _ll.AbsoluteContentSize.Y + 10)
end

_tb.MouseButton1Click:Connect(function()
	_lf.Visible = not _lf.Visible
	if _lf.Visible then _rl() end
end)

Players.PlayerAdded:Connect(function()
	if _gen ~= _mainGen then return end
	if _lf.Visible then _rl() end
end)
Players.PlayerRemoving:Connect(function()
	if _gen ~= _mainGen then return end
	task.wait(0.5)
	if _lf.Visible then _rl() end
end)

-- ============ MENU TOGGLE ============
_tg = Instance.new("TextButton")
_tg.Size = UDim2.new(0, 55, 0, 25)
_tg.Position = UDim2.new(0, 10, 0.5, -70)
_tg.BackgroundColor3 = C3_CLAUDEX
_tg.BackgroundTransparency = 0.2
_tg.TextColor3 = C3_WHITE
_tg.Font = Enum.Font.GothamBold
_tg.TextSize = 9
_tg.Text = ">>>"
_tg.Name = _rn()
_tg.Parent = _sg
Instance.new("UICorner", _tg).CornerRadius = UDim.new(0, 8)

_tg.MouseButton1Click:Connect(function()
	_open = not _open
	_tb.Visible = _open
	_mb.Visible = _open
	_rst.Visible = _open
	_spBtn.Visible = _open
	if not _open then _lf.Visible = false; _mdf.Visible = false end
	_tg.Text = ">>>"
	_tg.BackgroundColor3 = _open and C3_CLAUDEX or Color3.fromRGB(50, 50, 50)
end)

-- ============ DROPDOWN TOP ============
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

_dsg = _gui()
_AT._tsg = _dsg
local _dopen = false
_noclip = false
_nccon = nil
_bright = false
_brightOG = {}

local _dtab = Instance.new("TextButton")
_dtab.Size = UDim2.new(0, 110, 0, 20)
_dtab.Position = UDim2.new(0.5, -55, 0, 0)
_dtab.BackgroundColor3 = C3_CLAUDEX
_dtab.BackgroundTransparency = 0.2
_dtab.TextColor3 = Color3.fromRGB(255, 255, 255)
_dtab.Font = Enum.Font.GothamBold
_dtab.TextSize = 10
_dtab.Text = "▼ ✴ Claudex ▼"
_dtab.Name = _rn()
_dtab.Parent = _dsg
Instance.new("UICorner", _dtab).CornerRadius = UDim.new(0, 6)

local _dpanel = Instance.new("ScrollingFrame")
_dpanel.Size = UDim2.new(0, 300, 0, 200)
_dpanel.Position = UDim2.new(0.5, -150, -1, 0)
_dpanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
_dpanel.BackgroundTransparency = 0.15
_dpanel.BorderSizePixel = 0
_dpanel.ScrollBarThickness = 4
_dpanel.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
_dpanel.Name = _rn()
_dpanel.Parent = _dsg
Instance.new("UICorner", _dpanel).CornerRadius = UDim.new(0, 10)

local _dll = Instance.new("UIListLayout")
_dll.Padding = UDim.new(0, 4)
_dll.SortOrder = Enum.SortOrder.LayoutOrder
_dll.Parent = _dpanel
_dll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	_dpanel.CanvasSize = UDim2.new(0, 0, 0, _dll.AbsoluteContentSize.Y + 20)
end)

local _dpad = Instance.new("UIPadding")
_dpad.PaddingTop = UDim.new(0, 8)
_dpad.PaddingLeft = UDim.new(0, 8)
_dpad.PaddingRight = UDim.new(0, 8)
_dpad.Parent = _dpanel

local _dhdr = Instance.new("Frame")
_dhdr.Size = UDim2.new(1, 0, 0, 28)
_dhdr.BackgroundTransparency = 1
_dhdr.LayoutOrder = 0
_dhdr.Name = _rn()
_dhdr.Parent = _dpanel

local _dstar = Instance.new("TextLabel")
_dstar.Size = UDim2.new(0, 28, 0, 28)
_dstar.BackgroundTransparency = 1
_dstar.Text = "✴"
_dstar.TextColor3 = C3_CLAUDEX
_dstar.Font = Enum.Font.GothamBold
_dstar.TextSize = 20
_dstar.Name = _rn()
_dstar.Parent = _dhdr

local _dtitle = Instance.new("TextLabel")
_dtitle.Size = UDim2.new(1, -32, 0, 28)
_dtitle.Position = UDim2.new(0, 32, 0, 0)
_dtitle.BackgroundTransparency = 1
_dtitle.Text = "CLAUDEX"
_dtitle.TextColor3 = C3_CLAUDEX
_dtitle.Font = Enum.Font.GothamBold
_dtitle.TextSize = 14
_dtitle.TextXAlignment = Enum.TextXAlignment.Left
_dtitle.Name = _rn()
_dtitle.Parent = _dhdr

local _dline = Instance.new("Frame")
_dline.Size = UDim2.new(1, 0, 0, 1)
_dline.Position = UDim2.new(0, 0, 1, 0)
_dline.BackgroundColor3 = C3_CLAUDEX
_dline.BackgroundTransparency = 0.5
_dline.BorderSizePixel = 0
_dline.Name = _rn()
_dline.Parent = _dhdr

local function _dbtn(txt, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.BackgroundTransparency = 0.3
	b.TextColor3 = C3_OFF
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Text = txt
	b.LayoutOrder = order
	b.Name = _rn()
	b.Parent = _dpanel
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

_ncb = _dbtn("NOCLIP: OFF", 1)
_brb = _dbtn("LUZ: OFF", 2)
_dsb = _dbtn("DESLIZAMIENTO: OFF", 3)
_grb = _dbtn("GRAVEDAD 0: OFF", 5)
_ivb = _dbtn("INVIS: OFF", 8)

-- SLIDER YUPI
local _yupiMin = 1
local _yupiMax = 1000

_yuFrame = Instance.new("Frame")
_yuFrame.Size = UDim2.new(1, 0, 0, 30)
_yuFrame.BackgroundTransparency = 1
_yuFrame.LayoutOrder = 6
_yuFrame.Name = _rn()
_yuFrame.Visible = false
_yuFrame.Parent = _dpanel

local _yuLabel = Instance.new("TextLabel")
_yuLabel.Size = UDim2.new(0, 65, 1, 0)
_yuLabel.Position = UDim2.new(0, 0, 0, 0)
_yuLabel.BackgroundTransparency = 1
_yuLabel.TextColor3 = C3_RED
_yuLabel.Font = Enum.Font.GothamBold
_yuLabel.TextSize = 9
_yuLabel.Text = "YUPI: 10"
_yuLabel.Name = _rn()
_yuLabel.Parent = _yuFrame

local _yuBg = Instance.new("Frame")
_yuBg.Size = UDim2.new(1, -75, 0, 8)
_yuBg.Position = UDim2.new(0, 70, 0.5, -4)
_yuBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
_yuBg.BorderSizePixel = 0
_yuBg.Name = _rn()
_yuBg.Parent = _yuFrame
Instance.new("UICorner", _yuBg).CornerRadius = UDim.new(0, 4)

local _yuFill = Instance.new("Frame")
_yuFill.Size = UDim2.new((_yupiSpd - _yupiMin) / (_yupiMax - _yupiMin), 0, 1, 0)
_yuFill.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
_yuFill.BorderSizePixel = 0
_yuFill.Name = _rn()
_yuFill.Parent = _yuBg
Instance.new("UICorner", _yuFill).CornerRadius = UDim.new(0, 4)

local _yuKnob = Instance.new("Frame")
_yuKnob.Size = UDim2.new(0, 14, 0, 14)
_yuKnob.Position = UDim2.new((_yupiSpd - _yupiMin) / (_yupiMax - _yupiMin), -7, 0.5, -7)
_yuKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_yuKnob.BorderSizePixel = 0
_yuKnob.Name = _rn()
_yuKnob.Parent = _yuBg
Instance.new("UICorner", _yuKnob).CornerRadius = UDim.new(1, 0)

local _yuDrag = false

local function _updateYupi(inputX)
	local bgPos = _yuBg.AbsolutePosition.X
	local bgSize = _yuBg.AbsoluteSize.X
	local pct = mclamp((inputX - bgPos) / bgSize, 0, 1)
	_yupiSpd = mfloor(_yupiMin + pct * (_yupiMax - _yupiMin))
	_yuFill.Size = UDim2.new(pct, 0, 1, 0)
	_yuKnob.Position = UDim2.new(pct, -7, 0.5, -7)
	_yuLabel.Text = "YUPI: " .. tostring(_yupiSpd)
end

_yuBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		_yuDrag = true
		_updateYupi(input.Position.X)
	end
end)


-- SLIDER TP SPEED
local _spMin = 50
local _spMax = 500

_spFrame = Instance.new("Frame")
_spFrame.Size = UDim2.new(1, 0, 0, 30)
_spFrame.BackgroundTransparency = 1
_spFrame.LayoutOrder = 7
_spFrame.Name = _rn()
_spFrame.Visible = false
_spFrame.Parent = _dpanel

local _spLabel = Instance.new("TextLabel")
_spLabel.Size = UDim2.new(0, 55, 1, 0)
_spLabel.BackgroundTransparency = 1
_spLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
_spLabel.Font = Enum.Font.GothamBold
_spLabel.TextSize = 9
_spLabel.Text = "TP: " .. _spd
_spLabel.Name = _rn()
_spLabel.Parent = _spFrame

local _spBg = Instance.new("Frame")
_spBg.Size = UDim2.new(1, -65, 0, 8)
_spBg.Position = UDim2.new(0, 60, 0.5, -4)
_spBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
_spBg.BorderSizePixel = 0
_spBg.Name = _rn()
_spBg.Parent = _spFrame
Instance.new("UICorner", _spBg).CornerRadius = UDim.new(0, 4)

local _spFill = Instance.new("Frame")
_spFill.Size = UDim2.new((_spd - _spMin) / (_spMax - _spMin), 0, 1, 0)
_spFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
_spFill.BorderSizePixel = 0
_spFill.Name = _rn()
_spFill.Parent = _spBg
Instance.new("UICorner", _spFill).CornerRadius = UDim.new(0, 4)

local _spKnob = Instance.new("Frame")
_spKnob.Size = UDim2.new(0, 14, 0, 14)
_spKnob.Position = UDim2.new((_spd - _spMin) / (_spMax - _spMin), -7, 0.5, -7)
_spKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_spKnob.BorderSizePixel = 0
_spKnob.Name = _rn()
_spKnob.Parent = _spBg
Instance.new("UICorner", _spKnob).CornerRadius = UDim.new(1, 0)

local _spDrag = false

local function _updateTpSpd(inputX)
	local bgPos = _spBg.AbsolutePosition.X
	local bgSize = _spBg.AbsoluteSize.X
	local pct = mclamp((inputX - bgPos) / bgSize, 0, 1)
	_spd = mfloor(_spMin + pct * (_spMax - _spMin))
	_spFill.Size = UDim2.new(pct, 0, 1, 0)
	_spKnob.Position = UDim2.new(pct, -7, 0.5, -7)
	_spLabel.Text = "TP: " .. _spd
end

_spBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		_spDrag = true
		_updateTpSpd(input.Position.X)
	end
end)

-- SLIDER VELOCIDAD
_slide = false
local _slideSpd = 50
local _slideMin = 16
local _slideMax = 200

local _slFrame = Instance.new("Frame")
_slFrame.Size = UDim2.new(1, 0, 0, 30)
_slFrame.BackgroundTransparency = 1
_slFrame.LayoutOrder = 4
_slFrame.Name = _rn()
_slFrame.Parent = _dpanel

local _slLabel = Instance.new("TextLabel")
_slLabel.Size = UDim2.new(0, 50, 1, 0)
_slLabel.Position = UDim2.new(0, 0, 0, 0)
_slLabel.BackgroundTransparency = 1
_slLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
_slLabel.Font = Enum.Font.GothamBold
_slLabel.TextSize = 10
_slLabel.Text = "50"
_slLabel.Name = _rn()
_slLabel.Parent = _slFrame

local _slBg = Instance.new("Frame")
_slBg.Size = UDim2.new(1, -60, 0, 8)
_slBg.Position = UDim2.new(0, 55, 0.5, -4)
_slBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
_slBg.BorderSizePixel = 0
_slBg.Name = _rn()
_slBg.Parent = _slFrame
Instance.new("UICorner", _slBg).CornerRadius = UDim.new(0, 4)

local _slFill = Instance.new("Frame")
_slFill.Size = UDim2.new((_slideSpd - _slideMin) / (_slideMax - _slideMin), 0, 1, 0)
_slFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
_slFill.BorderSizePixel = 0
_slFill.Name = _rn()
_slFill.Parent = _slBg
Instance.new("UICorner", _slFill).CornerRadius = UDim.new(0, 4)

local _slKnob = Instance.new("Frame")
_slKnob.Size = UDim2.new(0, 14, 0, 14)
_slKnob.Position = UDim2.new((_slideSpd - _slideMin) / (_slideMax - _slideMin), -7, 0.5, -7)
_slKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_slKnob.BorderSizePixel = 0
_slKnob.Name = _rn()
_slKnob.Parent = _slBg
Instance.new("UICorner", _slKnob).CornerRadius = UDim.new(1, 0)

local _dragging = false

local function _updateSlider(inputX)
	local bgPos = _slBg.AbsolutePosition.X
	local bgSize = _slBg.AbsoluteSize.X
	local pct = mclamp((inputX - bgPos) / bgSize, 0, 1)
	_slideSpd = mfloor(_slideMin + pct * (_slideMax - _slideMin))
	_slFill.Size = UDim2.new(pct, 0, 1, 0)
	_slKnob.Position = UDim2.new(pct, -7, 0.5, -7)
	_slLabel.Text = tostring(_slideSpd)
	if _slide then _dsb.Text = "DESLIZ: " .. _slideSpd end
end

_slBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		_dragging = true
		_updateSlider(input.Position.X)
	end
end)

UIS.InputChanged:Connect(function(input)
	if _gen ~= _mainGen then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if _dragging then _updateSlider(input.Position.X) end
		if _yuDrag then _updateYupi(input.Position.X) end
		if _spDrag then _updateTpSpd(input.Position.X) end
	end
end)

UIS.InputEnded:Connect(function(input)
	if _gen ~= _mainGen then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		_dragging = false
		_yuDrag = false
		_spDrag = false
	end
end)

-- NOCLIP
local function _cacheNcParts()
	_ncParts = {}
	local ch = LP.Character
	if not ch then return end
	for _, p in ipairs(ch:GetDescendants()) do
		if p:IsA("BasePart") then tinsert(_ncParts, p) end
	end
end

local function _toggleNoclip()
	_noclip = not _noclip
	if _noclip then
		_ncb.Text = "NOCLIP: ON"
		_ncb.TextColor3 = C3_ON
		_cacheNcParts()
		_nccon = RS.Stepped:Connect(function()
			if not _noclip then return end
			for i = 1, #_ncParts do
				local p = _ncParts[i]
				if p and p.Parent then p.CanCollide = false end
			end
		end)
	else
		_ncb.Text = "NOCLIP: OFF"
		_ncb.TextColor3 = C3_OFF
		if _nccon then _nccon:Disconnect(); _nccon = nil end
		for i = 1, #_ncParts do
			local p = _ncParts[i]
			if p and p.Parent then p.CanCollide = true end
		end
		_ncParts = {}
	end
end
_ncb.MouseButton1Click:Connect(_toggleNoclip)

-- FULLBRIGHT
local function _toggleBright()
	_bright = not _bright
	if _bright then
		_brb.Text = "LUZ: ON"
		_brb.TextColor3 = C3_ON
		_brightOG = {
			amb = Lighting.Ambient,
			out = Lighting.OutdoorAmbient,
			bright = Lighting.Brightness,
			fog = Lighting.FogEnd,
			time = Lighting.ClockTime
		}
		Lighting.Ambient = C3_WHITE
		Lighting.OutdoorAmbient = C3_WHITE
		Lighting.Brightness = 2
		Lighting.FogEnd = 1e9
		Lighting.ClockTime = 14
		for _, e in ipairs(Lighting:GetDescendants()) do
			if e:IsA("Atmosphere") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") then
				e.Enabled = false
			end
		end
	else
		_brb.Text = "LUZ: OFF"
		_brb.TextColor3 = C3_OFF
		if _brightOG.amb then
			Lighting.Ambient = _brightOG.amb
			Lighting.OutdoorAmbient = _brightOG.out
			Lighting.Brightness = _brightOG.bright
			Lighting.FogEnd = _brightOG.fog
			Lighting.ClockTime = _brightOG.time
		end
		for _, e in ipairs(Lighting:GetDescendants()) do
			if e:IsA("Atmosphere") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") then
				e.Enabled = true
			end
		end
	end
end
_brb.MouseButton1Click:Connect(_toggleBright)

-- DESLIZAMIENTO
local function _toggleSlide()
	_slide = not _slide
	if _slide then
		_dsb.Text = "DESLIZ: " .. _slideSpd
		_dsb.TextColor3 = C3_ON
	else
		_dsb.Text = "DESLIZAMIENTO: OFF"
		_dsb.TextColor3 = C3_OFF
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end)
	end
end
_dsb.MouseButton1Click:Connect(_toggleSlide)

RS.Heartbeat:Connect(function()
	if _gen ~= _mainGen then return end
	if _tick % 4 == 0 and _slide then
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = _slideSpd end
		end)
	end
end)

LP.CharacterAdded:Connect(function()
	if _gen ~= _mainGen then return end
	task.wait(0.5)
	if _noclip then _cacheNcParts() end
	if _grav then _applyGyro() end
	if _slide then
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = _slideSpd end
		end)
	end
end)

-- GRAVEDAD 0
_grav = false
_gravOG = nil
_gravCon = nil

local function _applyGyro()
	pcall(function()
		if _gravGyro then _gravGyro:Destroy() end
		_gravGyro = nil
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			_gravGyro = Instance.new("BodyGyro")
			_gravGyro.MaxTorque = Vector3.new(400000, 0, 400000)
			_gravGyro.P = 10000
			_gravGyro.D = 500
			_gravGyro.CFrame = hrp.CFrame
			_gravGyro.Parent = hrp
		end
	end)
end

local function _toggleGrav()
	_grav = not _grav
	if _grav then
		_grb.Text = "GRAVEDAD 0: ON"
		_grb.TextColor3 = C3_ON
		_gravOG = game.Workspace.Gravity
		game.Workspace.Gravity = 2
		_applyGyro()
		_gravCon = RS.Heartbeat:Connect(function()
			if not _grav then return end
			if _tick % 15 ~= 0 then return end
			if game.Workspace.Gravity ~= 25 then
				game.Workspace.Gravity = 2
			end
		end)
	else
		_grb.Text = "GRAVEDAD 0: OFF"
		_grb.TextColor3 = C3_OFF
		if _gravCon then _gravCon:Disconnect(); _gravCon = nil end
		if _gravGyro then pcall(function() _gravGyro:Destroy() end); _gravGyro = nil end
		game.Workspace.Gravity = _gravOG or 196.2
	end
end
_grb.MouseButton1Click:Connect(_toggleGrav)

-- INVISIBILIDAD (FE CFrame Desync)
local _invisCF = nil

local function _toggleInvis()
	_invis = not _invis
	if _invis then
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then _invis = false; return end
		_ivb.Text = "INVIS: ON"
		_ivb.TextColor3 = C3_ON
		-- guardar posicion real
		_invisCF = hrp.CFrame
		-- mandar al servidor lejoooos
		hrp.CFrame = CFrame.new(9e8, 9e8, 9e8)
		hrp.Velocity = V3_ZERO
		-- esperar que el servidor registre
		task.wait(0.5)
		-- volver localmente a donde estabas
		hrp.CFrame = _invisCF
		-- mantener posicion local contra correcciones del servidor
		_invisCon = RS.Stepped:Connect(function()
			if not _invis then return end
			local hrp2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if not hrp2 then return end
			-- si el servidor intenta mandarnos de vuelta al 9e8, cancelar
			if hrp2.Position.Magnitude > 1e7 then
				hrp2.CFrame = _invisCF
			end
			-- actualizar posicion guardada pa cuando desactivemos
			if hrp2.Position.Magnitude < 1e7 then
				_invisCF = hrp2.CFrame
			end
		end)
	else
		_ivb.Text = "INVIS: OFF"
		_ivb.TextColor3 = C3_OFF
		if _invisCon then _invisCon:Disconnect(); _invisCon = nil end
		-- forzar al servidor a ver nuestra posicion real
		pcall(function()
			local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if hrp and _invisCF then
				hrp.CFrame = _invisCF
			end
		end)
		_invisCF = nil
	end
end
_ivb.MouseButton1Click:Connect(_toggleInvis)

local _tinfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function _toggleDropdown()
	_dopen = not _dopen
	if _dopen then
		TweenService:Create(_dpanel, _tinfo, {Position = UDim2.new(0.5, -150, 0, 22)}):Play()
		_dtab.Text = "▲ ✴ Claudex ▲"
	else
		TweenService:Create(_dpanel, _tinfo, {Position = UDim2.new(0.5, -150, -1, 0)}):Play()
		_dtab.Text = "▼ ✴ Claudex ▼"
	end
end
_dtab.MouseButton1Click:Connect(_toggleDropdown)

-- ============ KEYBINDS ============
UIS.InputBegan:Connect(function(input, gpe)
	if _gen ~= _mainGen then return end
	if gpe then return end
	local kc = input.KeyCode
	if kc == Enum.KeyCode.F2 then _toggleNoclip()
	elseif kc == Enum.KeyCode.F3 then _toggleBright()
	elseif kc == Enum.KeyCode.F4 then _toggleSlide()
	elseif kc == Enum.KeyCode.F5 then _toggleGrav()
	elseif kc == Enum.KeyCode.F6 then _toggleDropdown()
	elseif kc == Enum.KeyCode.F7 then _toggleInvis()
	elseif kc == Enum.KeyCode.F8 then _doRST()
	end
end)

-- ============ INIT ============
_AT._obj = _obj
_AT.startWatchdog(5)
local function _initPlayer(p)
	if _pcons[p] then
		for _, c in pairs(_pcons[p]) do pcall(function() c:Disconnect() end) end
		_pcons[p] = nil
	end
	_make(p); _td(p)
end
for _, p in ipairs(Players:GetPlayers()) do _initPlayer(p) end
Players.PlayerAdded:Connect(function(p) _initPlayer(p) end)
Players.PlayerRemoving:Connect(_del)
_md()
