-- UILibrary.lua
-- Place as a ModuleScript in ReplicatedStorage or use directly
-- Usage: local UI = require(path.to.UILibrary)

local UILibrary = {}
UILibrary.__index = UILibrary

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

---------------------------------------------------------
-- Theme
---------------------------------------------------------
local T = {
	Bg           = Color3.fromRGB(13, 13, 19),
	BgSecondary  = Color3.fromRGB(20, 20, 29),
	BgTertiary   = Color3.fromRGB(27, 27, 38),
	Accent       = Color3.fromRGB(108, 60, 210),
	AccentHover  = Color3.fromRGB(128, 80, 230),
	Border       = Color3.fromRGB(42, 42, 58),
	Text         = Color3.fromRGB(225, 225, 230),
	TextDim      = Color3.fromRGB(130, 130, 145),
	ToggleOn     = Color3.fromRGB(108, 60, 210),
	ToggleOff    = Color3.fromRGB(42, 42, 58),
	SliderFill   = Color3.fromRGB(108, 60, 210),
	DropBg       = Color3.fromRGB(16, 16, 23),
	Red          = Color3.fromRGB(220, 55, 55),
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

local function Tween(obj, goal, t, style, dir)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		goal
	):Play()
end

local function Corner(r)   return New("UICorner",  { CornerRadius = UDim.new(0, r or 4) }) end
local function Stroke(c,t) return New("UIStroke",  { Color = c or T.Border, Thickness = t or 1 }) end
local function Padding(a,b,c,d)
	return New("UIPadding", {
		PaddingTop    = UDim.new(0, a or 0),
		PaddingRight  = UDim.new(0, b or 0),
		PaddingBottom = UDim.new(0, c or 0),
		PaddingLeft   = UDim.new(0, d or 0),
	})
end
local function ListLayout(dir, pad)
	return New("UIListLayout", {
		FillDirection  = dir or Enum.FillDirection.Vertical,
		SortOrder      = Enum.SortOrder.LayoutOrder,
		Padding        = UDim.new(0, pad or 0),
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

---------------------------------------------------------
-- Window
---------------------------------------------------------
function UILibrary:CreateWindow(cfg)
	cfg = cfg or {}
	local title   = cfg.Title  or "Window"
	local size    = cfg.Size   or UDim2.new(0, 520, 0, 560)
	local pos     = cfg.Position or UDim2.new(0.5, -260, 0.5, -280)
	local minW    = cfg.MinimizeKey  -- optional KeyCode

	local gui = New("ScreenGui", {
		Name            = "UILib_" .. title,
		ResetOnSpawn    = false,
		ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset  = true,
	})
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not ok then
		gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Root frame
	local root = New("Frame", {
		Name              = "Root",
		Size              = size,
		Position          = pos,
		BackgroundColor3  = T.Bg,
		BorderSizePixel   = 0,
		ClipsDescendants  = true,
		Parent            = gui,
	}, { Corner(6), Stroke(T.Border) })

	-- Title bar
	local titleBar = New("Frame", {
		Size             = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = T.BgSecondary,
		BorderSizePixel  = 0,
		ZIndex           = 2,
		Parent           = root,
	})
	New("Frame", { -- square-off bottom of title bar
		Size             = UDim2.new(1, 0, 0, 6),
		Position         = UDim2.new(0, 0, 1, -6),
		BackgroundColor3 = T.BgSecondary,
		BorderSizePixel  = 0,
		ZIndex           = 2,
		Parent           = titleBar,
	})
	New("TextLabel", {
		Text             = title,
		Size             = UDim2.new(1, -70, 1, 0),
		Position         = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		TextColor3       = T.Text,
		TextXAlignment   = Enum.TextXAlignment.Left,
		Font             = Enum.Font.GothamBold,
		TextSize         = 13,
		ZIndex           = 3,
		Parent           = titleBar,
	})

	-- Minimise / Close buttons
	local function TitleBtn(icon, xOff)
		local b = New("TextButton", {
			Text             = icon,
			Size             = UDim2.new(0, 26, 0, 26),
			Position         = UDim2.new(1, xOff, 0.5, -13),
			BackgroundTransparency = 1,
			TextColor3       = T.TextDim,
			Font             = Enum.Font.GothamBold,
			TextSize         = 16,
			ZIndex           = 4,
			Parent           = titleBar,
		})
		b.MouseEnter:Connect(function() b.TextColor3 = T.Text end)
		b.MouseLeave:Connect(function() b.TextColor3 = T.TextDim end)
		return b
	end

	local closeBtn = TitleBtn("×", -30)
	local minBtn   = TitleBtn("–", -58)

	local minimised = false
	local fullSize  = size

	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
	minBtn.MouseButton1Click:Connect(function()
		minimised = not minimised
		if minimised then
			fullSize = root.Size
			Tween(root, { Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 34) }, 0.2)
		else
			Tween(root, { Size = fullSize }, 0.2)
		end
	end)

	if minW then
		UserInputService.InputBegan:Connect(function(i, gp)
			if not gp and i.KeyCode == minW then minBtn.MouseButton1Click:Fire() end
		end)
	end

	MakeDraggable(root, titleBar)

	-- Accent line under title
	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 0, 34),
		BackgroundColor3 = T.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 2,
		Parent           = root,
	})

	-- Tab bar
	local tabBar = New("Frame", {
		Name             = "TabBar",
		Size             = UDim2.new(1, 0, 0, 34),
		Position         = UDim2.new(0, 0, 0, 35),
		BackgroundColor3 = T.BgTertiary,
		BorderSizePixel  = 0,
		ZIndex           = 2,
		Parent           = root,
	}, { ListLayout(Enum.FillDirection.Horizontal) })

	-- Content area
	local content = New("Frame", {
		Name             = "Content",
		Size             = UDim2.new(1, 0, 1, -70),
		Position         = UDim2.new(0, 0, 0, 70),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		Parent           = root,
	})

	---------------------------------------------------------
	-- Window object
	---------------------------------------------------------
	local Win = { _tabs = {}, _active = nil, _root = root, _gui = gui }

	function Win:SelectTab(tab)
		for _, t in pairs(self._tabs) do
			t._page.Visible       = false
			t._indicator.Visible  = false
			Tween(t._btn, { TextColor3 = T.TextDim, BackgroundColor3 = T.BgTertiary }, 0.1)
		end
		tab._page.Visible      = true
		tab._indicator.Visible = true
		Tween(tab._btn, { TextColor3 = T.Text, BackgroundColor3 = T.Bg }, 0.1)
		self._active = tab
	end

	function Win:AddTab(name)
		local idx  = #self._tabs
		local tW   = 1 / math.max(4, idx + 1) -- up to 4 equal tabs; grows dynamically below
		-- Resize all tab buttons equally
		local btn = New("TextButton", {
			Name             = name,
			Text             = name,
			Size             = UDim2.new(0, 0, 1, 0), -- overridden below
			BackgroundColor3 = T.BgTertiary,
			BorderSizePixel  = 0,
			TextColor3       = T.TextDim,
			Font             = Enum.Font.Gotham,
			TextSize         = 12,
			LayoutOrder      = idx,
			ZIndex           = 2,
			Parent           = tabBar,
		})

		local indicator = New("Frame", {
			Size             = UDim2.new(1, 0, 0, 2),
			Position         = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = T.Accent,
			BorderSizePixel  = 0,
			Visible          = false,
			ZIndex           = 3,
			Parent           = btn,
		})

		-- Rebalance tab widths
		local function rebalance()
			local n = #self._tabs
			for _, t in pairs(self._tabs) do
				t._btn.Size = UDim2.new(1/n, 0, 1, 0)
			end
		end

		local page = New("ScrollingFrame", {
			Size                = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel     = 0,
			ScrollBarThickness  = 3,
			ScrollBarImageColor3 = T.Accent,
			CanvasSize          = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible             = false,
			ZIndex              = 2,
			Parent              = content,
		}, {
			Padding(10, 10, 10, 10),
			ListLayout(Enum.FillDirection.Vertical, 6),
		})

		local Tab = { _btn = btn, _indicator = indicator, _page = page, _sections = {} }
		table.insert(self._tabs, Tab)
		rebalance()

		btn.MouseButton1Click:Connect(function() self:SelectTab(Tab) end)
		if #self._tabs == 1 then self:SelectTab(Tab) end

		----------------------------------------------------
		-- Tab:AddSection
		----------------------------------------------------
		function Tab:AddSection(sName)
			sName = sName or ""
			local sec = New("Frame", {
				Name             = sName,
				Size             = UDim2.new(1, 0, 0, 0),
				AutomaticSize    = Enum.AutomaticSize.Y,
				BackgroundColor3 = T.BgSecondary,
				BorderSizePixel  = 0,
				LayoutOrder      = #self._sections,
				ZIndex           = 2,
				Parent           = page,
			}, {
				Corner(5),
				Stroke(T.Border),
				Padding(6, 10, 8, 10),
				ListLayout(Enum.FillDirection.Vertical, 5),
			})

			if sName ~= "" then
				New("TextLabel", {
					Text             = sName,
					Size             = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					TextColor3       = T.Accent,
					TextXAlignment   = Enum.TextXAlignment.Left,
					Font             = Enum.Font.GothamBold,
					TextSize         = 11,
					LayoutOrder      = 0,
					ZIndex           = 3,
					Parent           = sec,
				})
			end

			local Sec = { _frame = sec, _count = 0 }
			table.insert(self._sections, Sec)

			local function nextOrder(s)
				s._count = s._count + 1
				return s._count
			end

			-- Row helper (label + right-side widget)
			local function Row(s, h)
				return New("Frame", {
					Size             = UDim2.new(1, 0, 0, h or 24),
					BackgroundTransparency = 1,
					LayoutOrder      = nextOrder(s),
					ZIndex           = 3,
					Parent           = s._frame,
				})
			end

			local function RowLabel(parent, text)
				New("TextLabel", {
					Text             = text,
					Size             = UDim2.new(0.6, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3       = T.Text,
					TextXAlignment   = Enum.TextXAlignment.Left,
					Font             = Enum.Font.Gotham,
					TextSize         = 12,
					ZIndex           = 4,
					Parent           = parent,
				})
			end

			----------------------------------------------------
			-- Toggle
			----------------------------------------------------
			function Sec:AddToggle(cfg)
				cfg = cfg or {}
				local val  = cfg.Default  or false
				local cb   = cfg.Callback or function() end
				local row  = Row(self)
				RowLabel(row, cfg.Name or "Toggle")

				local bg = New("Frame", {
					Size             = UDim2.new(0, 36, 0, 18),
					Position         = UDim2.new(1, -36, 0.5, -9),
					BackgroundColor3 = val and T.ToggleOn or T.ToggleOff,
					ZIndex           = 4,
					Parent           = row,
				}, { Corner(9) })

				local knob = New("Frame", {
					Size             = UDim2.new(0, 14, 0, 14),
					Position         = val and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
					BackgroundColor3 = Color3.new(1,1,1),
					ZIndex           = 5,
					Parent           = bg,
				}, { Corner(7) })

				New("TextButton", {
					Text = "", Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1, ZIndex = 6, Parent = row,
				}).MouseButton1Click:Connect(function()
					val = not val
					Tween(bg,   { BackgroundColor3 = val and T.ToggleOn or T.ToggleOff })
					Tween(knob, { Position = val and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7) })
					cb(val)
				end)

				return { GetValue = function() return val end,
				         SetValue = function(_, v) val = v
				           Tween(bg,  { BackgroundColor3 = val and T.ToggleOn or T.ToggleOff })
				           Tween(knob,{ Position = val and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7) })
				           cb(val)
				         end }
			end

			----------------------------------------------------
			-- Slider
			----------------------------------------------------
			function Sec:AddSlider(cfg)
				cfg = cfg or {}
				local mn  = cfg.Min     or 0
				local mx  = cfg.Max     or 100
				local val = cfg.Default or mn
				local suf = cfg.Suffix  or ""
				local dp  = cfg.Decimals or 0
				local cb  = cfg.Callback or function() end

				local container = New("Frame", {
					Size             = UDim2.new(1, 0, 0, 40),
					BackgroundTransparency = 1,
					LayoutOrder      = nextOrder(self),
					ZIndex           = 3,
					Parent           = self._frame,
				})

				-- top row: name + value
				local topRow = New("Frame", {
					Size = UDim2.new(1,0,0,18), BackgroundTransparency=1, ZIndex=4, Parent=container,
				})
				New("TextLabel", {
					Text=cfg.Name or "Slider", Size=UDim2.new(0.7,0,1,0),
					BackgroundTransparency=1, TextColor3=T.Text, TextXAlignment=Enum.TextXAlignment.Left,
					Font=Enum.Font.Gotham, TextSize=12, ZIndex=4, Parent=topRow,
				})
				local valLbl = New("TextLabel", {
					Text=tostring(val)..suf, Size=UDim2.new(0.3,0,1,0), Position=UDim2.new(0.7,0,0,0),
					BackgroundTransparency=1, TextColor3=T.TextDim, TextXAlignment=Enum.TextXAlignment.Right,
					Font=Enum.Font.Gotham, TextSize=12, ZIndex=4, Parent=topRow,
				})

				local track = New("Frame", {
					Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,0,24),
					BackgroundColor3=T.BgTertiary, ZIndex=4, Parent=container,
				}, { Corner(3) })

				local pct = (val - mn) / (mx - mn)
				local fill = New("Frame", {
					Size=UDim2.new(pct,0,1,0), BackgroundColor3=T.SliderFill, ZIndex=5, Parent=track,
				}, { Corner(3) })
				local knob = New("Frame", {
					Size=UDim2.new(0,12,0,12), Position=UDim2.new(pct,-6,0.5,-6),
					BackgroundColor3=Color3.new(1,1,1), ZIndex=6, Parent=track,
				}, { Corner(6) })

				local sliding = false
				local hitbox  = New("TextButton", {
					Text="", Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,0.5,-12),
					BackgroundTransparency=1, ZIndex=7, Parent=track,
				})

				local function update(x)
					local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local mult = 10^dp
					val = math.floor((mn + (mx-mn)*rel)*mult+0.5)/mult
					fill.Size     = UDim2.new(rel, 0, 1, 0)
					knob.Position = UDim2.new(rel, -6, 0.5, -6)
					valLbl.Text   = tostring(val) .. suf
					cb(val)
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

				return { GetValue = function() return val end }
			end

			----------------------------------------------------
			-- Dropdown
			----------------------------------------------------
			function Sec:AddDropdown(cfg)
				cfg = cfg or {}
				local opts = cfg.Options or {}
				local val  = cfg.Default or opts[1] or ""
				local cb   = cfg.Callback or function() end
				local open = false

				local wrap = New("Frame", {
					Name="DropWrap", Size=UDim2.new(1,0,0,42),
					BackgroundTransparency=1, ClipsDescendants=false,
					LayoutOrder=nextOrder(self), ZIndex=3, Parent=self._frame,
				})

				New("TextLabel", {
					Text=cfg.Name or "Dropdown", Size=UDim2.new(1,0,0,18),
					BackgroundTransparency=1, TextColor3=T.Text, TextXAlignment=Enum.TextXAlignment.Left,
					Font=Enum.Font.Gotham, TextSize=12, ZIndex=4, Parent=wrap,
				})

				local head = New("TextButton", {
					Text="", Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0,20),
					BackgroundColor3=T.BgTertiary, BorderSizePixel=0, ZIndex=4, Parent=wrap,
				}, { Corner(4), Stroke(T.Border) })

				local selLbl = New("TextLabel", {
					Text=val, Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,8,0,0),
					BackgroundTransparency=1, TextColor3=T.Text, TextXAlignment=Enum.TextXAlignment.Left,
					Font=Enum.Font.Gotham, TextSize=12, ZIndex=5, Parent=head,
				})
				local arrow = New("TextLabel", {
					Text="▾", Size=UDim2.new(0,20,1,0), Position=UDim2.new(1,-22,0,0),
					BackgroundTransparency=1, TextColor3=T.TextDim, Font=Enum.Font.Gotham, TextSize=14,
					ZIndex=5, Parent=head,
				})

				local itemH  = 22
				local list   = New("Frame", {
					Size=UDim2.new(1,0,0,#opts*itemH), Position=UDim2.new(0,0,0,44),
					BackgroundColor3=T.DropBg, BorderSizePixel=0, Visible=false, ZIndex=20, Parent=wrap,
				}, { Corner(4), Stroke(T.Border), ListLayout(nil,0) })

				for i, opt in ipairs(opts) do
					local ob = New("TextButton", {
						Text=opt, Size=UDim2.new(1,0,0,itemH), BackgroundTransparency=1,
						TextColor3=T.TextDim, TextXAlignment=Enum.TextXAlignment.Left,
						Font=Enum.Font.Gotham, TextSize=12, LayoutOrder=i, ZIndex=21, Parent=list,
					}, { Padding(0,0,0,8) })
					ob.MouseEnter:Connect(function()
						Tween(ob, { BackgroundColor3=T.BgTertiary }, 0.08)
						ob.BackgroundTransparency = 0
						ob.TextColor3 = T.Text
					end)
					ob.MouseLeave:Connect(function()
						ob.BackgroundTransparency = 1
						ob.TextColor3 = T.TextDim
					end)
					ob.MouseButton1Click:Connect(function()
						val = opt; selLbl.Text = opt
						open = false; list.Visible = false
						wrap.Size = UDim2.new(1,0,0,42)
						cb(opt)
					end)
				end

				head.MouseButton1Click:Connect(function()
					open = not open
					list.Visible = open
					wrap.Size = open and UDim2.new(1,0,0,42 + #opts*itemH) or UDim2.new(1,0,0,42)
					Tween(arrow, { Rotation = open and 180 or 0 }, 0.15)
				end)

				return {
					GetValue  = function() return val end,
					SetOptions = function(_, newOpts)
						for _, c in pairs(list:GetChildren()) do
							if c:IsA("TextButton") then c:Destroy() end
						end
						opts = newOpts
						list.Size = UDim2.new(1,0,0,#opts*itemH)
						for i, opt in ipairs(opts) do
							local ob = New("TextButton", {
								Text=opt, Size=UDim2.new(1,0,0,itemH), BackgroundTransparency=1,
								TextColor3=T.TextDim, TextXAlignment=Enum.TextXAlignment.Left,
								Font=Enum.Font.Gotham, TextSize=12, LayoutOrder=i, ZIndex=21, Parent=list,
							}, { Padding(0,0,0,8) })
							ob.MouseButton1Click:Connect(function()
								val = opt; selLbl.Text = opt
								open = false; list.Visible = false
								wrap.Size = UDim2.new(1,0,0,42); cb(opt)
							end)
						end
					end,
				}
			end

			----------------------------------------------------
			-- ColorPicker  (HSV bar-based)
			----------------------------------------------------
			function Sec:AddColorPicker(cfg)
				cfg = cfg or {}
				local val = cfg.Default or Color3.fromRGB(220, 55, 55)
				local cb  = cfg.Callback or function() end
				local h, s, v = Color3.toHSV(val)

				local row = Row(self)
				RowLabel(row, cfg.Name or "Color")

				local preview = New("TextButton", {
					Text="", Size=UDim2.new(0,22,0,16), Position=UDim2.new(1,-22,0.5,-8),
					BackgroundColor3=val, ZIndex=5, Parent=row,
				}, { Corner(3), Stroke(T.Border) })

				local pickerOpen = false
				local picker

				local function rebuildColor()
					val = Color3.fromHSV(h, s, v)
					preview.BackgroundColor3 = val
					cb(val)
				end

				local function MakeHSVBar(parent, lbl, yOff, init, onChanged)
					New("TextLabel", {
						Text=lbl, Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,6,0,yOff),
						BackgroundTransparency=1, TextColor3=T.TextDim, Font=Enum.Font.GothamBold,
						TextSize=10, ZIndex=52, Parent=parent,
					})
					local trk = New("Frame", {
						Size=UDim2.new(1,-26,0,8), Position=UDim2.new(0,22,0,yOff+3),
						BackgroundColor3=T.BgTertiary, ZIndex=52, Parent=parent,
					}, { Corner(4) })
					local fl = New("Frame", {
						Size=UDim2.new(init,0,1,0), BackgroundColor3=T.Accent, ZIndex=53, Parent=trk,
					}, { Corner(4) })
					local hitb = New("TextButton", {
						Text="", Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0.5,-10),
						BackgroundTransparency=1, ZIndex=54, Parent=trk,
					})
					local sliding = false
					hitb.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then
							sliding = true
							local r = math.clamp((i.Position.X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
							fl.Size = UDim2.new(r,0,1,0); onChanged(r)
						end
					end)
					UserInputService.InputChanged:Connect(function(i)
						if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
							local r = math.clamp((i.Position.X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
							fl.Size = UDim2.new(r,0,1,0); onChanged(r)
						end
					end)
					UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
					end)
				end

				preview.MouseButton1Click:Connect(function()
					pickerOpen = not pickerOpen
					if picker then
						picker.Visible = pickerOpen
						return
					end
					picker = New("Frame", {
						Size=UDim2.new(0,180,0,108), Position=UDim2.new(1,-180,1,4),
						BackgroundColor3=T.BgSecondary, BorderSizePixel=0, ZIndex=50, Parent=row,
					}, { Corner(5), Stroke(T.Border) })

					MakeHSVBar(picker,"H",8, h, function(r) h=r; rebuildColor() end)
					MakeHSVBar(picker,"S",38,s, function(r) s=r; rebuildColor() end)
					MakeHSVBar(picker,"V",68,v, function(r) v=r; rebuildColor() end)

					New("TextLabel", {
						Text="Hue / Sat / Val", Size=UDim2.new(1,-10,0,14),
						Position=UDim2.new(0,6,1,-18),
						BackgroundTransparency=1, TextColor3=T.TextDim,
						TextXAlignment=Enum.TextXAlignment.Left,
						Font=Enum.Font.Code, TextSize=10, ZIndex=51, Parent=picker,
					})
				end)

				return {
					GetValue = function() return val end,
					SetValue = function(_, c)
						val=c; h,s,v=Color3.toHSV(c); preview.BackgroundColor3=c
					end,
				}
			end

			----------------------------------------------------
			-- Button
			----------------------------------------------------
			function Sec:AddButton(cfg)
				cfg = cfg or {}
				local cb = cfg.Callback or function() end
				local btn = New("TextButton", {
					Text=cfg.Name or "Button", Size=UDim2.new(1,0,0,26),
					BackgroundColor3=T.BgTertiary, BorderSizePixel=0,
					TextColor3=T.Text, Font=Enum.Font.Gotham, TextSize=12,
					LayoutOrder=nextOrder(self), ZIndex=4, Parent=self._frame,
				}, { Corner(4), Stroke(T.Border) })
				btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=T.BgTertiary},0.1) end)
				btn.MouseButton1Click:Connect(function()
					Tween(btn,{BackgroundColor3=T.Accent},0.1)
					task.delay(0.2, function() Tween(btn,{BackgroundColor3=T.BgTertiary},0.1) end)
					cb()
				end)
			end

			----------------------------------------------------
			-- Label
			----------------------------------------------------
			function Sec:AddLabel(cfg)
				cfg = cfg or {}
				local lbl = New("TextLabel", {
					Text=cfg.Text or "", Size=UDim2.new(1,0,0,18),
					BackgroundTransparency=1, TextColor3=T.TextDim,
					TextXAlignment=Enum.TextXAlignment.Left,
					Font=Enum.Font.Gotham, TextSize=12,
					LayoutOrder=nextOrder(self), ZIndex=4, Parent=self._frame,
				})
				return {
					SetText = function(_, t) lbl.Text = t end,
					GetText = function() return lbl.Text end,
				}
			end

			----------------------------------------------------
			-- TextBox
			----------------------------------------------------
			function Sec:AddTextBox(cfg)
				cfg = cfg or {}
				local val = cfg.Default or ""
				local cb  = cfg.Callback or function() end

				local wrap = New("Frame", {
					Size=UDim2.new(1,0,0,44), BackgroundTransparency=1,
					LayoutOrder=nextOrder(self), ZIndex=3, Parent=self._frame,
				})
				New("TextLabel", {
					Text=cfg.Name or "Input", Size=UDim2.new(1,0,0,18),
					BackgroundTransparency=1, TextColor3=T.Text,
					TextXAlignment=Enum.TextXAlignment.Left,
					Font=Enum.Font.Gotham, TextSize=12, ZIndex=4, Parent=wrap,
				})
				local box = New("TextBox", {
					Text=val, PlaceholderText=cfg.Placeholder or "...",
					Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,0,20),
					BackgroundColor3=T.BgTertiary, BorderSizePixel=0,
					TextColor3=T.Text, PlaceholderColor3=T.TextDim,
					TextXAlignment=Enum.TextXAlignment.Left,
					Font=Enum.Font.Gotham, TextSize=12, ZIndex=4, Parent=wrap,
				}, { Corner(4), Stroke(T.Border), Padding(0,6,0,8) })

				box.FocusLost:Connect(function() val = box.Text; cb(val) end)

				return {
					GetValue = function() return val end,
					SetValue = function(_, t) val=t; box.Text=t end,
				}
			end

			----------------------------------------------------
			-- Separator
			----------------------------------------------------
			function Sec:AddSeparator()
				New("Frame", {
					Size=UDim2.new(1,0,0,1), BackgroundColor3=T.Border,
					BorderSizePixel=0, LayoutOrder=nextOrder(self), ZIndex=4, Parent=self._frame,
				})
			end

			return Sec
		end -- AddSection

		return Tab
	end -- AddTab

	return Win
end -- CreateWindow

return UILibrary
