local UILib = loadstring(readfile("UILib.lua"))()

local plr  = game:GetService("Players").LocalPlayer
local re   = game:GetService("ReplicatedStorage").RemoteEvent
local RS   = game:GetService("RunService")
local cam  = workspace.CurrentCamera
local HIT_KEY    = "vb25rg20"
local FIRE_DELAY = 0.16

local aimOn = false
local espOn = false
local penOn = false

local box = Drawing.new("Square")
box.Thickness, box.Color, box.Filled, box.Visible = 2, Color3.fromRGB(100, 210, 80), false, false

local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude

local function getVisibleTarget()
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    losParams.FilterDescendantsInstances = {plr.Character}
    local best, bestHead, bestDist = nil, nil, math.huge
    for _, z in ipairs(workspace.Zombies:GetChildren()) do
        local hum, head = z:FindFirstChildOfClass("Humanoid"), z:FindFirstChild("Head")
        if hum and hum.Health > 0 and head then
            local dir = head.Position - cam.CFrame.Position
            local hit = workspace:Raycast(cam.CFrame.Position, dir, losParams)
            if hit and hit.Instance and hit.Instance:IsDescendantOf(z) then
                local d = (head.Position - root.Position).Magnitude
                if d < bestDist then bestDist, bestHead, best = d, head, z end
            end
        end
    end
    return best, bestHead
end

-- silent aim + wall penetration: both live in the RaycastModule hook
local ok, rayMod = pcall(require, game:GetService("ReplicatedStorage").ModuleScripts.RaycastModule)
assert(ok, "[Exploit] RaycastModule load failed: " .. tostring(rayMod))
local origRaycast = rayMod.Raycast
rayMod.Raycast = function(p1, p2, p3, p4, p5)
    if aimOn then
        local z, head = getVisibleTarget()
        if z and head then
            return { Position = head.Position, Instance = head, Normal = Vector3.new(0,1,0), Material = Enum.Material.SmoothPlastic, Distance = (head.Position - p1.Position).Magnitude }
        end
    end
    if penOn then
        local penParams = RaycastParams.new()
        penParams.FilterType = Enum.RaycastFilterType.Exclude
        local excluded = {}
        if p5 and p5.Character then table.insert(excluded, p5.Character) end
        for _ = 1, 20 do
            penParams.FilterDescendantsInstances = excluded
            local hit = workspace:Raycast(p1.Position, p2 * p3, penParams)
            if not hit then break end
            for _, z in ipairs(workspace.Zombies:GetChildren()) do
                local hum = z:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and hit.Instance:IsDescendantOf(z) then
                    return hit
                end
            end
            table.insert(excluded, hit.Instance)
        end
    end
    return origRaycast(p1, p2, p3, p4, p5)
end

RS.RenderStepped:Connect(function()
    if not espOn then box.Visible = false return end
    local z, head = getVisibleTarget()
    local hrp = z and z:FindFirstChild("HumanoidRootPart")
    if not hrp or not head then box.Visible = false return end
    local top, onScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
    local bot           = cam:WorldToViewportPoint(hrp.Position  - Vector3.new(0, 3, 0))
    if not onScreen or top.Z <= 0 then box.Visible = false return end
    local h = math.abs(bot.Y - top.Y)
    local w = h * 0.5
    box.Position, box.Size, box.Visible = Vector2.new(top.X - w/2, top.Y), Vector2.new(w, h), true
end)

local running = false
local function killAll()
    if running then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    running = true
    local n = 0
    for _, z in ipairs(workspace.Zombies:GetChildren()) do
        local hum = z:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            re:FireServer(HIT_KEY, root.Position, {{z.Name, "Head", CFrame.new()}}, tick())
            n += 1 ; task.wait(FIRE_DELAY)
        end
    end
    running = false
    print("[KillAll] " .. n .. " zombies")
end

-- ── Autofarm ──────────────────────────────────────────────────────────────────
local autofarmOn = false

-- hover: keep player pinned 5 studs above nearest living zombie every frame
RS.Heartbeat:Connect(function()
    if not autofarmOn then return end
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local nearest, nearestDist = nil, math.huge
    for _, z in ipairs(workspace.Zombies:GetChildren()) do
        local hum   = z:FindFirstChildOfClass("Humanoid")
        local zroot = z:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and zroot then
            local d = (zroot.Position - root.Position).Magnitude
            if d < nearestDist then nearestDist, nearest = d, zroot end
        end
    end

    if nearest then
        root.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 5, 0))
    end
end)

-- click loop: spam left click so the game's own knife logic handles hits
task.spawn(function()
    while true do
        if not autofarmOn then task.wait(0.2) continue end
        mouse1press()
        task.wait(0.05)
        mouse1release()
        task.wait(0.05)
    end
end)

-- ── Skin unlocker ─────────────────────────────────────────────────────────────
local skinMod = require(game:GetService("ReplicatedStorage").ModuleScripts.Skins)
local lastWeapon = nil

-- intercept the game's own "Update skins" calls to cache the weapon name
local oldNC
oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" then
        local args = {...}
        if args[1] == "Update skins" and args[2] then
            lastWeapon = args[2]
        end
    end
    return oldNC(self, ...)
end))

local function patchSkins()
    for _, data in pairs(skinMod.Stats) do
        data.Gold           = 0
        data.Prestige       = nil
        data.BattlepassSkin = nil
        data.USSF           = nil
        data.Level          = nil
    end
    for _, pack in ipairs(skinMod.GamepassPacks or {}) do
        pack.Active = true
        pack.Id     = nil
    end
    print("[Skins] All skins unlocked")
end

local function equipSkin(skinName)
    if not lastWeapon then print("[Skins] Open the skin tab once first") return end
    re:FireServer("Update skins", lastWeapon, {["Colour1"] = {["Skin"] = skinName}})
    print("[Skins] " .. skinName .. " -> " .. lastWeapon)
end

-- ── UI ────────────────────────────────────────────────────────────────────────
local win = UILib.new("ZOMBIE CHEAT")
win:AddToggle("Silent Aim",       false, function(v) aimOn        = v end)
win:AddToggle("ESP Box",          false, function(v) espOn        = v end)
win:AddToggle("Wall Penetration", false, function(v) penOn        = v end)
win:AddToggle("Autofarm",         false, function(v) autofarmOn   = v end)
win:AddButton("Kill All",    killAll)
win:AddButton("Patch Skins", patchSkins)
win:AddDropdown("Skin", {
    "Antimatter",
    "Blue Flame",
    "Christmas 21",
    "Bubblegum",
    "Dichotomy",
    "Skulls 2020",
    "Pumpkins 2020",
}, function(skin) equipSkin(skin) end)
