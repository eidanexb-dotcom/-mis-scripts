local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Network ownership boost (solo SimulationRadius)
if not getgenv().TornadoNetwork then
    getgenv().TornadoNetwork = true
    LocalPlayer.ReplicationFocus = workspace
    RunService.Heartbeat:Connect(function()
        pcall(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end)
    end)
end

-- GUI [STORM THEME]
local COLORS = {
    bg        = Color3.fromRGB(18, 22, 35),
    panel     = Color3.fromRGB(28, 34, 50),
    accent    = Color3.fromRGB(0, 200, 255),
    accentDim = Color3.fromRGB(0, 120, 180),
    active    = Color3.fromRGB(120, 255, 100),
    danger    = Color3.fromRGB(255, 70, 90),
    text      = Color3.fromRGB(230, 240, 255),
    textDim   = Color3.fromRGB(140, 160, 200),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperRingPartsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 310)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -155)
MainFrame.BackgroundColor3 = COLORS.bg
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent = MainFrame

-- Title bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -16, 0, 42)
Title.Position = UDim2.new(0, 8, 0, 6)
Title.Text = "⚡ TORNADO"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = COLORS.text
Title.BackgroundColor3 = COLORS.panel
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = Title

local titlePad = Instance.new("UIPadding")
titlePad.PaddingLeft = UDim.new(0, 14)
titlePad.Parent = Title

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, COLORS.accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 100, 255)),
}
titleGradient.Parent = Title

local function makeButton(text, posX, posY, sizeX, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(sizeX, 0, 0, 32)
    btn.Position = UDim2.new(posX, 0, 0, posY)
    btn.Text = text
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = color or COLORS.panel
    btn.TextColor3 = COLORS.text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = MainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = COLORS.accentDim
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = btn

    btn.MouseEnter:Connect(function()
        s.Transparency = 0
    end)
    btn.MouseLeave:Connect(function()
        s.Transparency = 0.5
    end)
    return btn
end

local function makeLabel(text, posX, posY, sizeX)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(sizeX, 0, 0, 32)
    lbl.Position = UDim2.new(posX, 0, 0, posY)
    lbl.Text = text
    lbl.BackgroundColor3 = COLORS.bg
    lbl.TextColor3 = COLORS.accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = MainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = lbl

    local s = Instance.new("UIStroke")
    s.Color = COLORS.accentDim
    s.Thickness = 1
    s.Transparency = 0.6
    s.Parent = lbl
    return lbl
end

local ToggleButton = makeButton("◯  RING PARTS  OFF", 0.06, 60, 0.88)

local DecreaseRadius = makeButton("−", 0.06, 105, 0.17)
local RadiusDisplay = makeLabel("RADIUS  50", 0.25, 105, 0.5)
local IncreaseRadius = makeButton("+", 0.77, 105, 0.17)

local DecreaseSpeed = makeButton("−", 0.06, 145, 0.17)
local SpeedDisplay = makeLabel("SPEED  1", 0.25, 145, 0.5)
local IncreaseSpeed = makeButton("+", 0.77, 145, 0.17)

local DecreaseStrength = makeButton("−", 0.06, 185, 0.17)
local StrengthDisplay = makeLabel("POWER  1000", 0.25, 185, 0.5)
local IncreaseStrength = makeButton("+", 0.77, 185, 0.17)

local CloseScript = makeButton("✕  DESTROY", 0.06, 235, 0.88, COLORS.panel)
CloseScript.TextColor3 = COLORS.danger

-- Footer status dot
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 1, -18)
StatusDot.BackgroundColor3 = COLORS.danger
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame
local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -28, 0, 14)
StatusText.Position = UDim2.new(0, 26, 1, -22)
StatusText.Text = "idle"
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextColor3 = COLORS.textDim
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 11
StatusText.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 26, 0, 26)
MinimizeButton.Position = UDim2.new(1, -32, 0, 14)
MinimizeButton.Text = "—"
MinimizeButton.AutoButtonColor = false
MinimizeButton.BackgroundColor3 = COLORS.bg
MinimizeButton.TextColor3 = COLORS.accent
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 14
MinimizeButton.Parent = MainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = MinimizeButton

local minStroke = Instance.new("UIStroke")
minStroke.Color = COLORS.accent
minStroke.Thickness = 1
minStroke.Transparency = 0.4
minStroke.Parent = MinimizeButton

local hideable = {ToggleButton, DecreaseRadius, IncreaseRadius, RadiusDisplay,
    DecreaseSpeed, IncreaseSpeed, SpeedDisplay,
    DecreaseStrength, IncreaseStrength, StrengthDisplay, CloseScript,
    StatusDot, StatusText}

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 54), "Out", "Quad", 0.25, true)
        MinimizeButton.Text = "+"
        for _, el in ipairs(hideable) do el.Visible = false end
    else
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 310), "Out", "Quad", 0.25, true)
        MinimizeButton.Text = "—"
        for _, el in ipairs(hideable) do el.Visible = true end
    end
end)

-- Drag
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tornado state
local radius = 50
local height = 100
local rotationSpeed = 1
local attractionStrength = 1000
local ringPartsEnabled = false

local noclippedParts = {}
local floorExcluded = {}
local FLOOR_STICKY_SECONDS = 3

local function getFloorPart()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -30, 0), params)
    if result then return result.Instance end
    return nil
end

local function getExclusionRoot(part)
    local node = part
    while node and node.Parent and node.Parent ~= workspace do
        node = node.Parent
    end
    return node or part
end

local function markFloor(instance)
    floorExcluded[instance] = os.clock() + FLOOR_STICKY_SECONDS
    if noclippedParts[instance] ~= nil and instance:IsA("BasePart") then
        instance.CanCollide = noclippedParts[instance]
        noclippedParts[instance] = nil
    end
end

local function cleanupFloor()
    local now = os.clock()
    for inst, expiry in pairs(floorExcluded) do
        if expiry < now or not inst.Parent then
            floorExcluded[inst] = nil
        end
    end
end

local function isFloorExcluded(part)
    if floorExcluded[part] then return true end
    local root = getExclusionRoot(part)
    return floorExcluded[root] ~= nil
end

local function applyNoclip(part)
    if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(workspace) then
        if part.Parent == LocalPlayer.Character or part:IsDescendantOf(LocalPlayer.Character) then
            return
        end
        if noclippedParts[part] == nil then
            noclippedParts[part] = part.CanCollide
        end
        part.CanCollide = false
    end
end

local function restoreAllNoclip()
    for part, original in pairs(noclippedParts) do
        if part and part.Parent then
            part.CanCollide = original
        end
    end
    noclippedParts = {}
end

local function isTrackable(Part)
    if not Part:IsA("BasePart") then return false end
    if not Part:IsDescendantOf(workspace) then return false end
    if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
        return false
    end
    return true
end

local parts = {}
local function addPart(part)
    if isTrackable(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
        if ringPartsEnabled and not part.Anchored then
            applyNoclip(part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
    if noclippedParts[part] ~= nil then
        noclippedParts[part] = nil
    end
end

for _, part in pairs(workspace:GetDescendants()) do
    addPart(part)
end

local addedConn = workspace.DescendantAdded:Connect(addPart)
local removedConn = workspace.DescendantRemoving:Connect(removePart)

-- Block sit + slight float
local FLOAT_OFFSET = 0.3
local originalHipHeight = nil
local currentHumanoid = nil
local sitConn = nil

local function applyFloat(humanoid)
    if not humanoid then return end
    if originalHipHeight == nil then
        originalHipHeight = humanoid.HipHeight
    end
    humanoid.HipHeight = originalHipHeight + FLOAT_OFFSET
end

local function restoreFloat(humanoid)
    if humanoid and originalHipHeight ~= nil then
        humanoid.HipHeight = originalHipHeight
    end
end

local function hookHumanoid(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    currentHumanoid = humanoid
    originalHipHeight = humanoid.HipHeight
    if ringPartsEnabled then
        pcall(applyFloat, humanoid)
    end
    if sitConn then sitConn:Disconnect() end
    sitConn = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        pcall(function()
            if ringPartsEnabled and humanoid.Sit then
                humanoid.Sit = false
                humanoid.SeatPart = nil
            end
        end)
    end)
end

if LocalPlayer.Character then
    hookHumanoid(LocalPlayer.Character)
end
local charConn = LocalPlayer.CharacterAdded:Connect(function(char)
    originalHipHeight = nil
    hookHumanoid(char)
end)

-- Tornado heartbeat (LOGICA INTACTA)
local tornadoConn
tornadoConn = RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end

    pcall(function()
        cleanupFloor()
        local floorPart = getFloorPart()
        if floorPart then
            markFloor(floorPart)
            markFloor(getExclusionRoot(floorPart))
        end
    end)

    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local tornadoCenter = humanoidRootPart.Position
    for _, part in pairs(parts) do
        pcall(function()
            if part.Parent and not part.Anchored and not isFloorExcluded(part) then
                if noclippedParts[part] == nil then
                    applyNoclip(part)
                end
                local pos = part.Position
                local flatDelta = Vector3.new(pos.X - tornadoCenter.X, 0, pos.Z - tornadoCenter.Z)
                local distance = flatDelta.Magnitude
                if distance < 0.01 then return end
                local angle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
                local newAngle = angle + math.rad(rotationSpeed)
                local targetPos = Vector3.new(
                    tornadoCenter.X + math.cos(newAngle) * math.min(radius, distance),
                    tornadoCenter.Y + (height * (math.abs(math.sin((pos.Y - tornadoCenter.Y) / height)))),
                    tornadoCenter.Z + math.sin(newAngle) * math.min(radius, distance)
                )
                local delta = targetPos - part.Position
                if delta.Magnitude < 0.01 then return end
                part.Velocity = delta.Unit * attractionStrength
            end
        end)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    ToggleButton.Text = ringPartsEnabled and "●  RING PARTS  ON" or "◯  RING PARTS  OFF"
    ToggleButton.BackgroundColor3 = ringPartsEnabled and COLORS.active or COLORS.panel
    ToggleButton.TextColor3 = ringPartsEnabled and COLORS.bg or COLORS.text
    StatusDot.BackgroundColor3 = ringPartsEnabled and COLORS.active or COLORS.danger
    StatusText.Text = ringPartsEnabled and "active" or "idle"
    if ringPartsEnabled then
        for _, part in pairs(parts) do
            if not part.Anchored then
                applyNoclip(part)
            end
        end
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.Sit then
                humanoid.Sit = false
                humanoid.SeatPart = nil
            end
            applyFloat(humanoid)
        end
    else
        restoreAllNoclip()
        restoreFloat(currentHumanoid)
    end
end)

DecreaseRadius.MouseButton1Click:Connect(function()
    radius = math.max(1, radius - 2)
    RadiusDisplay.Text = "RADIUS  " .. radius
end)

IncreaseRadius.MouseButton1Click:Connect(function()
    radius = math.min(1000, radius + 2)
    RadiusDisplay.Text = "RADIUS  " .. radius
end)

DecreaseSpeed.MouseButton1Click:Connect(function()
    rotationSpeed = math.max(0, rotationSpeed - 1)
    SpeedDisplay.Text = "SPEED  " .. rotationSpeed
end)

IncreaseSpeed.MouseButton1Click:Connect(function()
    rotationSpeed = math.min(100, rotationSpeed + 1)
    SpeedDisplay.Text = "SPEED  " .. rotationSpeed
end)

DecreaseStrength.MouseButton1Click:Connect(function()
    attractionStrength = math.max(50, attractionStrength - 100)
    StrengthDisplay.Text = "POWER  " .. attractionStrength
end)

IncreaseStrength.MouseButton1Click:Connect(function()
    attractionStrength = math.min(10000, attractionStrength + 100)
    StrengthDisplay.Text = "POWER  " .. attractionStrength
end)

CloseScript.MouseButton1Click:Connect(function()
    ringPartsEnabled = false
    restoreAllNoclip()
    restoreFloat(currentHumanoid)
    if tornadoConn then tornadoConn:Disconnect() end
    if addedConn then addedConn:Disconnect() end
    if removedConn then removedConn:Disconnect() end
    if sitConn then sitConn:Disconnect() end
    if charConn then charConn:Disconnect() end
    ScreenGui:Destroy()
end)
