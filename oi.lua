-- Cloudy UI Library
-- Dark theme, modern card layout
-- Supports: Divider, Label, Button, Toggle, Slider, Textbox, Keybind, Dropdown, Colorpicker

local UserInputService = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local TextService       = game:GetService("TextService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ─── Colour palette ────────────────────────────────────────────────────────────
local C = {
	BG          = Color3.fromRGB(10,  10,  15),
	Surface     = Color3.fromRGB(18,  18,  26),
	SurfaceAlt  = Color3.fromRGB(24,  24,  34),
	Stroke      = Color3.fromRGB(44,  44,  60),
	Accent      = Color3.fromRGB(110, 110, 200),
	AccentDim   = Color3.fromRGB(60,  60,  120),
	Text        = Color3.fromRGB(220, 220, 235),
	SubText     = Color3.fromRGB(130, 130, 160),
	White       = Color3.fromRGB(255, 255, 255),
	Green       = Color3.fromRGB(80,  200, 120),
	Red         = Color3.fromRGB(200, 80,  80),
}

-- ─── Tween helper ──────────────────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
	local info = TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

-- ─── Instance helper ───────────────────────────────────────────────────────────
local function New(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, child in pairs(children or {}) do child.Parent = inst end
	return inst
end

local function Stroke(parent, color, thickness)
	return New("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode    = Enum.LineJoinMode.Miter,
		Color           = color or C.Stroke,
		Thickness       = thickness or 1,
		Parent          = parent,
	})
end

local function Corner(parent, radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function Pad(parent, top, bottom, left, right)
	return New("UIPadding", {
		PaddingTop    = UDim.new(0, top    or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft   = UDim.new(0, left   or 0),
		PaddingRight  = UDim.new(0, right  or 0),
		Parent        = parent,
	})
end

local function ListLayout(parent, dir, align, pad)
	return New("UIListLayout", {
		FillDirection      = dir   or Enum.FillDirection.Vertical,
		HorizontalAlignment= align or Enum.HorizontalAlignment.Left,
		SortOrder          = Enum.SortOrder.LayoutOrder,
		Padding            = UDim.new(0, pad or 0),
		Parent             = parent,
	})
end

-- ─── Dragging utility ──────────────────────────────────────────────────────────
local function MakeDraggable(handle, frame)
	local dragging, dragStart, startPos = false, nil, nil
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and
		   inp.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging  = true
		dragStart = Vector2.new(inp.Position.X, inp.Position.Y)
		startPos  = frame.Position
		inp.Changed:Connect(function()
			if inp.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if not dragging then return end
		if inp.UserInputType ~= Enum.UserInputType.MouseMovement and
		   inp.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = Vector2.new(inp.Position.X, inp.Position.Y) - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Library
-- ═══════════════════════════════════════════════════════════════════════════════
local Library = {
	Flags    = {},
	_windows = {},
}

-- ─── Screen ────────────────────────────────────────────────────────────────────
local Screen = New("ScreenGui", {
	Name            = "CloudyUI",
	ResetOnSpawn    = false,
	ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset  = true,
	DisplayOrder    = 10,
})
do
	local ok = pcall(function() Screen.Parent = CoreGui end)
	if not ok then Screen.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end
Library.Screen = Screen

-- popup close helper
local function ClosePopups()
	for _, c in ipairs(Screen:GetChildren()) do
		if c:IsA("Frame") and (c.Name == "Popup" or c.Name == "ColorPopup") then
			c.Visible = false
		end
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CreateWindow
-- ═══════════════════════════════════════════════════════════════════════════════
function Library:CreateWindow(options)
	options = options or {}
	local title   = options.Title   or "Cloudy"
	local size    = options.Size    or UDim2.new(0, 520, 0, 480)
	local pos     = options.Position or UDim2.new(0.5, -260, 0.5, -240)

	-- ── outer frame ──────────────────────────────────────────────────────────
	local Win = New("Frame", {
		Name            = "Window",
		Size            = size,
		Position        = pos,
		BackgroundColor3= C.BG,
		BorderSizePixel = 0,
		ZIndex          = 2,
		Parent          = Screen,
	})
	Corner(Win, 8)
	Stroke(Win, C.Stroke)

	New("UIGradient", {
		Rotation = 135,
		Color    = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 32)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15)),
		}),
		Parent = Win,
	})

	-- ── topbar ───────────────────────────────────────────────────────────────
	local Topbar = New("Frame", {
		Name            = "Topbar",
		Size            = UDim2.new(1, 0, 0, 36),
		BackgroundColor3= C.SurfaceAlt,
		BorderSizePixel = 0,
		ZIndex          = 3,
		Parent          = Win,
	})
	Corner(Topbar, 8)
	-- hide bottom corners
	New("Frame", {
		Size            = UDim2.new(1, 0, 0, 8),
		Position        = UDim2.new(0, 0, 1, -8),
		BackgroundColor3= C.SurfaceAlt,
		BorderSizePixel = 0,
		ZIndex          = 3,
		Parent          = Topbar,
	})

	New("UIGradient", {
		Rotation = 90,
		Color    = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 26)),
		}),
		Parent = Topbar,
	})

	local TitleLabel = New("TextLabel", {
		Name            = "Title",
		Text            = title,
		Size            = UDim2.new(1, -80, 1, 0),
		Position        = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Font            = Enum.Font.GothamBold,
		TextSize        = 14,
		TextColor3      = C.Text,
		TextXAlignment  = Enum.TextXAlignment.Left,
		ZIndex          = 4,
		Parent          = Topbar,
	})

	-- close button
	local CloseBtn = New("TextButton", {
		Name            = "Close",
		Text            = "✕",
		Size            = UDim2.new(0, 28, 0, 20),
		Position        = UDim2.new(1, -34, 0.5, -10),
		BackgroundColor3= Color3.fromRGB(180, 60, 60),
		Font            = Enum.Font.GothamBold,
		TextSize        = 12,
		TextColor3      = C.White,
		ZIndex          = 5,
		Parent          = Topbar,
	})
	Corner(CloseBtn, 4)
	CloseBtn.MouseButton1Click:Connect(function() Win.Visible = not Win.Visible end)

	-- minimize
	local MinBtn = New("TextButton", {
		Name            = "Min",
		Text            = "─",
		Size            = UDim2.new(0, 28, 0, 20),
		Position        = UDim2.new(1, -68, 0.5, -10),
		BackgroundColor3= C.SurfaceAlt,
		Font            = Enum.Font.GothamBold,
		TextSize        = 12,
		TextColor3      = C.SubText,
		ZIndex          = 5,
		Parent          = Topbar,
	})
	Corner(MinBtn, 4)
	Stroke(MinBtn, C.Stroke)

	-- ── tab button bar ────────────────────────────────────────────────────────
	local TabBar = New("ScrollingFrame", {
		Name                 = "TabBar",
		Size                 = UDim2.new(1, -20, 0, 28),
		Position             = UDim2.new(0, 10, 0, 38),
		BackgroundTransparency = 1,
		BorderSizePixel      = 0,
		ScrollingDirection   = Enum.ScrollingDirection.X,
		CanvasSize           = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness   = 0,
		ZIndex               = 3,
		Parent               = Win,
	})
	ListLayout(TabBar, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 6)

	-- ── tab content area ──────────────────────────────────────────────────────
	local TabArea = New("Frame", {
		Name            = "TabArea",
		Size            = UDim2.new(1, -20, 1, -80),
		Position        = UDim2.new(0, 10, 0, 72),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex          = 2,
		Parent          = Win,
	})

	MakeDraggable(Topbar, Win)

	-- minimise logic
	local minimized = false
	local fullSize  = size
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		Tween(Win, { Size = minimized and UDim2.new(0, size.X.Offset, 0, 36) or fullSize })
		TabBar.Visible = not minimized
		TabArea.Visible = not minimized
	end)

	-- ── Window object ─────────────────────────────────────────────────────────
	local Window = { _tabs = {}, _activeTab = nil }

	function Window:CreateTab(name)
		name = name or "Tab"

		-- button
		local isFirst = #self._tabs == 0

		local Btn = New("TextButton", {
			Name            = name,
			Text            = name,
			Size            = UDim2.new(0, 0, 1, 0),
			AutomaticSize   = Enum.AutomaticSize.X,
			BackgroundColor3= isFirst and C.Accent or C.Surface,
			Font            = Enum.Font.GothamSemibold,
			TextSize        = 12,
			TextColor3      = isFirst and C.White or C.SubText,
			ZIndex          = 4,
			Parent          = TabBar,
		})
		Corner(Btn, 5)
		if not isFirst then Stroke(Btn, C.Stroke) end
		Pad(Btn, 0, 0, 10, 10)

		-- page (scrolling frame)
		local Page = New("ScrollingFrame", {
			Name                 = name .. "Page",
			Size                 = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel      = 0,
			ScrollingDirection   = Enum.ScrollingDirection.Y,
			CanvasSize           = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness   = 3,
			ScrollBarImageColor3 = C.Stroke,
			Visible              = isFirst,
			ZIndex               = 2,
			Parent               = TabArea,
		})
		ListLayout(Page, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, 10)
		Pad(Page, 6, 10, 0, 0)

		-- auto-resize canvas
		Page:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() end)
		local ll = Page:FindFirstChildOfClass("UIListLayout")
		ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 16)
		end)

		local Tab = { _page = Page, _sections = {} }

		-- tab switch
		Btn.MouseButton1Click:Connect(function()
			ClosePopups()
			for _, t in ipairs(Window._tabs) do
				t._page.Visible = false
				t._btn.BackgroundColor3 = C.Surface
				t._btn.TextColor3       = C.SubText
			end
			Page.Visible          = true
			Btn.BackgroundColor3  = C.Accent
			Btn.TextColor3        = C.White
			Window._activeTab = Tab
		end)

		Tab._btn = Btn
		table.insert(Window._tabs, Tab)
		if isFirst then Window._activeTab = Tab end

		-- ── Section ───────────────────────────────────────────────────────────
		function Tab:CreateSection(sectionTitle)
			sectionTitle = sectionTitle or ""

			local Card = New("Frame", {
				Name            = "Section",
				Size            = UDim2.new(1, 0, 0, 0),
				AutomaticSize   = Enum.AutomaticSize.Y,
				BackgroundColor3= C.Surface,
				BorderSizePixel = 0,
				ZIndex          = 3,
				Parent          = Page,
			})
			Corner(Card, 7)
			Stroke(Card, C.Stroke)

			local Inner = New("Frame", {
				Name            = "Inner",
				Size            = UDim2.new(1, 0, 0, 0),
				AutomaticSize   = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex          = 3,
				Parent          = Card,
			})
			ListLayout(Inner, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, 8)
			Pad(Inner, 10, 10, 10, 10)

			if sectionTitle ~= "" then
				local Header = New("TextLabel", {
					Name            = "SectionHeader",
					Text            = sectionTitle:upper(),
					Size            = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					Font            = Enum.Font.GothamBold,
					TextSize        = 11,
					TextColor3      = C.Accent,
					TextXAlignment  = Enum.TextXAlignment.Left,
					ZIndex          = 4,
					LayoutOrder     = -999,
					Parent          = Inner,
				})
			end

			local Section = {}

			-- helper: row frame
			local function Row(h)
				return New("Frame", {
					Size            = UDim2.new(1, 0, 0, h or 28),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex          = 4,
					Parent          = Inner,
				})
			end

			local function RowLabel(parent, text, xalign)
				return New("TextLabel", {
					Size            = UDim2.new(0.55, 0, 1, 0),
					BackgroundTransparency = 1,
					Font            = Enum.Font.Gotham,
					TextSize        = 13,
					TextColor3      = C.Text,
					TextXAlignment  = xalign or Enum.TextXAlignment.Left,
					Text            = text,
					ZIndex          = 5,
					Parent          = parent,
				})
			end

			-- ── Divider ───────────────────────────────────────────────────────
			function Section:AddDivider()
				local R = Row(1)
				R.Size = UDim2.new(1, 0, 0, 1)
				R.BackgroundColor3 = C.Stroke
				R.BackgroundTransparency = 0
				return R
			end

			-- ── Label ─────────────────────────────────────────────────────────
			function Section:AddLabel(opts)
				opts = opts or {}
				local R = Row(22)
				local lbl = New("TextLabel", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Font            = Enum.Font.Gotham,
					TextSize        = 13,
					TextColor3      = C.SubText,
					TextXAlignment  = Enum.TextXAlignment.Left,
					TextWrapped     = true,
					RichText        = true,
					Text            = opts.Text or "Label",
					ZIndex          = 5,
					Parent          = R,
				})
				local obj = {}
				function obj:SetText(t) lbl.Text = t end
				return obj
			end

			-- ── Button ────────────────────────────────────────────────────────
			function Section:AddButton(opts)
				opts = opts or {}
				local R = Row(30)
				local Btn = New("TextButton", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundColor3= C.SurfaceAlt,
					Font            = Enum.Font.GothamSemibold,
					TextSize        = 13,
					TextColor3      = C.Text,
					Text            = opts.Title or "Button",
					ZIndex          = 5,
					Parent          = R,
				})
				Corner(Btn, 5)
				Stroke(Btn, C.Stroke)

				Btn.MouseEnter:Connect(function()
					Tween(Btn, { BackgroundColor3 = C.Accent })
					Tween(Btn, { TextColor3 = C.White })
				end)
				Btn.MouseLeave:Connect(function()
					Tween(Btn, { BackgroundColor3 = C.SurfaceAlt })
					Tween(Btn, { TextColor3 = C.Text })
				end)
				Btn.MouseButton1Click:Connect(function()
					if opts.Callback then opts.Callback() end
				end)

				local obj = {}
				function obj:SetTitle(t) Btn.Text = t end
				return obj
			end

			-- ── Toggle ────────────────────────────────────────────────────────
			function Section:AddToggle(opts)
				opts = opts or {}
				local flag    = opts.Flag
				local value   = opts.Value or false
				local cb      = opts.Callback

				local R = Row(28)

				RowLabel(R, opts.Title or "Toggle")

				local Track = New("Frame", {
					Size            = UDim2.new(0, 44, 0, 22),
					Position        = UDim2.new(1, -46, 0.5, -11),
					BackgroundColor3= value and C.Accent or C.SurfaceAlt,
					BorderSizePixel = 0,
					ZIndex          = 5,
					Parent          = R,
				})
				Corner(Track, 11)
				Stroke(Track, C.Stroke)

				local Knob = New("Frame", {
					Size            = UDim2.new(0, 16, 0, 16),
					Position        = value and UDim2.new(0, 24, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
					BackgroundColor3= C.White,
					BorderSizePixel = 0,
					ZIndex          = 6,
					Parent          = Track,
				})
				Corner(Knob, 8)

				local Btn = New("TextButton", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text            = "",
					ZIndex          = 7,
					Parent          = Track,
				})

				local function SetValue(v)
					value = v
					if flag then Library.Flags[flag] = v end
					Tween(Track, { BackgroundColor3 = v and C.Accent or C.SurfaceAlt })
					Tween(Knob,  { Position = v and UDim2.new(0, 24, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
					if cb then cb(v) end
				end

				if flag then Library.Flags[flag] = value end
				Btn.MouseButton1Click:Connect(function() SetValue(not value) end)

				local obj = { Value = value }
				function obj:SetValue(v) SetValue(v) end
				function obj:GetValue() return value end
				return obj
			end

			-- ── Slider ────────────────────────────────────────────────────────
			function Section:AddSlider(opts)
				opts  = opts or {}
				local flag  = opts.Flag
				local min   = opts.Min   or 0
				local max   = opts.Max   or 100
				local step  = opts.Step  or 1
				local value = math.clamp(opts.Value or min, min, max)
				local cb    = opts.Callback

				local R = Row(38)

				local TopRow = New("Frame", {
					Size            = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					ZIndex          = 5,
					Parent          = R,
				})
				RowLabel(TopRow, opts.Title or "Slider")
				local ValLabel = New("TextLabel", {
					Size            = UDim2.new(0.45, 0, 1, 0),
					Position        = UDim2.new(0.55, 0, 0, 0),
					BackgroundTransparency = 1,
					Font            = Enum.Font.GothamSemibold,
					TextSize        = 12,
					TextColor3      = C.Accent,
					TextXAlignment  = Enum.TextXAlignment.Right,
					Text            = tostring(value),
					ZIndex          = 5,
					Parent          = TopRow,
				})

				local Track = New("Frame", {
					Size            = UDim2.new(1, 0, 0, 8),
					Position        = UDim2.new(0, 0, 0, 22),
					BackgroundColor3= C.SurfaceAlt,
					BorderSizePixel = 0,
					ZIndex          = 5,
					Parent          = R,
				})
				Corner(Track, 4)
				Stroke(Track, C.Stroke)

				local Fill = New("Frame", {
					Size            = UDim2.new((value - min) / (max - min), 0, 1, 0),
					BackgroundColor3= C.Accent,
					BorderSizePixel = 0,
					ZIndex          = 6,
					Parent          = Track,
				})
				Corner(Fill, 4)

				local Btn = New("TextButton", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text            = "",
					ZIndex          = 7,
					Parent          = Track,
				})

				local function SetValue(v)
					v = math.clamp(math.round(v / step) * step, min, max)
					value = v
					if flag then Library.Flags[flag] = v end
					ValLabel.Text = tostring(v)
					local pct = (v - min) / (max - min)
					Tween(Fill, { Size = UDim2.new(pct, 0, 1, 0) })
					if cb then cb(v) end
				end

				if flag then Library.Flags[flag] = value end

				local sliding = false
				Btn.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or
					   inp.UserInputType == Enum.UserInputType.Touch then
						sliding = true
					end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or
					   inp.UserInputType == Enum.UserInputType.Touch then
						sliding = false
					end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if not sliding then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseMovement and
					   inp.UserInputType ~= Enum.UserInputType.Touch then return end
					local rel  = (inp.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
					SetValue(min + rel * (max - min))
				end)

				local obj = { Value = value }
				function obj:SetValue(v) SetValue(v) end
				function obj:GetValue() return value end
				return obj
			end

			-- ── Textbox ───────────────────────────────────────────────────────
			function Section:AddTextbox(opts)
				opts = opts or {}
				local flag  = opts.Flag
				local value = opts.Value or ""
				local cb    = opts.Callback

				local R = Row(28)
				RowLabel(R, opts.Title or "Textbox")

				local Box = New("TextBox", {
					Size            = UDim2.new(0.45, 0, 1, 0),
					Position        = UDim2.new(0.55, 0, 0, 0),
					BackgroundColor3= C.SurfaceAlt,
					Font            = Enum.Font.Gotham,
					TextSize        = 12,
					TextColor3      = C.Text,
					PlaceholderText = opts.Placeholder or "...",
					PlaceholderColor3 = C.SubText,
					Text            = value,
					ClearTextOnFocus= opts.ClearOnFocus ~= false,
					ZIndex          = 5,
					Parent          = R,
				})
				Corner(Box, 5)
				Stroke(Box, C.Stroke)
				Pad(Box, 0, 0, 6, 6)

				Box.FocusLost:Connect(function(enter)
					value = Box.Text
					if flag then Library.Flags[flag] = value end
					if cb then cb(value, enter) end
				end)

				if flag then Library.Flags[flag] = value end

				local obj = { Value = value }
				function obj:SetValue(v) Box.Text = v; value = v end
				function obj:GetValue() return value end
				return obj
			end

			-- ── Keybind ───────────────────────────────────────────────────────
			function Section:AddKeybind(opts)
				opts  = opts or {}
				local flag    = opts.Flag
				local default = opts.Default or Enum.KeyCode.Unknown
				local value   = default
				local cb      = opts.Callback
				local listening = false

				local R = Row(28)
				RowLabel(R, opts.Title or "Keybind")

				local Btn = New("TextButton", {
					Size            = UDim2.new(0.45, 0, 1, 0),
					Position        = UDim2.new(0.55, 0, 0, 0),
					BackgroundColor3= C.SurfaceAlt,
					Font            = Enum.Font.GothamSemibold,
					TextSize        = 12,
					TextColor3      = C.SubText,
					Text            = value == Enum.KeyCode.Unknown and "[ NONE ]" or ("[ " .. value.Name .. " ]"),
					ZIndex          = 5,
					Parent          = R,
				})
				Corner(Btn, 5)
				Stroke(Btn, C.Stroke)

				if flag then Library.Flags[flag] = value end

				Btn.MouseButton1Click:Connect(function()
					listening = true
					Btn.Text  = "[ ... ]"
					Btn.TextColor3 = C.Accent
				end)

				UserInputService.InputBegan:Connect(function(inp, gp)
					if not listening then
						-- trigger callback on key press
						if inp.KeyCode == value and cb then cb() end
						return
					end
					if gp then return end
					if inp.UserInputType == Enum.UserInputType.Keyboard then
						value = inp.KeyCode
						if flag then Library.Flags[flag] = value end
						Btn.Text = "[ " .. value.Name .. " ]"
						Btn.TextColor3 = C.SubText
						listening = false
					end
				end)

				local obj = { Value = value }
				function obj:GetValue() return value end
				return obj
			end

			-- ── Dropdown ──────────────────────────────────────────────────────
			function Section:AddDropdown(opts)
				opts  = opts or {}
				local flag   = opts.Flag
				local items  = opts.Options or {}
				local value  = opts.Value or (items[1] or "")
				local multi  = opts.Multi or false
				local cb     = opts.Callback
				local selected = multi and {} or value

				local R = Row(28)
				RowLabel(R, opts.Title or "Dropdown")

				local BtnFrame = New("Frame", {
					Size            = UDim2.new(0.45, 0, 1, 0),
					Position        = UDim2.new(0.55, 0, 0, 0),
					BackgroundTransparency = 1,
					ZIndex          = 5,
					Parent          = R,
				})

				local Btn = New("TextButton", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundColor3= C.SurfaceAlt,
					Font            = Enum.Font.Gotham,
					TextSize        = 12,
					TextColor3      = C.Text,
					Text            = (multi and "Select..." or tostring(value)) .. "  ▾",
					TextTruncate    = Enum.TextTruncate.AtEnd,
					ZIndex          = 6,
					Parent          = BtnFrame,
				})
				Corner(Btn, 5)
				Stroke(Btn, C.Stroke)
				Pad(Btn, 0, 0, 6, 6)

				-- popup
				local Popup = New("Frame", {
					Name            = "Popup",
					Size            = UDim2.new(0, 0, 0, 0),
					AutomaticSize   = Enum.AutomaticSize.XY,
					BackgroundColor3= C.Surface,
					BorderSizePixel = 0,
					Visible         = false,
					ZIndex          = 20,
					Parent          = Screen,
				})
				Corner(Popup, 6)
				Stroke(Popup, C.Stroke)
				Pad(Popup, 4, 4, 4, 4)

				local PopList = New("Frame", {
					Size            = UDim2.new(0, 160, 0, 0),
					AutomaticSize   = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					ZIndex          = 21,
					Parent          = Popup,
				})
				ListLayout(PopList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3)

				local function UpdateLabel()
					if multi then
						local parts = {}
						for k in pairs(selected) do table.insert(parts, k) end
						Btn.Text = (#parts == 0 and "None" or table.concat(parts, ", ")) .. "  ▾"
					else
						Btn.Text = tostring(value) .. "  ▾"
					end
				end

				local function SetValue(v)
					if multi then
						selected[v] = not selected[v] or nil
						if flag then Library.Flags[flag] = selected end
						if cb then cb(selected) end
					else
						value = v
						if flag then Library.Flags[flag] = v end
						if cb then cb(v) end
					end
					UpdateLabel()
				end

				for _, item in ipairs(items) do
					local Item = New("TextButton", {
						Size            = UDim2.new(1, 0, 0, 24),
						BackgroundColor3= C.SurfaceAlt,
						Font            = Enum.Font.Gotham,
						TextSize        = 12,
						TextColor3      = C.Text,
						Text            = "  " .. tostring(item),
						TextXAlignment  = Enum.TextXAlignment.Left,
						ZIndex          = 22,
						Parent          = PopList,
					})
					Corner(Item, 4)
					Item.MouseEnter:Connect(function() Tween(Item, { BackgroundColor3 = C.AccentDim }) end)
					Item.MouseLeave:Connect(function() Tween(Item, { BackgroundColor3 = C.SurfaceAlt }) end)
					Item.MouseButton1Click:Connect(function()
						SetValue(item)
						if not multi then Popup.Visible = false end
					end)
				end

				if flag then Library.Flags[flag] = multi and selected or value end

				Btn.MouseButton1Click:Connect(function()
					ClosePopups()
					local abs = Btn.AbsolutePosition
					local sz  = Btn.AbsoluteSize
					Popup.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 4)
					Popup.Visible  = true
				end)

				local obj = {}
				function obj:SetValue(v) SetValue(v) end
				function obj:GetValue() return multi and selected or value end
				function obj:SetOptions(newItems)
					items = newItems
					for _, c in ipairs(PopList:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, item in ipairs(items) do
						local Item = New("TextButton", {
							Size            = UDim2.new(1, 0, 0, 24),
							BackgroundColor3= C.SurfaceAlt,
							Font            = Enum.Font.Gotham,
							TextSize        = 12,
							TextColor3      = C.Text,
							Text            = "  " .. tostring(item),
							TextXAlignment  = Enum.TextXAlignment.Left,
							ZIndex          = 22,
							Parent          = PopList,
						})
						Corner(Item, 4)
						Item.MouseEnter:Connect(function() Tween(Item, { BackgroundColor3 = C.AccentDim }) end)
						Item.MouseLeave:Connect(function() Tween(Item, { BackgroundColor3 = C.SurfaceAlt }) end)
						Item.MouseButton1Click:Connect(function()
							SetValue(item)
							if not multi then Popup.Visible = false end
						end)
					end
				end
				return obj
			end

			-- ── Colorpicker ───────────────────────────────────────────────────
			function Section:AddColorpicker(opts)
				opts  = opts or {}
				local flag   = opts.Flag
				local value  = opts.Value or Color3.fromRGB(255, 100, 100)
				local cb     = opts.Callback

				local R = Row(28)
				RowLabel(R, opts.Title or "Color")

				local Preview = New("TextButton", {
					Size            = UDim2.new(0, 28, 0, 20),
					Position        = UDim2.new(1, -30, 0.5, -10),
					BackgroundColor3= value,
					Text            = "",
					ZIndex          = 5,
					Parent          = R,
				})
				Corner(Preview, 4)
				Stroke(Preview, C.Stroke)

				if flag then Library.Flags[flag] = value end

				-- ── colour popup ────────────────────────────────────────────
				local Palette = New("Frame", {
					Name            = "ColorPopup",
					Size            = UDim2.new(0, 210, 0, 0),
					AutomaticSize   = Enum.AutomaticSize.Y,
					BackgroundColor3= C.Surface,
					BorderSizePixel = 0,
					Visible         = false,
					ZIndex          = 20,
					Parent          = Screen,
				})
				Corner(Palette, 8)
				Stroke(Palette, C.Stroke)
				Pad(Palette, 10, 10, 10, 10)

				local PalInner = New("Frame", {
					Size            = UDim2.new(1, 0, 0, 0),
					AutomaticSize   = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					ZIndex          = 21,
					Parent          = Palette,
				})
				ListLayout(PalInner, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, 8)

				-- saturation/value picker
				local h, s, v2 = Color3.toHSV(value)

				local SVBox = New("ImageLabel", {
					Size            = UDim2.new(1, 0, 0, 130),
					BackgroundColor3= Color3.fromHSV(h, 1, 1),
					BorderSizePixel = 0,
					Image           = "rbxassetid://6401156199", -- white->transparent gradient
					ZIndex          = 22,
					Parent          = PalInner,
				})
				Corner(SVBox, 5)

				-- white left-to-right
				New("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Parent = SVBox,
				})

				local SVOverlay = New("Frame", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex          = 23,
					Parent          = SVBox,
				})
				New("UIGradient", {
					Rotation = 90,
					Color    = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Parent = SVOverlay,
				})

				local SVCursor = New("Frame", {
					Size            = UDim2.new(0, 10, 0, 10),
					AnchorPoint     = Vector2.new(0.5, 0.5),
					Position        = UDim2.new(s, 0, 1 - v2, 0),
					BackgroundColor3= Color3.fromRGB(255,255,255),
					BorderSizePixel = 0,
					ZIndex          = 24,
					Parent          = SVBox,
				})
				Corner(SVCursor, 5)

				-- hue bar
				local HueBar = New("Frame", {
					Size            = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex          = 22,
					Parent          = PalInner,
				})
				Corner(HueBar, 4)

				local HueBg = New("Frame", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundColor3= Color3.fromRGB(255,0,0),
					BorderSizePixel = 0,
					ZIndex          = 22,
					Parent          = HueBar,
				})
				Corner(HueBg, 4)
				New("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,0,0)),
						ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255,255,0)),
						ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0,255,0)),
						ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0,255,255)),
						ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0,0,255)),
						ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,0,255)),
						ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,0,0)),
					}),
					Parent = HueBg,
				})

				local HueCursor = New("Frame", {
					Size            = UDim2.new(0, 4, 1, 0),
					Position        = UDim2.new(h, -2, 0, 0),
					BackgroundColor3= C.White,
					BorderSizePixel = 0,
					ZIndex          = 24,
					Parent          = HueBar,
				})
				Corner(HueCursor, 2)

				-- rgb display
				local RGBLabel = New("TextLabel", {
					Size            = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					Font            = Enum.Font.GothamSemibold,
					TextSize        = 11,
					TextColor3      = C.SubText,
					Text            = ("RGB: %d, %d, %d"):format(value.R*255, value.G*255, value.B*255),
					ZIndex          = 22,
					Parent          = PalInner,
				})

				local function UpdateColor()
					local col = Color3.fromHSV(h, s, v2)
					value = col
					Preview.BackgroundColor3 = col
					SVBox.BackgroundColor3   = Color3.fromHSV(h, 1, 1)
					SVCursor.Position        = UDim2.new(s, 0, 1 - v2, 0)
					HueCursor.Position       = UDim2.new(h, -2, 0, 0)
					RGBLabel.Text = ("RGB: %d, %d, %d"):format(col.R*255, col.G*255, col.B*255)
					if flag then Library.Flags[flag] = col end
					if cb then cb(col) end
				end

				-- SV dragging
				local svDragging = false
				local svBtn = New("TextButton", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text            = "",
					ZIndex          = 25,
					Parent          = SVBox,
				})
				svBtn.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = true end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if not svDragging then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
					local relX = math.clamp((inp.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
					local relY = math.clamp((inp.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
					s  = relX
					v2 = 1 - relY
					UpdateColor()
				end)

				-- Hue dragging
				local hueDragging = false
				local hueBtn = New("TextButton", {
					Size            = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text            = "",
					ZIndex          = 25,
					Parent          = HueBar,
				})
				hueBtn.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if not hueDragging then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
					h = math.clamp((inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
					UpdateColor()
				end)

				if flag then Library.Flags[flag] = value end

				Preview.MouseButton1Click:Connect(function()
					ClosePopups()
					local abs = Preview.AbsolutePosition
					local sz  = Preview.AbsoluteSize
					Palette.Position = UDim2.new(0, abs.X - 90, 0, abs.Y + sz.Y + 6)
					Palette.Visible  = true
				end)

				local obj = { Value = value }
				function obj:SetValue(col)
					value = col
					h, s, v2 = Color3.toHSV(col)
					UpdateColor()
				end
				function obj:GetValue() return value end
				return obj
			end

			return Section
		end -- CreateSection

		return Tab
	end -- CreateTab

	table.insert(Library._windows, Window)
	return Window
end -- CreateWindow

-- close all popups when clicking elsewhere
UserInputService.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		-- small delay so popup buttons fire first
		task.defer(function()
			-- only close if click wasn't on a popup child
			ClosePopups()
		end)
	end
end)

return Library
