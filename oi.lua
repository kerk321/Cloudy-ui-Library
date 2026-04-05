local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local Theme = {
	Shadow = Color3.fromRGB(8, 10, 14),
	Text = Color3.fromRGB(242, 245, 249),
	Border = Color3.fromRGB(57, 65, 79),
	Inline = Color3.fromRGB(24, 27, 33),
	Image = Color3.fromRGB(248, 248, 250),
	DarkGradient = Color3.fromRGB(15, 17, 21),
	InactiveText = Color3.fromRGB(154, 163, 176),
	Background = Color3.fromRGB(29, 32, 37),
	Element = Color3.fromRGB(66, 75, 92),
	Accent = Color3.fromRGB(35, 127, 237),
	AccentMuted = Color3.fromRGB(44, 51, 63),
	Card = Color3.fromRGB(31, 35, 41)
}

local Fonts = {
	Header = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	Semi = Enum.Font.GothamSemibold
}

local function protectGui(gui)
	if gethui then
		gui.Parent = gethui()
		return
	end

	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		end
	end)

	gui.Parent = CoreGui
end

local function create(className, props)
	local instance = Instance.new(className)
	for key, value in pairs(props or {}) do
		local isStructuredPadding = key == "Padding" and typeof(value) == "table"
		if key ~= "Children" and key ~= "Corner" and key ~= "Stroke" and key ~= "Gradient" and not isStructuredPadding then
			instance[key] = value
		end
	end

	if props then
		if props.Corner then
			local corner = Instance.new("UICorner")
			corner.CornerRadius = props.Corner
			corner.Parent = instance
		end

		if props.Stroke then
			local stroke = Instance.new("UIStroke")
			for key, value in pairs(props.Stroke) do
				stroke[key] = value
			end
			stroke.Parent = instance
		end

		if typeof(props.Padding) == "table" then
			local padding = Instance.new("UIPadding")
			for key, value in pairs(props.Padding) do
				padding[key] = value
			end
			padding.Parent = instance
		end

		if props.Gradient then
			local gradient = Instance.new("UIGradient")
			for key, value in pairs(props.Gradient) do
				gradient[key] = value
			end
			gradient.Parent = instance
		end

		for _, child in ipairs(props.Children or {}) do
			child.Parent = instance
		end
	end

	return instance
end

local function animate(object, goal)
	TweenService:Create(object, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

local function pointInObject(guiObject, point)
	if not guiObject or not guiObject.Visible then
		return false
	end

	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize
	return point.X >= position.X and point.X <= position.X + size.X and point.Y >= position.Y and point.Y <= position.Y + size.Y
end

local function makeDrag(handle, target)
	local dragging = false
	local dragStart
	local startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)
end

local function isPhone()
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1280, 720)
	return UserInputService.TouchEnabled and (size.X < 760 or size.Y < 760)
end

local function isTablet()
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1280, 720)
	return UserInputService.TouchEnabled and not isPhone() and (size.X < 1100 or size.Y < 900)
end

local function getWindowMetrics()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)

	if isPhone() then
		local width = math.clamp(viewport.X - 18, 290, 356)
		local height = math.clamp(viewport.Y - 110, 330, 470)
		return UDim2.fromOffset(width, height), UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	end

	if isTablet() then
		local width = math.clamp(math.floor(viewport.X * 0.58), 430, 540)
		local height = math.clamp(math.floor(viewport.Y * 0.64), 390, 520)
		return UDim2.fromOffset(width, height), UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	end

	local width = math.clamp(math.floor(viewport.X * 0.42), 520, 700)
	local height = math.clamp(math.floor(viewport.Y * 0.64), 410, 540)
	return UDim2.fromOffset(width, height), UDim2.new(0.5, -width / 2, 0.5, -height / 2)
end

local function makeText(text, size, color, font)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, size + 4),
		Font = font or Fonts.Body,
		Text = text,
		TextColor3 = color or Theme.Text,
		TextSize = size,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y
	})
end

local function rgbText(color)
	return string.format("%d, %d, %d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end

local function applyCanvas(scroll, layout, extra)
	local function update()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 0))
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end

local function makeBaseButton(text, height)
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or 36),
		Font = Fonts.Semi,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Corner = UDim.new(0, 7),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.15,
			Thickness = 1
		}
	})

	button.MouseEnter:Connect(function()
		animate(button, {BackgroundColor3 = Color3.fromRGB(76, 86, 104)})
	end)

	button.MouseLeave:Connect(function()
		animate(button, {BackgroundColor3 = Theme.Element})
	end)

	return button
end

local function createPopupCard(parent)
	return create("Frame", {
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Visible = false,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Corner = UDim.new(0, 8),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.08,
			Thickness = 1
		},
		Padding = {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}
	})
end

local function buildColorPicker(window, holder, trigger, initialColor, callback)
	local popup = createPopupCard(holder)
	popup.Position = UDim2.fromOffset(0, 60)

	local topRow = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 18)
	})

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -70, 1, 0),
		Font = Fonts.Semi,
		Text = "color picker",
		TextColor3 = Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local rgbValue = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -76, 0, 0),
		Size = UDim2.fromOffset(76, 18),
		Font = Fonts.Body,
		Text = "",
		TextColor3 = Theme.InactiveText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right
	})

	local satVal = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 92),
		Corner = UDim.new(0, 7),
		ClipsDescendants = true
	})

	local whiteOverlay = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Gradient = {
			Rotation = 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
		}
	})

	local blackOverlay = create("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Gradient = {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0)
			})
		}
	})

	local satValCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(10, 10),
		Corner = UDim.new(1, 0),
		Stroke = {
			Color = Color3.new(0, 0, 0),
			Transparency = 0,
			Thickness = 1
		}
	})

	local hueBar = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 12),
		Corner = UDim.new(1, 0),
		ClipsDescendants = true,
		Gradient = {
			Rotation = 0,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 85, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
			})
		}
	})

	local hueCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(8, 16),
		Corner = UDim.new(1, 0),
		Stroke = {
			Color = Color3.new(0, 0, 0),
			Transparency = 0,
			Thickness = 1
		}
	})

	local info = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Fonts.Body,
		Text = "tap or drag to change the color",
		TextColor3 = Theme.InactiveText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local popupLayout = create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	topRow.Parent = popup
	title.Parent = topRow
	rgbValue.Parent = topRow
	satVal.Parent = popup
	whiteOverlay.Parent = satVal
	blackOverlay.Parent = satVal
	satValCursor.Parent = satVal
	hueBar.Parent = popup
	hueCursor.Parent = hueBar
	info.Parent = popup
	popupLayout.Parent = popup

	local hue, saturation, value = initialColor:ToHSV()
	local satDragging = false
	local hueDragging = false

	local function currentColor()
		return Color3.fromHSV(hue, saturation, value)
	end

	local function pushColor(silent)
		local color = currentColor()
		satVal.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		rgbValue.Text = rgbText(color)
		hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
		satValCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
		if trigger then
			trigger.BackgroundColor3 = color
		end
		if callback and not silent then
			callback(color)
		end
	end

	local function updateSV(input)
		local x = math.clamp((input.Position.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
		local y = math.clamp((input.Position.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
		saturation = x
		value = 1 - y
		pushColor(false)
	end

	local function updateHue(input)
		hue = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
		pushColor(false)
	end

	satVal.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			satDragging = true
			updateSV(input)
		end
	end)

	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			hueDragging = true
			updateHue(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if satDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSV(input)
		elseif hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateHue(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			satDragging = false
			hueDragging = false
		end
	end)

	pushColor(true)

	return popup, function(color, silent)
		hue, saturation, value = color:ToHSV()
		pushColor(silent)
	end, function()
		return currentColor()
	end
end

function Library:SetTheme(colors)
	for key, value in pairs(colors or {}) do
		if Theme[key] ~= nil then
			Theme[key] = value
		end
	end
	return self
end

function Library:CreateWindow(options)
	options = options or {}

	local screenGui = create("ScreenGui", {
		Name = options.Name or "KiwiSenseUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	protectGui(screenGui)

	local shellSize, shellPosition = getWindowMetrics()

	local shadow = create("ImageLabel", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Theme.Shadow,
		ImageTransparency = 0.36,
		Position = shellPosition,
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.new(0, shellSize.X.Offset + 48, 0, shellSize.Y.Offset + 48),
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = 0
	})

	local shell = create("Frame", {
		Name = "Shell",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = shellPosition,
		Size = shellSize,
		Corner = UDim.new(0, 12),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.06,
			Thickness = 1.1
		},
		Gradient = {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 34, 40)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 20, 24))
			})
		}
	})

	local header = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 74)
	})

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.new(0, 160, 0, 20),
		Font = Fonts.Header,
		Text = options.Title or "kiwisense",
		TextColor3 = Theme.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local version = create("TextLabel", {
		BackgroundColor3 = Theme.Inline,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(101, 13),
		Size = UDim2.fromOffset(40, 16),
		Font = Fonts.Semi,
		Text = options.Version or "v2.1",
		TextColor3 = Theme.InactiveText,
		TextSize = 10,
		Corner = UDim.new(1, 0),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.2,
			Thickness = 1
		}
	})

	local subTitle = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 33),
		Size = UDim2.new(0, 220, 0, 16),
		Font = Fonts.Body,
		Text = options.SubTitle or "compact mobile profile",
		TextColor3 = Theme.InactiveText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local closeButton = create("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(16, 16),
		Font = Fonts.Semi,
		Text = "X",
		TextColor3 = Theme.Text,
		TextSize = 14
	})

	local tabBar = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Inline,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 38),
		Size = UDim2.new(0, 248, 0, 30),
		Corner = UDim.new(1, 0),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.18,
			Thickness = 1
		},
		Padding = {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4)
		}
	})

	local tabLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center
	})

	local body = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 82),
		Size = UDim2.new(1, -24, 1, -94)
	})

	local pageContainer = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1)
	})

	local launcher = create("ImageButton", {
		Name = "FloatToggleBtn",
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxassetid://77380393395155",
		Position = UDim2.new(1, -18, 0, 18),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromOffset(46, 46),
		Visible = false,
		Corner = UDim.new(0, 10),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0,
			Thickness = 1.2
		}
	})

	shadow.Parent = screenGui
	shell.Parent = screenGui
	launcher.Parent = screenGui
	header.Parent = shell
	title.Parent = header
	version.Parent = header
	subTitle.Parent = header
	closeButton.Parent = header
	tabBar.Parent = header
	tabLayout.Parent = tabBar
	body.Parent = shell
	pageContainer.Parent = body

	makeDrag(header, shell)
	makeDrag(launcher, launcher)

	local window = {
		Gui = screenGui,
		Shell = shell,
		Shadow = shadow,
		Launcher = launcher,
		PageContainer = pageContainer,
		TabBar = tabBar,
		Tabs = {},
		ActiveTab = nil,
		OpenPopup = nil,
		PopupTrigger = nil,
		Destroyed = false
	}

	function window:SetOpen(visible)
		self.Shell.Visible = visible
		self.Shadow.Visible = visible
		self.Launcher.Visible = not visible
		if not visible and self.OpenPopup then
			self.OpenPopup.Visible = false
			self.OpenPopup = nil
			self.PopupTrigger = nil
		end
	end

	function window:TogglePopup(popup, trigger)
		if self.OpenPopup and self.OpenPopup ~= popup then
			self.OpenPopup.Visible = false
		end

		local shouldShow = not popup.Visible
		popup.Visible = shouldShow
		self.OpenPopup = shouldShow and popup or nil
		self.PopupTrigger = shouldShow and trigger or nil
	end

	function window:Destroy()
		if self.Destroyed then
			return
		end
		self.Destroyed = true
		self.Gui:Destroy()
	end

	local function relayout()
		if window.Destroyed then
			return
		end

		local newSize, newPosition = getWindowMetrics()
		shell.Size = newSize
		shell.Position = newPosition
		shadow.Position = newPosition
		shadow.Size = UDim2.new(0, newSize.X.Offset + 48, 0, newSize.Y.Offset + 48)
		tabBar.Size = isPhone() and UDim2.new(1, -150, 0, 30) or UDim2.new(0, 248, 0, 30)
		for _, tab in ipairs(window.Tabs) do
			tab:UpdateLayout()
		end
	end

	closeButton.MouseButton1Click:Connect(function()
		window:SetOpen(false)
	end)

	launcher.MouseButton1Click:Connect(function()
		window:SetOpen(true)
	end)

	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
	end

	UserInputService.InputBegan:Connect(function(input)
		if window.Destroyed or not window.OpenPopup then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local point = Vector2.new(input.Position.X, input.Position.Y)
		if pointInObject(window.OpenPopup, point) or pointInObject(window.PopupTrigger, point) then
			return
		end

		window.OpenPopup.Visible = false
		window.OpenPopup = nil
		window.PopupTrigger = nil
	end)

	function window:SetTab(tabObject)
		for _, tab in ipairs(self.Tabs) do
			local active = tab == tabObject
			tab.Button.BackgroundColor3 = active and Theme.Accent or Theme.Inline
			tab.Button.TextColor3 = active and Theme.Text or Theme.InactiveText
			tab.Icon.BackgroundColor3 = active and Theme.Text or Theme.AccentMuted
			tab.Page.Visible = active
		end
		self.ActiveTab = tabObject
	end

	function window:CreateTab(name)
		local button = create("TextButton", {
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.Inline,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(74, 22),
			Font = Fonts.Semi,
			Text = name,
			TextColor3 = Theme.InactiveText,
			TextSize = 12,
			Corner = UDim.new(1, 0),
			Padding = {
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12)
			}
		})

		local dot = create("Frame", {
			Name = "Icon",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.AccentMuted,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, 11),
			Size = UDim2.fromOffset(6, 6),
			Corner = UDim.new(1, 0)
		})

		create("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 12)
		}).Parent = button
		dot.Parent = button

		local page = create("ScrollingFrame", {
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ScrollBarImageColor3 = Theme.Accent,
			ScrollBarThickness = 4,
			Size = UDim2.fromScale(1, 1),
			Visible = false
		})

		local content = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, -4, 0, 0)
		})

		local columns = create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top
		})

		local left = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(0.5, -5, 0, 0)
		})

		local right = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(0.5, -5, 0, 0)
		})

		local leftLayout = create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local rightLayout = create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		create("UIPadding", {
			PaddingBottom = UDim.new(0, 4)
		}).Parent = content
		button.Parent = tabBar
		page.Parent = pageContainer
		content.Parent = page
		columns.Parent = content
		left.Parent = content
		right.Parent = content
		leftLayout.Parent = left
		rightLayout.Parent = right
		applyCanvas(page, columns, 22)

		local tab = {
			Window = self,
			Button = button,
			Icon = dot,
			Page = page,
			Left = left,
			Right = right
		}

		function tab:UpdateLayout()
			if isPhone() then
				columns.FillDirection = Enum.FillDirection.Vertical
				left.Size = UDim2.new(1, 0, 0, 0)
				right.Size = UDim2.new(1, 0, 0, 0)
			else
				columns.FillDirection = Enum.FillDirection.Horizontal
				left.Size = UDim2.new(0.5, -5, 0, 0)
				right.Size = UDim2.new(0.5, -5, 0, 0)
			end
		end

		function tab:CreateSection(titleText, side)
			local target = side == "Right" and self.Right or self.Left

			local section = create("Frame", {
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Corner = UDim.new(0, 8),
				Stroke = {
					Color = Theme.Border,
					Transparency = 0.1,
					Thickness = 1
				},
				Padding = {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10)
				}
			})

			local sectionTitle = makeText(titleText, 17, Theme.Text, Fonts.Semi)
			local sectionLayout = create("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			section.Parent = target
			sectionTitle.Parent = section
			sectionLayout.Parent = section

			local api = {}

			function api:AddLabel(text)
				local label = makeText(text, 13, Theme.InactiveText, Fonts.Body)
				label.Parent = section
				return label
			end

			function api:AddDivider(text)
				local holder = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 18)
				})

				local line = create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Theme.Border,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 1)
				})

				line.Parent = holder
				if text and text ~= "" then
					local label = create("TextLabel", {
						BackgroundColor3 = Theme.Card,
						BorderSizePixel = 0,
						Size = UDim2.fromOffset(120, 18),
						Font = Fonts.Semi,
						Text = text,
						TextColor3 = Theme.InactiveText,
						TextSize = 11,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					label.Parent = holder
				end

				holder.Parent = section
				return holder
			end

			function api:AddButton(config)
				config = config or {}
				local button = makeBaseButton(config.Text or "button", 36)
				button.Parent = section
				button.MouseButton1Click:Connect(function()
					if config.Callback then
						config.Callback()
					end
				end)
				return button
			end

			function api:AddTextbox(config)
				config = config or {}
				local holder = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 60)
				})

				local label = makeText(config.Text or "textbox", 13, Theme.Text, Fonts.Semi)
				label.Size = UDim2.new(1, 0, 0, 16)

				local box = create("TextBox", {
					BackgroundColor3 = Theme.Element,
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					PlaceholderColor3 = Theme.InactiveText,
					PlaceholderText = config.Placeholder or "enter text",
					Position = UDim2.fromOffset(0, 22),
					Size = UDim2.new(1, 0, 0, 34),
					Font = Fonts.Body,
					Text = config.Default or "",
					TextColor3 = Theme.Text,
					TextSize = 13,
					Corner = UDim.new(0, 7),
					Stroke = {
						Color = Theme.Border,
						Transparency = 0.15,
						Thickness = 1
					},
					Padding = {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10)
					}
				})

				label.Parent = holder
				box.Parent = holder
				holder.Parent = section

				box.FocusLost:Connect(function(enterPressed)
					if config.Callback then
						config.Callback(box.Text, enterPressed)
					end
				end)

				return box
			end

			function api:AddToggle(config)
				config = config or {}
				local state = config.Default == true
				local selectedColor = config.Color or Theme.Accent

				local holder = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0)
				})

				local button = create("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = state and selectedColor or Theme.Inline,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 38),
					Font = Fonts.Semi,
					Text = "",
					Corner = UDim.new(0, 7),
					Stroke = {
						Color = state and selectedColor:Lerp(Color3.new(1, 1, 1), 0.55) or Theme.Border,
						Transparency = 0.1,
						Thickness = 1
					}
				})

				local label = create("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -118, 1, 0),
					Font = Fonts.Semi,
					Text = config.Text or "toggle",
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local stateLabel = create("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -48, 0.5, 0),
					Size = UDim2.fromOffset(44, 18),
					Font = Fonts.Semi,
					Text = state and "on" or "off",
					TextColor3 = state and Theme.Text or Theme.InactiveText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right
				})

				local swatchButton = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					AutoButtonColor = false,
					BackgroundColor3 = selectedColor,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(22, 22),
					Text = "",
					Visible = config.AllowColor ~= false,
					Corner = UDim.new(0, 6),
					Stroke = {
						Color = Theme.Image,
						Transparency = 0.3,
						Thickness = 1
					}
				})

				label.Parent = button
				stateLabel.Parent = button
				swatchButton.Parent = button
				button.Parent = holder
				holder.Parent = section

				local colorPopup, setColorValue, getColorValue = buildColorPicker(window, holder, swatchButton, selectedColor, function(color)
					selectedColor = color
					if state then
						button.BackgroundColor3 = color
						button.UIStroke.Color = color:Lerp(Color3.new(1, 1, 1), 0.55)
					end
					if config.ColorCallback then
						config.ColorCallback(color)
					end
					if config.Callback then
						config.Callback(state, color)
					end
				end)
				colorPopup.Parent = holder

				local function refresh(silent)
					button.BackgroundColor3 = state and selectedColor or Theme.Inline
					button.UIStroke.Color = state and selectedColor:Lerp(Color3.new(1, 1, 1), 0.55) or Theme.Border
					stateLabel.Text = state and "on" or "off"
					stateLabel.TextColor3 = state and Theme.Text or Theme.InactiveText
					swatchButton.BackgroundColor3 = selectedColor
					if config.Callback and not silent then
						config.Callback(state, selectedColor)
					end
				end

				button.MouseButton1Click:Connect(function()
					state = not state
					refresh(false)
				end)

				swatchButton.MouseButton1Click:Connect(function()
					window:TogglePopup(colorPopup, swatchButton)
				end)

				refresh(true)

				return {
					Set = function(_, value)
						state = value == true
						refresh(false)
					end,
					Get = function()
						return state
					end,
					SetColor = function(_, color)
						selectedColor = color
						setColorValue(color, true)
						refresh(false)
					end,
					GetColor = function()
						return getColorValue()
					end
				}
			end

			function api:AddSlider(config)
				config = config or {}
				local min = config.Min or 0
				local max = config.Max or 100
				local value = math.clamp(config.Default or min, min, max)

				local holder = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 58)
				})

				local label = makeText(config.Text or "slider", 13, Theme.Text, Fonts.Semi)
				label.Size = UDim2.new(1, -50, 0, 16)

				local valueLabel = create("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -54, 0, 0),
					Size = UDim2.fromOffset(54, 16),
					Font = Fonts.Body,
					Text = tostring(value),
					TextColor3 = Theme.InactiveText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right
				})

				local bar = create("Frame", {
					BackgroundColor3 = Theme.Inline,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 28),
					Size = UDim2.new(1, 0, 0, 10),
					Corner = UDim.new(1, 0)
				})

				local fill = create("Frame", {
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),
					Corner = UDim.new(1, 0)
				})

				local knob = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Theme.Text,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(10, 10),
					Corner = UDim.new(1, 0)
				})

				local dragging = false
				label.Parent = holder
				valueLabel.Parent = holder
				bar.Parent = holder
				fill.Parent = bar
				knob.Parent = bar
				holder.Parent = section

				local function setAlpha(alpha)
					alpha = math.clamp(alpha, 0, 1)
					value = math.floor(min + (max - min) * alpha + 0.5)
					fill.Size = UDim2.fromScale((value - min) / (max - min == 0 and 1 or max - min), 1)
					knob.Position = UDim2.fromScale((value - min) / (max - min == 0 and 1 or max - min), 0.5)
					valueLabel.Text = tostring(value)
					if config.Callback then
						config.Callback(value)
					end
				end

				local function updateFromInput(input)
					setAlpha((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
				end

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						updateFromInput(input)
					end
				end)

				bar.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(input)
					end
				end)

				setAlpha((value - min) / (max - min == 0 and 1 or max - min))
				return {
					Set = function(_, newValue)
						setAlpha((math.clamp(newValue, min, max) - min) / (max - min == 0 and 1 or max - min))
					end,
					Get = function()
						return value
					end
				}
			end

			function api:AddDropdown(config)
				config = config or {}
				local options = config.Options or {}
				local selected = config.Default or options[1] or "--"

				local holder = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0)
				})

				local label = makeText(config.Text or "dropdown", 13, Theme.Text, Fonts.Semi)
				label.Size = UDim2.new(1, 0, 0, 16)

				local button = create("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Element,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 22),
					Size = UDim2.new(1, 0, 0, 34),
					Font = Fonts.Semi,
					Text = tostring(selected),
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Corner = UDim.new(0, 7),
					Stroke = {
						Color = Theme.Border,
						Transparency = 0.15,
						Thickness = 1
					},
					Padding = {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 26)
					}
				})

				local arrow = create("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(12, 12),
					Font = Fonts.Semi,
					Text = "v",
					TextColor3 = Theme.InactiveText,
					TextSize = 12
				})

				local listCard = createPopupCard(holder)
				listCard.Position = UDim2.fromOffset(0, 60)

				local listScroll = create("ScrollingFrame", {
					Active = true,
					AutomaticCanvasSize = Enum.AutomaticSize.None,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(),
					ScrollBarImageColor3 = Theme.Accent,
					ScrollBarThickness = 4,
					Size = UDim2.new(1, 0, 0, math.min(#options * 30, 130))
				})

				local listLayout = create("UIListLayout", {
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder
				})

				label.Parent = holder
				button.Parent = holder
				arrow.Parent = button
				listCard.Parent = holder
				listScroll.Parent = listCard
				listLayout.Parent = listScroll
				holder.Parent = section
				applyCanvas(listScroll, listLayout, 8)

				local function choose(value)
					selected = value
					button.Text = tostring(value)
					listCard.Visible = false
					window.OpenPopup = nil
					window.PopupTrigger = nil
					if config.Callback then
						config.Callback(value)
					end
				end

				for _, option in ipairs(options) do
					local optionButton = create("TextButton", {
						AutoButtonColor = false,
						BackgroundColor3 = Theme.Inline,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 28),
						Font = Fonts.Body,
						Text = tostring(option),
						TextColor3 = Theme.Text,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Corner = UDim.new(0, 6),
						Padding = {
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10)
						}
					})
					optionButton.Parent = listScroll
					optionButton.MouseButton1Click:Connect(function()
						choose(option)
					end)
					optionButton.MouseEnter:Connect(function()
						animate(optionButton, {BackgroundColor3 = Theme.Element})
					end)
					optionButton.MouseLeave:Connect(function()
						animate(optionButton, {BackgroundColor3 = Theme.Inline})
					end)
					if tostring(option) == tostring(selected) then
						optionButton.BackgroundColor3 = Theme.Element
					end
				end

				button.MouseButton1Click:Connect(function()
					window:TogglePopup(listCard, button)
				end)

				return {
					Set = function(_, value)
						choose(value)
					end,
					Get = function()
						return selected
					end
				}
			end

			function api:AddColorPicker(config)
				config = config or {}
				local selected = config.Default or Theme.Accent

				local holder = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0)
				})

				local label = makeText(config.Text or "color", 13, Theme.Text, Fonts.Semi)
				label.Size = UDim2.new(1, 0, 0, 16)

				local trigger = create("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Inline,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 22),
					Size = UDim2.new(1, 0, 0, 36),
					Text = "",
					Corner = UDim.new(0, 7),
					Stroke = {
						Color = Theme.Border,
						Transparency = 0.15,
						Thickness = 1
					}
				})

				local swatch = create("Frame", {
					BackgroundColor3 = selected,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(9, 7),
					Size = UDim2.fromOffset(22, 22),
					Corner = UDim.new(0, 6),
					Stroke = {
						Color = Theme.Image,
						Transparency = 0.3,
						Thickness = 1
					}
				})

				local valueText = create("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(40, 0),
					Size = UDim2.new(1, -50, 1, 0),
					Font = Fonts.Body,
					Text = rgbText(selected),
					TextColor3 = Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				label.Parent = holder
				trigger.Parent = holder
				swatch.Parent = trigger
				valueText.Parent = trigger
				holder.Parent = section

				local popup, setColorValue, getColorValue = buildColorPicker(window, holder, swatch, selected, function(color)
					selected = color
					swatch.BackgroundColor3 = color
					valueText.Text = rgbText(color)
					if config.Callback then
						config.Callback(color)
					end
				end)
				popup.Parent = holder

				trigger.MouseButton1Click:Connect(function()
					window:TogglePopup(popup, trigger)
				end)

				return {
					Set = function(_, color)
						selected = color
						setColorValue(color, true)
						swatch.BackgroundColor3 = color
						valueText.Text = rgbText(color)
						if config.Callback then
							config.Callback(color)
						end
					end,
					Get = function()
						return getColorValue()
					end
				}
			end

			return api
		end

		table.insert(self.Tabs, tab)
		button.MouseButton1Click:Connect(function()
			self:SetTab(tab)
		end)
		tab:UpdateLayout()

		if not self.ActiveTab then
			self:SetTab(tab)
		end

		return tab
	end

	relayout()
	window:SetOpen(options.StartOpen ~= false)
	return window
end

return setmetatable(Library, Library)
