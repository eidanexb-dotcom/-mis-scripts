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

for _, p in pairs(Players:GetPlayers()) do makeESP(p) trackDeath(p) end
Players.PlayerAdded:Connect(function(p) makeESP(p) trackDeath(p) end)
Players.PlayerRemoving:Connect(delESP)
myDeath()
print("[ESP] Activado parcero")
