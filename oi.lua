local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Palette = {
	Background = Color3.fromRGB(8, 9, 14),
	BackgroundAlt = Color3.fromRGB(12, 13, 20),
	Surface = Color3.fromRGB(16, 18, 27),
	SurfaceAlt = Color3.fromRGB(22, 24, 36),
	SurfaceSoft = Color3.fromRGB(29, 31, 46),
	Border = Color3.fromRGB(48, 51, 66),
	BorderSoft = Color3.fromRGB(34, 37, 51),
	Text = Color3.fromRGB(244, 245, 247),
	Muted = Color3.fromRGB(144, 149, 167),
	Accent = Color3.fromRGB(117, 91, 255),
	AccentSoft = Color3.fromRGB(81, 65, 158),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Positive = Color3.fromRGB(97, 205, 138),
	Danger = Color3.fromRGB(216, 92, 92),
}

local Library = {
	Flags = {},
	Windows = {},
	OpenPopups = {},
}

local function tween(object, properties, duration, style, direction)
	local info = TweenInfo.new(duration or 0.16, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	TweenService:Create(object, info, properties):Play()
end

local function create(className, properties, children)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end
	return instance
end

local function round(parent, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = parent,
	})
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
		Color = color or Palette.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		Parent = parent,
	})
end

local function padding(parent, top, bottom, left, right)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		Parent = parent,
	})
end

local function layout(parent, fillDirection, horizontalAlignment, spacing)
	return create("UIListLayout", {
		FillDirection = fillDirection or Enum.FillDirection.Vertical,
		HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, spacing or 0),
		Parent = parent,
	})
end

local function gradient(parent, rotation, colors, transparencies)
	return create("UIGradient", {
		Rotation = rotation or 0,
		Color = colors,
		Transparency = transparencies,
		Parent = parent,
	})
end

local function clearChildren(parent, predicate)
	for _, child in ipairs(parent:GetChildren()) do
		if not predicate or predicate(child) then
			child:Destroy()
		end
	end
end

local function closeAllPopups()
	for popup in pairs(Library.OpenPopups) do
		if popup and popup.Parent then
			popup.Visible = false
		end
	end
end

local function registerPopup(frame)
	Library.OpenPopups[frame] = true
	return frame
end

local function createLabel(parent, props)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = props.Text or "",
		Font = props.Font or Enum.Font.Gotham,
		TextSize = props.TextSize or 14,
		TextColor3 = props.TextColor3 or Palette.Text,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		TextWrapped = props.TextWrapped == true,
		RichText = props.RichText == true,
		AutomaticSize = props.AutomaticSize,
		Size = props.Size or UDim2.new(1, 0, 0, 18),
		Position = props.Position,
		ZIndex = props.ZIndex or 1,
		Parent = parent,
	})
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local function getDeviceType()
	local viewport = getViewportSize()
	if not UserInputService.TouchEnabled then
		return "PC", viewport
	end
	if viewport.X < 700 or viewport.Y < 700 then
		return "Phone", viewport
	end
	return "Tablet", viewport
end

local function getAutoWindowMetrics()
	local device, viewport = getDeviceType()
	if device == "Phone" then
		local width = math.min(math.floor(viewport.X * 0.88), 332)
		local height = math.min(math.floor(viewport.Y * 0.74), 500)
		return device, UDim2.fromOffset(width, height), UDim2.new(0.5, -math.floor(width / 2) - 6, 0.5, -math.floor(height / 2) - 6)
	elseif device == "Tablet" then
		local width = math.min(math.floor(viewport.X * 0.86), 840)
		local height = math.min(math.floor(viewport.Y * 0.79), 610)
		return device, UDim2.fromOffset(width, height), UDim2.new(0.5, -math.floor(width / 2) - 20, 0.5, -math.floor(height / 2) - 4)
	else
		local width = math.min(math.floor(viewport.X * 0.9), 1140)
		local height = math.min(math.floor(viewport.Y * 0.82), 680)
		return device, UDim2.fromOffset(width, height), UDim2.new(0.5, -math.floor(width / 2) - 28, 0.5, -math.floor(height / 2) - 6)
	end
end

local function makeDraggable(handle, frame)
	local dragging = false
	local dragOrigin = nil
	local startPosition = nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		dragOrigin = Vector2.new(input.Position.X, input.Position.Y)
		startPosition = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local viewport = getViewportSize()
		local delta = Vector2.new(input.Position.X, input.Position.Y) - dragOrigin
		local baseX = startPosition.X.Scale * viewport.X
		local baseY = startPosition.Y.Scale * viewport.Y
		local absoluteX = baseX + startPosition.X.Offset + delta.X
		local absoluteY = baseY + startPosition.Y.Offset + delta.Y
		local minVisibleX = -frame.AbsoluteSize.X + math.min(120, math.max(76, math.floor(frame.AbsoluteSize.X * 0.34)))
		local maxVisibleX = viewport.X - math.min(120, math.max(76, math.floor(frame.AbsoluteSize.X * 0.34)))
		local minVisibleY = 0
		local maxVisibleY = viewport.Y - 44
		local clampedX = math.clamp(absoluteX, minVisibleX, maxVisibleX)
		local clampedY = math.clamp(absoluteY, minVisibleY, maxVisibleY)
		frame.Position = UDim2.new(
			startPosition.X.Scale,
			clampedX - baseX,
			startPosition.Y.Scale,
			clampedY - baseY
		)
	end)
end

local Screen = create("ScreenGui", {
	Name = "CloudyScriptHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 50,
})

do
	local ok = pcall(function()
		Screen.Parent = CoreGui
	end)
	if not ok then
		Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

Library.Screen = Screen

local function makeSnowLayer(parent, amount)
	local layer = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		Parent = parent,
	})

	local particles = {}
	local rng = Random.new(619)
	for _ = 1, amount do
		local size = rng:NextInteger(2, 4)
		local dot = create("Frame", {
			BackgroundColor3 = Color3.fromRGB(235, 240, 255),
			BackgroundTransparency = rng:NextNumber(0.25, 0.65),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(size, size),
			Position = UDim2.new(rng:NextNumber(0, 1), 0, rng:NextNumber(0, 1), 0),
			ZIndex = 2,
			Parent = layer,
		})
		round(dot, 999)
		particles[#particles + 1] = {
			Frame = dot,
			X = rng:NextNumber(0, 1),
			Y = rng:NextNumber(0, 1),
			Speed = rng:NextNumber(0.06, 0.18),
			Drift = rng:NextNumber(-0.025, 0.025),
		}
	end

	RunService.RenderStepped:Connect(function(deltaTime)
		local absoluteSize = layer.AbsoluteSize
		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end
		for _, particle in ipairs(particles) do
			particle.Y += particle.Speed * deltaTime
			particle.X += particle.Drift * deltaTime
			if particle.Y > 1.05 then
				particle.Y = -0.05
				particle.X = rng:NextNumber(0, 1)
			end
			if particle.X < -0.05 then
				particle.X = 1.05
			elseif particle.X > 1.05 then
				particle.X = -0.05
			end
			particle.Frame.Position = UDim2.new(particle.X, 0, particle.Y, 0)
		end
	end)

	return layer
end

local function createTopIconButton(parent, text)
	local button = create("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Palette.Surface,
		BorderSizePixel = 0,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Palette.Muted,
		AutoButtonColor = false,
		ZIndex = 8,
		Parent = parent,
	})
	round(button, 999)
	stroke(button, Palette.BorderSoft)
	button.MouseEnter:Connect(function()
		tween(button, { BackgroundColor3 = Palette.SurfaceSoft, TextColor3 = Palette.Text })
	end)
	button.MouseLeave:Connect(function()
		tween(button, { BackgroundColor3 = Palette.Surface, TextColor3 = Palette.Muted })
	end)
	return button
end

local function createPillButton(parent, text, width, selected)
	local button = create("TextButton", {
		Size = UDim2.fromOffset(width, 34),
		BackgroundColor3 = selected and Palette.Text or Palette.Surface,
		BorderSizePixel = 0,
		Text = text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = selected and Palette.Background or Palette.Text,
		AutoButtonColor = false,
		ZIndex = 8,
		Parent = parent,
	})
	round(button, 10)
	stroke(button, selected and Palette.Text or Palette.BorderSoft, 1, selected and 0.75 or 0)
	button.MouseEnter:Connect(function()
		tween(button, { BackgroundColor3 = selected and Color3.fromRGB(229, 230, 232) or Palette.SurfaceSoft })
	end)
	button.MouseLeave:Connect(function()
		tween(button, { BackgroundColor3 = selected and Palette.Text or Palette.Surface })
	end)
	return button
end

local function createHomeCard(parent, width)
	local card = create("Frame", {
		Size = UDim2.new(0, width, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		BackgroundColor3 = Palette.Surface,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = parent,
	})
	round(card, 20)
	local cardStroke = stroke(card, Palette.BorderSoft)
	cardStroke.Name = "CardStroke"
	gradient(card, 180, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 21, 31)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 15, 23)),
	}))
	local inner = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = card,
	})
	padding(inner, 14, 14, 14, 14)
	layout(inner, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 12)
	return card, inner
end

local function createHomePreview(parent, mode)
	local preview = create("Frame", {
		Size = UDim2.new(1, 0, 0, 118),
		ClipsDescendants = true,
		BackgroundColor3 = Palette.BackgroundAlt,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = parent,
	})
	round(preview, 16)
	stroke(preview, Palette.BorderSoft, 1, 0.45)
	gradient(preview, 135, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 19, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 18)),
	}))

	if mode == "Updates" then
		for index, config in ipairs({
			{ 0.06, 16, 0.72, 34, "Patch Notes" },
			{ 0.06, 56, 0.62, 26, "Responsive Tweaks" },
			{ 0.06, 88, 0.46, 10, "Announcements" },
		}) do
			local mini = create("Frame", {
				Position = UDim2.new(config[1], 0, 0, config[2]),
				Size = UDim2.new(config[3], 0, 0, config[4]),
				BackgroundColor3 = Palette.SurfaceSoft,
				BackgroundTransparency = index == 3 and 0.18 or 0.05,
				BorderSizePixel = 0,
				ZIndex = 9,
				Parent = preview,
			})
			round(mini, 10)
			stroke(mini, Palette.BorderSoft, 1, 0.55)
			createLabel(mini, {
				Text = config[5],
				Font = Enum.Font.GothamSemibold,
				TextSize = 10,
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.new(0, 6, 0, 0),
				ZIndex = 10,
			})
		end
	elseif mode == "Scripts" then
		local core = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.56, 0),
			Size = UDim2.fromOffset(24, 24),
			BackgroundColor3 = Palette.Background,
			BorderSizePixel = 0,
			ZIndex = 9,
			Parent = preview,
		})
		round(core, 999)
		stroke(core, Palette.AccentSoft)
		createLabel(core, {
			Text = "C",
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = Palette.Accent,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 10,
		})
		for index, y in ipairs({ 18, 41, 64, 87 }) do
			create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.56, 0),
				Size = UDim2.new(0, 74 - ((index - 1) * 10), 0, 1),
				Rotation = ({ -10, -2, 9, 16 })[index],
				BackgroundColor3 = Palette.BorderSoft,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = preview,
			})
			local orb = create("Frame", {
				Position = UDim2.new(0.82, 0, 0, y),
				Size = UDim2.fromOffset(18, 18),
				BackgroundColor3 = ({ Color3.fromRGB(243, 109, 73), Color3.fromRGB(84, 164, 255), Color3.fromRGB(229, 183, 60), Color3.fromRGB(92, 92, 96) })[index],
				BorderSizePixel = 0,
				ZIndex = 9,
				Parent = preview,
			})
			round(orb, 999)
		end
	else
		for index = 1, 4 do
			local block = create("Frame", {
				Position = UDim2.new(0, 12 + ((index - 1) * 46), 0, 20 + ((index % 2 == 0) and 8 or 0)),
				Size = UDim2.fromOffset(42, 56),
				BackgroundColor3 = Palette.SurfaceSoft,
				BorderSizePixel = 0,
				ZIndex = 9,
				Parent = preview,
			})
			round(block, 10)
			stroke(block, Palette.BorderSoft, 1, 0.45)
			createLabel(block, {
				Text = ({ "Discord", "Status", "Owners", "Links" })[index],
				Font = Enum.Font.GothamSemibold,
				TextSize = 8,
				TextWrapped = true,
				Size = UDim2.new(1, -8, 1, -8),
				Position = UDim2.new(0, 4, 0, 4),
				ZIndex = 10,
			})
		end
	end

	return preview
end

function Library:CreateWindow(options)
	options = options or {}
	local autoSize = options.AutoSize ~= false
	local title = options.Title or "Cloudy"
	local heroTitleText = options.HeroTitle or "Cloudy Developer | Script Hub"
	local heroSubtitleText = options.HeroSubtitle or "Clean responsive script hub with a built-in home page, updates, socials, owned scripts, and working library controls."
	local deviceType, defaultSize, defaultPosition = getAutoWindowMetrics()

	local windowFrame = create("Frame", {
		Name = "Window",
		Size = autoSize and defaultSize or (options.Size or defaultSize),
		Position = autoSize and defaultPosition or (options.Position or defaultPosition),
		BackgroundColor3 = Palette.Background,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = Screen,
	})
	round(windowFrame, 18)
	stroke(windowFrame, Palette.Border)
	gradient(windowFrame, 135, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 11, 18)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 8, 13)),
	}))

	local snowLayer = makeSnowLayer(windowFrame, deviceType == "Phone" and 12 or (deviceType == "Tablet" and 18 or 24))

	local navBar = create("Frame", {
		Size = UDim2.new(1, -20, 0, 38),
		Position = UDim2.new(0, 10, 0, 8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = windowFrame,
	})

	create("Frame", {
		Size = UDim2.new(1, -14, 0, 1),
		Position = UDim2.new(0, 7, 0, 46),
		BackgroundColor3 = Palette.BorderSoft,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = windowFrame,
	})

	local brandLabel = createLabel(navBar, {
		Text = title,
		Font = Enum.Font.GothamSemibold,
		TextSize = 11,
		Size = UDim2.fromOffset(96, 26),
		Position = UDim2.new(0, 6, 0, 6),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
	})
	brandLabel.BackgroundTransparency = 1

	local tabsHolder = create("ScrollingFrame", {
		Size = UDim2.new(1, -248, 0, 28),
		Position = UDim2.new(0, 96, 0, 5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ZIndex = 8,
		Parent = navBar,
	})
	local tabsLayout = layout(tabsHolder, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 8)
	tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local rightButtons = create("Frame", {
		Size = UDim2.fromOffset(96, 28),
		Position = UDim2.new(1, -102, 0, 5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = navBar,
	})
	local rightLayout = layout(rightButtons, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, 8)
	rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	local minimizeButton = createTopIconButton(rightButtons, "-")
	local closeButton = createTopIconButton(rightButtons, "x")

	local hero = create("Frame", {
		Size = UDim2.new(1, -72, 0, 146),
		Position = UDim2.new(0, 36, 0, 68),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = windowFrame,
	})

	local heroTitle = createLabel(hero, {
		Text = heroTitleText,
		Font = Enum.Font.GothamBold,
		TextSize = 32,
		TextWrapped = true,
		Size = UDim2.new(1, -120, 0, 48),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 8,
	})

	local heroSubtitle = createLabel(hero, {
		Text = heroSubtitleText,
		TextColor3 = Palette.Muted,
		TextSize = 14,
		TextWrapped = true,
		Size = UDim2.new(0, 660, 0, 36),
		Position = UDim2.new(0, 0, 0, 50),
		ZIndex = 8,
	})

	local heroButtons = create("Frame", {
		Size = UDim2.new(0, 280, 0, 34),
		Position = UDim2.new(0, 0, 0, 102),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = hero,
	})
	local heroButtonsLayout = layout(heroButtons, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 10)
	heroButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local updatesHeroButton = createPillButton(heroButtons, "Updates", 88, true)
	local socialsHeroButton = createPillButton(heroButtons, "Socials", 82, false)
	local scriptsHeroButton = createPillButton(heroButtons, "Scripts", 78, false)

	local content = create("Frame", {
		Size = UDim2.new(1, -28, 1, -238),
		Position = UDim2.new(0, 14, 0, 224),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = windowFrame,
	})

	makeDraggable(navBar, windowFrame)

	local windowObject = {
		Frame = windowFrame,
		Hero = hero,
		HeroTitle = heroTitle,
		HeroSubtitle = heroSubtitle,
		HomeCards = {},
		Tabs = {},
		TabMap = {},
		ActiveTab = nil,
		HomeFocus = "Updates",
		HomeData = {
			Updates = options.Updates or {
				{ Title = "Script Updates", Meta = "Editable", Body = "Use window:AddUpdateCard or window:SetUpdates to change this list anytime." },
				{ Title = "Responsive Layout", Meta = "Phone / Tablet / PC", Body = "The library now auto sizes and changes layout for touch devices." },
				{ Title = "Default Home Tab", Meta = "Built In", Body = "Home is created automatically inside oi.lua so you do not have to build it every time." },
			},
			Scripts = options.Scripts or {
				{ Name = "Main Script", Description = "Put your main loader here.", Image = "", ButtonText = "Execute", Callback = function() end },
				{ Name = "Utility Script", Description = "Secondary example script entry.", Image = "", ButtonText = "Execute", Callback = function() end },
			},
			Socials = options.Socials or {
				{ Title = "Discord", Value = ".gg/getcloudy", ButtonText = "Copy", Callback = function() if setclipboard then setclipboard(".gg/getcloudy") end end },
				{ Title = "Status", Value = "All systems online", ButtonText = "View", Callback = function() end },
			},
		},
	}

	local isMinimized = false
	local expandedHeight = windowFrame.Size
	minimizeButton.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			expandedHeight = windowFrame.Size
			tween(windowFrame, { Size = UDim2.new(windowFrame.Size.X.Scale, windowFrame.Size.X.Offset, 0, 56) }, 0.2)
			hero.Visible = false
			content.Visible = false
		else
			tween(windowFrame, { Size = expandedHeight }, 0.2)
			hero.Visible = true
			content.Visible = true
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		windowFrame.Visible = false
	end)

	function windowObject:SetTitle(newTitle)
		brandLabel.Text = newTitle
	end

	function windowObject:SetHero(newTitle, newSubtitle)
		if newTitle then
			heroTitle.Text = newTitle
		end
		if newSubtitle then
			heroSubtitle.Text = newSubtitle
		end
	end

	local function updateHeroButtons()
		local selectedMap = {
			Updates = updatesHeroButton,
			Socials = socialsHeroButton,
			Scripts = scriptsHeroButton,
		}
		for name, button in pairs(selectedMap) do
			local selected = windowObject.HomeFocus == name
			button.BackgroundColor3 = selected and Palette.Text or Palette.Surface
			button.TextColor3 = selected and Palette.Background or Palette.Text
		end
	end

	local homePage = create("ScrollingFrame", {
		Name = "HomePage",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Palette.BorderSoft,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = true,
		ZIndex = 7,
		Parent = content,
	})
	padding(homePage, 0, 12, 0, 12)

	local homeHolder = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = homePage,
	})
	local homeHolderLayout = layout(homeHolder, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 14)
	homeHolderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		homePage.CanvasSize = UDim2.new(0, 0, 0, homeHolderLayout.AbsoluteContentSize.Y + 18)
	end)

	local homeCardsRow = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = homeHolder,
	})
	local homeCardsLayout = layout(homeCardsRow, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 14)
	homeCardsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	local function focusCard(card, focused)
		local existingStroke = card:FindFirstChild("CardStroke")
		if existingStroke then
			existingStroke.Color = focused and Palette.Accent or Palette.BorderSoft
			existingStroke.Transparency = focused and 0 or 0.1
		end
	end

	function windowObject:SetUpdates(items)
		self.HomeData.Updates = items or {}
		self:RenderHome()
	end

	function windowObject:AddUpdateCard(item)
		table.insert(self.HomeData.Updates, item)
		self:RenderHome()
	end

	function windowObject:SetScripts(items)
		self.HomeData.Scripts = items or {}
		self:RenderHome()
	end

	function windowObject:AddScriptCard(item)
		table.insert(self.HomeData.Scripts, item)
		self:RenderHome()
	end

	function windowObject:SetSocials(items)
		self.HomeData.Socials = items or {}
		self:RenderHome()
	end

	function windowObject:AddSocialCard(item)
		table.insert(self.HomeData.Socials, item)
		self:RenderHome()
	end

	function windowObject:FocusHomeSection(name)
		self.HomeFocus = name
		updateHeroButtons()
		self:RenderHome()
		local target = self.HomeCards[name]
		if target and homePage.Visible then
			local offset = target.AbsolutePosition.Y - homeHolder.AbsolutePosition.Y
			homePage.CanvasPosition = Vector2.new(0, math.max(0, offset - 6))
		end
	end

	local function createHomeItemBox(parent, title, meta, body)
		local box = create("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Palette.SurfaceAlt,
			BackgroundTransparency = 0.03,
			BorderSizePixel = 0,
			ZIndex = 8,
			Parent = parent,
		})
		round(box, 14)
		stroke(box, Palette.BorderSoft, 1, 0.35)
		padding(box, 10, 10, 12, 12)
		createLabel(box, {
			Text = title,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			Size = UDim2.new(1, -70, 0, 16),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 9,
		})
		createLabel(box, {
			Text = meta or "",
			TextColor3 = Palette.Muted,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.new(0, 66, 0, 16),
			Position = UDim2.new(1, -66, 0, 0),
			ZIndex = 9,
		})
		local bodyLabel = createLabel(box, {
			Text = body,
			TextColor3 = Palette.Muted,
			TextSize = 11,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 20),
			ZIndex = 9,
		})
		return box, bodyLabel
	end

	local function executeScriptEntry(entry)
		if type(entry.Callback) == "function" then
			task.spawn(function()
				local ok, err = pcall(entry.Callback, entry)
				if not ok then
					warn("[Cloudy] Script callback failed:", err)
				end
			end)
			return true
		end

		if type(entry.Execute) == "function" then
			task.spawn(function()
				local ok, err = pcall(entry.Execute, entry)
				if not ok then
					warn("[Cloudy] Script execute failed:", err)
				end
			end)
			return true
		end

		if type(entry.Source) == "string" and entry.Source ~= "" then
			local chunk, loadErr = loadstring(entry.Source)
			if not chunk then
				warn("[Cloudy] Source load failed:", loadErr)
				return false
			end
			task.spawn(function()
				local ok, err = pcall(chunk)
				if not ok then
					warn("[Cloudy] Source execution failed:", err)
				end
			end)
			return true
		end

		local url = entry.Url or entry.URL or entry.Link
		if type(url) == "string" and url ~= "" then
			local ok, response = pcall(function()
				return game:HttpGet(url)
			end)
			if not ok then
				warn("[Cloudy] HttpGet failed:", response)
				return false
			end
			local chunk, loadErr = loadstring(response)
			if not chunk then
				warn("[Cloudy] Remote load failed:", loadErr)
				return false
			end
			task.spawn(function()
				local runOk, runErr = pcall(chunk)
				if not runOk then
					warn("[Cloudy] Remote script execution failed:", runErr)
				end
			end)
			return true
		end

		warn("[Cloudy] No executable script source found for", entry.Name or "Unnamed Script")
		return false
	end

	local function renderScripts(cardInner)
		for _, entry in ipairs(windowObject.HomeData.Scripts) do
			local row = create("Frame", {
				Size = UDim2.new(1, 0, 0, 146),
				BackgroundColor3 = Palette.SurfaceAlt,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = cardInner,
			})
			round(row, 14)
			stroke(row, Palette.BorderSoft, 1, 0.35)
			local imageWrap = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 10),
				Size = UDim2.fromOffset(58, 58),
				BackgroundColor3 = Palette.SurfaceSoft,
				BorderSizePixel = 0,
				ZIndex = 9,
				Parent = row,
			})
			round(imageWrap, 14)
			stroke(imageWrap, Palette.BorderSoft, 1, 0.3)
			local icon = create("ImageLabel", {
				Size = UDim2.new(1, -8, 1, -8),
				Position = UDim2.new(0, 4, 0, 4),
				BackgroundColor3 = Palette.SurfaceSoft,
				BorderSizePixel = 0,
				BackgroundTransparency = entry.Image ~= nil and entry.Image ~= "" and 1 or 0,
				Image = entry.Image or "",
				ScaleType = Enum.ScaleType.Crop,
				ZIndex = 9,
				Parent = imageWrap,
			})
			round(icon, 12)
			if entry.Image == nil or entry.Image == "" then
				stroke(icon, Palette.BorderSoft, 1, 0.35)
				createLabel(icon, {
					Text = string.sub(entry.Name or "S", 1, 1),
					Font = Enum.Font.GothamBold,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Center,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 10,
				})
			end
			createLabel(row, {
				Text = entry.Name or "Script",
				Font = Enum.Font.GothamSemibold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, -24, 0, 18),
				Position = UDim2.new(0, 12, 0, 76),
				ZIndex = 9,
			})
			createLabel(row, {
				Text = entry.Description or "",
				TextColor3 = Palette.Muted,
				TextSize = 11,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Top,
				Size = UDim2.new(1, -28, 0, 28),
				Position = UDim2.new(0, 14, 0, 96),
				ZIndex = 9,
			})
			local executeButton = create("TextButton", {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -10),
				Size = UDim2.fromOffset(122, 30),
				BackgroundColor3 = Palette.Text,
				BorderSizePixel = 0,
				Text = "Execute Script",
				Font = Enum.Font.GothamSemibold,
				TextSize = 11,
				TextColor3 = Palette.Background,
				AutoButtonColor = false,
				ZIndex = 9,
				Parent = row,
			})
			round(executeButton, 10)
			executeButton.MouseEnter:Connect(function()
				tween(executeButton, { BackgroundColor3 = Color3.fromRGB(231, 232, 234) })
			end)
			executeButton.MouseLeave:Connect(function()
				tween(executeButton, { BackgroundColor3 = Palette.Text })
			end)
			executeButton.MouseButton1Click:Connect(function()
				executeScriptEntry(entry)
			end)
		end
	end

	local function renderSocials(cardInner)
		for _, entry in ipairs(windowObject.HomeData.Socials) do
			local box = create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = Palette.SurfaceAlt,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = cardInner,
			})
			round(box, 14)
			stroke(box, Palette.BorderSoft, 1, 0.35)
			padding(box, 10, 10, 12, 12)
			createLabel(box, {
				Text = entry.Title or "Social",
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				Size = UDim2.new(1, -86, 0, 16),
				Position = UDim2.new(0, 0, 0, 0),
				ZIndex = 9,
			})
			createLabel(box, {
				Text = entry.Value or "",
				TextColor3 = Palette.Muted,
				TextSize = 11,
				TextWrapped = true,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, -94, 0, 0),
				Position = UDim2.new(0, 0, 0, 20),
				ZIndex = 9,
			})
			local actionButton = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.fromOffset(78, 28),
				BackgroundColor3 = Palette.SurfaceSoft,
				BorderSizePixel = 0,
				Text = entry.ButtonText or "Open",
				Font = Enum.Font.GothamSemibold,
				TextSize = 11,
				TextColor3 = Palette.Text,
				AutoButtonColor = false,
				ZIndex = 9,
				Parent = box,
			})
			round(actionButton, 10)
			stroke(actionButton, Palette.BorderSoft, 1, 0.35)
			actionButton.MouseEnter:Connect(function()
				tween(actionButton, { BackgroundColor3 = Palette.Surface })
			end)
			actionButton.MouseLeave:Connect(function()
				tween(actionButton, { BackgroundColor3 = Palette.SurfaceSoft })
			end)
			actionButton.MouseButton1Click:Connect(function()
				if entry.Callback then
					entry.Callback(entry)
				end
			end)
		end
	end

	function windowObject:RenderHome()
		clearChildren(homeCardsRow, function(child)
			return not child:IsA("UIListLayout")
		end)
		local currentDevice = getDeviceType()
		local phone = currentDevice == "Phone"
		local availableWidth = math.max(content.AbsoluteSize.X - (phone and 0 or 34), 280)
		local useThreeAcross = not phone and availableWidth >= 900
		local cardWidth = availableWidth
		if useThreeAcross then
			cardWidth = math.floor((availableWidth - 28) / 3)
		elseif not phone then
			cardWidth = availableWidth
		end
		if phone or not useThreeAcross then
			homeCardsLayout.FillDirection = Enum.FillDirection.Vertical
		else
			homeCardsLayout.FillDirection = Enum.FillDirection.Horizontal
		end
		self.HomeCards = {}

		local function createCardWrapper(offset)
			if phone or not useThreeAcross then
				return homeCardsRow
			end
			local wrapper = create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(0, cardWidth, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = homeCardsRow,
			})
			local wrapperLayout = layout(wrapper, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 0)
			wrapperLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			if offset > 0 then
				create("Frame", {
					Size = UDim2.new(1, 0, 0, offset),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = wrapper,
				})
			end
			return wrapper
		end

		local updatesCard, updatesInner = createHomeCard(createCardWrapper(16), cardWidth)
		updatesCard.Name = "UpdatesCard"
		self.HomeCards.Updates = updatesCard
		createHomePreview(updatesInner, "Updates")
		createLabel(updatesInner, {
			Text = "Updates",
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			Size = UDim2.new(1, 0, 0, 18),
			ZIndex = 8,
		})
		createLabel(updatesInner, {
			Text = "Patch notes, script changes, and messages.",
			TextColor3 = Palette.Muted,
			TextSize = 11,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 8,
		})
		for _, item in ipairs(self.HomeData.Updates) do
			createHomeItemBox(updatesInner, item.Title or "Update", item.Meta or "", item.Body or "")
		end

		local scriptsCard, scriptsInner = createHomeCard(createCardWrapper(0), cardWidth)
		scriptsCard.Name = "ScriptsCard"
		self.HomeCards.Scripts = scriptsCard
		createHomePreview(scriptsInner, "Scripts")
		createLabel(scriptsInner, {
			Text = "Scripts",
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			Size = UDim2.new(1, 0, 0, 18),
			ZIndex = 8,
		})
		createLabel(scriptsInner, {
			Text = "Owned scripts with images, names, and execute buttons.",
			TextColor3 = Palette.Muted,
			TextSize = 11,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 8,
		})
		renderScripts(scriptsInner)

		local socialsCard, socialsInner = createHomeCard(createCardWrapper(24), cardWidth)
		socialsCard.Name = "SocialsCard"
		self.HomeCards.Socials = socialsCard
		createHomePreview(socialsInner, "Socials")
		createLabel(socialsInner, {
			Text = "Socials",
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			Size = UDim2.new(1, 0, 0, 18),
			ZIndex = 8,
		})
		createLabel(socialsInner, {
			Text = "Contacts, status, and quick actions.",
			TextColor3 = Palette.Muted,
			TextSize = 11,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 8,
		})
		renderSocials(socialsInner)

		focusCard(updatesCard, self.HomeFocus == "Updates")
		focusCard(scriptsCard, self.HomeFocus == "Scripts")
		focusCard(socialsCard, self.HomeFocus == "Socials")
	end

	local function createTabButton(name)
		local button = create("TextButton", {
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 28),
			BackgroundColor3 = Palette.Surface,
			BorderSizePixel = 0,
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = Palette.Muted,
			AutoButtonColor = false,
			ZIndex = 8,
			Parent = tabsHolder,
		})
		padding(button, 0, 0, 12, 12)
		round(button, 999)
		stroke(button, Palette.BorderSoft)
		button.MouseEnter:Connect(function()
			if windowObject.ActiveTab and windowObject.ActiveTab.Button ~= button then
				tween(button, { BackgroundColor3 = Palette.SurfaceSoft, TextColor3 = Palette.Text })
			end
		end)
		button.MouseLeave:Connect(function()
			if windowObject.ActiveTab and windowObject.ActiveTab.Button ~= button then
				tween(button, { BackgroundColor3 = Palette.Surface, TextColor3 = Palette.Muted })
			end
		end)
		return button
	end

	local function createTabPage(name, isHome)
		local page = isHome and homePage or create("ScrollingFrame", {
			Name = name .. "Page",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Palette.BorderSoft,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false,
			ZIndex = 7,
			Parent = content,
		})
		if not isHome then
			padding(page, 0, 12, 0, 12)
		end
		return page
	end

	local function selectTab(tab)
		closeAllPopups()
		for _, existing in ipairs(windowObject.Tabs) do
			existing.Page.Visible = false
			existing.Button.BackgroundColor3 = Palette.Surface
			existing.Button.TextColor3 = Palette.Muted
		end
		tab.Page.Visible = true
		tab.Button.BackgroundColor3 = Palette.Text
		tab.Button.TextColor3 = Palette.Background
		heroButtons.Visible = tab.IsHome == true
		windowObject.ActiveTab = tab
	end

	local homeTab = {
		Name = "Home",
		Button = createTabButton("Home"),
		Page = createTabPage("Home", true),
		IsHome = true,
	}
	homeTab.Button.MouseButton1Click:Connect(function()
		selectTab(homeTab)
	end)
	windowObject.Tabs[#windowObject.Tabs + 1] = homeTab
	windowObject.TabMap.Home = homeTab

	function windowObject:CreateTab(name)
		name = name or "Tab"
		if self.TabMap[name] then
			return self.TabMap[name]
		end

		local tab = {
			Name = name,
			Button = createTabButton(name),
			Page = createTabPage(name, false),
			Sections = {},
		}

		local holder = create("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 8,
			Parent = tab.Page,
		})
		local holderLayout = layout(holder, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 12)
		holderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tab.Page.CanvasSize = UDim2.new(0, 0, 0, holderLayout.AbsoluteContentSize.Y + 18)
		end)

		tab.Button.MouseButton1Click:Connect(function()
			selectTab(tab)
		end)

		function tab:CreateSection(titleText)
			local section = create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = Palette.Surface,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = holder,
			})
			round(section, 18)
			stroke(section, Palette.BorderSoft)
			padding(section, 14, 14, 14, 14)
			local sectionLayout = layout(section, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 10)
			createLabel(section, {
				Text = titleText or "Section",
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				Size = UDim2.new(1, 0, 0, 18),
				ZIndex = 9,
			})

			local sectionObject = {}

			local function createRow(height)
				local row = create("Frame", {
					Size = UDim2.new(1, 0, 0, height or 38),
					BackgroundColor3 = Palette.SurfaceAlt,
					BorderSizePixel = 0,
					ZIndex = 9,
					Parent = section,
				})
				round(row, 14)
				stroke(row, Palette.BorderSoft, 1, 0.35)
				padding(row, 0, 0, 12, 12)
				return row
			end

			local function createRowLabel(row, text)
				return createLabel(row, {
					Text = text,
					TextSize = 12,
					Size = UDim2.new(0.58, 0, 1, 0),
					ZIndex = 10,
				})
			end

			function sectionObject:AddDivider()
				return create("Frame", {
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = Palette.BorderSoft,
					BackgroundTransparency = 0.2,
					BorderSizePixel = 0,
					ZIndex = 9,
					Parent = section,
				})
			end

			function sectionObject:AddLabel(opts)
				opts = opts or {}
				local row = createRow(44)
				local label = createLabel(row, {
					Text = opts.Text or "Label",
					TextSize = 12,
					TextColor3 = Palette.Muted,
					TextWrapped = true,
					Size = UDim2.new(1, -24, 1, 0),
					ZIndex = 10,
				})
				return {
					SetText = function(_, text)
						label.Text = text
					end,
				}
			end

			function sectionObject:AddButton(opts)
				opts = opts or {}
				local button = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = Palette.SurfaceAlt,
					BorderSizePixel = 0,
					Text = opts.Title or "Button",
					Font = Enum.Font.GothamSemibold,
					TextSize = 12,
					TextColor3 = Palette.Text,
					AutoButtonColor = false,
					ZIndex = 9,
					Parent = section,
				})
				round(button, 14)
				stroke(button, Palette.BorderSoft, 1, 0.25)
				button.MouseEnter:Connect(function()
					tween(button, { BackgroundColor3 = Palette.AccentSoft })
				end)
				button.MouseLeave:Connect(function()
					tween(button, { BackgroundColor3 = Palette.SurfaceAlt })
				end)
				button.MouseButton1Click:Connect(function()
					if opts.Callback then
						opts.Callback()
					end
				end)
				return {
					SetTitle = function(_, text)
						button.Text = text
					end,
				}
			end

			function sectionObject:AddToggle(opts)
				opts = opts or {}
				local flag = opts.Flag
				local current = opts.Value == true
				local callback = opts.Callback
				local row = createRow(40)
				createRowLabel(row, opts.Title or "Toggle")
				local track = create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(48, 24),
					BackgroundColor3 = current and Palette.Text or Palette.BackgroundAlt,
					BorderSizePixel = 0,
					ZIndex = 10,
					Parent = row,
				})
				round(track, 999)
				stroke(track, Palette.BorderSoft)
				local knob = create("Frame", {
					Size = UDim2.fromOffset(18, 18),
					Position = current and UDim2.new(0, 26, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
					BackgroundColor3 = current and Palette.Background or Palette.White,
					BorderSizePixel = 0,
					ZIndex = 11,
					Parent = track,
				})
				round(knob, 999)
				local button = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 12,
					Parent = track,
				})
				local function setValue(value)
					current = value
					if flag then
						Library.Flags[flag] = value
					end
					tween(track, { BackgroundColor3 = value and Palette.Text or Palette.BackgroundAlt })
					tween(knob, { Position = value and UDim2.new(0, 26, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = value and Palette.Background or Palette.White })
					if callback then
						callback(value)
					end
				end
				if flag then
					Library.Flags[flag] = current
				end
				button.MouseButton1Click:Connect(function()
					setValue(not current)
				end)
				return {
					SetValue = function(_, value) setValue(value) end,
					GetValue = function() return current end,
				}
			end

			function sectionObject:AddSlider(opts)
				opts = opts or {}
				local flag = opts.Flag
				local min = opts.Min or 0
				local max = opts.Max or 100
				local step = opts.Step or 1
				local current = math.clamp(opts.Value or min, min, max)
				local callback = opts.Callback
				local row = createRow(58)
				createLabel(row, {
					Text = opts.Title or "Slider",
					TextSize = 12,
					Size = UDim2.new(0.6, 0, 0, 16),
					Position = UDim2.new(0, 0, 0, 8),
					ZIndex = 10,
				})
				local valueLabel = createLabel(row, {
					Text = tostring(current),
					TextSize = 11,
					TextColor3 = Palette.Muted,
					TextXAlignment = Enum.TextXAlignment.Right,
					Size = UDim2.new(0.4, 0, 0, 16),
					Position = UDim2.new(0.6, 0, 0, 8),
					ZIndex = 10,
				})
				local track = create("Frame", {
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 1, -14),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					ZIndex = 10,
					Parent = row,
				})
				round(track, 999)
				local fill = create("Frame", {
					Size = UDim2.new((current - min) / math.max(max - min, 1), 0, 1, 0),
					BackgroundColor3 = Palette.Text,
					BorderSizePixel = 0,
					ZIndex = 11,
					Parent = track,
				})
				round(fill, 999)
				local thumb = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0),
					Size = UDim2.fromOffset(12, 12),
					BackgroundColor3 = Palette.White,
					BorderSizePixel = 0,
					ZIndex = 12,
					Parent = track,
				})
				round(thumb, 999)
				local input = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 13,
					Parent = track,
				})
				local dragging = false
				local function setValue(value)
					local snapped = math.clamp(math.round(value / step) * step, min, max)
					current = snapped
					if flag then
						Library.Flags[flag] = snapped
					end
					local alpha = (snapped - min) / math.max(max - min, 1)
					fill.Size = UDim2.new(alpha, 0, 1, 0)
					thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
					valueLabel.Text = tostring(snapped)
					if callback then
						callback(snapped)
					end
				end
				if flag then
					Library.Flags[flag] = current
				end
				input.InputBegan:Connect(function(userInput)
					if userInput.UserInputType == Enum.UserInputType.MouseButton1 or userInput.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						local alpha = (userInput.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
						setValue(min + math.clamp(alpha, 0, 1) * (max - min))
					end
				end)
				UserInputService.InputEnded:Connect(function(userInput)
					if userInput.UserInputType == Enum.UserInputType.MouseButton1 or userInput.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(userInput)
					if not dragging then return end
					if userInput.UserInputType ~= Enum.UserInputType.MouseMovement and userInput.UserInputType ~= Enum.UserInputType.Touch then return end
					local alpha = (userInput.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
					setValue(min + math.clamp(alpha, 0, 1) * (max - min))
				end)
				return {
					SetValue = function(_, value) setValue(value) end,
					GetValue = function() return current end,
				}
			end

			function sectionObject:AddTextbox(opts)
				opts = opts or {}
				local flag = opts.Flag
				local callback = opts.Callback
				local row = createRow(40)
				createRowLabel(row, opts.Title or "Textbox")
				local box = create("TextBox", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0.42, 0, 0, 28),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					Text = opts.Value or "",
					PlaceholderText = opts.Placeholder or "...",
					PlaceholderColor3 = Palette.Muted,
					TextColor3 = Palette.Text,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					ClearTextOnFocus = opts.ClearOnFocus ~= false,
					ZIndex = 10,
					Parent = row,
				})
				round(box, 10)
				stroke(box, Palette.BorderSoft, 1, 0.35)
				padding(box, 0, 0, 8, 8)
				if flag then
					Library.Flags[flag] = box.Text
				end
				box.FocusLost:Connect(function(entered)
					if flag then
						Library.Flags[flag] = box.Text
					end
					if callback then
						callback(box.Text, entered)
					end
				end)
				return {
					SetValue = function(_, value) box.Text = value end,
					GetValue = function() return box.Text end,
				}
			end

			function sectionObject:AddKeybind(opts)
				opts = opts or {}
				local flag = opts.Flag
				local callback = opts.Callback
				local current = opts.Default or Enum.KeyCode.Unknown
				local listening = false
				local row = createRow(40)
				createRowLabel(row, opts.Title or "Keybind")
				local bindButton = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0.42, 0, 0, 28),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					Text = current == Enum.KeyCode.Unknown and "[ NONE ]" or ("[ " .. current.Name .. " ]"),
					Font = Enum.Font.GothamSemibold,
					TextSize = 11,
					TextColor3 = Palette.Muted,
					AutoButtonColor = false,
					ZIndex = 10,
					Parent = row,
				})
				round(bindButton, 10)
				stroke(bindButton, Palette.BorderSoft, 1, 0.35)
				if flag then
					Library.Flags[flag] = current
				end
				bindButton.MouseButton1Click:Connect(function()
					listening = true
					bindButton.Text = "[ ... ]"
					bindButton.TextColor3 = Palette.Text
				end)
				UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if listening then
						if gameProcessed then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							current = input.KeyCode
							if flag then Library.Flags[flag] = current end
							bindButton.Text = current == Enum.KeyCode.Unknown and "[ NONE ]" or ("[ " .. current.Name .. " ]")
							bindButton.TextColor3 = Palette.Muted
							listening = false
						end
						return
					end
					if callback and input.KeyCode == current then
						callback()
					end
				end)
				return {
					GetValue = function() return current end,
				}
			end

			function sectionObject:AddDropdown(opts)
				opts = opts or {}
				local flag = opts.Flag
				local optionsList = opts.Options or {}
				local multi = opts.Multi == true
				local callback = opts.Callback
				local current = multi and {} or (opts.Value or optionsList[1] or "")
				local row = createRow(40)
				createRowLabel(row, opts.Title or "Dropdown")
				local button = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0.42, 0, 0, 28),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					Text = "",
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextColor3 = Palette.Text,
					TextTruncate = Enum.TextTruncate.AtEnd,
					AutoButtonColor = false,
					ZIndex = 10,
					Parent = row,
				})
				round(button, 10)
				stroke(button, Palette.BorderSoft, 1, 0.35)
				local popup = registerPopup(create("Frame", {
					Visible = false,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.fromOffset(190, 0),
					BackgroundColor3 = Palette.Surface,
					BorderSizePixel = 0,
					ZIndex = 40,
					Parent = Screen,
				}))
				round(popup, 14)
				stroke(popup, Palette.Border)
				padding(popup, 6, 6, 6, 6)
				local popupHolder = create("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 41,
					Parent = popup,
				})
				layout(popupHolder, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4)
				local function getText()
					if multi then
						local parts = {}
						for key in pairs(current) do parts[#parts + 1] = key end
						table.sort(parts)
						return (#parts == 0 and "None" or table.concat(parts, ", ")) .. " v"
					end
					return tostring(current) .. " v"
				end
				local function setValue(value)
					if multi then
						current[value] = not current[value] or nil
						if flag then Library.Flags[flag] = current end
						if callback then callback(current) end
					else
						current = value
						if flag then Library.Flags[flag] = value end
						if callback then callback(value) end
						popup.Visible = false
					end
					button.Text = getText()
				end
				local function rebuild()
					clearChildren(popupHolder, function(child) return child:IsA("TextButton") end)
					for _, option in ipairs(optionsList) do
						local optionButton = create("TextButton", {
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundColor3 = Palette.SurfaceAlt,
							BorderSizePixel = 0,
							Text = "  " .. tostring(option),
							TextXAlignment = Enum.TextXAlignment.Left,
							Font = Enum.Font.Gotham,
							TextSize = 11,
							TextColor3 = Palette.Text,
							AutoButtonColor = false,
							ZIndex = 42,
							Parent = popupHolder,
						})
						round(optionButton, 10)
						optionButton.MouseEnter:Connect(function()
							tween(optionButton, { BackgroundColor3 = Palette.SurfaceSoft })
						end)
						optionButton.MouseLeave:Connect(function()
							tween(optionButton, { BackgroundColor3 = Palette.SurfaceAlt })
						end)
						optionButton.MouseButton1Click:Connect(function()
							setValue(option)
						end)
					end
				end
				if flag then Library.Flags[flag] = current end
				rebuild()
				button.Text = getText()
				button.MouseButton1Click:Connect(function()
					closeAllPopups()
					local absolute = button.AbsolutePosition
					popup.Position = UDim2.fromOffset(absolute.X - 74, absolute.Y + 32)
					popup.Visible = true
				end)
				return {
					SetValue = function(_, value) setValue(value) end,
					GetValue = function() return current end,
					SetOptions = function(_, newOptions) optionsList = newOptions rebuild() end,
				}
			end

			function sectionObject:AddColorpicker(opts)
				opts = opts or {}
				local flag = opts.Flag
				local callback = opts.Callback
				local current = opts.Value or Color3.fromRGB(255, 100, 100)
				local hue, sat, val = Color3.toHSV(current)
				local row = createRow(40)
				createRowLabel(row, opts.Title or "Colorpicker")
				local preview = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(34, 24),
					BackgroundColor3 = current,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 10,
					Parent = row,
				})
				round(preview, 10)
				stroke(preview, Palette.BorderSoft, 1, 0.2)
				local popup = registerPopup(create("Frame", {
					Visible = false,
					Size = UDim2.fromOffset(220, 184),
					BackgroundColor3 = Palette.Surface,
					BorderSizePixel = 0,
					ZIndex = 40,
					Parent = Screen,
				}))
				round(popup, 14)
				stroke(popup, Palette.Border)
				padding(popup, 10, 10, 10, 10)
				local svFrame = create("Frame", {
					Size = UDim2.fromOffset(200, 116),
					BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
					BorderSizePixel = 0,
					ZIndex = 41,
					Parent = popup,
				})
				round(svFrame, 10)
				local whiteOverlay = create("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Palette.White,
					BorderSizePixel = 0,
					ZIndex = 42,
					Parent = svFrame,
				})
				round(whiteOverlay, 10)
				gradient(whiteOverlay, 0, ColorSequence.new(Palette.White, Palette.White), NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }))
				local blackOverlay = create("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Palette.Black,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					ZIndex = 43,
					Parent = svFrame,
				})
				round(blackOverlay, 10)
				gradient(blackOverlay, 90, ColorSequence.new(Palette.Black, Palette.Black), NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }))
				local svCursor = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(sat, 0, 1 - val, 0),
					Size = UDim2.fromOffset(12, 12),
					BackgroundColor3 = Palette.White,
					BorderSizePixel = 0,
					ZIndex = 44,
					Parent = svFrame,
				})
				round(svCursor, 999)
				stroke(svCursor, Palette.Black)
				local hueBar = create("Frame", {
					Size = UDim2.fromOffset(200, 12),
					Position = UDim2.new(0, 0, 0, 126),
					BackgroundColor3 = Palette.White,
					BorderSizePixel = 0,
					ZIndex = 41,
					Parent = popup,
				})
				round(hueBar, 999)
				gradient(hueBar, 0, ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				}))
				local hueCursor = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(hue, 0, 0.5, 0),
					Size = UDim2.fromOffset(8, 16),
					BackgroundColor3 = Palette.White,
					BorderSizePixel = 0,
					ZIndex = 42,
					Parent = hueBar,
				})
				round(hueCursor, 999)
				local rgbLabel = createLabel(popup, {
					Text = "",
					TextColor3 = Palette.Muted,
					TextSize = 11,
					Size = UDim2.new(1, 0, 0, 16),
					Position = UDim2.new(0, 0, 0, 148),
					ZIndex = 41,
				})
				local draggingSV = false
				local draggingHue = false
				local function updateColor()
					current = Color3.fromHSV(hue, sat, val)
					preview.BackgroundColor3 = current
					svFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
					svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
					hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
					rgbLabel.Text = string.format("RGB: %d, %d, %d", current.R * 255, current.G * 255, current.B * 255)
					if flag then Library.Flags[flag] = current end
					if callback then callback(current) end
				end
				if flag then Library.Flags[flag] = current end
				updateColor()
				local svButton = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 45,
					Parent = svFrame,
				})
				local hueButton = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 45,
					Parent = hueBar,
				})
				local function setSV(input)
					sat = math.clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
					val = 1 - math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
					updateColor()
				end
				local function setHue(input)
					hue = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
					updateColor()
				end
				svButton.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true setSV(input) end
				end)
				hueButton.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true setHue(input) end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = false draggingHue = false end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setSV(input) end
					if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setHue(input) end
				end)
				preview.MouseButton1Click:Connect(function()
					closeAllPopups()
					local absolute = preview.AbsolutePosition
					popup.Position = UDim2.fromOffset(absolute.X - 176, absolute.Y + 30)
					popup.Visible = true
				end)
				return {
					SetValue = function(_, value) current = value hue, sat, val = Color3.toHSV(value) updateColor() end,
					GetValue = function() return current end,
				}
			end

			tab.Sections[#tab.Sections + 1] = sectionObject
			return sectionObject
		end

		self.Tabs[#self.Tabs + 1] = tab
		self.TabMap[name] = tab
		return tab
	end

	updatesHeroButton.MouseButton1Click:Connect(function()
		selectTab(homeTab)
		windowObject:FocusHomeSection("Updates")
	end)
	socialsHeroButton.MouseButton1Click:Connect(function()
		selectTab(homeTab)
		windowObject:FocusHomeSection("Socials")
	end)
	scriptsHeroButton.MouseButton1Click:Connect(function()
		selectTab(homeTab)
		windowObject:FocusHomeSection("Scripts")
	end)

	function windowObject:RefreshLayout()
		local currentDevice, autoWindowSize, autoWindowPosition = getAutoWindowMetrics()
		deviceType = currentDevice
		if autoSize and not isMinimized then
			windowFrame.Size = autoWindowSize
			windowFrame.Position = autoWindowPosition
			expandedHeight = autoWindowSize
		end
		hero.Size = currentDevice == "Phone" and UDim2.new(1, -24, 0, 156) or (currentDevice == "Tablet" and UDim2.new(1, -52, 0, 150) or UDim2.new(1, -72, 0, 146))
		hero.Position = currentDevice == "Phone" and UDim2.new(0, 12, 0, 60) or (currentDevice == "Tablet" and UDim2.new(0, 26, 0, 64) or UDim2.new(0, 36, 0, 68))
		heroTitle.TextSize = currentDevice == "Phone" and 22 or (currentDevice == "Tablet" and 28 or 32)
		heroTitle.Size = currentDevice == "Phone" and UDim2.new(1, 0, 0, 42) or UDim2.new(1, -120, 0, 48)
		heroSubtitle.Size = currentDevice == "Phone" and UDim2.new(1, 0, 0, 42) or UDim2.new(0, currentDevice == "Tablet" and 560 or 660, 0, 36)
		heroSubtitle.Position = UDim2.new(0, 0, 0, currentDevice == "Phone" and 44 or 50)
		heroButtons.Position = UDim2.new(0, 0, 0, currentDevice == "Phone" and 96 or 102)
		content.Position = UDim2.new(0, 14, 0, currentDevice == "Phone" and 206 or (currentDevice == "Tablet" and 218 or 224))
		content.Size = UDim2.new(1, -28, 1, currentDevice == "Phone" and -220 or (currentDevice == "Tablet" and -230 or -238))
		homeCardsLayout.Padding = UDim.new(0, currentDevice == "Phone" and 12 or 14)
		self:RenderHome()
	end

	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			windowObject:RefreshLayout()
		end)
	end

	selectTab(homeTab)
	updateHeroButtons()
	windowObject:RefreshLayout()
	windowObject:SetHero(heroTitleText, heroSubtitleText)

	tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabsHolder.CanvasSize = UDim2.new(0, tabsLayout.AbsoluteContentSize.X + 8, 0, 0)
	end)

	table.insert(Library.Windows, windowObject)
	return windowObject
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		task.defer(function()
			closeAllPopups()
		end)
	end
end)

return Library
