--[[
    ✴ TORNADO CLEAN
    Base: Super Ring Parts V4 (lukas) - limpio
    Style: CLAUDEX
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============ CACHE ============
local mrand, mfloor = math.random, math.floor
local schar = string.char
local tconcat = table.concat
local C3_BG       = Color3.fromRGB(20, 20, 20)
local C3_BG2      = Color3.fromRGB(30, 30, 30)
local C3_BG3      = Color3.fromRGB(40, 40, 40)
local C3_TEXT     = Color3.fromRGB(255, 255, 255)
local C3_DIM      = Color3.fromRGB(140, 160, 200)
local C3_ACCENT   = Color3.fromRGB(0, 200, 255)
local C3_ON       = Color3.fromRGB(0, 255, 100)
local C3_OFF      = Color3.fromRGB(255, 80, 80)
local C3_DANGER   = Color3.fromRGB(255, 50, 50)
local C3_DANGERBG = Color3.fromRGB(60, 0, 0)

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
        pcall(function() p = game:GetService("CoreGui") end)
        if not p then p = LocalPlayer:WaitForChild("PlayerGui") end
    end
    local g = Instance.new("ScreenGui")
    g.Name = _rn()
    g.ResetOnSpawn = false
    g.Parent = p
    return g
end

local function _stroke(parent, color, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or C3_ACCENT
    s.Thickness = 1
    s.Transparency = trans or 0.5
    s.Parent = parent
    return s
end

local function _corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

-- ============ NETWORK OWNERSHIP ============
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }
    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end
    EnablePartControl()
end

-- ============ STATE ============
local radius = 50
local height = 100
local rotationSpeed = 1
local attractionStrength = 1000
local ringPartsEnabled = false

-- ============ GUI ============
local _sg = _gui()

-- Main floating button (TOR)
local _tb = Instance.new("TextButton")
_tb.Size = UDim2.new(0, 40, 0, 40)
_tb.Position = UDim2.new(0, 10, 0.5, -20)
_tb.BackgroundColor3 = C3_BG2
_tb.BackgroundTransparency = 0.3
_tb.TextColor3 = C3_ACCENT
_tb.Font = Enum.Font.GothamBold
_tb.TextSize = 16
_tb.Text = "TOR"
_tb.AutoButtonColor = false
_tb.Name = _rn()
_tb.Parent = _sg
_corner(_tb, 8)
_stroke(_tb, C3_ACCENT, 0.5)

-- Toggle (state) button below TOR
local _stb = Instance.new("TextButton")
_stb.Size = UDim2.new(0, 40, 0, 25)
_stb.Position = UDim2.new(0, 10, 0.5, 25)
_stb.BackgroundColor3 = C3_BG2
_stb.BackgroundTransparency = 0.3
_stb.TextColor3 = C3_OFF
_stb.Font = Enum.Font.GothamBold
_stb.TextSize = 9
_stb.Text = "OFF"
_stb.AutoButtonColor = false
_stb.Name = _rn()
_stb.Parent = _sg
_corner(_stb, 6)
local _stbStroke = _stroke(_stb, C3_OFF, 0.5)

-- RST button
local _rst = Instance.new("TextButton")
_rst.Size = UDim2.new(0, 40, 0, 25)
_rst.Position = UDim2.new(0, 10, 0.5, 55)
_rst.BackgroundColor3 = C3_DANGERBG
_rst.BackgroundTransparency = 0.3
_rst.TextColor3 = C3_DANGER
_rst.Font = Enum.Font.GothamBold
_rst.TextSize = 9
_rst.Text = "RST"
_rst.AutoButtonColor = false
_rst.Name = _rn()
_rst.Parent = _sg
_corner(_rst, 6)
_stroke(_rst, C3_DANGER, 0.4)

-- Settings panel (slides out)
local _panel = Instance.new("Frame")
_panel.Size = UDim2.new(0, 180, 0, 170)
_panel.Position = UDim2.new(0, 55, 0.5, -85)
_panel.BackgroundColor3 = C3_BG
_panel.BackgroundTransparency = 0.15
_panel.BorderSizePixel = 0
_panel.Visible = false
_panel.Name = _rn()
_panel.Parent = _sg
_corner(_panel, 8)
_stroke(_panel, C3_ACCENT, 0.4)

local _pl = Instance.new("UIListLayout")
_pl.Padding = UDim.new(0, 4)
_pl.SortOrder = Enum.SortOrder.LayoutOrder
_pl.Parent = _panel

local _pp = Instance.new("UIPadding")
_pp.PaddingTop = UDim.new(0, 6)
_pp.PaddingLeft = UDim.new(0, 6)
_pp.PaddingRight = UDim.new(0, 6)
_pp.Parent = _panel

local function _row(label, valueText, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Name = _rn()
    f.Parent = _panel

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 26, 1, 0)
    minus.Position = UDim2.new(0, 0, 0, 0)
    minus.BackgroundColor3 = C3_BG3
    minus.BackgroundTransparency = 0.3
    minus.TextColor3 = C3_ACCENT
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 14
    minus.Text = "−"
    minus.AutoButtonColor = false
    minus.Name = _rn()
    minus.Parent = f
    _corner(minus, 4)
    _stroke(minus, C3_ACCENT, 0.6)

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -56, 1, 0)
    val.Position = UDim2.new(0, 28, 0, 0)
    val.BackgroundColor3 = C3_BG2
    val.BackgroundTransparency = 0.3
    val.TextColor3 = C3_ACCENT
    val.Font = Enum.Font.GothamBold
    val.TextSize = 11
    val.Text = label .. "  " .. valueText
    val.Name = _rn()
    val.Parent = f
    _corner(val, 4)
    _stroke(val, C3_ACCENT, 0.6)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 26, 1, 0)
    plus.Position = UDim2.new(1, -26, 0, 0)
    plus.BackgroundColor3 = C3_BG3
    plus.BackgroundTransparency = 0.3
    plus.TextColor3 = C3_ACCENT
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 14
    plus.Text = "+"
    plus.AutoButtonColor = false
    plus.Name = _rn()
    plus.Parent = f
    _corner(plus, 4)
    _stroke(plus, C3_ACCENT, 0.6)

    return minus, val, plus
end

local _rMinus, _rVal, _rPlus = _row("RAD", tostring(radius), 1)
local _sMinus, _sVal, _sPlus = _row("SPD", tostring(rotationSpeed), 2)
local _pMinus, _pVal, _pPlus = _row("PWR", tostring(attractionStrength), 3)

-- Footer status
local _foot = Instance.new("Frame")
_foot.Size = UDim2.new(1, 0, 0, 18)
_foot.BackgroundTransparency = 1
_foot.LayoutOrder = 99
_foot.Name = _rn()
_foot.Parent = _panel

local _dot = Instance.new("Frame")
_dot.Size = UDim2.new(0, 8, 0, 8)
_dot.Position = UDim2.new(0, 4, 0.5, -4)
_dot.BackgroundColor3 = C3_OFF
_dot.BorderSizePixel = 0
_dot.Name = _rn()
_dot.Parent = _foot
_corner(_dot, 999)

local _stat = Instance.new("TextLabel")
_stat.Size = UDim2.new(1, -20, 1, 0)
_stat.Position = UDim2.new(0, 18, 0, 0)
_stat.BackgroundTransparency = 1
_stat.TextColor3 = C3_DIM
_stat.Font = Enum.Font.Gotham
_stat.TextSize = 10
_stat.TextXAlignment = Enum.TextXAlignment.Left
_stat.Text = "idle"
_stat.Name = _rn()
_stat.Parent = _foot

-- ============ TOGGLE GUI VISIBILITY ============
_tb.MouseButton1Click:Connect(function()
    _panel.Visible = not _panel.Visible
end)

-- ============ TORNADO LOGIC ============
local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false
        end
        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end

local parts = {}
local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

for _, part in pairs(workspace:GetDescendants()) do
    addPart(part)
end

workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end

    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local tornadoCenter = humanoidRootPart.Position
        for _, part in pairs(parts) do
            if part.Parent and not part.Anchored then
                local pos = part.Position
                local distance = (Vector3.new(pos.X, tornadoCenter.Y, pos.Z) - tornadoCenter).Magnitude
                local angle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
                local newAngle = angle + math.rad(rotationSpeed)
                local targetPos = Vector3.new(
                    tornadoCenter.X + math.cos(newAngle) * math.min(radius, distance),
                    tornadoCenter.Y + (height * (math.abs(math.sin((pos.Y - tornadoCenter.Y) / height)))),
                    tornadoCenter.Z + math.sin(newAngle) * math.min(radius, distance)
                )
                local directionToTarget = (targetPos - part.Position).unit
                part.Velocity = directionToTarget * attractionStrength
            end
        end
    end
end)

-- ============ BUTTON CALLBACKS ============
_stb.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    _stb.Text = ringPartsEnabled and "ON" or "OFF"
    _stb.TextColor3 = ringPartsEnabled and C3_ON or C3_OFF
    _stbStroke.Color = ringPartsEnabled and C3_ON or C3_OFF
    _dot.BackgroundColor3 = ringPartsEnabled and C3_ON or C3_OFF
    _stat.Text = ringPartsEnabled and "active" or "idle"
end)

_rMinus.MouseButton1Click:Connect(function()
    radius = math.max(1, radius - 2)
    _rVal.Text = "RAD  " .. radius
end)
_rPlus.MouseButton1Click:Connect(function()
    radius = math.min(1000, radius + 2)
    _rVal.Text = "RAD  " .. radius
end)

_sMinus.MouseButton1Click:Connect(function()
    rotationSpeed = math.max(0, rotationSpeed - 1)
    _sVal.Text = "SPD  " .. rotationSpeed
end)
_sPlus.MouseButton1Click:Connect(function()
    rotationSpeed = math.min(100, rotationSpeed + 1)
    _sVal.Text = "SPD  " .. rotationSpeed
end)

_pMinus.MouseButton1Click:Connect(function()
    attractionStrength = math.max(50, attractionStrength - 100)
    _pVal.Text = "PWR  " .. attractionStrength
end)
_pPlus.MouseButton1Click:Connect(function()
    attractionStrength = math.min(10000, attractionStrength + 100)
    _pVal.Text = "PWR  " .. attractionStrength
end)

-- ============ RST (DESTROY) ============
_rst.MouseButton1Click:Connect(function()
    ringPartsEnabled = false
    pcall(function() _sg:Destroy() end)
end)
