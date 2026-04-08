-- UILibrary.lua
-- ModuleScript — place in ReplicatedStorage

local UILibrary     = {}
UILibrary.__index   = UILibrary

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

----------------------------------------------------------------
-- Built-in themes
----------------------------------------------------------------
UILibrary.Themes = {
	CSGO = {
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

-- Create a new theme by extending an existing one
function UILibrary:CreateTheme(baseName, overrides)
	local base = UILibrary.Themes[baseName] or UILibrary.Themes.CSGO
	local theme = {}
	for k, v in pairs(base) do theme[k] = v end
	for k, v in pairs(overrides or {}) do theme[k] = v end
	return theme
end

-- Register a custom theme so it appears in dropdowns / SetTheme calls
function UILibrary:RegisterTheme(name, theme)
	UILibrary.Themes[name] = theme
end

----------------------------------------------------------------
-- Static helpers (no theme dependency)
----------------------------------------------------------------
local function _New(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do obj[k] = v end
	for _, c in pairs(children or {}) do if c then c.Parent = obj end end
	return obj
end

local function Pad(top, right, bottom, left)
	return _New("UIPadding", {
		PaddingTop    = UDim.new(0, top    or 0),
		PaddingRight  = UDim.new(0, right  or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft   = UDim.new(0, left   or 0),
	})
end
local function VList(s)
	return _New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder     = Enum.SortOrder.LayoutOrder,
		Padding       = UDim.new(0, s or 0),
	})
end
local function HList(s)
	return _New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder     = Enum.SortOrder.LayoutOrder,
		Padding       = UDim.new(0, s or 0),
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
			frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X,
			                           origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)
end
local function DefaultCB(name)
	return function(v)
		print(("[UI] %s → %s"):format(name or "?", tostring(v)))
	end
end

----------------------------------------------------------------
-- CreateWindow
----------------------------------------------------------------
function UILibrary:CreateWindow(cfg)
	cfg = cfg or {}

	local T
	if type(cfg.Theme) == "string" then
		T = UILibrary.Themes[cfg.Theme] or UILibrary.Themes.CSGO
	elseif type(cfg.Theme) == "table" then
		T = cfg.Theme
	else
		T = UILibrary.Themes.CSGO
	end

	local winW = cfg.Width    or 520
	local winH = cfg.Height   or 560
	local title = cfg.Title   or "Menu"
	local pos   = cfg.Position or UDim2.new(0.5, -winW/2, 0.5, -winH/2)

	--------------------------------------------------------------
	-- Theme registration system
	-- styled = { {inst, prop, themeKey}, ... }
	-- refresh = { fn, ... }  — called for stateful elements
	--------------------------------------------------------------
	local styled  = {}
	local refresh = {}

	local function Reg(inst, prop, key)
		styled[#styled+1] = {inst, prop, key}
		inst[prop] = T[key]
	end
	local function AddRefresh(fn) refresh[#refresh+1] = fn end

	-- New + auto-register shortcut
	local function New(class, props, regs, children)
		-- regs: { prop = themeKey, ... }  (optional)
		local obj = Instance.new(class)
		for k, v in pairs(props or {}) do obj[k] = v end
		for prop, key in pairs(regs or {}) do Reg(obj, prop, key) end
		for _, c in pairs(children or {}) do if c then c.Parent = obj end end
		return obj
	end

	local function Stroke(parent, key)
		key = key or "Border"
		local s = New("UIStroke", {Thickness=1}, {Color=key})
		s.Parent = parent
		return s
	end

	--------------------------------------------------------------
	-- ScreenGui
	--------------------------------------------------------------
	local gui = _New("ScreenGui", {
		Name           = "UILib",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = true,
	})
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not ok then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Root
	local root = New("Frame", {
		Name             = "Root",
		Size             = UDim2.new(0, winW, 0, winH),
		Position         = pos,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = 1,
		Parent           = gui,
	}, { BackgroundColor3 = "Bg" })
	Stroke(root, "Border")

	-- Title bar
	local titleBar = New("Frame", {
		Size            = UDim2.new(1,0,0,34),
		BorderSizePixel = 0,
		ZIndex          = 10,
		Parent          = root,
	}, { BackgroundColor3 = "BgSecondary" })

	New("TextLabel", {
		Text                  = title,
		Size                  = UDim2.new(1,-64,1,0),
		Position              = UDim2.new(0,10,0,0),
		BackgroundTransparency = 1,
		Font                  = Enum.Font.GothamBold,
		TextSize              = 13,
		TextXAlignment        = Enum.TextXAlignment.Left,
		ZIndex                = 11,
		Parent                = titleBar,
	}, { TextColor3 = "Text" })

	local function TitleBtn(icon, xOff)
		local b = New("TextButton", {
			Text                  = icon,
			Size                  = UDim2.new(0,28,0,28),
			Position              = UDim2.new(1,xOff,0.5,-14),
			BackgroundTransparency = 1,
			Font                  = Enum.Font.GothamBold,
			TextSize              = 16,
			ZIndex                = 12,
			Parent                = titleBar,
		}, { TextColor3 = "TextDim" })
		b.MouseEnter:Connect(function() b.TextColor3 = T.Text end)
		b.MouseLeave:Connect(function() b.TextColor3 = T.TextDim end)
		AddRefresh(function()
			b.TextColor3 = T.TextDim
		end)
		return b
	end

	local closeBtn = TitleBtn("×", -4)
	local minBtn   = TitleBtn("–", -32)

	local minimised = false
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
	minBtn.MouseButton1Click:Connect(function()
		minimised = not minimised
		local info = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(root, info, {
			Size = minimised
				and UDim2.new(0, winW, 0, 34)
				or  UDim2.new(0, winW, 0, winH)
		}):Play()
	end)
	if cfg.MinimizeKey then
		UserInputService.InputBegan:Connect(function(i, gp)
			if not gp and i.KeyCode == cfg.MinimizeKey then
				minBtn.MouseButton1Click:Fire()
			end
		end)
	end
	MakeDraggable(root, titleBar)

	-- Accent line
	New("Frame", {
		Size            = UDim2.new(1,0,0,2),
		Position        = UDim2.new(0,0,0,34),
		BorderSizePixel = 0,
		ZIndex          = 10,
		Parent          = root,
	}, { BackgroundColor3 = "Accent" })

	-- Tab bar
	local tabBar = New("Frame", {
		Size            = UDim2.new(1,0,0,32),
		Position        = UDim2.new(0,0,0,36),
		BorderSizePixel = 0,
		ZIndex          = 10,
		Parent          = root,
	}, { BackgroundColor3 = "BgSecondary" }, { HList(0) })

	New("Frame", {
		Size            = UDim2.new(1,0,0,1),
		Position        = UDim2.new(0,0,0,68),
		BorderSizePixel = 0,
		ZIndex          = 10,
		Parent          = root,
	}, { BackgroundColor3 = "Border" })

	local CONTENT_TOP = 69
	local content = _New("Frame", {
		Name                  = "Content",
		Size                  = UDim2.new(1,0,1,-CONTENT_TOP),
		Position              = UDim2.new(0,0,0,CONTENT_TOP),
		BackgroundTransparency = 1,
		BorderSizePixel       = 0,
		ZIndex                = 2,
		Parent                = root,
	})

	--------------------------------------------------------------
	-- Window object
	--------------------------------------------------------------
	local Win = { _tabs = {}, _gui = gui, _root = root }

	function Win:SetTheme(newT)
		if type(newT) == "string" then
			newT = UILibrary.Themes[newT] or UILibrary.Themes.CSGO
		end
		if not newT then return end
		T = newT
		for _, s in ipairs(styled) do
			pcall(function()
				if s[1] and s[1].Parent then
					s[1][s[2]] = T[s[3]]
				end
			end)
		end
		for _, fn in ipairs(refresh) do
			pcall(fn)
		end
	end

	function Win:SelectTab(tab)
		for _, t in ipairs(self._tabs) do
			t._page.Visible         = false
			t._ind.Visible          = false
			t._btn.BackgroundColor3 = T.TabInactive
			t._btnLbl.TextColor3    = T.TextDim
		end
		tab._page.Visible         = true
		tab._ind.Visible          = true
		tab._btn.BackgroundColor3 = T.TabActive
		tab._btnLbl.TextColor3    = T.Text
	end

	local function rebalance()
		local n = #Win._tabs
		for _, t in ipairs(Win._tabs) do
			t._btn.Size = UDim2.new(1/n, 0, 1, 0)
		end
	end

	function Win:AddTab(name)
		local btn = New("Frame", {  -- wrapper so we can stack text + indicator
			Size            = UDim2.new(1,0,1,0),
			BorderSizePixel = 0,
			LayoutOrder     = #self._tabs,
			ZIndex          = 11,
			Parent          = tabBar,
		}, { BackgroundColor3 = "TabInactive" })
		Reg(btn, "BackgroundColor3", "TabInactive")  -- default state

		local btnLbl = New("TextButton", {
			Text                  = name,
			Size                  = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Font                  = Enum.Font.Gotham,
			TextSize              = 12,
			ZIndex                = 12,
			Parent                = btn,
		}, { TextColor3 = "TextDim" })

		local ind = _New("Frame", {
			Size            = UDim2.new(1,0,0,2),
			Position        = UDim2.new(0,0,1,-2),
			BorderSizePixel = 0,
			Visible         = false,
			ZIndex          = 13,
			Parent          = btn,
		})
		Reg(ind, "BackgroundColor3", "Accent")

		local page = _New("ScrollingFrame", {
			Size                 = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			BorderSizePixel      = 0,
			ScrollBarThickness   = 3,
			CanvasSize           = UDim2.new(0,0,0,0),
			AutomaticCanvasSize  = Enum.AutomaticSize.Y,
			Visible              = false,
			ZIndex               = 3,
			Parent               = content,
		}, {Pad(8,8,8,8), VList(6)})
		Reg(page, "ScrollBarImageColor3", "Accent")

		local Tab = { _btn = btn, _btnLbl = btnLbl, _ind = ind, _page = page, _sections = {} }
		table.insert(self._tabs, Tab)
		rebalance()

		-- On theme change, re-apply correct active/inactive state
		AddRefresh(function()
			local isActive = Tab._page.Visible
			btn.BackgroundColor3    = isActive and T.TabActive   or T.TabInactive
			btnLbl.TextColor3       = isActive and T.Text        or T.TextDim
		end)

		btnLbl.MouseButton1Click:Connect(function() self:SelectTab(Tab) end)
		if #self._tabs == 1 then self:SelectTab(Tab) end

		----------------------------------------------------------
		-- Tab:AddSection
		----------------------------------------------------------
		function Tab:AddSection(sName)
			sName = sName or ""
			local sec = New("Frame", {
				Name            = sName ~= "" and sName or "Section",
				Size            = UDim2.new(1,0,0,0),
				AutomaticSize   = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				LayoutOrder     = #self._sections + 1,
				ZIndex          = 3,
				Parent          = page,
			}, { BackgroundColor3 = "BgSecondary" },
			{ Stroke(nil, "Border"), Pad(6,8,8,8), VList(4) })

			if sName ~= "" then
				local hdr = _New("Frame", {
					Size                  = UDim2.new(1,0,0,20),
					BackgroundTransparency = 1,
					LayoutOrder           = 0,
					ZIndex                = 4,
					Parent                = sec,
				})
				New("TextLabel", {
					Text                  = sName,
					Size                  = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					Font                  = Enum.Font.GothamBold,
					TextSize              = 11,
					TextXAlignment        = Enum.TextXAlignment.Left,
					ZIndex                = 5,
					Parent                = hdr,
				}, { TextColor3 = "Accent" })
			end

			local Sec = { _frame = sec, _order = 0 }
			table.insert(self._sections, Sec)

			local function nxt(s) s._order = s._order + 1; return s._order end

			local function MakeRow(s, h)
				return _New("Frame", {
					Size                  = UDim2.new(1,0,0,h or 24),
					BackgroundTransparency = 1,
					LayoutOrder           = nxt(s),
					ZIndex                = 4,
					Parent                = s._frame,
				})
			end

			local function RowLbl(parent, text)
				New("TextLabel", {
					Text                  = text,
					Size                  = UDim2.new(0.6,0,1,0),
					BackgroundTransparency = 1,
					Font                  = Enum.Font.Gotham,
					TextSize              = 12,
					TextXAlignment        = Enum.TextXAlignment.Left,
					ZIndex                = 5,
					Parent                = parent,
				}, { TextColor3 = "Text" })
			end

			-- Shared inline slider builder (used by Slider + ColorPicker)
			local function MakeInlineSlider(parent, zBase, initPct, fillColor, onChanged)
				local track = New("Frame", {
					Size            = UDim2.new(1,0,0,5),
					Position        = UDim2.new(0,0,0.5,-2),
					BorderSizePixel = 0,
					ZIndex          = zBase,
					Parent          = parent,
				}, { BackgroundColor3 = "BgTertiary" })
				Stroke(track, "Border")

				local fill = _New("Frame", {
					Size            = UDim2.new(initPct,0,1,0),
					BackgroundColor3 = fillColor or T.SliderFill,
					BorderSizePixel = 0,
					ZIndex          = zBase+1,
					Parent          = track,
				})
				if not fillColor then Reg(fill, "BackgroundColor3", "SliderFill") end

				local knob = New("Frame", {
					Size            = UDim2.new(0,9,0,9),
					Position        = UDim2.new(initPct,-4,0.5,-4),
					BorderSizePixel = 0,
					ZIndex          = zBase+2,
					Parent          = track,
				}, { BackgroundColor3 = "Text" })

				local hitbox = _New("TextButton", {
					Text                  = "",
					Size                  = UDim2.new(1,0,0,22),
					Position              = UDim2.new(0,0,0.5,-11),
					BackgroundTransparency = 1,
					ZIndex                = zBase+3,
					Parent                = track,
				})

				local sliding = false
				local function upd(x)
					local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					fill.Size     = UDim2.new(rel, 0, 1, 0)
					knob.Position = UDim2.new(rel, -4, 0.5, -4)
					onChanged(rel)
				end
				hitbox.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=true; upd(i.Position.X) end
				end)
				UserInputService.InputChanged:Connect(function(i)
					if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end
				end)
				UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=false end
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
				RowLbl(row, cfg.Name or "Toggle")

				local bg = New("Frame", {
					Size            = UDim2.new(0,34,0,16),
					Position        = UDim2.new(1,-34,0.5,-8),
					BorderSizePixel = 0,
					ZIndex          = 5,
					Parent          = row,
				}, { BackgroundColor3 = val and "ToggleOn" or "ToggleOff" })
				Stroke(bg, "Border")

				local knob = New("Frame", {
					Size            = UDim2.new(0,12,0,12),
					Position        = val and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6),
					BorderSizePixel = 0,
					ZIndex          = 6,
					Parent          = bg,
				}, { BackgroundColor3 = "Text" })

				AddRefresh(function()
					bg.BackgroundColor3   = val and T.ToggleOn or T.ToggleOff
					knob.BackgroundColor3 = T.Text
				end)

				_New("TextButton", {
					Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=7,Parent=row,
				}).MouseButton1Click:Connect(function()
					val = not val
					TweenService:Create(bg,   TweenInfo.new(0.12), { BackgroundColor3 = val and T.ToggleOn or T.ToggleOff }):Play()
					TweenService:Create(knob, TweenInfo.new(0.12), { Position = val and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6) }):Play()
					cb(val)
				end)
				return {
					GetValue = function() return val end,
					SetValue = function(_, v)
						val = v
						bg.BackgroundColor3   = val and T.ToggleOn or T.ToggleOff
						knob.Position         = val and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
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

				local wrap = _New("Frame", {
					Size                  = UDim2.new(1,0,0,38),
					BackgroundTransparency = 1,
					LayoutOrder           = nxt(self),
					ZIndex                = 4,
					Parent                = self._frame,
				})
				local top = _New("Frame", {Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,ZIndex=5,Parent=wrap})
				New("TextLabel", {
					Text=cfg.Name or "Slider",Size=UDim2.new(0.65,0,1,0),
					BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,
					TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=top,
				},{TextColor3="Text"})
				local valLbl = New("TextLabel", {
					Text=tostring(val)..suf,Size=UDim2.new(0.35,0,1,0),Position=UDim2.new(0.65,0,0,0),
					BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,
					TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5,Parent=top,
				},{TextColor3="TextDim"})

				local tw = _New("Frame", {Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,22),BackgroundTransparency=1,ZIndex=5,Parent=wrap})
				MakeInlineSlider(tw, 6, (val-mn)/(mx-mn), nil, function(rel)
					local mult = 10^dp
					val = math.floor((mn + (mx-mn)*rel)*mult + 0.5)/mult
					valLbl.Text = tostring(val)..suf
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

				local wrap = _New("Frame", {
					Name="DropWrap",Size=UDim2.new(1,0,0,40),
					BackgroundTransparency=1,ClipsDescendants=false,
					LayoutOrder=nxt(self),ZIndex=4,Parent=self._frame,
				})
				New("TextLabel", {
					Text=cfg.Name or "Dropdown",Size=UDim2.new(1,0,0,16),
					BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,
					TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=wrap,
				},{TextColor3="Text"})

				local head = New("Frame", {
					Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,18),
					BorderSizePixel=0,ZIndex=5,Parent=wrap,
				},{BackgroundColor3="BgTertiary"})
				Stroke(head, "Border")

				local selLbl = New("TextLabel", {
					Text=val,Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,6,0,0),
					BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,
					TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,Parent=head,
				},{TextColor3="Text"})
				local arrow = New("TextLabel", {
					Text="▾",Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-20,0,0),
					BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=13,ZIndex=6,Parent=head,
				},{TextColor3="TextDim"})

				local itemH = 22
				local list = New("Frame", {
					Size=UDim2.new(1,0,0,#opts*itemH),Position=UDim2.new(0,0,0,42),
					BorderSizePixel=0,Visible=false,ZIndex=100,Parent=wrap,
				},{BackgroundColor3="DropBg"},{Stroke(nil,"Border"),VList(0)})

				local function buildOpts(optList)
					for _, c in pairs(list:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					list.Size = UDim2.new(1,0,0,#optList*itemH)
					for i, opt in ipairs(optList) do
						local ob = New("TextButton", {
							Text=opt,Size=UDim2.new(1,0,0,itemH),BackgroundTransparency=1,
							BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=12,
							TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=i,ZIndex=101,Parent=list,
						},{TextColor3="TextDim"},{Pad(0,0,0,8)})
						ob.MouseEnter:Connect(function() ob.BackgroundTransparency=0; ob.BackgroundColor3=T.BgTertiary; ob.TextColor3=T.Text end)
						ob.MouseLeave:Connect(function() ob.BackgroundTransparency=1; ob.TextColor3=T.TextDim end)
						ob.MouseButton1Click:Connect(function()
							val=opt; selLbl.Text=opt; open=false; list.Visible=false
							wrap.Size=UDim2.new(1,0,0,40)
							TweenService:Create(arrow,TweenInfo.new(0.12),{Rotation=0}):Play()
							cb(opt)
						end)
					end
				end
				buildOpts(opts)

				_New("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Parent=head}).MouseButton1Click:Connect(function()
					open = not open
					list.Visible = open
					wrap.Size = open and UDim2.new(1,0,0,40+#opts*itemH) or UDim2.new(1,0,0,40)
					TweenService:Create(arrow,TweenInfo.new(0.12),{Rotation=open and 180 or 0}):Play()
				end)

				return {
					GetValue   = function() return val end,
					SetOptions = function(_, o) opts=o; buildOpts(o) end,
				}
			end

			----------------------------------------------------
			-- Keybind
			----------------------------------------------------
			function Sec:AddKeybind(cfg)
				cfg = cfg or {}
				local current   = cfg.Default    or Enum.KeyCode.Unknown
				local cb        = cfg.Callback   or DefaultCB(cfg.Name)  -- fires when key pressed in-game
				local changeCb  = cfg.OnChanged  or function() end        -- fires when binding changes
				local listening = false

				local row = MakeRow(self)
				RowLbl(row, cfg.Name or "Keybind")

				local keyBox = New("Frame", {
					Size=UDim2.new(0,80,0,18),Position=UDim2.new(1,-80,0.5,-9),
					BorderSizePixel=0,ZIndex=5,Parent=row,
				},{BackgroundColor3="BgTertiary"})
				Stroke(keyBox, "Border")

				local keyLbl = New("TextLabel", {
					Text = current == Enum.KeyCode.Unknown and "None" or current.Name,
					Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
					Font=Enum.Font.Gotham,TextSize=11,ZIndex=6,Parent=keyBox,
				},{TextColor3="Accent"})

				AddRefresh(function()
					keyLbl.TextColor3 = listening and T.TextDim or T.Accent
				end)

				_New("TextButton",{Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=7,Parent=keyBox}).MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					keyLbl.Text      = "..."
					keyLbl.TextColor3 = T.TextDim
				end)

				UserInputService.InputBegan:Connect(function(input, gp)
					if not listening then
						-- Fire callback when bound key is pressed during gameplay
						if not gp and input.UserInputType == Enum.UserInputType.Keyboard
							and input.KeyCode == current then
							cb(current)
						end
						return
					end
					-- Escape cancels
					if input.KeyCode == Enum.KeyCode.Escape then
						listening = false
						keyLbl.Text       = current == Enum.KeyCode.Unknown and "None" or current.Name
						keyLbl.TextColor3 = T.Accent
						return
					end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						listening = false
						current = input.KeyCode
						keyLbl.Text       = current.Name
						keyLbl.TextColor3 = T.Accent
						changeCb(current)
					end
				end)

				return {
					GetKey = function() return current end,
					SetKey = function(_, k)
						current = k
						keyLbl.Text = k == Enum.KeyCode.Unknown and "None" or k.Name
					end,
				}
			end

			----------------------------------------------------
			-- ColorPicker  (RGB — panel hangs off right side)
			----------------------------------------------------
			function Sec:AddColorPicker(cfg)
				cfg = cfg or {}
				local val = cfg.Default  or Color3.fromRGB(220,55,55)
				local cb  = cfg.Callback or DefaultCB(cfg.Name)
				local r,g,b = math.floor(val.R*255), math.floor(val.G*255), math.floor(val.B*255)

				local row = MakeRow(self)
				RowLbl(row, cfg.Name or "Color")

				local swatch = New("Frame", {
					Size=UDim2.new(0,22,0,14),Position=UDim2.new(1,-22,0.5,-7),
					BorderSizePixel=0,ZIndex=5,Parent=row,
				},{})
				swatch.BackgroundColor3 = val
				Stroke(swatch, "Border")

				local clickTarget = _New("TextButton", {
					Text="",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Parent=swatch,
				})

				local PICKER_W, PICKER_H = 210, 148
				local pickerOpen, picker, trackConn = false, nil, nil
				local previewBar, hexLbl

				local function toHex() return string.format("#%02X%02X%02X",r,g,b) end
				local function rebuild()
					val = Color3.fromRGB(r,g,b)
					swatch.BackgroundColor3 = val
					if previewBar then previewBar.BackgroundColor3 = val end
					if hexLbl      then hexLbl.Text = toHex() end
					cb(val)
				end

				local function snap()
					if not picker or not picker.Parent then return end
					local rAbs, rSz = root.AbsolutePosition, root.AbsoluteSize
					local py = math.clamp(row.AbsolutePosition.Y - 30, rAbs.Y, rAbs.Y + rSz.Y - PICKER_H)
					picker.Position = UDim2.new(0, rAbs.X + rSz.X + 6, 0, py)
				end

				clickTarget.MouseButton1Click:Connect(function()
					pickerOpen = not pickerOpen
					if picker then
						picker.Visible = pickerOpen
						if pickerOpen then
							snap()
							trackConn = trackConn or RunService.Heartbeat:Connect(snap)
						else
							if trackConn then trackConn:Disconnect(); trackConn=nil end
						end
						return
					end

					picker = New("Frame", {
						Size=UDim2.new(0,PICKER_W,0,PICKER_H),BackgroundTransparency=0,
						BorderSizePixel=0,ZIndex=500,Parent=gui,
					},{BackgroundColor3="BgSecondary"},{_New("UIStroke",{Color=Color3.new(0,0,0),Thickness=1})})

					previewBar = _New("Frame", {
						Size=UDim2.new(1,0,0,32),BackgroundColor3=val,BorderSizePixel=0,ZIndex=501,Parent=picker,
					})
					_New("UIStroke",{Color=Color3.new(0,0,0),Thickness=1,Parent=previewBar})

					hexLbl = _New("TextLabel", {
						Text=toHex(),Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,8,0,0),
						BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),
						TextStrokeTransparency=0.3,TextXAlignment=Enum.TextXAlignment.Left,
						Font=Enum.Font.Code,TextSize=13,ZIndex=502,Parent=previewBar,
					})

					local CH = {
						{lbl="R",col=Color3.fromRGB(220,65,65),  get=function()return r end,set=function(v)r=v end},
						{lbl="G",col=Color3.fromRGB(65,200,80),  get=function()return g end,set=function(v)g=v end},
						{lbl="B",col=Color3.fromRGB(65,120,220), get=function()return b end,set=function(v)b=v end},
					}
					for i,ch in ipairs(CH) do
						local y = 32+(i-1)*38+8
						_New("TextLabel",{Text=ch.lbl,Size=UDim2.new(0,12,0,14),Position=UDim2.new(0,8,0,y+8),
							BackgroundTransparency=1,TextColor3=ch.col,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=502,Parent=picker})
						local numLbl = _New("TextLabel",{Text=tostring(ch.get()),Size=UDim2.new(0,28,0,14),
							Position=UDim2.new(1,-34,0,y+8),BackgroundTransparency=1,TextColor3=T.TextDim,
							TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.Gotham,TextSize=11,ZIndex=502,Parent=picker})

						local tw = _New("Frame",{Size=UDim2.new(1,-54,0,16),Position=UDim2.new(0,22,0,y+11),
							BackgroundTransparency=1,ZIndex=502,Parent=picker})
						local track = New("Frame",{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0.5,-2),
							BorderSizePixel=0,ZIndex=503,Parent=tw},{BackgroundColor3="BgTertiary"})
						Stroke(track,"Border")
						local fl = _New("Frame",{Size=UDim2.new(ch.get()/255,0,1,0),BackgroundColor3=ch.col,BorderSizePixel=0,ZIndex=504,Parent=track})
						local kn = New("Frame",{Size=UDim2.new(0,9,0,9),Position=UDim2.new(ch.get()/255,-4,0.5,-4),
							BorderSizePixel=0,ZIndex=505,Parent=track},{BackgroundColor3="Text"})
						local hit = _New("TextButton",{Text="",Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0.5,-11),
							BackgroundTransparency=1,ZIndex=506,Parent=track})
						local sl = false
						local function upd(x)
							local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
							fl.Size=UDim2.new(rel,0,1,0); kn.Position=UDim2.new(rel,-4,0.5,-4)
							ch.set(math.floor(rel*255+0.5)); numLbl.Text=tostring(ch.get()); rebuild()
						end
						hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true;upd(i.Position.X) end end)
						UserInputService.InputChanged:Connect(function(i) if sl and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
						UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
					end
					snap()
					trackConn = RunService.Heartbeat:Connect(snap)
				end)

				return {
					GetValue = function() return val end,
					SetValue = function(_,c)
						val=c; r=math.floor(c.R*255); g=math.floor(c.G*255); b=math.floor(c.B*255)
						swatch.BackgroundColor3=c
					end,
				}
			end

			----------------------------------------------------
			-- Button
			----------------------------------------------------
			function Sec:AddButton(cfg)
				cfg = cfg or {}
				local cb = cfg.Callback or DefaultCB(cfg.Name)
				local btn = New("Frame", {
					Size=UDim2.new(1,0,0,24),BorderSizePixel=0,
					LayoutOrder=nxt(self),ZIndex=5,Parent=self._frame,
				},{BackgroundColor3="BgTertiary"})
				Stroke(btn,"Border")
				local lbl = New("TextButton", {
					Text=cfg.Name or "Button",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
					Font=Enum.Font.Gotham,TextSize=12,ZIndex=6,Parent=btn,
				},{TextColor3="Text"})
				lbl.MouseEnter:Connect(function()
					TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=T.Accent}):Play()
					TweenService:Create(lbl,TweenInfo.new(0.1),{TextColor3=T.Bg}):Play()
				end)
				lbl.MouseLeave:Connect(function()
					TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=T.BgTertiary}):Play()
					TweenService:Create(lbl,TweenInfo.new(0.1),{TextColor3=T.Text}):Play()
				end)
				lbl.MouseButton1Click:Connect(cb)
			end

			----------------------------------------------------
			-- Label
			----------------------------------------------------
			function Sec:AddLabel(cfg)
				cfg = cfg or {}
				local lbl = New("TextLabel", {
					Text=cfg.Text or "",Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,
					Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
					LayoutOrder=nxt(self),ZIndex=5,Parent=self._frame,
				},{TextColor3="TextDim"})
				return {
					SetText = function(_,t) lbl.Text=t end,
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
				local wrap = _New("Frame",{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,LayoutOrder=nxt(self),ZIndex=4,Parent=self._frame})
				New("TextLabel",{Text=cfg.Name or "Input",Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
					Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=wrap},{TextColor3="Text"})
				local box = New("TextBox",{
					Text=val,PlaceholderText=cfg.Placeholder or "...",
					Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,18),
					BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=12,
					TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=wrap,
				},{BackgroundColor3="BgTertiary",TextColor3="Text",PlaceholderColor3="TextDim"},{Stroke(nil,"Border"),Pad(0,6,0,6)})
				box.FocusLost:Connect(function() val=box.Text; cb(val) end)
				return {
					GetValue = function()    return val end,
					SetValue = function(_,t) val=t; box.Text=t end,
				}
			end

			----------------------------------------------------
			-- Separator
			----------------------------------------------------
			function Sec:AddSeparator()
				New("Frame",{Size=UDim2.new(1,0,0,1),BorderSizePixel=0,
					LayoutOrder=nxt(self),ZIndex=5,Parent=self._frame},{BackgroundColor3="Border"})
			end

			----------------------------------------------------
			-- ESP Preview
			-- Creates a ViewportFrame with the local character,
			-- overlays 2D ESP elements (box, name, health, distance).
			--
			-- HOW TO WIRE THIS UP IN YOUR GAME:
			-- The preview is purely visual — it shows what your ESP
			-- will look like. To implement real in-game ESP you:
			--   1. On each RenderStepped, loop Players:GetPlayers()
			--   2. Skip LocalPlayer and dead characters
			--   3. Use camera:WorldToViewportPoint(part.Position) to get
			--      screen-space position + depth
			--   4. Draw/resize Frame elements (box top/bottom/left/right)
			--      around the character's BoundingBox projected corners
			--   5. Position TextLabels for name, health, distance
			-- The shapes below (box lines, healthbar, name tag) are the
			-- same elements you'd use for real ESP — just driven by the
			-- ViewportFrame camera here instead of the game camera.
			----------------------------------------------------
			function Sec:AddESPPreview(cfg)
				cfg = cfg or {}
				local h = cfg.Height or 200

				local container = New("Frame", {
					Size=UDim2.new(1,0,0,h),BorderSizePixel=0,
					LayoutOrder=nxt(self),ZIndex=4,Parent=self._frame,
					ClipsDescendants=true,
				},{BackgroundColor3="BgTertiary"},{Stroke(nil,"Border")})

				-- ViewportFrame fills the container
				local vp = _New("ViewportFrame", {
					Size=UDim2.new(1,0,1,0),
					BackgroundColor3=Color3.fromRGB(20,24,20),
					LightDirection=Vector3.new(-1,-2,-1),
					Ambient=Color3.fromRGB(60,60,60),
					BorderSizePixel=0,
					ZIndex=5,Parent=container,
				})

				local cam = Instance.new("Camera")
				cam.FieldOfView = 55
				cam.Parent = vp
				vp.CurrentCamera = cam

				-- Clone local character into viewport
				local char = Players.LocalPlayer.Character
				local hasChar = false

				if char and char:FindFirstChild("HumanoidRootPart") then
					local clone = char:Clone()
					for _, s in pairs(clone:GetDescendants()) do
						if s:IsA("BaseScript") or s:IsA("LocalScript") or s:IsA("Script") then s:Destroy() end
					end
					if clone:FindFirstChild("Animate") then clone.Animate:Destroy() end
					clone:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
					clone.Parent = vp
					hasChar = true

					-- Camera: slightly to the side + elevated, looking at chest
					cam.CFrame = CFrame.new(Vector3.new(2.5, 5.5, 11), Vector3.new(0, 4.5, 0))

					-- ── ESP Overlay elements (BillboardGui on HRP) ──────────
					local hrp = clone:FindFirstChild("HumanoidRootPart")
					if hrp then
						-- Box — 4 line frames around a BillboardGui
						local bbg = _New("BillboardGui", {
							Size=UDim2.new(0, 62, 0, 110),
							StudsOffset=Vector3.new(0, 0.5, 0),
							AlwaysOnTop=true,
							ZIndexBehavior=Enum.ZIndexBehavior.Global,
							Parent=hrp,
						})

						local boxColor = cfg.BoxColor or Color3.fromRGB(220, 55, 55)
						local thick = 1

						-- Top, Bottom, Left, Right lines
						local function Line(xScale, yScale, xSize, ySize, xOff, yOff)
							_New("Frame",{
								Size=UDim2.new(xScale,xSize,yScale,ySize),
								Position=UDim2.new(xOff,0,yOff,0),
								BackgroundColor3=boxColor,BorderSizePixel=0,ZIndex=10,Parent=bbg,
							})
						end
						Line(1,0, 0,thick,  0,0)    -- top
						Line(1,0, 0,thick,  0,1)    -- bottom (offset handled by Position below)
						Line(0,1, thick,0,  0,0)    -- left
						Line(0,1, thick,0,  1,0)    -- right

						-- Fix bottom line position
						local children = bbg:GetChildren()
						if children[2] then children[2].Position = UDim2.new(0,0,1,-thick) end
						if children[4] then children[4].Position = UDim2.new(1,-thick,0,0) end

						-- Name tag
						_New("TextLabel",{
							Text = Players.LocalPlayer.Name,
							Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,-16),
							BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),
							Font=Enum.Font.GothamBold,TextSize=11,ZIndex=10,Parent=bbg,
						})

						-- Health bar (left side, green)
						local healthBg = _New("Frame",{
							Size=UDim2.new(0,4,1,0),Position=UDim2.new(0,-7,0,0),
							BackgroundColor3=Color3.fromRGB(40,40,40),BorderSizePixel=0,ZIndex=10,Parent=bbg,
						})
						_New("Frame",{
							Size=UDim2.new(1,0,0.75,0),Position=UDim2.new(0,0,0.25,0), -- 75% health
							BackgroundColor3=Color3.fromRGB(80,200,70),BorderSizePixel=0,ZIndex=11,Parent=healthBg,
						})

						-- Distance label
						_New("TextLabel",{
							Text="12m",Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,2),
							BackgroundTransparency=1,TextColor3=Color3.fromRGB(200,200,200),
							Font=Enum.Font.Gotham,TextSize=9,ZIndex=10,Parent=bbg,
						})
					end
				else
					-- No character: show a static "no preview" message
					_New("TextLabel",{
						Text="No character loaded",Size=UDim2.new(1,0,1,0),
						BackgroundTransparency=1,TextColor3=Color3.fromRGB(100,100,100),
						Font=Enum.Font.Gotham,TextSize=12,ZIndex=6,Parent=vp,
					})
				end

				-- Category tab buttons across the bottom of the preview
				local tabRow = New("Frame",{
					Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-22),
					BorderSizePixel=0,ZIndex=6,Parent=container,
				},{BackgroundColor3="Bg"},{HList(0)})

				local previewTabs = cfg.Categories or {"Enemies","Allies","Bots","Vehicles"}
				for i, cat in ipairs(previewTabs) do
					local tb = New("TextButton",{
						Text=cat,Size=UDim2.new(1/#previewTabs,0,1,0),BorderSizePixel=0,
						Font=Enum.Font.Gotham,TextSize=10,ZIndex=7,LayoutOrder=i,Parent=tabRow,
					},{BackgroundColor3= i==1 and "BgTertiary" or "Bg", TextColor3= i==1 and "Text" or "TextDim"})
					tb.MouseButton1Click:Connect(function()
						for _, c in pairs(tabRow:GetChildren()) do
							if c:IsA("TextButton") then
								c.BackgroundColor3 = T.Bg; c.TextColor3 = T.TextDim
							end
						end
						tb.BackgroundColor3 = T.BgTertiary; tb.TextColor3 = T.Text
					end)
				end

				return { ViewportFrame = vp, Camera = cam }
			end

			return Sec
		end -- AddSection
		return Tab
	end -- AddTab

	--------------------------------------------------------------
	-- Watermark
	--------------------------------------------------------------
	function Win:CreateWatermark(cfg)
		cfg = cfg or {}
		local wmTitle = cfg.Title    or title
		local version = cfg.Version  or ""
		local wPos    = cfg.Position or UDim2.new(0, 6, 0, 6)
		local key     = cfg.ToggleKey

		local wm = New("Frame",{
			Size=UDim2.new(0,0,0,24),AutomaticSize=Enum.AutomaticSize.X,
			Position=wPos,BorderSizePixel=0,ZIndex=900,Parent=gui,
		},{BackgroundColor3="BgSecondary"},{Stroke(nil,"Border"),Pad(0,8,0,8)})

		local wmLbl = New("TextLabel",{
			Text="",AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),
			BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=901,Parent=wm,
		},{TextColor3="Text"})
		local fpsLbl = New("TextLabel",{
			Text="",AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),
			BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,ZIndex=901,Parent=wm,
		},{TextColor3="TextDim"})

		-- Horizontal layout for the text labels
		local hl = HList(0); hl.Parent = wm

		local fps, fpsSum, fpsCnt = 0, 0, 0
		local conn = RunService.RenderStepped:Connect(function(dt)
			fpsCnt = fpsCnt + 1
			fpsSum = fpsSum + (1/dt)
			if fpsCnt >= 30 then
				fps = math.floor(fpsSum/fpsCnt)
				fpsCnt = 0; fpsSum = 0
			end
			local t = os.date("*t")
			local timeStr = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
			wmLbl.Text  = (version~="" and (wmTitle.." "..version) or wmTitle) .. "  "
			fpsLbl.Text = string.format("fps: %d  |  %s", fps, timeStr)
		end)

		MakeDraggable(wm, wm)

		if key then
			UserInputService.InputBegan:Connect(function(i,gp)
				if not gp and i.KeyCode == key then
					wm.Visible = not wm.Visible
				end
			end)
		end

		return {
			Show    = function() wm.Visible = true  end,
			Hide    = function() wm.Visible = false end,
			Toggle  = function() wm.Visible = not wm.Visible end,
			Destroy = function() conn:Disconnect(); wm:Destroy() end,
		}
	end

	--------------------------------------------------------------
	-- Player List
	--------------------------------------------------------------
	function Win:CreatePlayerList(cfg)
		cfg = cfg or {}
		local plPos    = cfg.Position  or UDim2.new(1,-172,0.5,-160)
		local plWidth  = cfg.Width     or 166
		local key      = cfg.ToggleKey
		local visible  = cfg.StartVisible ~= false

		local plFrame = New("Frame",{
			Size=UDim2.new(0,plWidth,0,0),AutomaticSize=Enum.AutomaticSize.Y,
			Position=plPos,BorderSizePixel=0,
			Visible=visible,ZIndex=800,Parent=gui,
		},{BackgroundColor3="BgSecondary"},{Stroke(nil,"Border")})

		-- Header
		local header = New("Frame",{
			Size=UDim2.new(1,0,0,26),BorderSizePixel=0,ZIndex=801,Parent=plFrame,
		},{BackgroundColor3="Bg"})
		New("TextLabel",{
			Text="Players",Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,8,0,0),
			BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,
			TextXAlignment=Enum.TextXAlignment.Left,ZIndex=802,Parent=header,
		},{TextColor3="Accent"})
		local countLbl = New("TextLabel",{
			Text="0",Size=UDim2.new(0,30,1,0),Position=UDim2.new(1,-34,0,0),
			BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,
			TextXAlignment=Enum.TextXAlignment.Right,ZIndex=802,Parent=header,
		},{TextColor3="TextDim"})

		New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,26),
			BorderSizePixel=0,ZIndex=801,Parent=plFrame},{BackgroundColor3="Border"})

		local listFrame = _New("Frame",{
			Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
			Position=UDim2.new(0,0,0,27),BackgroundTransparency=1,
			BorderSizePixel=0,ZIndex=801,Parent=plFrame,
		},{VList(0),Pad(2,4,2,4)})

		local rowCache = {}

		local function Refresh()
			-- Clear existing rows
			for _, r in pairs(rowCache) do r:Destroy() end
			rowCache = {}

			local all = Players:GetPlayers()
			countLbl.Text = tostring(#all)

			for _, plr in ipairs(all) do
				local row = _New("Frame",{
					Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,
					BorderSizePixel=0,ZIndex=802,Parent=listFrame,
				})
				table.insert(rowCache, row)

				-- Team colour dot
				local dot = _New("Frame",{
					Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,2,0.5,-4),
					BorderSizePixel=0,ZIndex=803,Parent=row,
				})
				dot.BackgroundColor3 = (plr.Team and plr.TeamColor and plr.TeamColor.Color)
					or Color3.fromRGB(120,120,120)

				-- Name
				local isLocal = plr == Players.LocalPlayer
				New("TextLabel",{
					Text = isLocal and ("▶ "..plr.Name) or plr.Name,
					Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,14,0,0),
					BackgroundTransparency=1,Font=isLocal and Enum.Font.GothamBold or Enum.Font.Gotham,
					TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=803,Parent=row,
				},{TextColor3= isLocal and "Accent" or "Text"})
			end
		end

		Refresh()
		Players.PlayerAdded:Connect(function() task.delay(0.05, Refresh) end)
		Players.PlayerRemoving:Connect(function() task.delay(0.05, Refresh) end)
		MakeDraggable(plFrame, header)

		if key then
			UserInputService.InputBegan:Connect(function(i,gp)
				if not gp and i.KeyCode == key then
					plFrame.Visible = not plFrame.Visible
				end
			end)
		end

		return {
			Show    = function() plFrame.Visible = true  end,
			Hide    = function() plFrame.Visible = false end,
			Toggle  = function() plFrame.Visible = not plFrame.Visible end,
			Refresh = Refresh,
		}
	end

	return Win
end -- CreateWindow

return UILibrary
