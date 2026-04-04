local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Palette = {
	Background = Color3.fromRGB(8, 9, 14),
	BackgroundAlt = Color3.fromRGB(13, 14, 21),
	Surface = Color3.fromRGB(17, 19, 28),
	SurfaceAlt = Color3.fromRGB(22, 24, 36),
	SurfaceSoft = Color3.fromRGB(27, 29, 43),
	Border = Color3.fromRGB(45, 48, 63),
	BorderSoft = Color3.fromRGB(30, 33, 47),
	Text = Color3.fromRGB(245, 246, 248),
	Muted = Color3.fromRGB(148, 152, 168),
	Accent = Color3.fromRGB(123, 92, 255),
	AccentSoft = Color3.fromRGB(83, 67, 161),
	Success = Color3.fromRGB(96, 210, 135),
	Danger = Color3.fromRGB(220, 92, 92),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
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

local function layout(parent, fillDirection, horizontalAlignment, paddingOffset)
	return create("UIListLayout", {
		FillDirection = fillDirection or Enum.FillDirection.Vertical,
		HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, paddingOffset or 0),
		Parent = parent,
	})
end

local function gradient(parent, rotation, colorSequence, transparencySequence)
	return create("UIGradient", {
		Rotation = rotation or 0,
		Color = colorSequence,
		Transparency = transparencySequence,
		Parent = parent,
	})
end

local function makeButtonBase(button)
	round(button, 999)
	stroke(button, Palette.BorderSoft)
	button.AutoButtonColor = false
	button.MouseEnter:Connect(function()
		tween(button, { BackgroundColor3 = Palette.SurfaceSoft })
	end)
	button.MouseLeave:Connect(function()
		tween(button, { BackgroundColor3 = Palette.Surface })
	end)
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
		local delta = Vector2.new(input.Position.X, input.Position.Y) - dragOrigin
		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

local function createText(parent, props)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = props.Font or Enum.Font.Gotham,
		Text = props.Text or "",
		TextColor3 = props.TextColor3 or Palette.Text,
		TextSize = props.TextSize or 14,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		RichText = props.RichText == true,
		TextWrapped = props.TextWrapped == true,
		AutomaticSize = props.AutomaticSize,
		Size = props.Size or UDim2.new(1, 0, 0, 18),
		Position = props.Position,
		ZIndex = props.ZIndex or 1,
		Parent = parent,
	})
end

local Screen = create("ScreenGui", {
	Name = "CloudyImageUI",
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

local function buildStars(parent)
	local rng = Random.new(1701)
	for _ = 1, 36 do
		local star = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(rng:NextNumber(0.02, 0.98), 0, rng:NextNumber(0.08, 0.95), 0),
			Size = UDim2.new(0, rng:NextInteger(1, 3), 0, rng:NextInteger(1, 3)),
			BackgroundColor3 = Color3.fromRGB(210, 215, 230),
			BackgroundTransparency = rng:NextNumber(0.45, 0.85),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = parent,
		})
		round(star, 999)
	end
end

local function buildShowcasePreview(parent, mode)
	local preview = create("Frame", {
		Name = "Preview",
		Size = UDim2.new(1, 0, 0, 106),
		BackgroundColor3 = Palette.BackgroundAlt,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = parent,
	})
	round(preview, 18)
	stroke(preview, Palette.BorderSoft)
	gradient(preview, 135, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 21, 31)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 12, 19)),
	}))

	if mode == 1 then
		for index, config in ipairs({
			{ 10, 14, 152, 38, "Meta Tags" },
			{ 10, 58, 132, 28, "Responsive" },
			{ 10, 90, 112, 10, "Services" },
		}) do
			local mini = create("Frame", {
				BackgroundColor3 = Palette.SurfaceSoft,
				BackgroundTransparency = index == 3 and 0.25 or 0.08,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(config[1], config[2]),
				Size = UDim2.fromOffset(config[3], config[4]),
				ZIndex = 5,
				Parent = preview,
			})
			round(mini, 10)
			stroke(mini, Palette.BorderSoft, 1, 0.55)
			createText(mini, {
				Text = config[5],
				Font = Enum.Font.GothamSemibold,
				TextSize = 10,
				Size = UDim2.new(1, -12, 1, 0),
				Position = UDim2.new(0, 6, 0, 0),
				ZIndex = 6,
			})
		end
	elseif mode == 2 then
		local center = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.56, 0),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Palette.Background,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = preview,
		})
		round(center, 999)
		stroke(center, Palette.AccentSoft)
		createText(center, {
			Text = "F",
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = Palette.Accent,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 6,
		})
		for index, y in ipairs({ 18, 40, 62, 84 }) do
			local orb = create("Frame", {
				Position = UDim2.fromOffset(182, y),
				Size = UDim2.fromOffset(18, 18),
				BackgroundColor3 = ({ Color3.fromRGB(241, 109, 70), Color3.fromRGB(88, 166, 255), Color3.fromRGB(230, 181, 46), Color3.fromRGB(93, 92, 96) })[index],
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = preview,
			})
			round(orb, 999)
			create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.56, 0),
				Size = UDim2.fromOffset(80 - ((index - 1) * 10), 1),
				Rotation = ({ -8, 0, 8, 14 })[index],
				BackgroundColor3 = Palette.BorderSoft,
				BorderSizePixel = 0,
				ZIndex = 4,
				Parent = preview,
			})
		end
		local avatar = create("Frame", {
			Position = UDim2.fromOffset(22, 50),
			Size = UDim2.fromOffset(24, 24),
			BackgroundColor3 = Palette.SurfaceAlt,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = preview,
		})
		round(avatar, 999)
		stroke(avatar, Palette.BorderSoft)
		createText(avatar, {
			Text = "o",
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = Palette.Muted,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 6,
		})
	else
		for index = 1, 5 do
			local box = create("Frame", {
				BackgroundColor3 = Palette.SurfaceSoft,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(10 + ((index - 1) * 44), 16 + ((index % 2 == 0) and 6 or 0)),
				Size = UDim2.fromOffset(40, 58),
				ZIndex = 5,
				Parent = preview,
			})
			round(box, 9)
			stroke(box, Palette.BorderSoft, 1, 0.45)
			createText(box, {
				Text = ({ "Handle", "Optimize", "Avoid", "Scale", "Refit" })[index],
				Font = Enum.Font.GothamSemibold,
				TextSize = 8,
				TextWrapped = true,
				Size = UDim2.new(1, -8, 1, -8),
				Position = UDim2.new(0, 4, 0, 4),
				ZIndex = 6,
			})
		end
	end

	return preview
end

local function createSurfaceButton(parent, text, width, filled)
	local button = create("TextButton", {
		Size = UDim2.new(0, width, 0, 34),
		BackgroundColor3 = filled and Palette.Text or Palette.Surface,
		BorderSizePixel = 0,
		Text = text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = filled and Palette.Background or Palette.Text,
		ZIndex = 6,
		Parent = parent,
	})
	round(button, 10)
	stroke(button, filled and Palette.Text or Palette.BorderSoft, 1, filled and 0.8 or 0)
	button.AutoButtonColor = false
	button.MouseEnter:Connect(function()
		tween(button, { BackgroundColor3 = filled and Color3.fromRGB(230, 231, 233) or Palette.SurfaceSoft })
	end)
	button.MouseLeave:Connect(function()
		tween(button, { BackgroundColor3 = filled and Palette.Text or Palette.Surface })
	end)
	return button
end

function Library:CreateWindow(options)
	options = options or {}
	local title = options.Title or "Cloudy"
	local size = options.Size or UDim2.new(0, 980, 0, 720)
	local position = options.Position or UDim2.new(0.5, -(size.X.Offset / 2), 0.5, -(size.Y.Offset / 2))
	local heroTitle = options.HeroTitle or "Front-End Developer | Freelancer"
	local heroSubtitle = options.HeroSubtitle or "Responsive interface layout with large content cards, clean contrast, and working interactive controls."

	local windowFrame = create("Frame", {
		Name = "Window",
		Size = size,
		Position = position,
		BackgroundColor3 = Palette.Background,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = Screen,
	})
	round(windowFrame, 18)
	stroke(windowFrame, Palette.Border)
	gradient(windowFrame, 135, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 12, 18)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 8, 13)),
	}))
	buildStars(windowFrame)

	local topDivider = create("Frame", {
		Size = UDim2.new(1, -14, 0, 1),
		Position = UDim2.new(0, 7, 0, 46),
		BackgroundColor3 = Palette.BorderSoft,
		BorderSizePixel = 0,
		BackgroundTransparency = 0.25,
		ZIndex = 3,
		Parent = windowFrame,
	})

	local navBar = create("Frame", {
		Name = "NavBar",
		Size = UDim2.new(1, -22, 0, 34),
		Position = UDim2.new(0, 11, 0, 8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = windowFrame,
	})

	local brandButton = create("TextButton", {
		AutoButtonColor = false,
		Size = UDim2.new(0, 92, 0, 26),
		Position = UDim2.new(0, 6, 0, 4),
		BackgroundColor3 = Palette.Surface,
		BorderSizePixel = 0,
		Text = title,
		Font = Enum.Font.GothamSemibold,
		TextSize = 11,
		TextColor3 = Palette.Text,
		ZIndex = 5,
		Parent = navBar,
	})
	round(brandButton, 999)
	stroke(brandButton, Color3.fromRGB(107, 84, 191))

	local tabStrip = create("ScrollingFrame", {
		Name = "Tabs",
		Size = UDim2.new(1, -290, 0, 26),
		Position = UDim2.new(0, 112, 0, 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ZIndex = 5,
		Parent = navBar,
	})
	local tabLayout = layout(tabStrip, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 14)
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local utilityFrame = create("Frame", {
		Size = UDim2.new(0, 178, 0, 26),
		Position = UDim2.new(1, -184, 0, 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = navBar,
	})
	local utilityLayout = layout(utilityFrame, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, 8)
	utilityLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local contactButton = create("TextButton", {
		Size = UDim2.new(0, 90, 0, 26),
		BackgroundColor3 = Palette.BackgroundAlt,
		BorderSizePixel = 0,
		Text = "CONTACT",
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Palette.Muted,
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = utilityFrame,
	})
	round(contactButton, 999)
	stroke(contactButton, Palette.BorderSoft)

	local themeButton = create("TextButton", {
		Size = UDim2.new(0, 26, 0, 26),
		BackgroundColor3 = Palette.Surface,
		BorderSizePixel = 0,
		Text = "o",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Palette.Muted,
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = utilityFrame,
	})
	makeButtonBase(themeButton)

	local closeButton = create("TextButton", {
		Size = UDim2.new(0, 26, 0, 26),
		BackgroundColor3 = Palette.Surface,
		BorderSizePixel = 0,
		Text = "x",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Palette.Muted,
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = utilityFrame,
	})
	makeButtonBase(closeButton)

	local heroWrap = create("Frame", {
		Name = "Hero",
		Size = UDim2.new(1, -82, 0, 152),
		Position = UDim2.new(0, 42, 0, 106),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = windowFrame,
	})

	local heroTitleLabel = createText(heroWrap, {
		Text = heroTitle,
		Font = Enum.Font.GothamBold,
		TextSize = 34,
		TextWrapped = true,
		Size = UDim2.new(1, -120, 0, 58),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 5,
	})

	local heroSubtitleLabel = createText(heroWrap, {
		Text = heroSubtitle,
		TextColor3 = Palette.Muted,
		TextSize = 14,
		TextWrapped = true,
		Size = UDim2.new(0, 610, 0, 48),
		Position = UDim2.new(0, 0, 0, 62),
		ZIndex = 5,
	})

	local ctaRow = create("Frame", {
		Size = UDim2.new(0, 220, 0, 34),
		Position = UDim2.new(0, 0, 0, 118),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = heroWrap,
	})
	local ctaLayout = layout(ctaRow, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 10)
	ctaLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	createSurfaceButton(ctaRow, "Hire me", 82, true)
	createSurfaceButton(ctaRow, "Github", 62, false)
	createSurfaceButton(ctaRow, "Linked", 62, false)

	local contentFrame = create("Frame", {
		Name = "ContentFrame",
		Size = UDim2.new(1, -42, 1, -288),
		Position = UDim2.new(0, 21, 0, 274),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = windowFrame,
	})

	makeDraggable(navBar, windowFrame)

	local windowObject = {
		Frame = windowFrame,
		HeroTitle = heroTitleLabel,
		HeroSubtitle = heroSubtitleLabel,
		Tabs = {},
		ActiveTab = nil,
	}

	function windowObject:SetHero(newTitle, newSubtitle)
		if newTitle then
			heroTitleLabel.Text = newTitle
		end
		if newSubtitle then
			heroSubtitleLabel.Text = newSubtitle
		end
	end

	closeButton.MouseButton1Click:Connect(function()
		windowFrame.Visible = false
	end)

	contactButton.MouseButton1Click:Connect(function()
		windowFrame.Visible = true
	end)

	themeButton.MouseButton1Click:Connect(function()
		local nowBright = heroSubtitleLabel.TextColor3 == Palette.Muted
		heroSubtitleLabel.TextColor3 = nowBright and Color3.fromRGB(180, 186, 208) or Palette.Muted
		tween(themeButton, { TextColor3 = nowBright and Palette.Accent or Palette.Muted })
	end)

	function windowObject:CreateTab(name)
		name = name or "Tab"
		local first = #self.Tabs == 0

		local tabButton = create("TextButton", {
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = first and Palette.Text or Palette.Muted,
			AutoButtonColor = false,
			ZIndex = 6,
			Parent = tabStrip,
		})

		local page = create("Frame", {
			Name = name .. "Page",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = first,
			ZIndex = 4,
			Parent = contentFrame,
		})

		local scroller = create("ScrollingFrame", {
			Name = "Cards",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Palette.BorderSoft,
			ScrollingDirection = Enum.ScrollingDirection.X,
			ZIndex = 5,
			Parent = page,
		})
		padding(scroller, 0, 12, 0, 12)
		local cardLayout = layout(scroller, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 14)
		cardLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		cardLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroller.CanvasSize = UDim2.new(0, cardLayout.AbsoluteContentSize.X + 24, 0, 0)
		end)

		local tabObject = {
			Button = tabButton,
			Page = page,
			Scroller = scroller,
			Sections = {},
			SectionIndex = 0,
		}

		local function activateTab(target)
			closeAllPopups()
			for _, existing in ipairs(windowObject.Tabs) do
				existing.Page.Visible = false
				existing.Button.TextColor3 = Palette.Muted
			end
			target.Page.Visible = true
			target.Button.TextColor3 = Palette.Text
			windowObject.ActiveTab = target
			windowObject:SetHero(heroTitle, heroSubtitle)
		end

		tabButton.MouseButton1Click:Connect(function()
			activateTab(tabObject)
		end)

		function tabObject:SetHero(tabTitle, tabSubtitle)
			windowObject:SetHero(tabTitle, tabSubtitle)
		end

		function tabObject:CreateSection(sectionTitle)
			self.SectionIndex += 1
			local cardWidth = math.clamp(math.floor((windowFrame.AbsoluteSize.X - 90) / 3), 280, 318)
			local card = create("Frame", {
				Name = "Section",
				Size = UDim2.new(0, cardWidth, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Palette.Surface,
				BorderSizePixel = 0,
				ZIndex = 6,
				Parent = scroller,
			})
			round(card, 20)
			stroke(card, Palette.BorderSoft)
			gradient(card, 180, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 20, 30)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 15, 23)),
			}))

			local cardInner = create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 7,
				Parent = card,
			})
			padding(cardInner, 10, 12, 10, 10)
			layout(cardInner, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 10)

			buildShowcasePreview(cardInner, ((self.SectionIndex - 1) % 3) + 1)

			local headingWrap = create("Frame", {
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = cardInner,
			})
			createText(headingWrap, {
				Text = sectionTitle or "Section",
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				Size = UDim2.new(1, 0, 0, 18),
				Position = UDim2.new(0, 0, 0, 0),
				ZIndex = 8,
			})
			createText(headingWrap, {
				Text = "Working controls with the portfolio card look.",
				TextColor3 = Palette.Muted,
				TextSize = 12,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 22),
				Position = UDim2.new(0, 0, 0, 18),
				ZIndex = 8,
			})

			local controlsHolder = create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 8,
				Parent = cardInner,
			})
			layout(controlsHolder, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 8)

			local sectionObject = {}

			local function controlShell(height)
				local shell = create("Frame", {
					Size = UDim2.new(1, 0, 0, height or 34),
					BackgroundColor3 = Palette.SurfaceAlt,
					BorderSizePixel = 0,
					ZIndex = 9,
					Parent = controlsHolder,
				})
				round(shell, 14)
				stroke(shell, Palette.BorderSoft, 1, 0.35)
				padding(shell, 0, 0, 12, 12)
				return shell
			end

			local function shellLabel(shell, text)
				return createText(shell, {
					Text = text,
					TextSize = 12,
					Size = UDim2.new(0.58, 0, 1, 0),
					TextColor3 = Palette.Text,
					ZIndex = 10,
				})
			end

			function sectionObject:AddDivider()
				return create("Frame", {
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = Palette.BorderSoft,
					BackgroundTransparency = 0.35,
					BorderSizePixel = 0,
					ZIndex = 9,
					Parent = controlsHolder,
				})
			end

			function sectionObject:AddLabel(opts)
				opts = opts or {}
				local shell = controlShell(42)
				local label = createText(shell, {
					Text = opts.Text or "Label",
					TextColor3 = Palette.Muted,
					TextSize = 12,
					TextWrapped = true,
					Size = UDim2.new(1, -24, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
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
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundColor3 = Palette.SurfaceAlt,
					BorderSizePixel = 0,
					Text = opts.Title or "Button",
					Font = Enum.Font.GothamSemibold,
					TextSize = 12,
					TextColor3 = Palette.Text,
					AutoButtonColor = false,
					ZIndex = 9,
					Parent = controlsHolder,
				})
				round(button, 14)
				stroke(button, Palette.BorderSoft, 1, 0.15)
				gradient(button, 90, ColorSequence.new({
					ColorSequenceKeypoint.new(0, Palette.SurfaceSoft),
					ColorSequenceKeypoint.new(1, Palette.SurfaceAlt),
				}))
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
				local shell = controlShell(38)
				shellLabel(shell, opts.Title or "Toggle")

				local switch = create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(46, 24),
					BackgroundColor3 = current and Palette.Text or Palette.BackgroundAlt,
					BorderSizePixel = 0,
					ZIndex = 10,
					Parent = shell,
				})
				round(switch, 999)
				stroke(switch, Palette.BorderSoft)

				local knob = create("Frame", {
					Size = UDim2.fromOffset(18, 18),
					Position = current and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
					BackgroundColor3 = current and Palette.Background or Palette.White,
					BorderSizePixel = 0,
					ZIndex = 11,
					Parent = switch,
				})
				round(knob, 999)

				local hitbox = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 12,
					Parent = switch,
				})

				local function setValue(value)
					current = value
					if flag then
						Library.Flags[flag] = value
					end
					tween(switch, { BackgroundColor3 = value and Palette.Text or Palette.BackgroundAlt })
					tween(knob, {
						Position = value and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
						BackgroundColor3 = value and Palette.Background or Palette.White,
					})
					if callback then
						callback(value)
					end
				end

				if flag then
					Library.Flags[flag] = current
				end

				hitbox.MouseButton1Click:Connect(function()
					setValue(not current)
				end)

				return {
					SetValue = function(_, value)
						setValue(value)
					end,
					GetValue = function()
						return current
					end,
				}
			end

			function sectionObject:AddSlider(opts)
				opts = opts or {}
				local flag = opts.Flag
				local minimum = opts.Min or 0
				local maximum = opts.Max or 100
				local step = opts.Step or 1
				local current = math.clamp(opts.Value or minimum, minimum, maximum)
				local callback = opts.Callback
				local shell = controlShell(54)

				createText(shell, {
					Text = opts.Title or "Slider",
					TextSize = 12,
					Size = UDim2.new(0.58, 0, 0, 16),
					Position = UDim2.new(0, 0, 0, 7),
					ZIndex = 10,
				})
				local valueLabel = createText(shell, {
					Text = tostring(current),
					TextSize = 11,
					TextColor3 = Palette.Muted,
					TextXAlignment = Enum.TextXAlignment.Right,
					Size = UDim2.new(0.4, 0, 0, 16),
					Position = UDim2.new(0.6, 0, 0, 7),
					ZIndex = 10,
				})

				local track = create("Frame", {
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 1, -14),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					ZIndex = 10,
					Parent = shell,
				})
				round(track, 999)
				local fill = create("Frame", {
					Size = UDim2.new((current - minimum) / math.max(maximum - minimum, 1), 0, 1, 0),
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

				local dragButton = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 13,
					Parent = track,
				})

				local dragging = false

				local function setValue(value)
					local snapped = math.clamp(math.round(value / step) * step, minimum, maximum)
					current = snapped
					if flag then
						Library.Flags[flag] = snapped
					end
					local scale = (snapped - minimum) / math.max(maximum - minimum, 1)
					fill.Size = UDim2.new(scale, 0, 1, 0)
					thumb.Position = UDim2.new(scale, 0, 0.5, 0)
					valueLabel.Text = tostring(snapped)
					if callback then
						callback(snapped)
					end
				end

				if flag then
					Library.Flags[flag] = current
				end

				dragButton.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						local ratio = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
						setValue(minimum + (math.clamp(ratio, 0, 1) * (maximum - minimum)))
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if not dragging then
						return
					end
					if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
						return
					end
					local ratio = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
					setValue(minimum + (math.clamp(ratio, 0, 1) * (maximum - minimum)))
				end)

				return {
					SetValue = function(_, value)
						setValue(value)
					end,
					GetValue = function()
						return current
					end,
				}
			end

			function sectionObject:AddTextbox(opts)
				opts = opts or {}
				local flag = opts.Flag
				local callback = opts.Callback
				local shell = controlShell(38)
				shellLabel(shell, opts.Title or "Textbox")

				local box = create("TextBox", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0.42, 0, 0, 26),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					Text = opts.Value or "",
					PlaceholderText = opts.Placeholder or "...",
					PlaceholderColor3 = Palette.Muted,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = Palette.Text,
					ClearTextOnFocus = opts.ClearOnFocus ~= false,
					ZIndex = 10,
					Parent = shell,
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
					SetValue = function(_, value)
						box.Text = value
						if flag then
							Library.Flags[flag] = value
						end
					end,
					GetValue = function()
						return box.Text
					end,
				}
			end

			function sectionObject:AddKeybind(opts)
				opts = opts or {}
				local flag = opts.Flag
				local callback = opts.Callback
				local current = opts.Default or Enum.KeyCode.Unknown
				local listening = false
				local shell = controlShell(38)
				shellLabel(shell, opts.Title or "Keybind")

				local bindButton = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0.42, 0, 0, 26),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					Text = current == Enum.KeyCode.Unknown and "[ NONE ]" or ("[ " .. current.Name .. " ]"),
					Font = Enum.Font.GothamSemibold,
					TextSize = 11,
					TextColor3 = Palette.Muted,
					AutoButtonColor = false,
					ZIndex = 10,
					Parent = shell,
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
						if gameProcessed then
							return
						end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							current = input.KeyCode
							if flag then
								Library.Flags[flag] = current
							end
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
					GetValue = function()
						return current
					end,
				}
			end

			function sectionObject:AddDropdown(opts)
				opts = opts or {}
				local flag = opts.Flag
				local optionsList = opts.Options or {}
				local multiple = opts.Multi == true
				local callback = opts.Callback
				local current = multiple and {} or (opts.Value or optionsList[1] or "")
				local shell = controlShell(38)
				shellLabel(shell, opts.Title or "Dropdown")

				local mainButton = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0.42, 0, 0, 26),
					BackgroundColor3 = Palette.BackgroundAlt,
					BorderSizePixel = 0,
					Text = "",
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextColor3 = Palette.Text,
					AutoButtonColor = false,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 10,
					Parent = shell,
				})
				round(mainButton, 10)
				stroke(mainButton, Palette.BorderSoft, 1, 0.35)

				local popup = registerPopup(create("Frame", {
					Name = "Popup",
					Visible = false,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(0, 180, 0, 0),
					BackgroundColor3 = Palette.Surface,
					BorderSizePixel = 0,
					ZIndex = 40,
					Parent = Screen,
				}))
				round(popup, 14)
				stroke(popup, Palette.Border)
				padding(popup, 6, 6, 6, 6)

				local popupList = create("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 41,
					Parent = popup,
				})
				layout(popupList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4)

				local function getDisplayText()
					if multiple then
						local selected = {}
						for value in pairs(current) do
							table.insert(selected, value)
						end
						table.sort(selected)
						return (#selected == 0 and "None" or table.concat(selected, ", ")) .. " v"
					end
					return tostring(current) .. " v"
				end

				local function pushValue(value)
					if multiple then
						if current[value] then
							current[value] = nil
						else
							current[value] = true
						end
						if flag then
							Library.Flags[flag] = current
						end
						if callback then
							callback(current)
						end
					else
						current = value
						if flag then
							Library.Flags[flag] = value
						end
						if callback then
							callback(value)
						end
						popup.Visible = false
					end
					mainButton.Text = getDisplayText()
				end

				local function rebuildOptions()
					for _, child in ipairs(popupList:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end
					for _, option in ipairs(optionsList) do
						local optionButton = create("TextButton", {
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundColor3 = Palette.SurfaceAlt,
							BorderSizePixel = 0,
							Text = "  " .. tostring(option),
							Font = Enum.Font.Gotham,
							TextSize = 11,
							TextColor3 = Palette.Text,
							TextXAlignment = Enum.TextXAlignment.Left,
							AutoButtonColor = false,
							ZIndex = 42,
							Parent = popupList,
						})
						round(optionButton, 10)
						optionButton.MouseEnter:Connect(function()
							tween(optionButton, { BackgroundColor3 = Palette.SurfaceSoft })
						end)
						optionButton.MouseLeave:Connect(function()
							tween(optionButton, { BackgroundColor3 = Palette.SurfaceAlt })
						end)
						optionButton.MouseButton1Click:Connect(function()
							pushValue(option)
						end)
					end
				end

				if flag then
					Library.Flags[flag] = current
				end

				rebuildOptions()
				mainButton.Text = getDisplayText()

				mainButton.MouseButton1Click:Connect(function()
					closeAllPopups()
					local absolute = mainButton.AbsolutePosition
					local absoluteSize = mainButton.AbsoluteSize
					popup.Position = UDim2.fromOffset(absolute.X - 70, absolute.Y + absoluteSize.Y + 6)
					popup.Visible = true
				end)

				return {
					SetValue = function(_, value)
						pushValue(value)
					end,
					GetValue = function()
						return current
					end,
					SetOptions = function(_, newOptions)
						optionsList = newOptions
						rebuildOptions()
						mainButton.Text = getDisplayText()
					end,
				}
			end

			function sectionObject:AddColorpicker(opts)
				opts = opts or {}
				local flag = opts.Flag
				local callback = opts.Callback
				local current = opts.Value or Color3.fromRGB(255, 100, 100)
				local hue, sat, val = Color3.toHSV(current)
				local shell = controlShell(38)
				shellLabel(shell, opts.Title or "Colorpicker")

				local preview = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(34, 24),
					BackgroundColor3 = current,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 10,
					Parent = shell,
				})
				round(preview, 10)
				stroke(preview, Palette.BorderSoft, 1, 0.2)

				local popup = registerPopup(create("Frame", {
					Name = "ColorPopup",
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
				gradient(whiteOverlay, 0, ColorSequence.new(Palette.White, Palette.White), NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}))

				local blackOverlay = create("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Palette.Black,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					ZIndex = 43,
					Parent = svFrame,
				})
				round(blackOverlay, 10)
				gradient(blackOverlay, 90, ColorSequence.new(Palette.Black, Palette.Black), NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				}))

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
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
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

				local rgbLabel = createText(popup, {
					Text = "",
					TextColor3 = Palette.Muted,
					TextSize = 11,
					Size = UDim2.new(1, 0, 0, 18),
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
					if flag then
						Library.Flags[flag] = current
					end
					if callback then
						callback(current)
					end
				end

				if flag then
					Library.Flags[flag] = current
				end
				updateColor()

				local svButton = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 45,
					Parent = svFrame,
				})
				local hueButton = create("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
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
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSV = true
						setSV(input)
					end
				end)
				hueButton.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingHue = true
						setHue(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSV = false
						draggingHue = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						setSV(input)
					elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						setHue(input)
					end
				end)

				preview.MouseButton1Click:Connect(function()
					closeAllPopups()
					local absolute = preview.AbsolutePosition
					popup.Position = UDim2.fromOffset(absolute.X - 176, absolute.Y + 30)
					popup.Visible = true
				end)

				return {
					SetValue = function(_, value)
						current = value
						hue, sat, val = Color3.toHSV(value)
						updateColor()
					end,
					GetValue = function()
						return current
					end,
				}
			end

			table.insert(self.Sections, sectionObject)
			return sectionObject
		end

		table.insert(self.Tabs, tabObject)
		tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tabStrip.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 8, 0, 0)
		end)
		if first then
			self.ActiveTab = tabObject
		end
		return tabObject
	end

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
