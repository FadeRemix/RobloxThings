--[[
    UILib — 2018 HVH CS:GO Style
    Square, flat, no rounding. Pure utility.
--]]

local UILib = {}
UILib.__index = UILib

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ── Theme ─────────────────────────────────────────────────────────────────────
local T = {
    Bg          = Color3.fromRGB(10,  10,  14),
    BgPanel     = Color3.fromRGB(15,  15,  21),
    BgSection   = Color3.fromRGB(18,  18,  26),
    BgElement   = Color3.fromRGB(22,  22,  32),
    BgHover     = Color3.fromRGB(28,  28,  40),
    Border      = Color3.fromRGB(38,  38,  55),
    BorderLight = Color3.fromRGB(55,  55,  75),
    Accent      = Color3.fromRGB(130, 40,  220),
    AccentHover = Color3.fromRGB(155, 65,  245),
    AccentDark  = Color3.fromRGB(85,  15,  155),
    AccentFill  = Color3.fromRGB(100, 25,  185),
    Text        = Color3.fromRGB(210, 210, 225),
    TextDim     = Color3.fromRGB(115, 115, 140),
    TextDisabled= Color3.fromRGB(60,  60,  80),
    White       = Color3.fromRGB(255, 255, 255),
    CheckBg     = Color3.fromRGB(8,   8,   12),
}

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function new(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function tw(obj, props, t, style)
    TweenService:Create(obj, TweenInfo.new(t or 0.1, style or Enum.EasingStyle.Linear), props):Play()
end

local function mkStroke(color, thick, parent)
    return new("UIStroke", { Color = color or T.Border, Thickness = thick or 1, Parent = parent })
end

-- ── Window ────────────────────────────────────────────────────────────────────
function UILib.new(cfg)
    cfg = cfg or {}
    local self   = setmetatable({}, UILib)
    self._tabs   = {}
    self._active = nil
    self._open   = true

    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    self.gui = new("ScreenGui", {
        Name           = cfg.Name or "UILib",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = ok and cg or game:GetService("Players").LocalPlayer.PlayerGui,
    })

    -- Window
    self.win = new("Frame", {
        Size             = UDim2.new(0, cfg.Width or 600, 0, cfg.Height or 450),
        Position         = UDim2.new(0.5, -(cfg.Width or 600)/2, 0.5, -(cfg.Height or 450)/2),
        BackgroundColor3 = T.Bg,
        BorderSizePixel  = 0,
        Parent           = self.gui,
    })
    mkStroke(T.Border, 1, self.win)

    -- Title bar
    local bar = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = T.BgPanel,
        BorderSizePixel  = 0,
        Parent           = self.win,
    })
    mkStroke(T.Border, 1, bar)

    new("TextLabel", {
        Size              = UDim2.new(0, 160, 1, 0),
        Position          = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text              = (cfg.Title or "UILib"),
        TextColor3        = T.Text,
        Font              = Enum.Font.GothamBold,
        TextSize          = 12,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = bar,
    })

    if cfg.Subtitle then
        new("TextLabel", {
            Size              = UDim2.new(0, 160, 1, 0),
            Position          = UDim2.new(0, 90, 0, 0),
            BackgroundTransparency = 1,
            Text              = "| " .. cfg.Subtitle,
            TextColor3        = T.TextDim,
            Font              = Enum.Font.Gotham,
            TextSize          = 11,
            TextXAlignment    = Enum.TextXAlignment.Left,
            Parent            = bar,
        })
    end

    new("TextLabel", {
        Size              = UDim2.new(0, 200, 1, 0),
        Position          = UDim2.new(1, -240, 0, 0),
        BackgroundTransparency = 1,
        Text              = os.date("%B %d %Y") .. (cfg.Author and "  |  " .. cfg.Author or ""),
        TextColor3        = T.TextDim,
        Font              = Enum.Font.Gotham,
        TextSize          = 10,
        TextXAlignment    = Enum.TextXAlignment.Right,
        Parent            = bar,
    })

    -- Close
    local closeBtn = new("TextButton", {
        Size              = UDim2.new(0, 32, 1, 0),
        Position          = UDim2.new(1, -32, 0, 0),
        BackgroundTransparency = 1,
        Text              = "×",
        TextColor3        = T.TextDim,
        Font              = Enum.Font.GothamBold,
        TextSize          = 18,
        Parent            = bar,
    })
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(220,60,60) end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = T.TextDim end)
    closeBtn.MouseButton1Click:Connect(function()
        self._open = not self._open
        self.win.Visible = self._open
    end)

    -- Tab bar
    self._tabBar = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 26),
        Position         = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = T.BgPanel,
        BorderSizePixel  = 0,
        Parent           = self.win,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Parent        = self._tabBar,
    })

    -- Bottom border of tab bar
    new("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = self._tabBar,
    })

    -- Accent line under tab bar
    new("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 0, 62),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Parent           = self.win,
    })

    -- Content
    self._content = new("Frame", {
        Size             = UDim2.new(1, 0, 1, -64),
        Position         = UDim2.new(0, 0, 0, 64),
        BackgroundTransparency = 1,
        Parent           = self.win,
    })

    -- Drag
    local dragging = false
    local dm, dw
    bar.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = true; dm = i.Position; dw = self.win.Position
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = i.Position - dm
        self.win.Position = UDim2.new(dw.X.Scale, dw.X.Offset + d.X, dw.Y.Scale, dw.Y.Offset + d.Y)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    if cfg.ToggleKey then
        UserInputService.InputBegan:Connect(function(i, gpe)
            if not gpe and i.KeyCode == cfg.ToggleKey then
                self._open = not self._open; self.win.Visible = self._open
            end
        end)
    end

    return self
end

-- ── Tab ───────────────────────────────────────────────────────────────────────
function UILib:tab(name)
    local idx = #self._tabs + 1

    local btn = new("TextButton", {
        Size              = UDim2.new(0, math.max(55, #name * 7 + 16), 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel   = 0,
        Text              = name:lower(),
        TextColor3        = T.TextDim,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        LayoutOrder       = idx,
        Parent            = self._tabBar,
    })

    -- Active indicator (bottom line)
    local ind = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Visible          = false,
        Parent           = btn,
    })

    local frame = new("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible          = false,
        Parent           = self._content,
    })

    local function makeCol(xScale, xOffset, wScale, wOffset)
        local scroll = new("ScrollingFrame", {
            Size                  = UDim2.new(wScale, wOffset, 1, -8),
            Position              = UDim2.new(xScale, xOffset, 0, 4),
            BackgroundTransparency= 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 2,
            ScrollBarImageColor3  = T.Accent,
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            CanvasSize            = UDim2.new(0,0,0,0),
            Parent                = frame,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4), Parent = scroll })
        new("UIPadding",    { PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,3), PaddingBottom = UDim.new(0,5), Parent = scroll })
        return scroll
    end

    local left  = makeCol(0,   0,  0.5, -5)
    local right = makeCol(0.5, 2,  0.5, -5)

    local tab = { _frame=frame, _btn=btn, _ind=ind, _left=left, _right=right }
    table.insert(self._tabs, tab)
    if idx == 1 then self:_activate(tab) end

    btn.MouseButton1Click:Connect(function() self:_activate(tab) end)
    btn.MouseEnter:Connect(function() if self._active ~= tab then btn.TextColor3 = T.Text end end)
    btn.MouseLeave:Connect(function() if self._active ~= tab then btn.TextColor3 = T.TextDim end end)

    local api = {}
    function api:section(sName, side)
        return UILib._section((side == "right") and right or left, sName)
    end
    function api:leftSection(sName)  return UILib._section(left,  sName) end
    function api:rightSection(sName) return UILib._section(right, sName) end
    return api
end

function UILib:_activate(tab)
    for _, t in ipairs(self._tabs) do
        t._frame.Visible  = false
        t._ind.Visible    = false
        t._btn.TextColor3 = T.TextDim
        t._btn.Font       = Enum.Font.Gotham
    end
    tab._frame.Visible  = true
    tab._ind.Visible    = true
    tab._btn.TextColor3 = T.Text
    tab._btn.Font       = Enum.Font.GothamBold
    self._active = tab
end

-- ── Section ───────────────────────────────────────────────────────────────────
function UILib._section(parent, name)
    local sec = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.BgSection,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    mkStroke(T.Border, 1, sec)

    new("UIPadding", {
        PaddingLeft   = UDim.new(0,8),
        PaddingRight  = UDim.new(0,8),
        PaddingTop    = UDim.new(0, name and 0 or 6),
        PaddingBottom = UDim.new(0,7),
        Parent        = sec,
    })
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,3), Parent = sec })

    if name then
        local hdr = new("Frame", { Size = UDim2.new(1,0,0,22), BackgroundTransparency=1, LayoutOrder=0, Parent=sec })
        new("TextLabel", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text = name:lower(), TextColor3 = T.Accent,
            Font = Enum.Font.GothamBold, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = hdr,
        })
        new("Frame", {
            Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
            BackgroundColor3 = T.Border, BorderSizePixel=0, Parent = hdr,
        })
    end

    local api = {}
    local ord = 1
    local function O() ord+=1; return ord end

    -- ── Toggle ────────────────────────────────────────────────────────────
    function api:toggle(label, default, callback)
        local val = default == true
        local row = new("Frame", { Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, LayoutOrder=O(), Parent=sec })

        -- Square checkbox
        local box = new("Frame", {
            Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,0,0.5,-6),
            BackgroundColor3 = val and T.Accent or T.CheckBg, BorderSizePixel=0, Parent=row,
        })
        local boxStroke = mkStroke(val and T.Accent or T.Border, 1, box)

        local check = new("TextLabel", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text="✓", TextColor3=T.White, Font=Enum.Font.GothamBold, TextSize=9,
            Visible=val, Parent=box,
        })

        new("TextLabel", {
            Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,20,0,0),
            BackgroundTransparency=1, Text=label, TextColor3=T.Text,
            Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
        })

        local hit = new("TextButton", { Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=row })
        local obj = { value = val }

        local function refresh()
            box.BackgroundColor3 = obj.value and T.Accent or T.CheckBg
            boxStroke.Color      = obj.value and T.Accent or T.Border
            check.Visible        = obj.value
            if callback then task.spawn(callback, obj.value) end
        end

        hit.MouseButton1Click:Connect(function() obj.value = not obj.value; refresh() end)
        function obj:set(v) obj.value = v; refresh() end
        return obj
    end

    -- ── Slider ────────────────────────────────────────────────────────────
    function api:slider(label, min, max, default, step, callback)
        if type(step) == "function" then callback=step; step=1 end
        step = step or 1
        local val = math.clamp(default or min, min, max)

        local row = new("Frame", { Size=UDim2.new(1,0,0,38), BackgroundTransparency=1, LayoutOrder=O(), Parent=sec })

        -- Label row
        local top = new("Frame", { Size=UDim2.new(1,0,0,15), BackgroundTransparency=1, Parent=row })
        new("TextLabel", {
            Size=UDim2.new(0.7,0,1,0), BackgroundTransparency=1,
            Text=label, TextColor3=T.Text, Font=Enum.Font.Gotham, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=top,
        })
        local valLbl = new("TextLabel", {
            Size=UDim2.new(0.3,0,1,0), Position=UDim2.new(0.7,0,0,0),
            BackgroundTransparency=1, Text=tostring(val),
            TextColor3=T.Accent, Font=Enum.Font.GothamBold, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Right, Parent=top,
        })

        -- Track (full width, flat)
        local track = new("Frame", {
            Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,0,20),
            BackgroundColor3=T.BgElement, BorderSizePixel=0, Parent=row,
        })
        mkStroke(T.Border, 1, track)

        -- Fill (accent color from left to value)
        local pct0 = (val-min)/(max-min)
        local fill = new("Frame", {
            Size=UDim2.new(pct0,0,1,0),
            BackgroundColor3=T.Accent, BorderSizePixel=0, Parent=track,
        })

        -- Grip line at right edge of fill
        local grip = new("Frame", {
            Size=UDim2.new(0,2,1,4), Position=UDim2.new(pct0,-1,0,-2),
            BackgroundColor3=T.White, BorderSizePixel=0, Parent=track,
        })

        local obj = { value = val }
        local drag = false

        local function update(px)
            local p = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            obj.value = math.floor((min + (max-min)*p) / step + 0.5) * step
            local p2 = (obj.value-min)/(max-min)
            fill.Size = UDim2.new(p2, 0, 1, 0)
            grip.Position = UDim2.new(p2,-1,0,-2)
            valLbl.Text = tostring(obj.value)
            if callback then task.spawn(callback, obj.value) end
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=true; update(i.Position.X) end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
        end)

        function obj:set(v)
            local p = (math.clamp(v,min,max)-min)/(max-min)
            update(track.AbsolutePosition.X + p * track.AbsoluteSize.X)
        end
        return obj
    end

    -- ── Dropdown ──────────────────────────────────────────────────────────
    function api:dropdown(label, options, default, callback)
        local sel  = default or options[1]
        local open = false

        local wrapper = new("Frame", {
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, LayoutOrder=O(), Parent=sec,
        })
        new("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2), Parent=wrapper })

        if label and label ~= "" then
            new("TextLabel", {
                Size=UDim2.new(1,0,0,14), BackgroundTransparency=1,
                Text=label, TextColor3=T.TextDim, Font=Enum.Font.Gotham, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=wrapper,
            })
        end

        local btn = new("TextButton", {
            Size=UDim2.new(1,0,0,22), BackgroundColor3=T.BgElement,
            BorderSizePixel=0, Text="", Parent=wrapper,
        })
        mkStroke(T.Border,1,btn)

        local selLbl = new("TextLabel", {
            Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,7,0,0),
            BackgroundTransparency=1, Text=tostring(sel),
            TextColor3=T.Text, Font=Enum.Font.Gotham, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=btn,
        })
        new("TextLabel", {
            Size=UDim2.new(0,18,1,0), Position=UDim2.new(1,-20,0,0),
            BackgroundTransparency=1, Text="▾",
            TextColor3=T.TextDim, Font=Enum.Font.GothamBold, TextSize=10, Parent=btn,
        })

        local list = new("Frame", {
            Size=UDim2.new(1,0,0,0), BackgroundColor3=T.BgElement,
            BorderSizePixel=0, ClipsDescendants=true, Visible=false, ZIndex=20, Parent=wrapper,
        })
        mkStroke(T.Border,1,list)
        new("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder, Parent=list })

        local optH = 20
        local function buildOption(opt)
            local ob = new("TextButton", {
                Size=UDim2.new(1,0,0,optH), BackgroundTransparency=1,
                Text=tostring(opt), TextColor3=(opt==sel) and T.Accent or T.Text,
                Font=Enum.Font.Gotham, TextSize=12, ZIndex=21, Parent=list,
            })
            new("UIPadding",{PaddingLeft=UDim.new(0,7),Parent=ob})
            ob.TextXAlignment = Enum.TextXAlignment.Left
            ob.MouseEnter:Connect(function() ob.BackgroundColor3=T.BgHover; ob.BackgroundTransparency=0 end)
            ob.MouseLeave:Connect(function() ob.BackgroundTransparency=1 end)
            ob.MouseButton1Click:Connect(function()
                sel=opt; selLbl.Text=tostring(opt)
                open=false; tw(list,{Size=UDim2.new(1,0,0,0)},0.1)
                task.delay(0.1, function() list.Visible=false end)
                if callback then task.spawn(callback,opt) end
            end)
        end
        for _, o in ipairs(options) do buildOption(o) end

        btn.MouseButton1Click:Connect(function()
            open = not open; list.Visible=true
            tw(list,{Size=UDim2.new(1,0,0, open and #options*optH or 0)},0.12)
            if not open then task.delay(0.12, function() list.Visible=false end) end
        end)

        local obj = { value=sel }
        function obj:set(v) sel=v; selLbl.Text=tostring(v); obj.value=v; if callback then task.spawn(callback,v) end end
        return obj
    end

    -- ── Button ────────────────────────────────────────────────────────────
    function api:button(label, callback)
        local btn = new("TextButton", {
            Size=UDim2.new(1,0,0,22), BackgroundColor3=T.BgElement,
            BorderSizePixel=0, Text=label, TextColor3=T.Text,
            Font=Enum.Font.GothamBold, TextSize=12, LayoutOrder=O(), Parent=sec,
        })
        mkStroke(T.Border,1,btn)
        btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=T.Accent, TextColor3=T.White},0.08) end)
        btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=T.BgElement, TextColor3=T.Text},0.08) end)
        btn.MouseButton1Click:Connect(function()
            tw(btn,{BackgroundColor3=T.AccentDark},0.04)
            task.delay(0.1, function() tw(btn,{BackgroundColor3=T.Accent},0.08) end)
            if callback then task.spawn(callback) end
        end)
    end

    -- ── Keybind ───────────────────────────────────────────────────────────
    function api:keybind(label, default, callback)
        local key = default
        local listening = false
        local row = new("Frame", { Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, LayoutOrder=O(), Parent=sec })
        new("TextLabel", {
            Size=UDim2.new(0.58,0,1,0), BackgroundTransparency=1,
            Text=label, TextColor3=T.Text, Font=Enum.Font.Gotham, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
        })
        local kbtn = new("TextButton", {
            Size=UDim2.new(0.4,0,0.8,0), Position=UDim2.new(0.6,0,0.1,0),
            BackgroundColor3=T.BgElement, BorderSizePixel=0,
            Text=key and key.Name or "NONE",
            TextColor3=T.Accent, Font=Enum.Font.GothamBold, TextSize=10, Parent=row,
        })
        mkStroke(T.Border,1,kbtn)
        kbtn.MouseButton1Click:Connect(function()
            listening=true; kbtn.Text="..."; kbtn.TextColor3=T.TextDim
        end)
        UserInputService.InputBegan:Connect(function(i,gpe)
            if listening and i.UserInputType==Enum.UserInputType.Keyboard then
                if i.KeyCode==Enum.KeyCode.Escape then
                    key=nil; listening=false; kbtn.Text="NONE"; kbtn.TextColor3=T.TextDim
                else
                    key=i.KeyCode; listening=false; kbtn.Text=key.Name; kbtn.TextColor3=T.Accent
                end
            elseif not gpe and not listening and key and i.KeyCode==key then
                if callback then task.spawn(callback) end
            end
        end)
        local obj = { value=key }
        function obj:set(k) key=k; kbtn.Text=k and k.Name or "NONE"; obj.value=k end
        return obj
    end

    -- ── Label (refreshable) ───────────────────────────────────────────────
    function api:label(text, color)
        local lbl = new("TextLabel", {
            Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
            Text=tostring(text), TextColor3=color or T.TextDim,
            Font=Enum.Font.Gotham, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=O(), Parent=sec,
        })
        local obj = {}
        function obj:set(t)  lbl.Text = tostring(t) end
        function obj:color(c) lbl.TextColor3 = c end
        function obj:hide()  lbl.Visible = false end
        function obj:show()  lbl.Visible = true end
        return obj
    end

    -- ── Input ─────────────────────────────────────────────────────────────
    function api:input(label, placeholder, callback)
        local wrapper = new("Frame", {
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, LayoutOrder=O(), Parent=sec,
        })
        new("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2), Parent=wrapper })
        if label and label~="" then
            new("TextLabel", {
                Size=UDim2.new(1,0,0,14), BackgroundTransparency=1,
                Text=label, TextColor3=T.TextDim, Font=Enum.Font.Gotham, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=wrapper,
            })
        end
        local box = new("TextBox", {
            Size=UDim2.new(1,0,0,22), BackgroundColor3=T.BgElement, BorderSizePixel=0,
            Text="", PlaceholderText=placeholder or "",
            TextColor3=T.Text, PlaceholderColor3=T.TextDisabled,
            Font=Enum.Font.Gotham, TextSize=12,
            ClearTextOnFocus=false, Parent=wrapper,
        })
        mkStroke(T.Border,1,box)
        new("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7),Parent=box})
        box.Focused:Connect(function() box:FindFirstChildOfClass("UIStroke").Color = T.Accent end)
        box.FocusLost:Connect(function(enter)
            box:FindFirstChildOfClass("UIStroke").Color = T.Border
            if callback then task.spawn(callback, box.Text, enter) end
        end)
        local obj = {}
        function obj:get() return box.Text end
        function obj:set(v) box.Text = v end
        return obj
    end

    -- ── Separator ─────────────────────────────────────────────────────────
    function api:separator(color)
        new("Frame", {
            Size=UDim2.new(1,0,0,1), BackgroundColor3=color or T.Border,
            BorderSizePixel=0, LayoutOrder=O(), Parent=sec,
        })
    end

    -- ── ColorPicker ───────────────────────────────────────────────────────
    function api:colorpicker(label, default, callback)
        local col = default or Color3.fromRGB(130,40,220)
        local r,g,b = math.floor(col.R*255), math.floor(col.G*255), math.floor(col.B*255)
        local popOpen = false

        local row = new("Frame", { Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, LayoutOrder=O(), Parent=sec })
        new("TextLabel", {
            Size=UDim2.new(0.72,0,1,0), BackgroundTransparency=1,
            Text=label, TextColor3=T.Text, Font=Enum.Font.Gotham, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
        })
        local prev = new("TextButton", {
            Size=UDim2.new(0,44,0,14), Position=UDim2.new(1,-44,0.5,-7),
            BackgroundColor3=col, BorderSizePixel=0, Text="", Parent=row,
        })
        mkStroke(T.Border,1,prev)

        local popup = new("Frame", {
            Size=UDim2.new(1,0,0,0), BackgroundColor3=T.BgElement,
            BorderSizePixel=0, Visible=false, ZIndex=30,
            LayoutOrder=O(), Parent=sec,
        })
        mkStroke(T.Border,1,popup)
        new("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,6),Parent=popup})
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3),Parent=popup})

        local obj={value=col}
        local function upd() obj.value=Color3.fromRGB(r,g,b); prev.BackgroundColor3=obj.value; if callback then task.spawn(callback,obj.value) end end

        local function rgbRow(lbl,getF,setF)
            local f=new("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Parent=popup})
            new("TextLabel",{Size=UDim2.new(0,10,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.TextDim,Font=Enum.Font.GothamBold,TextSize=9,Parent=f})
            local tr=new("Frame",{Size=UDim2.new(1,-26,0,5),Position=UDim2.new(0,12,0.5,-2.5),BackgroundColor3=T.BgSection,BorderSizePixel=0,Parent=f})
            mkStroke(T.Border,1,tr)
            local fl=new("Frame",{Size=UDim2.new(getF()/255,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=tr})
            local vl=new("TextLabel",{Size=UDim2.new(0,12,1,0),Position=UDim2.new(1,-12,0,0),BackgroundTransparency=1,Text=tostring(getF()),TextColor3=T.TextDim,Font=Enum.Font.GothamBold,TextSize=8,Parent=f})
            local d=false
            local function pu(px) local p=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); setF(math.floor(p*255)); fl.Size=UDim2.new(p,0,1,0); vl.Text=tostring(getF()); upd() end
            tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=true;pu(i.Position.X) end end)
            UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType==Enum.UserInputType.MouseMovement then pu(i.Position.X) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end end)
        end

        rgbRow("R", function() return r end, function(v) r=v end)
        rgbRow("G", function() return g end, function(v) g=v end)
        rgbRow("B", function() return b end, function(v) b=v end)

        tw(popup,{Size=UDim2.new(1,0,0,0)},0)
        prev.MouseButton1Click:Connect(function()
            popOpen=not popOpen; popup.Visible=true
            tw(popup,{Size=UDim2.new(1,0,0,popOpen and 64 or 0)},0.12)
            if not popOpen then task.delay(0.12,function() popup.Visible=false end) end
        end)

        function obj:set(c) obj.value=c; prev.BackgroundColor3=c; r,g,b=math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255) end
        return obj
    end

    return api
end

-- ── Notify ────────────────────────────────────────────────────────────────────
function UILib:notify(cfg)
    cfg = cfg or {}
    local holder = self.gui:FindFirstChild("__Notify")
    if not holder then
        holder = new("Frame", {
            Name="__Notify", Size=UDim2.new(0,270,1,-16),
            Position=UDim2.new(1,-278,0,8), BackgroundTransparency=1, Parent=self.gui,
        })
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,5),Parent=holder})
    end

    local n = new("Frame", {
        Size=UDim2.new(1,0,0,56), BackgroundColor3=T.BgSection,
        BorderSizePixel=0, Position=UDim2.new(1,5,0,0), Parent=holder,
    })
    mkStroke(T.Border,1,n)

    new("Frame", { Size=UDim2.new(0,3,1,0), BackgroundColor3=cfg.Color or T.Accent, BorderSizePixel=0, Parent=n })
    new("TextLabel", {
        Size=UDim2.new(1,-14,0,20), Position=UDim2.new(0,10,0,7),
        BackgroundTransparency=1, Text=cfg.Title or "Notice",
        TextColor3=T.Text, Font=Enum.Font.GothamBold, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=n,
    })
    new("TextLabel", {
        Size=UDim2.new(1,-14,0,22), Position=UDim2.new(0,10,0,26),
        BackgroundTransparency=1, Text=cfg.Text or "",
        TextColor3=T.TextDim, Font=Enum.Font.Gotham, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=n,
    })
    local prog = new("Frame", {
        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=cfg.Color or T.Accent, BorderSizePixel=0, Parent=n,
    })

    local dur = cfg.Duration or 3
    tw(n,{Position=UDim2.new(0,0,0,0)},0.25)
    tw(prog,{Size=UDim2.new(0,0,0,2)},dur,Enum.EasingStyle.Linear)
    task.delay(dur,function()
        tw(n,{Position=UDim2.new(1,5,0,0)},0.25)
        task.delay(0.3,function() n:Destroy() end)
    end)
end

return UILib
