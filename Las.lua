local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Network ownership setup
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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperRingPartsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 240)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(204, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = ""
Title.TextColor3 = Color3.fromRGB(153, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 51, 51)
Title.Font = Enum.Font.Fondamento
Title.TextSize = 22
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = Title

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleButton.Text = "Ring Parts Off"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.Fondamento
ToggleButton.TextSize = 18
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local DecreaseRadius = Instance.new("TextButton")
DecreaseRadius.Size = UDim2.new(0.2, 0, 0, 35)
DecreaseRadius.Position = UDim2.new(0.1, 0, 0, 90)
DecreaseRadius.Text = "<"
DecreaseRadius.BackgroundColor3 = Color3.fromRGB(255, 153, 153)
DecreaseRadius.TextColor3 = Color3.fromRGB(255, 255, 255)
DecreaseRadius.Font = Enum.Font.Fondamento
DecreaseRadius.TextSize = 18
DecreaseRadius.Parent = MainFrame

local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 10)
DecreaseCorner.Parent = DecreaseRadius

local IncreaseRadius = Instance.new("TextButton")
IncreaseRadius.Size = UDim2.new(0.2, 0, 0, 35)
IncreaseRadius.Position = UDim2.new(0.7, 0, 0, 90)
IncreaseRadius.Text = ">"
IncreaseRadius.BackgroundColor3 = Color3.fromRGB(255, 153, 153)
IncreaseRadius.TextColor3 = Color3.fromRGB(255, 255, 255)
IncreaseRadius.Font = Enum.Font.Fondamento
IncreaseRadius.TextSize = 18
IncreaseRadius.Parent = MainFrame

local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 10)
IncreaseCorner.Parent = IncreaseRadius

local RadiusDisplay = Instance.new("TextLabel")
RadiusDisplay.Size = UDim2.new(0.4, 0, 0, 35)
RadiusDisplay.Position = UDim2.new(0.3, 0, 0, 90)
RadiusDisplay.Text = "Radius: 50"
RadiusDisplay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RadiusDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusDisplay.Font = Enum.Font.Fondamento
RadiusDisplay.TextSize = 18
RadiusDisplay.Parent = MainFrame

local RadiusCorner = Instance.new("UICorner")
RadiusCorner.CornerRadius = UDim.new(0, 10)
RadiusCorner.Parent = RadiusDisplay

local DecreaseSpeed = Instance.new("TextButton")
DecreaseSpeed.Size = UDim2.new(0.2, 0, 0, 35)
DecreaseSpeed.Position = UDim2.new(0.1, 0, 0, 135)
DecreaseSpeed.Text = "<"
DecreaseSpeed.BackgroundColor3 = Color3.fromRGB(255, 153, 153)
DecreaseSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
DecreaseSpeed.Font = Enum.Font.Fondamento
DecreaseSpeed.TextSize = 18
DecreaseSpeed.Parent = MainFrame

local DecreaseSpeedCorner = Instance.new("UICorner")
DecreaseSpeedCorner.CornerRadius = UDim.new(0, 10)
DecreaseSpeedCorner.Parent = DecreaseSpeed

local IncreaseSpeed = Instance.new("TextButton")
IncreaseSpeed.Size = UDim2.new(0.2, 0, 0, 35)
IncreaseSpeed.Position = UDim2.new(0.7, 0, 0, 135)
IncreaseSpeed.Text = ">"
IncreaseSpeed.BackgroundColor3 = Color3.fromRGB(255, 153, 153)
IncreaseSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
IncreaseSpeed.Font = Enum.Font.Fondamento
IncreaseSpeed.TextSize = 18
IncreaseSpeed.Parent = MainFrame

local IncreaseSpeedCorner = Instance.new("UICorner")
IncreaseSpeedCorner.CornerRadius = UDim.new(0, 10)
IncreaseSpeedCorner.Parent = IncreaseSpeed

local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Size = UDim2.new(0.4, 0, 0, 35)
SpeedDisplay.Position = UDim2.new(0.3, 0, 0, 135)
SpeedDisplay.Text = "Speed: 1"
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDisplay.Font = Enum.Font.Fondamento
SpeedDisplay.TextSize = 18
SpeedDisplay.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 10)
SpeedCorner.Parent = SpeedDisplay

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 0, 20)
Watermark.Position = UDim2.new(0, 0, 1, -25)
Watermark.Text = ""
Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
Watermark.BackgroundTransparency = 1
Watermark.Font = Enum.Font.Fondamento
Watermark.TextSize = 14
Watermark.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.Fondamento
MinimizeButton.TextSize = 18
MinimizeButton.Parent = MainFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 15)
MinimizeCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 40), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "+"
        ToggleButton.Visible = false
        DecreaseRadius.Visible = false
        IncreaseRadius.Visible = false
        RadiusDisplay.Visible = false
        DecreaseSpeed.Visible = false
        IncreaseSpeed.Visible = false
        SpeedDisplay.Visible = false
        Watermark.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 240), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "-"
        ToggleButton.Visible = true
        DecreaseRadius.Visible = true
        IncreaseRadius.Visible = true
        RadiusDisplay.Visible = true
        DecreaseSpeed.Visible = true
        IncreaseSpeed.Visible = true
        SpeedDisplay.Visible = true
        Watermark.Visible = true
    end
end)

-- Drag
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

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
        update(input)
    end
end)

-- Tornado logic
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

workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

-- Block sitting + slight float while tornado is active
local FLOAT_OFFSET = 0.3
local originalHipHeight = nil
local currentHumanoid = nil

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
        applyFloat(humanoid)
    end
    humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if ringPartsEnabled and humanoid.Sit then
            humanoid.Sit = false
            humanoid.SeatPart = nil
        end
    end)
end

if LocalPlayer.Character then
    hookHumanoid(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    originalHipHeight = nil
    hookHumanoid(char)
end)

RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end

    cleanupFloor()
    local floorPart = getFloorPart()
    if floorPart then
        markFloor(floorPart)
        markFloor(getExclusionRoot(floorPart))
    end

    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local tornadoCenter = humanoidRootPart.Position
        local grabRange = radius * 2
        for _, part in pairs(parts) do
            if part.Parent and not part.Anchored and not isFloorExcluded(part) then
                local pos = part.Position
                local horizontalDist = (Vector3.new(pos.X, tornadoCenter.Y, pos.Z) - tornadoCenter).Magnitude
                local verticalDist = math.abs(pos.Y - tornadoCenter.Y)

                if horizontalDist > grabRange or verticalDist > height * 2 then
                    if noclippedParts[part] ~= nil then
                        part.CanCollide = noclippedParts[part]
                        noclippedParts[part] = nil
                    end
                else
                    if noclippedParts[part] == nil then
                        applyNoclip(part)
                    end
                    local angle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
                    local newAngle = angle + math.rad(rotationSpeed)
                    local verticalY = tornadoCenter.Y + (height * (math.abs(math.sin((pos.Y - tornadoCenter.Y) / height))))
                    local targetPos = Vector3.new(
                        tornadoCenter.X + math.cos(newAngle) * radius,
                        verticalY,
                        tornadoCenter.Z + math.sin(newAngle) * radius
                    )

                    if horizontalDist > radius * 1.5 then
                        part.CFrame = CFrame.new(targetPos)
                        part.Velocity = Vector3.new(0, 0, 0)
                    end

                    local directionToTarget = (targetPos - part.Position)
                    local magnitude = directionToTarget.Magnitude
                    if magnitude > 0 then
                        local pullStrength = attractionStrength + magnitude * 20
                        part.Velocity = directionToTarget.Unit * pullStrength
                    end
                end
            end
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    ToggleButton.Text = ringPartsEnabled and "Ring Parts On" or "Ring Parts Off"
    ToggleButton.BackgroundColor3 = ringPartsEnabled and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(160, 82, 45)
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
    RadiusDisplay.Text = "Radius: " .. radius
end)

IncreaseRadius.MouseButton1Click:Connect(function()
    radius = math.min(1000, radius + 2)
    RadiusDisplay.Text = "Radius: " .. radius
end)

DecreaseSpeed.MouseButton1Click:Connect(function()
    rotationSpeed = math.max(0, rotationSpeed - 1)
    SpeedDisplay.Text = "Speed: " .. rotationSpeed
end)

IncreaseSpeed.MouseButton1Click:Connect(function()
    rotationSpeed = math.min(100, rotationSpeed + 1)
    SpeedDisplay.Text = "Speed: " .. rotationSpeed
end)
