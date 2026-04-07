local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local ESP_ON = true
local objs = {}
local kills = {}

local function colorDist(d)
if d <= 20 then return Color3.fromRGB(255,0,0)
elseif d <= 30 then local t=(d-20)/10 return Color3.fromRGB(255,math.floor(165*t),0)
elseif d <= 50 then local t=(d-30)/20 return Color3.fromRGB(math.floor(255*(1-t)),math.floor(165+90*t),0)
else return Color3.fromRGB(0,255,0) end
end

local function esAnim(c)
if not c then return false end
local h = c:FindFirstChild("Head")
local r = c:FindFirstChild("HumanoidRootPart")
if h and r then
if (h.Position.Y - r.Position.Y) + h.Size.Y > 7 then return true end
end
return false
end

local function getDist(c)
if not LP.Character then return nil end
local m = LP.Character:FindFirstChild("HumanoidRootPart")
if not m or not c then return nil end
local r = c:FindFirstChild("HumanoidRootPart")
if not r then return nil end
return math.floor((m.Position - r.Position).Magnitude)
end

local function getCerca(ch, pl)
local v = ch:FindFirstChild("HumanoidRootPart")
if not v then return nil end
local cl = nil
local md = 999999
for _, op in pairs(Players:GetPlayers()) do
if op ~= pl and op.Character then
local oh = op.Character:FindFirstChild("HumanoidRootPart")
if oh then
local d = (oh.Position - v.Position).Magnitude
if d < md then md = d cl = op.Name end
end
end
end
return cl
end

local function makeESP(pl)
if pl == LP then return end
local function go(ch)
if not ch then return end
local hr = ch:WaitForChild("HumanoidRootPart", 5)
if not hr then return end
if objs[pl] then
for _, o in pairs(objs[pl]) do pcall(function() o:Destroy() end) end
end
objs[pl] = {}
local hl = nil
pcall(function()
hl = Instance.new("Highlight")
hl.Adornee = ch
hl.FillColor = Color3.fromRGB(255,0,0)
hl.FillTransparency = 0.7
hl.OutlineColor = Color3.new(1,1,1)
hl.OutlineTransparency = 0.3
pcall(function() hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
hl.Parent = ch
end)
local bb = Instance.new("BillboardGui")
bb.Adornee = hr
bb.Size = UDim2.new(0,250,0,50)
bb.StudsOffset = Vector3.new(0,3,0)
bb.AlwaysOnTop = true
bb.Parent = ch
local nl = Instance.new("TextLabel")
nl.Size = UDim2.new(1,0,0.5,0)
nl.BackgroundTransparency = 1
nl.TextColor3 = Color3.fromRGB(255,0,0)
nl.TextStrokeTransparency = 0.5
nl.TextStrokeColor3 = Color3.new(0,0,0)
nl.Font = Enum.Font.Gotham
nl.TextSize = 13
nl.Text = pl.Name
nl.Parent = bb
local dl = Instance.new("TextLabel")
dl.Size = UDim2.new(1,0,0.5,0)
dl.Position = UDim2.new(0,0,0.5,0)
dl.BackgroundTransparency = 1
dl.TextColor3 = Color3.fromRGB(255,255,100)
dl.TextStrokeTransparency = 0.5
dl.TextStrokeColor3 = Color3.new(0,0,0)
dl.Font = Enum.Font.Gotham
dl.TextSize = 11
dl.Text = "0m"
dl.Parent = bb
if hl then objs[pl] = {hl, bb} else objs[pl] = {bb} end
local cn = nil
cn = RunService.RenderStepped:Connect(function()
if not ch or not ch.Parent then cn:Disconnect() return end
local d = getDist(ch)
if not d then return end
dl.Text = d .. "m"
local k = kills[pl.Name] or 0
if esAnim(ch) and hl then
hl.FillColor = Color3.fromRGB(180,0,255)
hl.FillTransparency = 0.3
hl.OutlineColor = Color3.fromRGB(255,0,0)
nl.TextColor3 = Color3.fromRGB(255,0,0)
if k > 0 then nl.Text = "[!] ANIMATRONICO " .. pl.Name .. " [" .. k .. " kills]"
else nl.Text = "[!] ANIMATRONICO " .. pl.Name end
else
local co = colorDist(d)
if hl then hl.FillColor = co hl.FillTransparency = 0.7 hl.OutlineColor = Color3.new(1,1,1) end
nl.TextColor3 = co
if k > 0 then nl.Text = pl.Name .. " [" .. k .. " kills]"
else nl.Text = pl.Name end
end
end)
end
if pl.Character then go(pl.Character) end
pl.CharacterAdded:Connect(function(c) wait(0.5) if ESP_ON then go(c) end end)
end

local function delESP(pl)
if objs[pl] then
for _, o in pairs(objs[pl]) do pcall(function() o:Destroy() end) end
objs[pl] = nil
end
end

local function trackDeath(pl)
local function onCh(ch)
if not ch then return end
local hum = ch:WaitForChild("Humanoid", 5)
if not hum then return end
hum.Died:Connect(function()
local c = getCerca(ch, pl)
if c then
kills[c] = (kills[c] or 0) + 1
print("[MUERTE] " .. pl.Name .. " murio cerca de " .. c)
end
end)
end
if pl.Character then onCh(pl.Character) end
pl.CharacterAdded:Connect(onCh)
end

local function myDeath()
local function onMe(ch)
if not ch then return end
local hum = ch:WaitForChild("Humanoid", 5)
if not hum then return end
hum.Died:Connect(function() kills = {} print("[ESP] Reset") end)
end
if LP.Character then onMe(LP.Character) end
LP.CharacterAdded:Connect(onMe)
end

-- ============ TELEPORT GUI ============
local UIS = game:GetService("UserInputService")
local tpGui = Instance.new("ScreenGui")
tpGui.Name = "ESP_TP"
tpGui.ResetOnSpawn = false
tpGui.Parent = LP:WaitForChild("PlayerGui")

local tpSuave = false
local tpSpeed = 100
local tpMoving = false
local tpConn = nil

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0,40,0,40)
tpBtn.Position = UDim2.new(0,10,0.5,-20)
tpBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
tpBtn.BackgroundTransparency = 0.3
tpBtn.TextColor3 = Color3.fromRGB(0,200,255)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 18
tpBtn.Text = "TP"
tpBtn.Parent = tpGui
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0,8)
tpCorner.Parent = tpBtn

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0,40,0,25)
modeBtn.Position = UDim2.new(0,10,0.5,25)
modeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
modeBtn.BackgroundTransparency = 0.3
modeBtn.TextColor3 = Color3.fromRGB(0,255,100)
modeBtn.Font = Enum.Font.Gotham
modeBtn.TextSize = 9
modeBtn.Text = "INST"
modeBtn.Parent = tpGui
local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0,6)
mCorner.Parent = modeBtn

modeBtn.MouseButton1Click:Connect(function()
tpSuave = not tpSuave
if tpSuave then
modeBtn.Text = "SUAVE"
modeBtn.TextColor3 = Color3.fromRGB(255,200,0)
else
if tpMoving and tpConn then tpConn:Disconnect() tpMoving = false end
modeBtn.Text = "INST"
modeBtn.TextColor3 = Color3.fromRGB(0,255,100)
end
end)

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(0,200,0,300)
listFrame.Position = UDim2.new(0,60,0.5,-150)
listFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
listFrame.BackgroundTransparency = 0.2
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.Visible = false
listFrame.Parent = tpGui
local lCorner = Instance.new("UICorner")
lCorner.CornerRadius = UDim.new(0,8)
lCorner.Parent = listFrame
local lLayout = Instance.new("UIListLayout")
lLayout.Padding = UDim.new(0,3)
lLayout.SortOrder = Enum.SortOrder.Name
lLayout.Parent = listFrame

local function refreshList()
for _, c in pairs(listFrame:GetChildren()) do
if c:IsA("TextButton") then c:Destroy() end
end
for _, p in pairs(Players:GetPlayers()) do
if p ~= LP then
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1,-6,0,40)
btn.Position = UDim2.new(0,3,0,0)
btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
btn.BackgroundTransparency = 0.3
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.Gotham
btn.TextSize = 12
btn.Text = p.Name
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.Parent = listFrame
local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0,6)
bc.Parent = btn
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0,30,0,30)
avatar.Position = UDim2.new(0,5,0.5,-15)
avatar.BackgroundTransparency = 1
avatar.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
avatar.Parent = btn
local avCorner = Instance.new("UICorner")
avCorner.CornerRadius = UDim.new(1,0)
avCorner.Parent = avatar
local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0,45)
pad.Parent = btn
btn.MouseButton1Click:Connect(function()
if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
local myHRP = LP.Character.HumanoidRootPart
if tpSuave then
if tpMoving and tpConn then tpConn:Disconnect() end
tpMoving = true
print("[TP] Yendo suave hacia " .. p.Name)
tpConn = RunService.RenderStepped:Connect(function(dt)
if not tpMoving then tpConn:Disconnect() return end
if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then tpConn:Disconnect() tpMoving = false return end
if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then tpConn:Disconnect() tpMoving = false return end
local target = p.Character.HumanoidRootPart.Position
local myPos = myHRP.Position
local dir3 = target - myPos
local dirFlat = Vector3.new(dir3.X, 0, dir3.Z)
if dirFlat.Magnitude < 8 then
tpConn:Disconnect()
tpMoving = false
print("[TP] Llegaste a " .. p.Name)
return
end
local move = dir3.Unit * tpSpeed * dt
myHRP.Velocity = Vector3.new(0, 0, 0)
local hum = LP.Character:FindFirstChildOfClass("Humanoid")
if hum then hum:Move(dirFlat.Unit) end
myHRP.CFrame = myHRP.CFrame + move
end)
else
myHRP.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
print("[TP] Teleportado a " .. p.Name)
end
end)
end
end
listFrame.CanvasSize = UDim2.new(0,0,0,lLayout.AbsoluteContentSize.Y + 10)
end

tpBtn.MouseButton1Click:Connect(function()
listFrame.Visible = not listFrame.Visible
if listFrame.Visible then refreshList() end
end)

Players.PlayerAdded:Connect(function()
if listFrame.Visible then refreshList() end
end)
Players.PlayerRemoving:Connect(function()
wait(0.5)
if listFrame.Visible then refreshList() end
end)

-- ============ INICIAR ============
for _, p in pairs(Players:GetPlayers()) do makeESP(p) trackDeath(p) end
Players.PlayerAdded:Connect(function(p) makeESP(p) trackDeath(p) end)
Players.PlayerRemoving:Connect(delESP)
myDeath()
print("[ESP] Activado parcero")
print("[TP] Boton TP a la izquierda")
