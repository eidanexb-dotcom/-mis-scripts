local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer

local _on = true
local _obj = {}
local _k = {}
local _tick = 0
local _int = 0.15

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
			if not ch or not ch.Parent then
				cn:Disconnect()
				return
			end

			_tick = _tick + 1
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
	pl.CharacterAdded:Connect(function(c) task.wait(0.5) if _on then _go(c) end end)
end

local function _del(pl)
	if _obj[pl] then
		for _, o in pairs(_obj[pl]) do pcall(function() o:Destroy() end) end
		_obj[pl] = nil
	end
end

local function _td(pl)
	local function _oc(ch)
		if not ch then return end
		local hum = ch:WaitForChild("Humanoid", 5)
		if not hum then return end
		hum.Died:Connect(function()
			local c = _cerca(ch, pl)
			if c then _k[c] = (_k[c] or 0) + 1 end
		end)
	end
	if pl.Character then _oc(pl.Character) end
	pl.CharacterAdded:Connect(_oc)
end

local function _md()
	local function _om(ch)
		if not ch then return end
		local hum = ch:WaitForChild("Humanoid", 5)
		if not hum then return end
		hum.Died:Connect(function() _k = {} end)
	end
	if LP.Character then _om(LP.Character) end
	LP.CharacterAdded:Connect(_om)
end

-- ============ TP ============
local _sg = _gui()
local _ts = false
local _spd = 100
local _mv = false
local _tc = nil

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
	_ts = not _ts
	if _ts then
		_mb.Text = "SUAVE"
		_mb.TextColor3 = Color3.fromRGB(255, 200, 0)
	else
		if _mv and _tc then _tc:Disconnect(); _mv = false end
		_mb.Text = "INST"
		_mb.TextColor3 = Color3.fromRGB(0, 255, 100)
	end
end)

local _lf = Instance.new("ScrollingFrame")
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
				if _ts then
					if _mv and _tc then _tc:Disconnect() end
					_mv = true
					_tc = RS.Heartbeat:Connect(function(dt)
						if not _mv then _tc:Disconnect() return end
						if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then _tc:Disconnect(); _mv = false; return end
						if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then _tc:Disconnect(); _mv = false; return end
						local target = p.Character.HumanoidRootPart.Position
						local myPos = myHRP.Position
						local dir3 = target - myPos
						local dirFlat = Vector3.new(dir3.X, 0, dir3.Z)
						if dirFlat.Magnitude < 8 then
							_tc:Disconnect()
							_mv = false
							return
						end
						local move = dir3.Unit * _spd * dt
						myHRP.Velocity = Vector3.new(0, 0, 0)
						local hum = LP.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum:Move(dirFlat.Unit) end
						myHRP.CFrame = myHRP.CFrame + move
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

-- ============ INIT ============
for _, p in ipairs(Players:GetPlayers()) do _make(p); _td(p) end
Players.PlayerAdded:Connect(function(p) _make(p); _td(p) end)
Players.PlayerRemoving:Connect(_del)
_md()
