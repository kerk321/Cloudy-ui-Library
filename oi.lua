local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

local Theme = {
	Shadow = Color3.fromRGB(6, 8, 12),
	Text = Color3.fromRGB(242, 246, 252),
	Border = Color3.fromRGB(50, 58, 70),
	Inline = Color3.fromRGB(24, 28, 35),
	Image = Color3.fromRGB(245, 247, 250),
	DarkGradient = Color3.fromRGB(15, 18, 23),
	InactiveText = Color3.fromRGB(148, 158, 172),
	Background = Color3.fromRGB(19, 22, 27),
	Element = Color3.fromRGB(48, 56, 69),
	Accent = Color3.fromRGB(37, 132, 240),
	AccentSoft = Color3.fromRGB(72, 84, 102),
	Success = Color3.fromRGB(94, 186, 125)
}

local Fonts = {
	Header = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	Heavy = Enum.Font.GothamSemibold
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
		local isSpecialPadding = key == "Padding" and typeof(value) == "table"
		if key ~= "Children" and key ~= "Corner" and key ~= "Stroke" and key ~= "Gradient" and not isSpecialPadding then
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

local function isPhone()
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1280, 720)
	return UserInputService.TouchEnabled and (size.X < 760 or size.Y < 760)
end

local function getWindowMetrics()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local phone = isPhone()

	if phone then
		local width = math.clamp(math.floor(viewport.X - 24), 300, 430)
		local height = math.clamp(math.floor(viewport.Y - 120), 360, 620)
		return UDim2.fromOffset(width, height), UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	end

	local width = math.clamp(math.floor(viewport.X * 0.58), 720, 980)
	local height = math.clamp(math.floor(viewport.Y * 0.76), 470, 650)
	return UDim2.fromOffset(width, height), UDim2.new(0.5, -width / 2, 0.5, -height / 2)
end

local function animateColor(object, property, color)
	TweenService:Create(object, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		[property] = color
	}):Play()
end

local function makeDrag(handle, frame)
	local dragging = false
	local dragStart
	local startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

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
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)
end

local function makeButton(text, height)
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or 36),
		Font = Fonts.Heavy,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Corner = UDim.new(0, 8),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.15,
			Thickness = 1
		}
	})

	button.MouseEnter:Connect(function()
		animateColor(button, "BackgroundColor3", Color3.fromRGB(61, 72, 89))
	end)

	button.MouseLeave:Connect(function()
		animateColor(button, "BackgroundColor3", Theme.Element)
	end)

	return button
end

local function makeTextLabel(text, size, color, font)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, size + 6),
		Font = font or Fonts.Body,
		Text = text,
		TextColor3 = color or Theme.Text,
		TextSize = size,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y
	})
end

local function applyCanvas(scroll, layout, extra)
	local function update()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 0))
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
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
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true
	})
	protectGui(screenGui)

	local shellSize, shellPosition = getWindowMetrics()

	local overlay = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1)
	})

	local shell = create("Frame", {
		Name = "Shell",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = shellPosition,
		Size = shellSize,
		Corner = UDim.new(0, 14),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.08,
			Thickness = 1.2
		},
		Gradient = {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 33, 39)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 18, 22))
			})
		}
	})

	local shadow = create("ImageLabel", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Theme.Shadow,
		ImageTransparency = 0.28,
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.new(1, 68, 1, 68),
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = 0
	})

	local header = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 86)
	})

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(18, 16),
		Size = UDim2.new(0, 280, 0, 24),
		Font = Fonts.Header,
		Text = options.Title or "kiwisense",
		TextColor3 = Theme.Text,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local version = create("TextLabel", {
		BackgroundColor3 = Theme.Inline,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(118, 18),
		Size = UDim2.fromOffset(42, 18),
		Font = Fonts.Heavy,
		Text = options.Version or "v2.1",
		TextColor3 = Theme.InactiveText,
		TextSize = 11,
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
		Position = UDim2.fromOffset(18, 41),
		Size = UDim2.new(0, 280, 0, 18),
		Font = Fonts.Body,
		Text = options.SubTitle or "mobile-ready control panel",
		TextColor3 = Theme.InactiveText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local closeButton = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -34, 0, 8),
		Size = UDim2.fromOffset(26, 26),
		Font = Fonts.Heavy,
		Text = "x",
		TextColor3 = Theme.Text,
		TextSize = 20
	})

	local tabBarBack = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(18, 21, 25),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 46),
		Size = UDim2.new(0, 320, 0, 34),
		Corner = UDim.new(1, 0),
		Stroke = {
			Color = Theme.Border,
			Transparency = 0.18,
			Thickness = 1
		}
	})

	local tabList = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center
	})

	local tabPadding = create("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4)
	})

	local body = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 92),
		Size = UDim2.new(1, -32, 1, -108)
	})

	local pageContainer = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1)
	})

	shadow.Parent = screenGui
	overlay.Parent = screenGui
	shell.Parent = screenGui
	header.Parent = shell
	title.Parent = header
	version.Parent = header
	subTitle.Parent = header
	closeButton.Parent = header
	tabBarBack.Parent = header
	tabPadding.Parent = tabBarBack
	tabList.Parent = tabBarBack
	body.Parent = shell
	pageContainer.Parent = body

	makeDrag(header, shell)

	local window = {
		Gui = screenGui,
		Shell = shell,
		Body = body,
		Header = header,
		TabBar = tabBarBack,
		PageContainer = pageContainer,
		Tabs = {},
		ActiveTab = nil,
		Destroyed = false
	}

	local function relayout()
		if window.Destroyed then
			return
		end

		local size, position = getWindowMetrics()
		local phone = isPhone()
		shell.Size = size
		shell.Position = position
		tabBarBack.Size = phone and UDim2.new(1, -88, 0, 34) or UDim2.new(0, 320, 0, 34)
		for _, tab in ipairs(window.Tabs) do
			if tab.UpdateLayout then
				tab:UpdateLayout()
			end
		end
	end

	closeButton.MouseButton1Click:Connect(function()
		window:Destroy()
	end)

	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
	end

	function window:Destroy()
		if self.Destroyed then
			return
		end
		self.Destroyed = true
		self.Gui:Destroy()
	end

	function window:SetTab(tabObject)
		for _, tab in ipairs(self.Tabs) do
			tab.Button.BackgroundColor3 = tab == tabObject and Theme.Accent or Color3.fromRGB(22, 24, 28)
			tab.Button.TextColor3 = tab == tabObject and Theme.Text or Theme.InactiveText
			tab.Page.Visible = tab == tabObject
		end
		self.ActiveTab = tabObject
	end

	function window:CreateTab(name)
		local tabButton = create("TextButton", {
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Color3.fromRGB(22, 24, 28),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(78, 26),
			Font = Fonts.Heavy,
			Text = name,
			TextColor3 = Theme.InactiveText,
			TextSize = 13,
			Corner = UDim.new(1, 0),
			Padding = {
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14)
			}
		})

		local page = create("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			Position = UDim2.fromOffset(0, 0),
			ScrollBarImageColor3 = Theme.Accent,
			ScrollBarThickness = 4,
			Size = UDim2.fromScale(1, 1),
			Visible = false
		})

		local content = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, -4, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y
		})

		local columns = create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Wraps = false
		})

		local leftColumn = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(0.5, -6, 0, 0)
		})

		local rightColumn = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(0.5, -6, 0, 0)
		})

		local leftLayout = create("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local rightLayout = create("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local pagePadding = create("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2)
		})

		tabButton.Parent = tabBarBack
		page.Parent = pageContainer
		content.Parent = page
		pagePadding.Parent = content
		columns.Parent = content
		leftColumn.Parent = content
		rightColumn.Parent = content
		leftLayout.Parent = leftColumn
		rightLayout.Parent = rightColumn

		applyCanvas(page, columns, 28)

		local tab = {
			Window = self,
			Button = tabButton,
			Page = page,
			Content = content,
			Left = leftColumn,
			Right = rightColumn,
			Layouts = {
				Left = leftLayout,
				Right = rightLayout
			}
		}

		function tab:UpdateLayout()
			if isPhone() then
				columns.FillDirection = Enum.FillDirection.Vertical
				leftColumn.Size = UDim2.new(1, 0, 0, 0)
				rightColumn.Size = UDim2.new(1, 0, 0, 0)
			else
				columns.FillDirection = Enum.FillDirection.Horizontal
				leftColumn.Size = UDim2.new(0.5, -6, 0, 0)
				rightColumn.Size = UDim2.new(0.5, -6, 0, 0)
			end
		end

		function tab:CreateSection(titleText, side)
			local target = side == "Right" and self.Right or self.Left

			local section = create("Frame", {
				BackgroundColor3 = Theme.Background,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Corner = UDim.new(0, 10),
				Stroke = {
					Color = Theme.Border,
					Transparency = 0.1,
					Thickness = 1
				},
				Padding = {
					PaddingTop = UDim.new(0, 12),
					PaddingBottom = UDim.new(0, 12),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12)
				}
			})

			local sectionTitle = makeTextLabel(titleText, 18, Theme.Text, Fonts.Heavy)
			local sectionLayout = create("UIListLayout", {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			section.Parent = target
			sectionTitle.Parent = section
			sectionLayout.Parent = section

			local api = {}

			function api:AddLabel(text)
				local label = makeTextLabel(text, 14, Theme.InactiveText, Fonts.Body)
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
					local tag = create("TextLabel", {
						BackgroundColor3 = Theme.Background,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(0, 0),
						Size = UDim2.fromOffset(100, 18),
						Font = Fonts.Heavy,
						Text = text,
						TextColor3 = Theme.InactiveText,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					tag.Parent = holder
				end

				holder.Parent = section
				return holder
			end

			function api:AddButton(config)
				config = config or {}
				local button = makeButton(config.Text or "button", 38)
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
					Size = UDim2.new(1, 0, 0, 66)
				})

				local label = makeTextLabel(config.Text or "textbox", 14, Theme.Text, Fonts.Heavy)
				label.Size = UDim2.new(1, 0, 0, 18)

				local box = create("TextBox", {
					BackgroundColor3 = Theme.Element,
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					PlaceholderText = config.Placeholder or "enter text",
					Position = UDim2.fromOffset(0, 26),
					Size = UDim2.new(1, 0, 0, 36),
					Font = Fonts.Body,
					Text = config.Default or "",
					TextColor3 = Theme.Text,
					TextSize = 14,
					PlaceholderColor3 = Theme.InactiveText,
					Corner = UDim.new(0, 8),
					Stroke = {
						Color = Theme.Border,
						Transparency = 0.15,
						Thickness = 1
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

				local button = create("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 42),
					Font = Fonts.Heavy,
					Text = "",
					Corner = UDim.new(0, 8),
					Stroke = {
						Color = Theme.Border,
						Transparency = 0.12,
						Thickness = 1
					}
				})

				local label = create("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.new(1, -58, 1, 0),
					Font = Fonts.Heavy,
					Text = config.Text or "toggle",
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local track = create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = state and Theme.Accent or Theme.Element,
					BorderSizePixel = 0,
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(42, 22),
					Corner = UDim.new(1, 0)
				})

				local knob = create("Frame", {
					BackgroundColor3 = Theme.Text,
					BorderSizePixel = 0,
					Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
					Size = UDim2.fromOffset(18, 18),
					Corner = UDim.new(1, 0)
				})

				label.Parent = button
				track.Parent = button
				knob.Parent = track
				button.Parent = section

				local function setState(value)
					state = value
					animateColor(track, "BackgroundColor3", state and Theme.Accent or Theme.Element)
					TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
					}):Play()
					if config.Callback then
						config.Callback(state)
					end
				end

				button.MouseButton1Click:Connect(function()
					setState(not state)
				end)

				return {
					Set = setState,
					Get = function()
						return state
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
					Size = UDim2.new(1, 0, 0, 62)
				})

				local titleRow = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 18)
				})

				local label = makeTextLabel(config.Text or "slider", 14, Theme.Text, Fonts.Heavy)
				label.Size = UDim2.new(1, -60, 1, 0)

				local valueLabel = create("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -54, 0, 0),
					Size = UDim2.fromOffset(54, 18),
					Font = Fonts.Heavy,
					Text = tostring(value),
					TextColor3 = Theme.InactiveText,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right
				})

				local bar = create("Frame", {
					BackgroundColor3 = Theme.Element,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 32),
					Size = UDim2.new(1, 0, 0, 10),
					Corner = UDim.new(1, 0)
				})

				local fill = create("Frame", {
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),
					Corner = UDim.new(1, 0)
				})

				local dragging = false

				label.Parent = titleRow
				valueLabel.Parent = titleRow
				titleRow.Parent = holder
				bar.Parent = holder
				fill.Parent = bar
				holder.Parent = section

				local function setValueFromAlpha(alpha)
					alpha = math.clamp(alpha, 0, 1)
					value = math.floor((min + (max - min) * alpha) + 0.5)
					fill.Size = UDim2.fromScale((value - min) / (max - min == 0 and 1 or max - min), 1)
					valueLabel.Text = tostring(value)
					if config.Callback then
						config.Callback(value)
					end
				end

				setValueFromAlpha((value - min) / (max - min == 0 and 1 or max - min))

				local function updateFromInput(input)
					local alpha = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
					setValueFromAlpha(alpha)
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

				return {
					Set = function(_, newValue)
						setValueFromAlpha((math.clamp(newValue, min, max) - min) / (max - min == 0 and 1 or max - min))
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

				local label = makeTextLabel(config.Text or "dropdown", 14, Theme.Text, Fonts.Heavy)
				label.Size = UDim2.new(1, 0, 0, 18)

				local button = makeButton(tostring(selected), 36)
				button.TextXAlignment = Enum.TextXAlignment.Left
				button.TextSize = 13
				create("UIPadding", {
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12)
				}).Parent = button

				local list = create("Frame", {
					BackgroundColor3 = Theme.Background,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					Visible = false,
					Corner = UDim.new(0, 8),
					Stroke = {
						Color = Theme.Border,
						Transparency = 0.12,
						Thickness = 1
					},
					Padding = {
						PaddingTop = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8)
					}
				})

				local listLayout = create("UIListLayout", {
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder
				})

				label.Parent = holder
				button.Parent = holder
				list.Parent = holder
				listLayout.Parent = list
				holder.Parent = section

				local function choose(value)
					selected = value
					button.Text = tostring(value)
					list.Visible = false
					if config.Callback then
						config.Callback(value)
					end
				end

				for _, option in ipairs(options) do
					local optionButton = makeButton(tostring(option), 32)
					optionButton.TextXAlignment = Enum.TextXAlignment.Left
					create("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10)
					}).Parent = optionButton
					optionButton.Parent = list
					optionButton.MouseButton1Click:Connect(function()
						choose(option)
					end)
				end

				button.MouseButton1Click:Connect(function()
					list.Visible = not list.Visible
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

			return api
		end

		table.insert(self.Tabs, tab)
		tabButton.MouseButton1Click:Connect(function()
			self:SetTab(tab)
		end)

		tab:UpdateLayout()

		if not self.ActiveTab then
			self:SetTab(tab)
		end

		return tab
	end

	relayout()
	return window
end

return setmetatable(Library, Library)
