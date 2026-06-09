local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ── Load UILib ────────────────────────────────────────────────────────────────
local UI  = loadfile("UILib.lua")()
local win = UI.new("Zombie Tracker")

-- ── Load ESPLib ───────────────────────────────────────────────────────────────
local ESP = loadfile("ESPLib.lua")()

-- ── Shims ─────────────────────────────────────────────────────────────────────
local function notify(title, body)
    print(string.format("[Zombie Tracker] %s: %s", title, body or ""))
end
local function printl(...) print(...) end

-- ── Config ─────────────────────────────────────────────────────────────────────
local cfg = {
    NoCollide      = { Enabled = false },
    HitboxExpander = { Enabled = false, Size = 6, KeepVisible = false },
}

-- ── State ──────────────────────────────────────────────────────────────────────
local zombieData     = {}
local hitboxStore    = {}
local noCollideStore = {}

-- ── Helpers ────────────────────────────────────────────────────────────────────
local function getRootPart(model)
    if not model or not model:IsA("Model") then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    if model.PrimaryPart then return model.PrimaryPart end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

local function getHumanoid(model) return model:FindFirstChildWhichIsA("Humanoid") end

local function getHeadPart(model)
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") and child.Name:lower() == "head" then return child end
    end
    return nil
end

-- ── Hitbox ─────────────────────────────────────────────────────────────────────
local function applyHitbox(model)
    if not model or not model.Parent then return end
    local head = getHeadPart(model)
    if not head or not head.Parent or hitboxStore[head] then return end
    hitboxStore[head] = { size = head.Size, collide = head.CanCollide, transparency = head.Transparency }
    local s = cfg.HitboxExpander.Size
    head.Size = Vector3.new(s, s, s); head.CanCollide = false
    if not cfg.HitboxExpander.KeepVisible then head.Transparency = 1 end
end

function restoreAllHitboxes()
    for part, orig in pairs(hitboxStore) do
        if part and part.Parent then
            part.Size = orig.size; part.CanCollide = orig.collide; part.Transparency = orig.transparency
        end
    end
    hitboxStore = {}
end

local function cleanHitboxStore()
    for part in pairs(hitboxStore) do
        if not part or not part.Parent then hitboxStore[part] = nil end
    end
end

function applyAllHitboxes()
    for _, data in pairs(zombieData) do
        if data.model and data.model.Parent then applyHitbox(data.model) end
    end
end

-- ── No-collide ─────────────────────────────────────────────────────────────────
local function applyNoCollideToRoot(root)
    if not root or not root.Parent then return end
    if noCollideStore[root] and noCollideStore[root].Parent then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local c = Instance.new("NoCollisionConstraint")
    c.Part0 = hrp; c.Part1 = root; c.Parent = hrp
    noCollideStore[root] = c
end

function applyZombieNoCollide()
    for _, data in pairs(zombieData) do applyNoCollideToRoot(data.root) end
end

function restoreZombieCollide()
    for _, c in pairs(noCollideStore) do c:Destroy() end
    noCollideStore = {}
end

local function cleanNoCollideStore()
    for root, c in pairs(noCollideStore) do
        if not root or not root.Parent or not c or not c.Parent then
            if c and c.Parent then c:Destroy() end
            noCollideStore[root] = nil
        end
    end
end

-- ── Zombie tracking ─────────────────────────────────────────────────────────────
local function isZombieAlive(data)
    return data.model and data.model.Parent
        and data.root  and data.root.Parent
        and data.hum   and data.hum.Parent
        and data.hum.Health > 0
end

function scanZombies()
    local ignore       = workspace:FindFirstChild("Ignore")
    local zombieFolder = ignore and ignore:FindFirstChild("Zombies")
    cleanHitboxStore()
    if not zombieFolder then
        local dead = {}
        for key in pairs(zombieData) do dead[#dead + 1] = key end
        for _, key in ipairs(dead) do zombieData[key] = nil end
        return
    end
    local found = {}
    for _, zombie in ipairs(zombieFolder:GetChildren()) do
        if zombie and zombie:IsA("Model") then
            local root = getRootPart(zombie)
            if root then
                found[zombie] = true
                if not zombieData[zombie] then
                    zombieData[zombie] = {
                        model = zombie, root = root, sizeCache = nil,
                        hum = getHumanoid(zombie),
                    }
                    if cfg.HitboxExpander.Enabled then applyHitbox(zombie)        end
                    if cfg.NoCollide.Enabled      then applyNoCollideToRoot(root) end
                else
                    zombieData[zombie].root = root
                    if not zombieData[zombie].hum or not zombieData[zombie].hum.Parent then
                        zombieData[zombie].hum = getHumanoid(zombie)
                    end
                end
            end
        end
    end
    local dead = {}
    for key in pairs(zombieData) do
        if not found[key] or not key.Parent then dead[#dead + 1] = key end
    end
    for _, key in ipairs(dead) do zombieData[key] = nil end
end

-- ── ESP Registration ────────────────────────────────────────────────────────────
local zombieOpts = ESP:register("zombie", {
    scan = function()
        local out = {}
        for inst in pairs(zombieData) do out[#out + 1] = inst end
        return out
    end,
    filter = function(inst)
        local d = zombieData[inst]; return d ~= nil and isZombieAlive(d)
    end,
    getRoot = function(inst)
        local d = zombieData[inst]; return d and d.root
    end,
    getName = function(inst, dist)
        return string.format("%s [%dm]", inst.Name, math.floor(dist))
    end,
    getHealth = function(inst)
        local d = zombieData[inst]; if not d then return nil end
        local hum = d.hum; if not hum or not hum.Parent then return nil end
        return hum.Health, hum.MaxHealth
    end,
    getBoxSize = function(inst, root, dist)
        local d = zombieData[inst]
        if d and not d.sizeCache then d.sizeCache = root.Size end
        local sy = d and d.sizeCache and d.sizeCache.Y or 4
        local sx = d and d.sizeCache and d.sizeCache.X or 2
        local scale = math.clamp(1000 / math.max(dist, 1), 0.3, 8)
        return math.max(math.floor(sx * 5 * scale / 10), 10),
               math.max(math.floor(sy * 11 * scale / 10), 20)
    end,
    visible    = false,
    showBox    = false,
    showLine   = false,
    showName   = false,
    showHealth = false,
    boxColor   = Color3.new(0, 1, 0),
    lineColor  = Color3.new(1, 0.5, 0),
    textColor  = Color3.new(0, 1, 0),
})

local mbOpts = ESP:register("mysteryBox", {
    scan = function()
        local mc = workspace:FindFirstChild("_MapComponents")
        local mb = mc and mc:FindFirstChild("MysteryBox")
        if not mb or not mb:IsA("Model") then return {} end
        return { mb }
    end,
    getRoot = function(inst)
        return inst:FindFirstChild("PurchaseBox")
            or inst.PrimaryPart
            or inst:FindFirstChildWhichIsA("BasePart")
    end,
    getName = function(inst, dist)
        return string.format("Mystery Box [%dm]", math.floor(dist))
    end,
    getBoxSize = function(inst, root, dist)
        local scale = math.clamp(1000 / math.max(dist, 1), 0.3, 8)
        return math.max(math.floor(20 * scale / 10), 14),
               math.max(math.floor(30 * scale / 10), 20)
    end,
    visible  = false,
    showBox  = false,
    showLine = false,
    showName = false,
    boxColor  = Color3.new(1, 0, 1),
    lineColor = Color3.new(1, 1, 0),
    textColor = Color3.new(1, 0, 1),
})

local wallBuyOpts = ESP:register("wallBuy", {
    scan = function()
        local mc = workspace:FindFirstChild("_MapComponents")
        local f  = mc and mc:FindFirstChild("WallBuys")
        if not f then return {} end
        local out = {}
        for _, m in ipairs(f:GetChildren()) do if m:IsA("Model") then out[#out + 1] = m end end
        return out
    end,
    getName = function(inst, dist)
        return string.format("Wall Buy [%dm]", math.floor(dist))
    end,
    visible  = false,
    showBox  = true,
    showLine = true,
    showName = true,
    boxColor  = Color3.new(0, 0.7, 1),
    lineColor = Color3.new(0, 0.7, 1),
    textColor = Color3.new(0, 0.7, 1),
})

local perkOpts = ESP:register("perk", {
    scan = function()
        local mc = workspace:FindFirstChild("_MapComponents")
        local f  = mc and mc:FindFirstChild("Perks")
        if not f then return {} end
        local out = {}
        for _, m in ipairs(f:GetChildren()) do if m:IsA("Model") then out[#out + 1] = m end end
        return out
    end,
    getName = function(inst, dist)
        return string.format("Perk [%dm]", math.floor(dist))
    end,
    visible  = false,
    showBox  = true,
    showLine = true,
    showName = true,
    boxColor  = Color3.new(0.5, 0, 1),
    lineColor = Color3.new(0.5, 0, 1),
    textColor = Color3.new(0.5, 0, 1),
})

local totOpts = ESP:register("trickOrTreat", {
    scan = function()
        local mc = workspace:FindFirstChild("_MapComponents")
        local f  = mc and (mc:FindFirstChild("TrickOrTreat") or mc:FindFirstChild("TreatBags"))
        if not f then return {} end
        local out = {}
        for _, m in ipairs(f:GetChildren()) do
            if m:IsA("Model") or m:IsA("BasePart") then out[#out + 1] = m end
        end
        return out
    end,
    getName = function(inst, dist)
        return string.format("Trick Or Treat [%dm]", math.floor(dist))
    end,
    visible  = false,
    showBox  = true,
    showLine = true,
    showName = true,
    boxColor  = Color3.new(1, 0.5, 0),
    lineColor = Color3.new(1, 0.5, 0),
    textColor = Color3.new(1, 0.5, 0),
})

local pumpkinOpts = ESP:register("pumpkin", {
    scan = function()
        local mc = workspace:FindFirstChild("_MapComponents")
        local f  = mc and (mc:FindFirstChild("Pumpkins") or mc:FindFirstChild("Collectibles"))
        if not f then return {} end
        local out = {}
        for _, m in ipairs(f:GetChildren()) do
            if m:IsA("Model") or m:IsA("BasePart") then out[#out + 1] = m end
        end
        return out
    end,
    getName = function(inst, dist)
        return string.format("Pumpkin [%dm]", math.floor(dist))
    end,
    visible  = false,
    showBox  = true,
    showLine = true,
    showName = true,
    boxColor  = Color3.new(1, 0.4, 0),
    lineColor = Color3.new(1, 0.4, 0),
    textColor = Color3.new(1, 0.4, 0),
})

-- ── UILib UI ───────────────────────────────────────────────────────────────────
local tabEsp    = win:AddTab("ESP")
local tabCombat = win:AddTab("Combat")

-- ── Tab: ESP ───────────────────────────────────────────────────────────────────
tabEsp:AddToggle("Zombie ESP", zombieOpts.visible, function(s)
    zombieOpts.visible = s
    if s then task.spawn(scanZombies) end
end)
tabEsp:AddToggle("Zombie: Show Box", zombieOpts.showBox, function(s)
    zombieOpts.showBox = s
end, zombieOpts.boxColor, function(c) zombieOpts.boxColor = c end)
tabEsp:AddToggle("Zombie: Show Line", zombieOpts.showLine, function(s)
    zombieOpts.showLine = s
end, zombieOpts.lineColor, function(c) zombieOpts.lineColor = c end)
tabEsp:AddToggle("Zombie: Show Name", zombieOpts.showName, function(s)
    zombieOpts.showName = s
end, zombieOpts.textColor, function(c) zombieOpts.textColor = c end)
tabEsp:AddToggle("Zombie: Show Health", zombieOpts.showHealth, function(s)
    zombieOpts.showHealth = s
end)
tabEsp:AddToggle("Mystery Box ESP", mbOpts.visible, function(s)
    mbOpts.visible = s
end)
tabEsp:AddToggle("MB: Show Box", mbOpts.showBox, function(s)
    mbOpts.showBox = s
end, mbOpts.boxColor, function(c) mbOpts.boxColor = c end)
tabEsp:AddToggle("MB: Show Line", mbOpts.showLine, function(s)
    mbOpts.showLine = s
end, mbOpts.lineColor, function(c) mbOpts.lineColor = c end)
tabEsp:AddToggle("MB: Show Name", mbOpts.showName, function(s)
    mbOpts.showName = s
end, mbOpts.textColor, function(c) mbOpts.textColor = c end)
tabEsp:AddToggle("Wall Buy ESP", wallBuyOpts.visible, function(s)
    wallBuyOpts.visible = s
end, wallBuyOpts.boxColor, function(c)
    wallBuyOpts.boxColor = c; wallBuyOpts.lineColor = c; wallBuyOpts.textColor = c
end)
tabEsp:AddToggle("Perk ESP", perkOpts.visible, function(s)
    perkOpts.visible = s
end, perkOpts.boxColor, function(c)
    perkOpts.boxColor = c; perkOpts.lineColor = c; perkOpts.textColor = c
end)
tabEsp:AddToggle("Trick Or Treat ESP", totOpts.visible, function(s)
    totOpts.visible = s
end, totOpts.boxColor, function(c)
    totOpts.boxColor = c; totOpts.lineColor = c; totOpts.textColor = c
end)
tabEsp:AddToggle("Pumpkin ESP", pumpkinOpts.visible, function(s)
    pumpkinOpts.visible = s
end, pumpkinOpts.boxColor, function(c)
    pumpkinOpts.boxColor = c; pumpkinOpts.lineColor = c; pumpkinOpts.textColor = c
end)

-- ── Tab: Combat ────────────────────────────────────────────────────────────────
tabCombat:AddToggle("Hitbox Expander", cfg.HitboxExpander.Enabled, function(s)
    cfg.HitboxExpander.Enabled = s
    if s then applyAllHitboxes() else restoreAllHitboxes() end
end)
tabCombat:AddSlider("Head Size", 2, 15, cfg.HitboxExpander.Size, 1, "st", function(v)
    cfg.HitboxExpander.Size = v
    if cfg.HitboxExpander.Enabled then
        for part in pairs(hitboxStore) do
            if part and part.Parent then part.Size = Vector3.new(v, v, v) end
        end
    end
end)
tabCombat:AddToggle("Keep Heads Visible", cfg.HitboxExpander.KeepVisible, function(s)
    cfg.HitboxExpander.KeepVisible = s
    if cfg.HitboxExpander.Enabled then
        for part, orig in pairs(hitboxStore) do
            if part and part.Parent then part.Transparency = s and orig.transparency or 1 end
        end
    end
end)
tabCombat:AddToggle("No Zombie Collision", cfg.NoCollide.Enabled, function(s)
    cfg.NoCollide.Enabled = s
    if s then applyZombieNoCollide() else restoreZombieCollide() end
end)

-- ── Main loops ─────────────────────────────────────────────────────────────────
local _espFrame = 0
RunService.RenderStepped:Connect(function()
    if not isrbxactive() then return end
    _espFrame = _espFrame + 1
    if _espFrame < 2 then return end
    _espFrame = 0
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    ESP:updateAll(hrp.Position)
end)

task.spawn(function()
    while true do
        if isrbxactive() then
            scanZombies(); ESP:scanAll()
            cleanNoCollideStore()
            if cfg.NoCollide.Enabled then applyZombieNoCollide() end
        end
        task.wait(0.5)
    end
end)

printl("[Zombie Tracker] Loaded")
