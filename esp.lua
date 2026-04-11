if _ESP_LOADED then return end
_ESP_LOADED = true

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
		_ESP_LOADED = nil
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
		local ok = _ref.pcall(function()
			local d = debug
			if d and d.getinfo then
				local info = d.getinfo(_AT.checkIntegrity)
				if info and info.source and info.source:find("@") then return false end
			end
		end)
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

	_AT._ref = _AT.protectReadOnly(_ref)
	_AT.protectTable(_AT)
end
-- ============ FIN ANTI-TAMPER ============

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer

local _on = true
local _obj = {}
local _k = {}
local _tick = 0
local _int = 0.15
local _gen = 0

RS.Heartbeat:Connect(function()
	_tick = _tick + 1
end)

local function _rn()
	local s = ""
	for i = 1, math.random(8, 14) do
		local r = math.random(1, 2)
		if r == 1 then s = s .. string.char(math.random(65, 90))
		else s = s .. string.char(math.random(97, 122)) end
	end
	return s
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
	if d <= 20 then return Color3.fromRGB(255, 0, 0)
	elseif d <= 30 then
		local t = (d - 20) / 10
		return Color3.fromRGB(255, math.floor(165 * t), 0)
	elseif d <= 50 then
		local t = (d - 30) / 20
		return Color3.fromRGB(math.floor(255 * (1 - t)), math.floor(165 + 90 * t), 0)
	else return Color3.fromRGB(0, 255, 0) end
end

local function _anim(c)
	if not c then return false end
	local h = c:FindFirstChild("Head")
	local r = c:FindFirstChild("HumanoidRootPart")
	if h and r then
		if (h.Position.Y - r.Position.Y) + h.Size.Y > 7 then return true end
	end
	return false
end

local function _dist(c)
	local mc = LP.Character
	if not mc then return nil end
	local m = mc:FindFirstChild("HumanoidRootPart")
	if not m or not c then return nil end
	local r = c:FindFirstChild("HumanoidRootPart")
	if not r then return nil end
	return math.floor((m.Position - r.Position).Magnitude)
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
			hl.FillColor = Color3.fromRGB(255, 0, 0)
			hl.FillTransparency = 0.7
			hl.OutlineColor = Color3.new(1, 1, 1)
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
		nl.TextColor3 = Color3.fromRGB(255, 0, 0)
		nl.TextStrokeTransparency = 0.5
		nl.TextStrokeColor3 = Color3.new(0, 0, 0)
		nl.Font = Enum.Font.Gotham
		nl.TextSize = 13
		nl.Text = pl.Name
		nl.Name = _rn()
		nl.Parent = bb

		local dl = Instance.new("TextLabel")
		dl.Size = UDim2.new(1, 0, 0.5, 0)
		dl.Position = UDim2.new(0, 0, 0.5, 0)
		dl.BackgroundTransparency = 1
		dl.TextColor3 = Color3.fromRGB(255, 255, 100)
		dl.TextStrokeTransparency = 0.5
		dl.TextStrokeColor3 = Color3.new(0, 0, 0)
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

			if _anim(ch) and hl then
				hl.FillColor = Color3.fromRGB(180, 0, 255)
				hl.FillTransparency = 0.3
				hl.OutlineColor = Color3.fromRGB(255, 0, 0)
				nl.TextColor3 = Color3.fromRGB(255, 0, 0)
				if k > 0 then nl.Text = "[!] ANIMATRONICO " .. pl.Name .. " [" .. k .. " kills]"
				else nl.Text = "[!] ANIMATRONICO " .. pl.Name end
			else
				local co = _cd(d)
				if hl then
					hl.FillColor = co
					hl.FillTransparency = 0.7
					hl.OutlineColor = Color3.new(1, 1, 1)
				end
				nl.TextColor3 = co
				if k > 0 then nl.Text = pl.Name .. " [" .. k .. " kills]"
				else nl.Text = pl.Name end
			end
		end)
	end

	if pl.Character then _go(pl.Character) end
	pl.CharacterAdded:Connect(function(c) if _gen ~= _mg then return end task.wait(0.5) if _on then _go(c) end end)
end

local function _del(pl)
	if _obj[pl] then
		for _, o in pairs(_obj[pl]) do pcall(function() o:Destroy() end) end
		_obj[pl] = nil
	end
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
	pl.CharacterAdded:Connect(function(c) if _gen ~= _mg then return end _oc(c) end)
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
_mb.TextColor3 = Color3.fromRGB(0, 255, 100)
_mb.Font = Enum.Font.Gotham
_mb.TextSize = 9
_mb.Text = "INST"
_mb.Name = _rn()
_mb.Parent = _sg
Instance.new("UICorner", _mb).CornerRadius = UDim.new(0, 6)

_mb.MouseButton1Click:Connect(function()
	local _prev = _tm
	if _mv and _tc then _tc:Disconnect(); _mv = false end
	if _prev == 2 then
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.Sit = false end
		end)
	end
	_tm = (_tm + 1) % 3
	if _tm == 0 then
		_mb.Text = "INST"
		_mb.TextColor3 = Color3.fromRGB(0, 255, 100)
	elseif _tm == 1 then
		_mb.Text = "SUAVE"
		_mb.TextColor3 = Color3.fromRGB(255, 200, 0)
	else
		_mb.Text = "BROMA"
		_mb.TextColor3 = Color3.fromRGB(255, 0, 200)
	end
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

_rst.MouseButton1Click:Connect(function()
	_gen = _gen + 1
	if _mv and _tc then _tc:Disconnect(); _mv = false end
	pcall(function()
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Sit = false end
	end)
	for pl, objs in pairs(_obj) do
		for _, o in pairs(objs) do pcall(function() o:Destroy() end) end
	end
	_obj = {}
	_k = {}
	_tick = 0
	_tm = 0
	_mb.Text = "INST"
	_mb.TextColor3 = Color3.fromRGB(0, 255, 100)
	_lf.Visible = false
	_open = true
	_tb.Visible = true
	_mb.Visible = true
	_rst.Visible = true
	_tg.Text = "ESP"
	_tg.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
	task.wait(0.3)
	for _, p in ipairs(Players:GetPlayers()) do _make(p); _td(p) end
	_md()
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
				if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
				if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
				local myHRP = LP.Character.HumanoidRootPart
				local head = p.Character:FindFirstChild("Head")
				if _tm == 1 then
					if _mv and _tc then _tc:Disconnect() end
					_mv = true
					_tc = RS.Heartbeat:Connect(function(dt)
						if not _mv then _tc:Disconnect() return end
						local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
						if not myRoot then _tc:Disconnect(); _mv = false; return end
						local tHead = p.Character and p.Character:FindFirstChild("Head")
						if not tHead then return end
						local target = tHead.Position + Vector3.new(0, 2, 0)
						local dir3 = target - myRoot.Position
						if dir3.Magnitude < 3 then
							myRoot.CFrame = CFrame.new(target)
							_tc:Disconnect()
							_mv = false
							return
						end
						pcall(function()
							myRoot.Velocity = Vector3.new(0, 0, 0)
							myRoot.CFrame = myRoot.CFrame + dir3.Unit * _spd * dt
						end)
					end)
				elseif _tm == 2 then
					if _mv and _tc then _tc:Disconnect() end
					if not head then return end
					myHRP.CFrame = CFrame.new(head.Position + Vector3.new(0, 2, 0))
					local hum = LP.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.Sit = true end
					_mv = true
					_tc = RS.Heartbeat:Connect(function()
						if not _mv then _tc:Disconnect() return end
						local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
						if not myRoot then _tc:Disconnect(); _mv = false; return end
						local tHead = p.Character and p.Character:FindFirstChild("Head")
						if not tHead then return end
						pcall(function()
							myRoot.CFrame = tHead.CFrame * CFrame.new(0, 2, 0)
							myRoot.Velocity = Vector3.new(0, 0, 0)
						end)
					end)
				else
					myHRP.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
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
	if _lf.Visible then _rl() end
end)
Players.PlayerRemoving:Connect(function()
	task.wait(0.5)
	if _lf.Visible then _rl() end
end)

-- ============ MENU TOGGLE ============
_tg = Instance.new("TextButton")
_tg.Size = UDim2.new(0, 40, 0, 25)
_tg.Position = UDim2.new(0, 10, 0.5, -70)
_tg.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
_tg.BackgroundTransparency = 0.3
_tg.TextColor3 = Color3.new(1, 1, 1)
_tg.Font = Enum.Font.GothamBold
_tg.TextSize = 10
_tg.Text = "ESP"
_tg.Name = _rn()
_tg.Parent = _sg
Instance.new("UICorner", _tg).CornerRadius = UDim.new(0, 8)

_tg.MouseButton1Click:Connect(function()
	_open = not _open
	_tb.Visible = _open
	_mb.Visible = _open
	_rst.Visible = _open
	if not _open then _lf.Visible = false end
	_tg.Text = _open and "ESP" or ">>>"
	_tg.BackgroundColor3 = _open and Color3.fromRGB(0, 130, 255) or Color3.fromRGB(50, 50, 50)
end)

-- ============ TOOLS GUI ============
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local _tsg = _gui()
_AT._tsg = _tsg
local _topen = true
local _noclip = false
local _nccon = nil
local _bright = false
local _brightOG = {}
local _slide = false
local _slideSpd = 80

local _tp = Instance.new("Frame")
_tp.Size = UDim2.new(0, 140, 0, 130)
_tp.Position = UDim2.new(1, -150, 0.5, -65)
_tp.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
_tp.BackgroundTransparency = 0.2
_tp.BorderSizePixel = 0
_tp.Name = _rn()
_tp.Parent = _tsg
Instance.new("UICorner", _tp).CornerRadius = UDim.new(0, 8)

local _tll = Instance.new("UIListLayout")
_tll.Padding = UDim.new(0, 4)
_tll.SortOrder = Enum.SortOrder.LayoutOrder
_tll.Parent = _tp

local _tpad = Instance.new("UIPadding")
_tpad.PaddingTop = UDim.new(0, 6)
_tpad.PaddingLeft = UDim.new(0, 6)
_tpad.PaddingRight = UDim.new(0, 6)
_tpad.Parent = _tp

local function _tbtn(txt, order, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.BackgroundTransparency = 0.3
	b.TextColor3 = col or Color3.fromRGB(255, 80, 80)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Text = txt
	b.LayoutOrder = order
	b.Name = _rn()
	b.Parent = _tp
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local _ncb = _tbtn("NOCLIP: OFF", 1)
local _brb = _tbtn("LUZ: OFF", 2)
local _slb = _tbtn("PATINAZO: OFF", 3)

-- NOCLIP
_ncb.MouseButton1Click:Connect(function()
	_noclip = not _noclip
	if _noclip then
		_ncb.Text = "NOCLIP: ON"
		_ncb.TextColor3 = Color3.fromRGB(0, 255, 100)
		_nccon = RS.Stepped:Connect(function()
			if not _noclip then return end
			local ch = LP.Character
			if not ch then return end
			for _, p in ipairs(ch:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	else
		_ncb.Text = "NOCLIP: OFF"
		_ncb.TextColor3 = Color3.fromRGB(255, 80, 80)
		if _nccon then _nccon:Disconnect(); _nccon = nil end
	end
end)

-- FULLBRIGHT
_brb.MouseButton1Click:Connect(function()
	_bright = not _bright
	if _bright then
		_brb.Text = "LUZ: ON"
		_brb.TextColor3 = Color3.fromRGB(0, 255, 100)
		_brightOG = {
			amb = Lighting.Ambient,
			out = Lighting.OutdoorAmbient,
			bright = Lighting.Brightness,
			fog = Lighting.FogEnd,
			time = Lighting.ClockTime
		}
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
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
		_brb.TextColor3 = Color3.fromRGB(255, 80, 80)
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
end)

-- PATINAZO
_slb.MouseButton1Click:Connect(function()
	_slide = not _slide
	if _slide then
		_slb.Text = "PATINAZO: ON"
		_slb.TextColor3 = Color3.fromRGB(0, 255, 100)
	else
		_slb.Text = "PATINAZO: OFF"
		_slb.TextColor3 = Color3.fromRGB(255, 80, 80)
		pcall(function()
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end)
	end
end)

local function _applySlide()
	if not _slide then return end
	local ch = LP.Character
	if not ch then return end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = _slideSpd end
end

RS.Heartbeat:Connect(function()
	if _tick % 4 == 0 then _applySlide() end
end)

LP.CharacterAdded:Connect(function(ch)
	task.wait(0.5)
	_applySlide()
end)

-- TOOLS TOGGLE
local _ttg = Instance.new("TextButton")
_ttg.Size = UDim2.new(0, 40, 0, 25)
_ttg.Position = UDim2.new(1, -50, 0.5, -90)
_ttg.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
_ttg.BackgroundTransparency = 0.3
_ttg.TextColor3 = Color3.new(1, 1, 1)
_ttg.Font = Enum.Font.GothamBold
_ttg.TextSize = 9
_ttg.Text = "TOOL"
_ttg.Name = _rn()
_ttg.Parent = _tsg
Instance.new("UICorner", _ttg).CornerRadius = UDim.new(0, 8)

_ttg.MouseButton1Click:Connect(function()
	_topen = not _topen
	_tp.Visible = _topen
	_ttg.Text = _topen and "TOOL" or "<<<"
	_ttg.BackgroundColor3 = _topen and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 50, 50)
end)

-- ============ INIT ============
_AT._obj = _obj
_AT.startWatchdog(5)
for _, p in ipairs(Players:GetPlayers()) do _make(p); _td(p) end
Players.PlayerAdded:Connect(function(p) _make(p); _td(p) end)
Players.PlayerRemoving:Connect(_del)
_md()
