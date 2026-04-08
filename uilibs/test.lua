-- UILibrary.lua
-- ModuleScript — place in ReplicatedStorage
-- local UI = require(game.ReplicatedStorage.UILibrary)

local UILibrary = {}
UILibrary.__index = UILibrary

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

---------------------------------------------------------
-- Built-in themes
---------------------------------------------------------
UILibrary.Themes = {
	CSGO = {
		Name        = "CSGO",
		Bg          = Color3.fromRGB(26,  26,  26),
		BgSecondary = Color3.fromRGB(33,  33,  33),
		BgTertiary  = Color3.fromRGB(44,  44,  44),
		Accent      = Color3.fromRGB(235, 130, 50),
		Border      = Color3.fromRGB(60,  60,  60),
		Text        = Color3.fromRGB(212, 212, 212),
		TextDim     = Color3.fromRGB(128, 128, 128),
		ToggleOn    = Color3.fromRGB(235, 130, 50),
		ToggleOff   = Color3.fromRGB(58,  58,  58),
		SliderFill  = Color3.fromRGB(235, 130, 50),
		DropBg      = Color3.fromRGB(20,  20,  20),
		TabActive   = Color3.fromRGB(44,  44,  44),
		TabInactive = Color3.fromRGB(33,  33,  33),
	},
	Purple = {
		Name        = "Purple",
		Bg          = Color3.fromRGB(13,  13,  19),
		BgSecondary = Color3.fromRGB(20,  20,  29),
		BgTertiary  = Color3.fromRGB(27,  27,  38),
		Accent      = Color3.fromRGB(108, 60,  210),
		Border      = Color3.fromRGB(42,  42,  58),
		Text        = Color3.fromRGB(225, 225, 230),
		TextDim     = Color3.fromRGB(130, 130, 145),
		ToggleOn    = Color3.fromRGB(108, 60,  210),
		ToggleOff   = Color3.fromRGB(42,  42,  58),
		SliderFill  = Color3.fromRGB(108, 60,  210),
		DropBg      = Color3.fromRGB(16,  16,  23),
		TabActive   = Color3.fromRGB(27,  27,  38),
		TabInactive = Color3.fromRGB(20,  20,  29),
	},
	Dark = {
		Name        = "Dark",
		Bg          = Color3.fromRGB(15,  15,  15),
		BgSecondary = Color3.fromRGB(22,  22,  22),
		BgTertiary  = Color3.fromRGB(32,  32,  32),
		Accent      = Color3.fromRGB(190, 190, 190),
		Border      = Color3.fromRGB(48,  48,  48),
		Text        = Color3.fromRGB(220, 220, 220),
		TextDim     = Color3.fromRGB(110, 110, 110),
		ToggleOn    = Color3.fromRGB(190, 190, 190),
		ToggleOff   = Color3.fromRGB(48,  48,  48),
		SliderFill  = Color3.fromRGB(190, 190, 190),
		DropBg      = Color3.fromRGB(12,  12,  12),
		TabActive   = Color3.fromRGB(32,  32,  32),
		TabInactive = Color3.fromRGB(22,  22,  22),
	},
	Green = {
		Name        = "Green",
		Bg          = Color3.fromRGB(14,  20,  14),
		BgSecondary = Color3.fromRGB(20,  28,  20),
		BgTertiary  = Color3.fromRGB(26,  36,  26),
		Accent      = Color3.fromRGB(80,  200, 90),
		Border      = Color3.fromRGB(38,  58,  38),
		Text        = Color3.fromRGB(205, 230, 205),
		TextDim     = Color3.fromRGB(115, 150, 115),
		ToggleOn    = Color3.fromRGB(80,  200, 90),
		ToggleOff   = Color3.fromRGB(38,  58,  38),
		SliderFill  = Color3.fromRGB(80,  200, 90),
		DropBg      = Color3.fromRGB(10,  15,  10),
		TabActive   = Color3.fromRGB(26,  36,  26),
		TabInactive = Color3.fromRGB(20,  28,  20),
	},
	Red = {
		Name        = "Red",
		Bg          = Color3.fromRGB(20,  14,  14),
		BgSecondary = Color3.fromRGB(28,  20,  20),
		BgTertiary  = Color3.fromRGB(36,  26,  26),
		Accent      = Color3.fromRGB(210, 50,  50),
		Border      = Color3.fromRGB(58,  38,  38),
		Text        = Color3.fromRGB(230, 210, 210),
		TextDim     = Color3.fromRGB(150, 115, 115),
		ToggleOn    = Color3.fromRGB(210, 50,  50),
		ToggleOff   = Color3.fromRGB(58,  38,  38),
		SliderFill  = Color3.fromRGB(210, 50,  50),
		DropBg      = Color3.fromRGB(15,  10,  10),
		TabActive   = Color3.fromRGB(36,  26,  26),
		TabInactive = Color3.fromRGB(28,  20,  20),
	},
}

---------------------------------------------------------
-- Helpers
---------------------------------------------------------
local function New(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	for _, c in pairs(children or {}) do
		c.Parent = obj
	end
	return obj
end

local function Tween(obj, goal, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

local function Stroke(col, thickness)
	return New("UIStroke", { Color = col, Thickness = thickness or 1 })
end

local function Pad(top, right, bottom, left)
	return New("UIPadding", {
		PaddingTop    = UDim.new(0, top    or 0),
		PaddingRight  = UDim.new(0, right  or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft   = UDim.new(0, left   or 0),
	})
end

local function VList(spacing)
	return New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder     = Enum.SortOrder.LayoutOrder,
		Padding       = UDim.new(0, spacing or 0),
	})
end

local function HList(spacing)
	return New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder     = Enum.SortOrder.LayoutOrder,
		Padding       = UDim.new(0, spacing or 0),
	})
end

local function MakeDraggable(frame, handle)
	local drag, start, origin = false
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true; start = i.Position; origin = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - start
			frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)
end

-- Returns a print-based default callback labelled with the control name
local function DefaultCB(name)
	return function(v)
		print(("[UI] %s → %s"):format(name or "control", tostring(v)))
	end
end

---------------------------------------------------------
-- CreateWindow
---------------------------------------------------------
function UILibrary:CreateWindow(cfg)
	cfg = cfg or {}

	-- Resolve theme
	local T
	if type(cfg.Theme) == "string" then
		T = UILibrary.Themes[cfg.Theme] or UILibrary.Themes.CSGO
	elseif type(cfg.Theme) == "table" then
		T = cfg.Theme
	else
		T = UILibrary.Themes.CSGO
	end

	local title = cfg.Title    or "Menu"
	local winW  = cfg.Width    or 520
	local winH  = cfg.Height   or 560
	local pos   = cfg.Position or UDim2.new(0.5, -winW/2, 0.5, -winH/2)

	-- ScreenGui
	local gui = New("ScreenGui", {
		Name           = "UILib",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = true,
	})
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not ok then
		gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Root
	local root = New("Frame", {
		Name             = "Root",
		Size             = UDim2.new(0, winW, 0, winH),
		Position         = pos,
		BackgroundColor3 = T.Bg,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		Parent           = gui,
	}, { Stroke(T.Border) })

	-- ── Title bar ──────────────────────────────────────
	local titleBar = New("Frame", {
		Name             = "TitleBar",
		Size             = UDim2.new(1, 0, 0, 34),
		Position         = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = T.BgSecondary,
		BorderSizePixel  = 0,
		ZIndex           = 10,
		Parent           = root,
	})

	New("TextLabel", {
		Text                  = title,
		Size                  = UDim2.new(1, -70, 1, 0),
		Position              = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		TextColor3            = T.Text,
		TextXAlignment        = Enum.TextXAlignment.Left,
		Font                  = Enum.Font.GothamBold,
		TextSize              = 13,
		ZIndex                = 11,
		Parent                = titleBar,
	})

	-- Title buttons
	local function MakeTitleBtn(icon, xOff)
		local b = New("TextButton", {
			Text                  = icon,
			Size                  = UDim2.new(0, 28, 0, 28),
			Position              = UDim2.new(1, xOff, 0.5, -14),
			BackgroundTransparency = 1,
			TextColor3            = T.TextDim,
			Font                  = Enum.Font.GothamBold,
			TextSize              = 16,
			ZIndex                = 12,
			Parent                = titleBar,
		})
		b.MouseEnter:Connect(function() b.TextColor3 = T.Text end)
		b.MouseLeave:Connect(function() b.TextColor3 = T.TextDim end)
		return b
	end

	local closeBtn = MakeTitleBtn("×", -4)
	local minBtn   = MakeTitleBtn("–", -32)

	local minimised = false
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
	minBtn.MouseButton1Click:Connect(function()
		minimised = not minimised
		if minimised then
			Tween(root, { Size = UDim2.new(0, winW, 0, 34) }, 0.18)
		else
			Tween(root, { Size = UDim2.new(0, winW, 0, winH) }, 0.18)
		end
	end)

	if cfg.MinimizeKey then
		UserInputService.InputBegan:Connect(function(i, gp)
			if not gp and i.KeyCode == cfg.MinimizeKey then
				minBtn.MouseButton1Click:Fire()
			end
		end)
	end

	MakeDraggable(root, titleBar)

	-- Accent line beneath title bar
	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 2),
		Position         = UDim2.new(0, 0, 0, 34),
		BackgroundColor3 = T.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 10,
		Parent           = root,
	})

	-- ── Tab bar ────────────────────────────────────────
	local tabBar = New("Frame", {
		Name             = "TabBar",
		Size             = UDim2.new(1, 0, 0, 32),
		Position         = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = T.BgSecondary,
		BorderSizePixel  = 0,
		ZIndex           = 10,
		Parent           = root,
	}, { HList(0) })

	-- Thin separator under tab bar
	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 0, 68),
		BackgroundColor3 = T.Border,
		BorderSizePixel  = 0,
		ZIndex           = 10,
		Parent           = root,
	})

	-- ── Content area ───────────────────────────────────
	-- Starts at y=69 (34 titlebar + 2 accent + 32 tabbar + 1 sep)
	local CONTENT_TOP = 69
	local content = New("Frame", {
		Name             = "Content",
		Size             = UDim2.new(1, 0, 1, -CONTENT_TOP),
		Position         = UDim2.new(0, 0, 0, CONTENT_TOP),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ZIndex           = 2,
		Parent           = root,
	})

	---------------------------------------------------------
	-- Window object
	---------------------------------------------------------
	local Win = { _tabs = {}, _gui = gui, _root = root, _T = T }

	function Win:SelectTab(tab)
		for _, t in ipairs(self._tabs) do
			t._page.Visible      = false
			t._indicator.Visible = false
			t._btn.TextColor3       = T.TextDim
			t._btn.BackgroundColor3 = T.TabInactive
		end
		tab._page.Visible      = true
		tab._indicator.Visible = true
		tab._btn.TextColor3       = T.Text
		tab._btn.BackgroundColor3 = T.TabActive
	end

	local function rebalanceTabs()
		local n = #Win._tabs
		for _, t in ipairs(Win._tabs) do
			t._btn.Size = UDim2.new(1 / n, 0, 1, 0)
		end
	end

	function Win:AddTab(name)
		local btn = New("TextButton", {
			Name             = name,
			Text             = name,
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = T.TabInactive,
			BorderSizePixel  = 0,
			TextColor3       = T.TextDim,
			Font             = Enum.Font.Gotham,
			TextSize         = 12,
			LayoutOrder      = #self._tabs,
			ZIndex           = 11,
			Parent           = tabBar,
		})

		-- Bottom indicator
		local indicator = New("Frame", {
			Size             = UDim2.new(1, 0, 0, 2),
			Position         = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = T.Accent,
			BorderSizePixel  = 0,
			Visible          = false,
			ZIndex           = 12,
			Parent           = btn,
		})

		-- Page (scrolling)
		local page = New("ScrollingFrame", {
			Size                 = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel      = 0,
			ScrollBarThickness   = 3,
			ScrollBarImageColor3 = T.Accent,
			CanvasSize           = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize  = Enum.AutomaticSize.Y,
			Visible              = false,
			ZIndex               = 3,
			Parent               = content,
		}, {
			Pad(8, 8, 8, 8),
			VList(6),
		})

		local Tab = { _btn = btn, _indicator = indicator, _page = page, _sections = {} }
		table.insert(self._tabs, Tab)
		rebalanceTabs()

		btn.MouseButton1Click:Connect(function() self:SelectTab(Tab) end)
		if #self._tabs == 1 then self:SelectTab(Tab) end

		------------------------------------------------------
		-- Tab:AddSection
		------------------------------------------------------
		function Tab:AddSection(sName)
			sName = sName or ""

			local sec = New("Frame", {
				Name             = sName ~= "" and sName or "Section",
				Size             = UDim2.new(1, 0, 0, 0),
				AutomaticSize    = Enum.AutomaticSize.Y,
				BackgroundColor3 = T.BgSecondary,
				BorderSizePixel  = 0,
				LayoutOrder      = #self._sections + 1,
				ZIndex           = 3,
				Parent           = page,
			}, {
				Stroke(T.Border),
				Pad(6, 8, 8, 8),
				VList(4),
			})

			if sName ~= "" then
				local hdr = New("Frame", {
					Size                  = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					LayoutOrder           = 0,
					ZIndex                = 4,
					Parent                = sec,
				})
				New("TextLabel", {
					Text                  = sName,
					Size                  = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3            = T.Accent,
					TextXAlignment        = Enum.TextXAlignment.Left,
					Font                  = Enum.Font.GothamBold,
					TextSize              = 11,
					ZIndex                = 5,
					Parent                = hdr,
				})
			end

			local Sec = { _frame = sec, _order = 0 }
			table.insert(self._sections, Sec)

			local function nxt(s)
				s._order = s._order + 1
				return s._order
			end

			-- Shared row + label
			local function MakeRow(s, h)
				return New("Frame", {
					Size                  = UDim2.new(1, 0, 0, h or 24),
					BackgroundTransparency = 1,
					LayoutOrder           = nxt(s),
					ZIndex                = 4,
					Parent                = s._frame,
				})
			end

			local function MakeLabel(parent, text)
				New("TextLabel", {
					Text                  = text,
					Size                  = UDim2.new(0.55, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3            = T.Text,
					TextXAlignment        = Enum.TextXAlignment.Left,
					Font                  = Enum.Font.Gotham,
					TextSize              = 12,
					ZIndex                = 5,
					Parent                = parent,
				})
			end

			-- Shared horizontal slider (used by Slider + ColorPicker)
			local function MakeSlider(parent, zBase, initPct, onChanged)
				local track = New("Frame", {
					Size             = UDim2.new(1, 0, 0, 5),
					BackgroundColor3 = T.BgTertiary,
					BorderSizePixel  = 0,
					ZIndex           = zBase,
					Parent           = parent,
				}, { Stroke(T.Border) })

				local fill = New("Frame", {
					Size             = UDim2.new(initPct, 0, 1, 0),
					BackgroundColor3 = T.SliderFill,
					BorderSizePixel  = 0,
					ZIndex           = zBase + 1,
					Parent           = track,
				})

				local knob = New("Frame", {
					Size             = UDim2.new(0, 9, 0, 9),
					Position         = UDim2.new(initPct, -4, 0.5, -4),
					BackgroundColor3 = T.Text,
					BorderSizePixel  = 0,
					ZIndex           = zBase + 2,
					Parent           = track,
				})

				local hitbox = New("TextButton", {
					Text = "", Size = UDim2.new(1, 0, 0, 22),
					Position = UDim2.new(0, 0, 0.5, -11),
					BackgroundTransparency = 1,
					ZIndex = zBase + 3,
					Parent = track,
				})

				local sliding = false
				local function update(x)
					local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					fill.Size     = UDim2.new(rel, 0, 1, 0)
					knob.Position = UDim2.new(rel, -4, 0.5, -4)
					onChanged(rel)
				end

				hitbox.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = true; update(i.Position.X)
					end
				end)
				UserInputService.InputChanged:Connect(function(i)
					if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
						update(i.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
				end)

				return fill, knob
			end

			----------------------------------------------------
			-- Toggle
			----------------------------------------------------
			function Sec:AddToggle(cfg)
				cfg = cfg or {}
				local val = cfg.Default  or false
				local cb  = cfg.Callback or DefaultCB(cfg.Name)
				local row = MakeRow(self)
				MakeLabel(row, cfg.Name or "Toggle")

				local bg = New("Frame", {
					Size             = UDim2.new(0, 34, 0, 16),
					Position         = UDim2.new(1, -34, 0.5, -8),
					BackgroundColor3 = val and T.ToggleOn or T.ToggleOff,
					BorderSizePixel  = 0,
					ZIndex           = 5,
					Parent           = row,
				}, { Stroke(T.Border) })

				local knob = New("Frame", {
					Size             = UDim2.new(0, 12, 0, 12),
					Position         = val and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
					BackgroundColor3 = T.Text,
					BorderSizePixel  = 0,
					ZIndex           = 6,
					Parent           = bg,
				})

				New("TextButton", {
					Text = "", Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1, ZIndex = 7, Parent = row,
				}).MouseButton1Click:Connect(function()
					val = not val
					Tween(bg,   { BackgroundColor3 = val and T.ToggleOn or T.ToggleOff })
					Tween(knob, { Position = val and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6) })
					cb(val)
				end)

				return {
					GetValue = function() return val end,
					SetValue = function(_, v)
						val = v
						Tween(bg,   { BackgroundColor3 = val and T.ToggleOn or T.ToggleOff })
						Tween(knob, { Position = val and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6) })
						cb(val)
					end,
				}
			end

			----------------------------------------------------
			-- Slider
			----------------------------------------------------
			function Sec:AddSlider(cfg)
				cfg = cfg or {}
				local mn  = cfg.Min      or 0
				local mx  = cfg.Max      or 100
				local dp  = cfg.Decimals or 0
				local suf = cfg.Suffix   or ""
				local val = math.clamp(cfg.Default or mn, mn, mx)
				local cb  = cfg.Callback or DefaultCB(cfg.Name)

				local wrap = New("Frame", {
					Size                  = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 1,
					LayoutOrder           = nxt(self),
					ZIndex                = 4,
					Parent                = self._frame,
				})

				-- name + value row
				local topRow = New("Frame", {
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1, ZIndex = 5, Parent = wrap,
				})
				New("TextLabel", {
					Text = cfg.Name or "Slider", Size = UDim2.new(0.65, 0, 1, 0),
					BackgroundTransparency = 1, TextColor3 = T.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 5, Parent = topRow,
				})
				local valLbl = New("TextLabel", {
					Text = tostring(val) .. suf,
					Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(0.65, 0, 0, 0),
					BackgroundTransparency = 1, TextColor3 = T.TextDim,
					TextXAlignment = Enum.TextXAlignment.Right,
					Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 5, Parent = topRow,
				})

				-- track container positioned below the label
				local trackWrap = New("Frame", {
					Size = UDim2.new(1, 0, 0, 14),
					Position = UDim2.new(0, 0, 0, 22),
					BackgroundTransparency = 1, ZIndex = 5, Parent = wrap,
				})

				local pct = (val - mn) / (mx - mn)
				MakeSlider(trackWrap, 6, pct, function(rel)
					local mult = 10 ^ dp
					val = math.floor((mn + (mx - mn) * rel) * mult + 0.5) / mult
					valLbl.Text = tostring(val) .. suf
					cb(val)
				end)

				return { GetValue = function() return val end }
			end

			----------------------------------------------------
			-- Dropdown
			----------------------------------------------------
			function Sec:AddDropdown(cfg)
				cfg = cfg or {}
				local opts = cfg.Options  or {}
				local val  = cfg.Default  or opts[1] or ""
				local cb   = cfg.Callback or DefaultCB(cfg.Name)
				local open = false

				local wrap = New("Frame", {
					Name = "DropWrap", Size = UDim2.new(1, 0, 0, 40),
					BackgroundTransparency = 1, ClipsDescendants = false,
					LayoutOrder = nxt(self), ZIndex = 4, Parent = self._frame,
				})

				New("TextLabel", {
					Text = cfg.Name or "Dropdown", Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1, TextColor3 = T.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 5, Parent = wrap,
				})

				local head = New("TextButton", {
					Text = "", Size = UDim2.new(1, 0, 0, 22),
					Position = UDim2.new(0, 0, 0, 18),
					BackgroundColor3 = T.BgTertiary, BorderSizePixel = 0,
					ZIndex = 5, Parent = wrap,
				}, { Stroke(T.Border) })

				local selLbl = New("TextLabel", {
					Text = val, Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 6, 0, 0),
					BackgroundTransparency = 1, TextColor3 = T.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 6, Parent = head,
				})
				local arrow = New("TextLabel", {
					Text = "▾", Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0),
					BackgroundTransparency = 1, TextColor3 = T.TextDim,
					Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 6, Parent = head,
				})

				local itemH = 22
				local list  = New("Frame", {
					Size = UDim2.new(1, 0, 0, #opts * itemH),
					Position = UDim2.new(0, 0, 0, 42),
					BackgroundColor3 = T.DropBg, BorderSizePixel = 0,
					Visible = false, ZIndex = 100, Parent = wrap,
				}, { Stroke(T.Border), VList(0) })

				local function buildOptions(optList)
					for _, c in pairs(list:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					list.Size = UDim2.new(1, 0, 0, #optList * itemH)
					for i, opt in ipairs(optList) do
						local ob = New("TextButton", {
							Text = opt, Size = UDim2.new(1, 0, 0, itemH),
							BackgroundTransparency = 1, BorderSizePixel = 0,
							TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
							Font = Enum.Font.Gotham, TextSize = 12,
							LayoutOrder = i, ZIndex = 101, Parent = list,
						}, { Pad(0, 0, 0, 8) })
						ob.MouseEnter:Connect(function()
							ob.BackgroundTransparency = 0
							ob.BackgroundColor3 = T.BgTertiary
							ob.TextColor3 = T.Text
						end)
						ob.MouseLeave:Connect(function()
							ob.BackgroundTransparency = 1
							ob.TextColor3 = T.TextDim
						end)
						ob.MouseButton1Click:Connect(function()
							val = opt; selLbl.Text = opt
							open = false; list.Visible = false
							wrap.Size = UDim2.new(1, 0, 0, 40)
							Tween(arrow, { Rotation = 0 })
							cb(opt)
						end)
					end
				end

				buildOptions(opts)

				head.MouseButton1Click:Connect(function()
					open = not open
					list.Visible = open
					wrap.Size = open and UDim2.new(1, 0, 0, 40 + #opts * itemH) or UDim2.new(1, 0, 0, 40)
					Tween(arrow, { Rotation = open and 180 or 0 })
				end)

				return {
					GetValue   = function() return val end,
					SetOptions = function(_, newOpts)
						opts = newOpts; buildOptions(opts)
					end,
				}
			end

			----------------------------------------------------
			-- ColorPicker  (RGB sliders)
			-- Popup is parented to ScreenGui to avoid all clipping
			----------------------------------------------------
			function Sec:AddColorPicker(cfg)
				cfg = cfg or {}
				local val = cfg.Default  or Color3.fromRGB(220, 55, 55)
				local cb  = cfg.Callback or DefaultCB(cfg.Name)

				local r = math.floor(val.R * 255)
				local g = math.floor(val.G * 255)
				local b = math.floor(val.B * 255)

				local row = MakeRow(self)
				MakeLabel(row, cfg.Name or "Color")

				local preview = New("TextButton", {
					Text = "", Size = UDim2.new(0, 22, 0, 14),
					Position = UDim2.new(1, -22, 0.5, -7),
					BackgroundColor3 = val, BorderSizePixel = 0,
					ZIndex = 5, Parent = row,
				}, { Stroke(T.Border) })

				local pickerOpen = false
				local picker

				local function rebuild()
					val = Color3.fromRGB(r, g, b)
					preview.BackgroundColor3 = val
					cb(val)
				end

				preview.MouseButton1Click:Connect(function()
					pickerOpen = not pickerOpen
					if picker then picker.Visible = pickerOpen; return end

					-- Position relative to screen
					local pAbs = preview.AbsolutePosition
					picker = New("Frame", {
						Size             = UDim2.new(0, 190, 0, 130),
						Position         = UDim2.new(0, pAbs.X - 168, 0, pAbs.Y + 18),
						BackgroundColor3 = T.BgSecondary,
						BorderSizePixel  = 0,
						ZIndex           = 500,
						Parent           = gui,  -- parented to ScreenGui directly
					}, { Stroke(T.Border), Pad(8, 8, 8, 8), VList(8) })

					local function MakeRGBRow(lbl, initVal, onChanged)
						local rw = New("Frame", {
							Size = UDim2.new(1, 0, 0, 26),
							BackgroundTransparency = 1, ZIndex = 501, Parent = picker,
						})
						New("TextLabel", {
							Text = lbl, Size = UDim2.new(0, 12, 0, 16),
							Position = UDim2.new(0, 0, 0, 0),
							BackgroundTransparency = 1, TextColor3 = T.TextDim,
							Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 502, Parent = rw,
						})
						local numLbl = New("TextLabel", {
							Text = tostring(initVal),
							Size = UDim2.new(0, 28, 0, 16), Position = UDim2.new(1, -28, 0, 0),
							BackgroundTransparency = 1, TextColor3 = T.TextDim,
							TextXAlignment = Enum.TextXAlignment.Right,
							Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 502, Parent = rw,
						})
						local trackWrap = New("Frame", {
							Size = UDim2.new(1, -44, 0, 16),
							Position = UDim2.new(0, 16, 0, 5),
							BackgroundTransparency = 1, ZIndex = 502, Parent = rw,
						})
						MakeSlider(trackWrap, 503, initVal / 255, function(rel)
							local newVal = math.floor(rel * 255 + 0.5)
							numLbl.Text = tostring(newVal)
							onChanged(newVal)
						end)
					end

					MakeRGBRow("R", r, function(v) r = v; rebuild() end)
					MakeRGBRow("G", g, function(v) g = v; rebuild() end)
					MakeRGBRow("B", b, function(v) b = v; rebuild() end)
				end)

				return {
					GetValue = function() return val end,
					SetValue = function(_, c)
						val = c
						r = math.floor(c.R * 255)
						g = math.floor(c.G * 255)
						b = math.floor(c.B * 255)
						preview.BackgroundColor3 = c
					end,
				}
			end

			----------------------------------------------------
			-- Button
			----------------------------------------------------
			function Sec:AddButton(cfg)
				cfg = cfg or {}
				local cb = cfg.Callback or DefaultCB(cfg.Name)
				local btn = New("TextButton", {
					Text = cfg.Name or "Button", Size = UDim2.new(1, 0, 0, 24),
					BackgroundColor3 = T.BgTertiary, BorderSizePixel = 0,
					TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 12,
					LayoutOrder = nxt(self), ZIndex = 5, Parent = self._frame,
				}, { Stroke(T.Border) })
				btn.MouseEnter:Connect(function()
					Tween(btn, { BackgroundColor3 = T.Accent, TextColor3 = T.Bg })
				end)
				btn.MouseLeave:Connect(function()
					Tween(btn, { BackgroundColor3 = T.BgTertiary, TextColor3 = T.Text })
				end)
				btn.MouseButton1Click:Connect(cb)
			end

			----------------------------------------------------
			-- Label
			----------------------------------------------------
			function Sec:AddLabel(cfg)
				cfg = cfg or {}
				local lbl = New("TextLabel", {
					Text = cfg.Text or "", Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1, TextColor3 = T.TextDim,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham, TextSize = 12,
					LayoutOrder = nxt(self), ZIndex = 5, Parent = self._frame,
				})
				return {
					SetText = function(_, t) lbl.Text = t end,
					GetText = function()    return lbl.Text end,
				}
			end

			----------------------------------------------------
			-- TextBox
			----------------------------------------------------
			function Sec:AddTextBox(cfg)
				cfg = cfg or {}
				local val = cfg.Default or ""
				local cb  = cfg.Callback or DefaultCB(cfg.Name)

				local wrap = New("Frame", {
					Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1,
					LayoutOrder = nxt(self), ZIndex = 4, Parent = self._frame,
				})
				New("TextLabel", {
					Text = cfg.Name or "Input", Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1, TextColor3 = T.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 5, Parent = wrap,
				})
				local box = New("TextBox", {
					Text = val, PlaceholderText = cfg.Placeholder or "...",
					Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 18),
					BackgroundColor3 = T.BgTertiary, BorderSizePixel = 0,
					TextColor3 = T.Text, PlaceholderColor3 = T.TextDim,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 5, Parent = wrap,
				}, { Stroke(T.Border), Pad(0, 6, 0, 6) })

				box.FocusLost:Connect(function() val = box.Text; cb(val) end)

				return {
					GetValue = function()    return val end,
					SetValue = function(_, t) val = t; box.Text = t end,
				}
			end

			----------------------------------------------------
			-- Separator
			----------------------------------------------------
			function Sec:AddSeparator()
				New("Frame", {
					Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Border,
					BorderSizePixel = 0, LayoutOrder = nxt(self), ZIndex = 5, Parent = self._frame,
				})
			end

			return Sec
		end -- AddSection

		return Tab
	end -- AddTab

	return Win
end -- CreateWindow

return UILibrary
