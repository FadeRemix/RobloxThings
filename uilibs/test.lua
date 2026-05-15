--[[
    UILib - Professional Exploit UI Library
    Inspired by modern cheat menu designs
    Usage: local UI = loadstring(game:HttpGet("..."))() or require()
--]]

local UILib = {}
UILib.__index = UILib

-- ── Services ─────────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

-- ── Theme ─────────────────────────────────────────────────────────────────────
local T = {
    Bg          = Color3.fromRGB(13, 13, 18),
    BgSecondary = Color3.fromRGB(19, 19, 27),
    BgTertiary  = Color3.fromRGB(25, 25, 36),
    Border      = Color3.fromRGB(40, 40, 58),
    Accent      = Color3.fromRGB(138, 43, 226),
    AccentLight = Color3.fromRGB(170, 80, 255),
    AccentDark  = Color3.fromRGB(100, 20, 180),
    Text        = Color3.fromRGB(210, 210, 225),
    TextDim     = Color3.fromRGB(120, 120, 145),
    TextDisabled= Color3.fromRGB(65,  65,  85),
    White       = Color3.fromRGB(255, 255, 255),
    Success     = Color3.fromRGB(50,  200, 100),
    Danger      = Color3.fromRGB(220, 60,  60),
}

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function new(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function tw(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(t or 0.12, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function corner(r, parent)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 4), Parent = parent })
end

local function stroke(color, thickness, parent)
    return new("UIStroke", { Color = color or T.Border, Thickness = thickness or 1, Parent = parent })
end

local function padding(v, parent)
    return new("UIPadding", {
        PaddingLeft   = UDim.new(0, v),
        PaddingRight  = UDim.new(0, v),
        PaddingTop    = UDim.new(0, v),
        PaddingBottom = UDim.new(0, v),
        Parent        = parent
    })
end

-- ── Window ────────────────────────────────────────────────────────────────────
function UILib.new(config)
    config = config or {}
    local self      = setmetatable({}, UILib)
    self._tabs      = {}
    self._active    = nil
    self._visible   = true

    -- Root GUI
    self.gui = new("ScreenGui", {
        Name            = config.Name or "UILib",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        Parent          = (pcall(function() return game:GetService("CoreGui") end)) and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui,
    })

    -- Shadow
    local shadow = new("ImageLabel", {
        Size                  = UDim2.new(1, 40, 1, 40),
        Position              = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency= 1,
        Image                 = "rbxassetid://6014261993",
        ImageColor3           = Color3.new(0,0,0),
        ImageTransparency     = 0.5,
        ScaleType             = Enum.ScaleType.Slice,
        SliceCenter           = Rect.new(49,49,450,450),
        ZIndex                = 0,
    })

    -- Main frame
    self.win = new("Frame", {
        Name              = "Window",
        Size              = UDim2.new(0, config.Width or 580, 0, config.Height or 440),
        Position          = UDim2.new(0.5, -(config.Width or 580)/2, 0.5, -(config.Height or 440)/2),
        BackgroundColor3  = T.Bg,
        BorderSizePixel   = 0,
        ClipsDescendants  = true,
        Parent            = self.gui,
    })
    corner(6, self.win)
    stroke(T.Border, 1, self.win)
    shadow.Parent = self.win

    -- ── Title bar ──────────────────────────────────────────────────────────
    local bar = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = T.BgSecondary,
        BorderSizePixel  = 0,
        Parent           = self.win,
    })
    -- bottom corners fix
    new("Frame", { Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0), BackgroundColor3 = T.BgSecondary, BorderSizePixel = 0, Parent = bar })
    corner(6, bar)

    new("TextLabel", {
        Size              = UDim2.new(0, 200, 1, 0),
        Position          = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text              = config.Title or "UILib",
        TextColor3        = T.Text,
        Font              = Enum.Font.GothamBold,
        TextSize          = 13,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = bar,
    })

    if config.Subtitle then
        new("TextLabel", {
            Size              = UDim2.new(0, 200, 1, 0),
            Position          = UDim2.new(0, 105, 0, 0),
            BackgroundTransparency = 1,
            Text              = "│  " .. config.Subtitle,
            TextColor3        = T.TextDim,
            Font              = Enum.Font.Gotham,
            TextSize          = 12,
            TextXAlignment    = Enum.TextXAlignment.Left,
            Parent            = bar,
        })
    end

    -- Date + build
    new("TextLabel", {
        Size              = UDim2.new(0, 220, 1, 0),
        Position          = UDim2.new(1, -228, 0, 0),
        BackgroundTransparency = 1,
        Text              = os.date("%b %d %Y") .. (config.Author and "  |  " .. config.Author or ""),
        TextColor3        = T.TextDim,
        Font              = Enum.Font.Gotham,
        TextSize          = 11,
        TextXAlignment    = Enum.TextXAlignment.Right,
        Parent            = bar,
    })

    -- Close button
    local closeBtn = new("TextButton", {
        Size              = UDim2.new(0, 28, 0, 28),
        Position          = UDim2.new(1, -34, 0.5, -14),
        BackgroundTransparency = 1,
        Text              = "✕",
        TextColor3        = T.TextDim,
        Font              = Enum.Font.GothamBold,
        TextSize          = 13,
        Parent            = bar,
    })
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = T.Danger end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = T.TextDim end)
    closeBtn.MouseButton1Click:Connect(function()
        self._visible = not self._visible
        self.win.Visible = self._visible
    end)

    -- ── Tab bar ────────────────────────────────────────────────────────────
    self._tabBar = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        Position         = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent           = self.win,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Parent        = self._tabBar,
    })

    -- Divider
    new("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 66),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = self.win,
    })

    -- Content
    self._content = new("Frame", {
        Size             = UDim2.new(1, 0, 1, -67),
        Position         = UDim2.new(0, 0, 0, 67),
        BackgroundTransparency = 1,
        Parent           = self.win,
    })

    -- ── Dragging ───────────────────────────────────────────────────────────
    local dragging, startMouse, startWin = false, nil, nil
    bar.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging  = true
        startMouse = i.Position
        startWin   = self.win.Position
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = i.Position - startMouse
        self.win.Position = UDim2.new(
            startWin.X.Scale, startWin.X.Offset + d.X,
            startWin.Y.Scale, startWin.Y.Offset + d.Y
        )
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Toggle key
    if config.ToggleKey then
        UserInputService.InputBegan:Connect(function(i, gpe)
            if not gpe and i.KeyCode == config.ToggleKey then
                self._visible = not self._visible
                self.win.Visible = self._visible
            end
        end)
    end

    return self
end

-- ── Tab ───────────────────────────────────────────────────────────────────────
function UILib:tab(name)
    local idx = #self._tabs + 1

    local btn = new("TextButton", {
        Size              = UDim2.new(0, math.max(60, #name * 7 + 20), 1, 0),
        BackgroundTransparency = 1,
        Text              = name,
        TextColor3        = T.TextDim,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        LayoutOrder       = idx,
        Parent            = self._tabBar,
    })

    local indicator = new("Frame", {
        Size             = UDim2.new(0.75, 0, 0, 2),
        Position         = UDim2.new(0.125, 0, 1, -2),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Visible          = false,
        Parent           = btn,
    })
    corner(2, indicator)

    local frame = new("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible          = false,
        Parent           = self._content,
    })

    -- Two columns
    local function makeCol(xPos)
        local scroll = new("ScrollingFrame", {
            Size                  = UDim2.new(0.5, -9, 1, -8),
            Position              = UDim2.new(xPos, xPos == 0 and 7 or 2, 0, 4),
            BackgroundTransparency= 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 2,
            ScrollBarImageColor3  = T.Accent,
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            Parent                = frame,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = scroll })
        new("UIPadding",    { PaddingBottom = UDim.new(0, 6), Parent = scroll })
        return scroll
    end

    local left  = makeCol(0)
    local right = makeCol(0.5)

    local tab = {
        _frame = frame, _btn = btn, _ind = indicator,
        _left = left, _right = right, _name = name
    }
    table.insert(self._tabs, tab)

    if idx == 1 then self:_activate(tab) end

    btn.MouseButton1Click:Connect(function() self:_activate(tab) end)
    btn.MouseEnter:Connect(function()
        if self._active ~= tab then btn.TextColor3 = T.Text end
    end)
    btn.MouseLeave:Connect(function()
        if self._active ~= tab then btn.TextColor3 = T.TextDim end
    end)

    -- Return section builder
    local tabAPI = {}
    function tabAPI:section(name, side)
        local col = (side == "right") and right or left
        return UILib._buildSection(col, name)
    end
    function tabAPI:leftSection(name)  return UILib._buildSection(left,  name) end
    function tabAPI:rightSection(name) return UILib._buildSection(right, name) end
    return tabAPI
end

function UILib:_activate(tab)
    for _, t in ipairs(self._tabs) do
        t._frame.Visible   = false
        t._ind.Visible     = false
        t._btn.TextColor3  = T.TextDim
        t._btn.Font        = Enum.Font.Gotham
    end
    tab._frame.Visible  = true
    tab._ind.Visible    = true
    tab._btn.TextColor3 = T.Text
    tab._btn.Font       = Enum.Font.GothamBold
    self._active = tab
end

-- ── Section ───────────────────────────────────────────────────────────────────
function UILib._buildSection(parent, name)
    local sec = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.BgSecondary,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    corner(4, sec)
    stroke(T.Border, 1, sec)
    new("UIPadding", {
        PaddingLeft   = UDim.new(0, 9),
        PaddingRight  = UDim.new(0, 9),
        PaddingTop    = UDim.new(0, name and 2 or 6),
        PaddingBottom = UDim.new(0, 8),
        Parent        = sec,
    })
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = sec })

    -- Header
    if name then
        local hdr = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 0, Parent = sec })
        new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = name:upper(), TextColor3 = T.Accent,
            Font = Enum.Font.GothamBold, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = hdr,
        })
        new("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = hdr,
        })
    end

    local api = {}
    local order = 1

    local function nextOrder() order += 1; return order end

    -- ── Toggle ────────────────────────────────────────────────────────────
    function api:toggle(label, default, callback)
        local val = default == true
        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = sec })

        local box = new("Frame", {
            Size = UDim2.new(0, 13, 0, 13), Position = UDim2.new(0, 0, 0.5, -6.5),
            BackgroundColor3 = val and T.Accent or T.BgTertiary, BorderSizePixel = 0, Parent = row,
        })
        corner(3, box)
        local boxStroke = stroke(val and T.Accent or T.Border, 1, box)

        local check = new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = "✓", TextColor3 = T.White,
            Font = Enum.Font.GothamBold, TextSize = 9,
            Visible = val, Parent = box,
        })

        new("TextLabel", {
            Size = UDim2.new(1, -21, 1, 0), Position = UDim2.new(0, 21, 0, 0),
            BackgroundTransparency = 1, Text = label,
            TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })

        local hit = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = row })
        local obj = { value = val }

        local function refresh()
            tw(box, { BackgroundColor3 = obj.value and T.Accent or T.BgTertiary }, 0.1)
            boxStroke.Color = obj.value and T.Accent or T.Border
            check.Visible   = obj.value
            if callback then task.spawn(callback, obj.value) end
        end

        hit.MouseButton1Click:Connect(function() obj.value = not obj.value; refresh() end)
        function obj:set(v) obj.value = v; refresh() end
        return obj
    end

    -- ── Slider ────────────────────────────────────────────────────────────
    function api:slider(label, min, max, default, step, callback)
        if type(step) == "function" then callback = step; step = 1 end
        step = step or 1
        local val = math.clamp(default or min, min, max)

        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = sec })

        local top = new("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Parent = row })
        new("TextLabel", {
            Size = UDim2.new(0.65, 0, 1, 0), BackgroundTransparency = 1,
            Text = label, TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = top,
        })
        local valLbl = new("TextLabel", {
            Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(0.65, 0, 0, 0),
            BackgroundTransparency = 1, Text = tostring(val),
            TextColor3 = T.Accent, Font = Enum.Font.GothamBold, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right, Parent = top,
        })

        local track = new("Frame", {
            Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 22),
            BackgroundColor3 = T.BgTertiary, BorderSizePixel = 0, Parent = row,
        })
        corner(2, track)

        local fill = new("Frame", {
            Size = UDim2.new((val - min)/(max - min), 0, 1, 0),
            BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = track,
        })
        corner(2, fill)

        local knob = new("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new((val - min)/(max - min), -5, 0.5, -5),
            BackgroundColor3 = T.White, BorderSizePixel = 0, Parent = track,
        })
        corner(5, knob)

        local obj = { value = val }
        local drag = false

        local function update(px)
            local pct = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local raw = min + (max - min) * pct
            obj.value = math.floor(raw / step + 0.5) * step
            local p2 = (obj.value - min) / (max - min)
            fill.Size = UDim2.new(p2, 0, 1, 0)
            knob.Position = UDim2.new(p2, -5, 0.5, -5)
            valLbl.Text = tostring(obj.value)
            if callback then task.spawn(callback, obj.value) end
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; update(i.Position.X) end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
        end)

        function obj:set(v) update(track.AbsolutePosition.X + ((v - min)/(max - min)) * track.AbsoluteSize.X) end
        return obj
    end

    -- ── Dropdown ──────────────────────────────────────────────────────────
    function api:dropdown(label, options, default, callback)
        local sel  = default or options[1]
        local open = false

        local wrapper = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = sec,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = wrapper })

        if label and label ~= "" then
            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1,
                Text = label, TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = wrapper,
            })
        end

        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = T.BgTertiary,
            BorderSizePixel = 0, Text = "", Parent = wrapper,
        })
        corner(4, btn)
        stroke(T.Border, 1, btn)

        local selLbl = new("TextLabel", {
            Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1, Text = tostring(sel),
            TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
        })
        local arrow = new("TextLabel", {
            Size = UDim2.new(0, 18, 1, 0), Position = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 1, Text = "▾",
            TextColor3 = T.TextDim, Font = Enum.Font.GothamBold, TextSize = 11, Parent = btn,
        })

        local listFrame = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = T.BgTertiary,
            BorderSizePixel = 0, ClipsDescendants = true, Visible = false,
            ZIndex = 20, Parent = wrapper,
        })
        corner(4, listFrame)
        stroke(T.Border, 1, listFrame)
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = listFrame })

        local optH = 20
        for _, opt in ipairs(options) do
            local ob = new("TextButton", {
                Size = UDim2.new(1, 0, 0, optH), BackgroundTransparency = 1,
                Text = tostring(opt), TextColor3 = (opt == sel) and T.Accent or T.Text,
                Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 21, Parent = listFrame,
            })
            new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = ob })
            ob.TextXAlignment = Enum.TextXAlignment.Left
            ob.MouseEnter:Connect(function() ob.BackgroundTransparency = 0.85; ob.BackgroundColor3 = T.Accent end)
            ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
            ob.MouseButton1Click:Connect(function()
                sel = opt; selLbl.Text = tostring(opt)
                open = false
                tw(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.12)
                tw(arrow, { Rotation = 0 }, 0.12)
                task.delay(0.12, function() listFrame.Visible = false end)
                if callback then task.spawn(callback, opt) end
            end)
        end

        btn.MouseButton1Click:Connect(function()
            open = not open
            listFrame.Visible = true
            tw(listFrame, { Size = UDim2.new(1, 0, 0, open and #options * optH or 0) }, 0.15)
            tw(arrow, { Rotation = open and 180 or 0 }, 0.15)
            if not open then task.delay(0.15, function() listFrame.Visible = false end) end
        end)

        local obj = { value = sel }
        function obj:set(v) sel = v; selLbl.Text = tostring(v); obj.value = v; if callback then task.spawn(callback, v) end end
        function obj:setOptions(opts)
            for _, c in ipairs(listFrame:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, opt in ipairs(opts) do
                local ob = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, optH), BackgroundTransparency = 1,
                    Text = tostring(opt), TextColor3 = T.Text,
                    Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 21, Parent = listFrame,
                })
                new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = ob })
                ob.TextXAlignment = Enum.TextXAlignment.Left
                ob.MouseButton1Click:Connect(function()
                    obj:set(opt); open = false
                    tw(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.12)
                    task.delay(0.12, function() listFrame.Visible = false end)
                end)
            end
        end
        return obj
    end

    -- ── Button ────────────────────────────────────────────────────────────
    function api:button(label, callback)
        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = T.BgTertiary,
            BorderSizePixel = 0, Text = label,
            TextColor3 = T.Text, Font = Enum.Font.GothamBold, TextSize = 12,
            LayoutOrder = nextOrder(), Parent = sec,
        })
        corner(4, btn)
        stroke(T.Border, 1, btn)

        btn.MouseEnter:Connect(function()
            tw(btn, { BackgroundColor3 = T.Accent, TextColor3 = T.White }, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, { BackgroundColor3 = T.BgTertiary, TextColor3 = T.Text }, 0.1)
        end)
        btn.MouseButton1Click:Connect(function()
            tw(btn, { BackgroundColor3 = T.AccentDark }, 0.05)
            task.delay(0.12, function() tw(btn, { BackgroundColor3 = T.Accent }, 0.1) end)
            if callback then task.spawn(callback) end
        end)
    end

    -- ── Keybind ───────────────────────────────────────────────────────────
    function api:keybind(label, default, callback)
        local key = default
        local listening = false

        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = sec })
        new("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1,
            Text = label, TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })

        local kbtn = new("TextButton", {
            Size = UDim2.new(0.38, 0, 0.85, 0), Position = UDim2.new(0.62, 0, 0.075, 0),
            BackgroundColor3 = T.BgTertiary, BorderSizePixel = 0,
            Text = key and key.Name or "NONE",
            TextColor3 = T.Accent, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row,
        })
        corner(3, kbtn); stroke(T.Border, 1, kbtn)

        kbtn.MouseButton1Click:Connect(function()
            listening = true; kbtn.Text = "..."; kbtn.TextColor3 = T.TextDim
        end)
        UserInputService.InputBegan:Connect(function(i, gpe)
            if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                key = i.KeyCode; listening = false
                kbtn.Text = key.Name; kbtn.TextColor3 = T.Accent
            elseif not gpe and not listening and key and i.KeyCode == key then
                if callback then task.spawn(callback) end
            end
        end)

        local obj = { value = key }
        function obj:set(k) key = k; kbtn.Text = k.Name; obj.value = k end
        return obj
    end

    -- ── Label ─────────────────────────────────────────────────────────────
    function api:label(text)
        local lbl = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = text, TextColor3 = T.TextDim, Font = Enum.Font.Gotham, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(), Parent = sec,
        })
        local obj = {}
        function obj:set(t) lbl.Text = t end
        function obj:setColor(c) lbl.TextColor3 = c end
        return obj
    end

    -- ── Input ─────────────────────────────────────────────────────────────
    function api:input(label, placeholder, callback)
        local wrapper = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = sec,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = wrapper })
        if label and label ~= "" then
            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1,
                Text = label, TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = wrapper,
            })
        end
        local box = new("TextBox", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = T.BgTertiary,
            BorderSizePixel = 0, Text = "",
            PlaceholderText = placeholder or "", TextColor3 = T.Text,
            PlaceholderColor3 = T.TextDim, Font = Enum.Font.Gotham, TextSize = 12,
            ClearTextOnFocus = false, Parent = wrapper,
        })
        corner(4, box); stroke(T.Border, 1, box)
        new("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), Parent = box })
        box.Focused:Connect(function() stroke(T.Accent, 1, box) end)
        box.FocusLost:Connect(function(enter)
            stroke(T.Border, 1, box)
            if callback then task.spawn(callback, box.Text, enter) end
        end)
        local obj = {}
        function obj:get() return box.Text end
        function obj:set(v) box.Text = v end
        return obj
    end

    -- ── ColorPicker ───────────────────────────────────────────────────────
    function api:colorpicker(label, default, callback)
        local color = default or Color3.fromRGB(138, 43, 226)

        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = sec })
        new("TextLabel", {
            Size = UDim2.new(0.75, 0, 1, 0), BackgroundTransparency = 1,
            Text = label, TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
        })
        local preview = new("TextButton", {
            Size = UDim2.new(0, 40, 0, 16), Position = UDim2.new(1, -40, 0.5, -8),
            BackgroundColor3 = color, BorderSizePixel = 0, Text = "", Parent = row,
        })
        corner(3, preview); stroke(T.Border, 1, preview)

        -- Simple popup with RGB sliders
        local popup = new("Frame", {
            Size = UDim2.new(1, 0, 0, 80), BackgroundColor3 = T.BgTertiary,
            BorderSizePixel = 0, Visible = false, ZIndex = 30,
            LayoutOrder = nextOrder(), Parent = sec,
        })
        corner(4, popup); stroke(T.Border, 1, popup)
        new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = popup })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = popup })

        local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
        local obj = { value = color }

        local function updateColor()
            obj.value = Color3.fromRGB(r, g, b)
            preview.BackgroundColor3 = obj.value
            if callback then task.spawn(callback, obj.value) end
        end

        local function addRGBSlider(lbl, getV, setV)
            local f = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = popup })
            new("TextLabel", { Size = UDim2.new(0, 10, 1, 0), BackgroundTransparency = 1, Text = lbl, TextColor3 = T.TextDim, Font = Enum.Font.GothamBold, TextSize = 10, Parent = f })
            local track = new("Frame", { Size = UDim2.new(1, -30, 0, 4), Position = UDim2.new(0, 14, 0.5, -2), BackgroundColor3 = T.Bg, BorderSizePixel = 0, Parent = f })
            corner(2, track)
            local fill = new("Frame", { Size = UDim2.new(getV()/255, 0, 1, 0), BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = track })
            corner(2, fill)
            local valL = new("TextLabel", { Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0), BackgroundTransparency = 1, Text = tostring(getV()), TextColor3 = T.TextDim, Font = Enum.Font.GothamBold, TextSize = 9, Parent = f })
            local drag2 = false
            local function upd(px)
                local pct = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                setV(math.floor(pct * 255))
                fill.Size = UDim2.new(pct, 0, 1, 0)
                valL.Text = tostring(getV())
                updateColor()
            end
            track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag2 = true; upd(i.Position.X) end end)
            UserInputService.InputChanged:Connect(function(i) if drag2 and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag2 = false end end)
        end

        addRGBSlider("R", function() return r end, function(v) r = v end)
        addRGBSlider("G", function() return g end, function(v) g = v end)
        addRGBSlider("B", function() return b end, function(v) b = v end)

        local popupOpen = false
        preview.MouseButton1Click:Connect(function()
            popupOpen = not popupOpen
            popup.Visible = popupOpen
        end)

        function obj:set(c)
            obj.value = c; preview.BackgroundColor3 = c
            r, g, b = math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)
            if callback then task.spawn(callback, c) end
        end
        return obj
    end

    -- ── Separator ─────────────────────────────────────────────────────────
    function api:separator()
        new("Frame", {
            Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Border,
            BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = sec,
        })
    end

    return api
end

-- ── Notify ────────────────────────────────────────────────────────────────────
function UILib:notify(config)
    config = config or {}
    local title   = config.Title   or "Notification"
    local text    = config.Text    or ""
    local duration= config.Duration or 3
    local color   = config.Color   or T.Accent

    local holder = self.gui:FindFirstChild("__NotifyHolder")
    if not holder then
        holder = new("Frame", {
            Name = "__NotifyHolder",
            Size = UDim2.new(0, 280, 1, -20),
            Position = UDim2.new(1, -290, 0, 10),
            BackgroundTransparency = 1,
            Parent = self.gui,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 6), Parent = holder })
    end

    local notif = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = T.BgSecondary,
        BorderSizePixel = 0, Parent = holder, Position = UDim2.new(1, 0, 0, 0),
    })
    corner(5, notif); stroke(T.Border, 1, notif)

    -- Accent bar
    new("Frame", {
        Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = color,
        BorderSizePixel = 0, Parent = notif,
    })
    corner(2, notif)

    new("TextLabel", {
        Size = UDim2.new(1, -14, 0, 22), Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = T.Text, Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = notif,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -14, 0, 24), Position = UDim2.new(0, 10, 0, 26),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.TextDim, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = notif,
    })

    -- Progress bar
    local prog = new("Frame", {
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = color, BorderSizePixel = 0, Parent = notif,
    })

    tw(notif, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)
    tw(prog, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        tw(notif, { Position = UDim2.new(1, 10, 0, 0) }, 0.3)
        task.delay(0.35, function() notif:Destroy() end)
    end)
end

return UILib
