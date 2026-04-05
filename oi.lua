local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local CloudyUI = {
	Flags = {},
	Theme = {
		Background = Color3.fromRGB(12, 12, 14),
		Panel = Color3.fromRGB(18, 18, 21),
		PanelAlt = Color3.fromRGB(22, 22, 26),
		Section = Color3.fromRGB(15, 15, 18),
		SectionAlt = Color3.fromRGB(25, 25, 29),
		Border = Color3.fromRGB(46, 46, 52),
		BorderSoft = Color3.fromRGB(34, 34, 39),
		Text = Color3.fromRGB(230, 230, 235),
		Muted = Color3.fromRGB(146, 146, 154),
		Accent = Color3.fromRGB(204, 204, 209),
		AccentDark = Color3.fromRGB(118, 118, 124),
		Success = Color3.fromRGB(212, 212, 218),
		Danger = Color3.fromRGB(168, 86, 86),
		Transparent = Color3.fromRGB(0, 0, 0)
	}
}

CloudyUI.__index = CloudyUI

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local function create(className, properties)
	local instance = Instance.new(className)

	for key, value in pairs(properties or {}) do
		if key ~= "Parent" then
			instance[key] = value
		end
	end

	if properties and properties.Parent then
		instance.Parent = properties.Parent
	end

	return instance
end

local function safeCallback(callback, ...)
	if type(callback) ~= "function" then
		return
	end

	local success, result = pcall(callback, ...)
	if not success then
		warn("[CloudyUI] callback error:", result)
	end
end

local function normalizeOptions(options, defaultKey)
	if type(options) == "table" then
		return options
	end

	if defaultKey then
		return {
			[defaultKey] = options
		}
	end

	return {}
end

local function applyStroke(target, color, thickness)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color,
		LineJoinMode = Enum.LineJoinMode.Miter,
		Thickness = thickness or 1,
		Parent = target
	})
end

local function applyPadding(target, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		Parent = target
	})
end

local function setFlag(flag, value)
	if flag and flag ~= "" then
		CloudyUI.Flags[flag] = value
	end
end

local function getGuiParent()
	if gethui then
		local success, ui = pcall(gethui)
		if success and ui then
			return ui
		end
	end

	return CoreGui
end

local function protectGui(gui)
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, gui)
	end

	if protectgui then
		pcall(protectgui, gui)
	end

	return gui
end

local function destroyExisting()
	local parent = getGuiParent()
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "CloudyUILibrary" then
			child:Destroy()
		end
	end
end

local function tween(object, info, properties)
	local animation = TweenService:Create(object, info, properties)
	animation:Play()
	return animation
end

local function formatSliderValue(value, decimals)
	if decimals and decimals > 0 then
		return string.format("%." .. tostring(decimals) .. "f", value)
	end

	if math.abs(value % 1) < 0.001 then
		return tostring(math.floor(value + 0.5))
	end

	return string.format("%.2f", value)
end

local function clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end

	return Vector2.new(1280, 720)
end

local function getDeviceClass()
	local viewport = getViewportSize()
	if not UserInputService.TouchEnabled then
		return "PC", viewport
	end

	if math.min(viewport.X, viewport.Y) <= 700 then
		return "Phone", viewport
	end

	return "Tablet", viewport
end

local function getResponsiveMetrics(preferredWidth, preferredHeight)
	local deviceClass, viewport = getDeviceClass()
	local width = preferredWidth or 780
	local height = preferredHeight or 530
	local metrics = {
		Device = deviceClass,
		Viewport = viewport,
		Width = width,
		Height = height,
		TopbarHeight = 58,
		TabBarHeight = 44,
		TitleSize = 18,
		SubtitleSize = 11,
		TabTextSize = 12,
		ProfileImageSize = 56,
		ProfileX = 18,
		ProfileTextX = 84,
		BottomInset = 18,
		BarMargin = 12,
		MinTabWidth = 88,
		MaxTabBarWidth = 540
	}

	if deviceClass == "Phone" then
		metrics.Width = clamp(width, 300, math.min(viewport.X - 18, 360))
		metrics.Height = clamp(height, 380, math.min(viewport.Y - 22, 460))
		metrics.TopbarHeight = 52
		metrics.TabBarHeight = 40
		metrics.TitleSize = 16
		metrics.SubtitleSize = 10
		metrics.TabTextSize = 11
		metrics.ProfileImageSize = 46
		metrics.ProfileX = 12
		metrics.ProfileTextX = 64
		metrics.BottomInset = 12
		metrics.BarMargin = 8
		metrics.MinTabWidth = 74
		metrics.MaxTabBarWidth = metrics.Width - 12
	elseif deviceClass == "Tablet" then
		metrics.Width = clamp(width, 540, math.min(viewport.X - 42, 760))
		metrics.Height = clamp(height, 420, math.min(viewport.Y - 36, 560))
		metrics.MaxTabBarWidth = math.min(metrics.Width - 18, 560)
	else
		metrics.Width = clamp(width, 620, math.min(viewport.X - 80, 860))
		metrics.Height = clamp(height, 460, math.min(viewport.Y - 70, 620))
		metrics.MaxTabBarWidth = math.min(metrics.Width - 22, 620)
	end

	return metrics
end

local function makeDraggable(handle, target)
	local dragging = false
	local dragStart
	local startPosition

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = target.Position

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

		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

local function bindDrag(object, onChanged)
	local dragging = false

	local function apply(position)
		safeCallback(onChanged, position)
	end

	object.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		apply(input.Position)
	end)

	object.InputEnded:Connect(function(input)
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

		apply(input.Position)
	end)

	return function()
		dragging = false
	end
	end

local function setVisibleForChildren(folder, visible)
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = visible
		end
	end
end

local function getPlayerThumbnail()
	if not LocalPlayer then
		return ""
	end

	local success, image = pcall(function()
		return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)

	if success then
		return image
	end

	return ""
end

function Window:ClosePopups(except)
	for _, popupData in ipairs(self.Popups) do
		if popupData.Popup ~= except then
			popupData.Popup.Visible = false
			if popupData.Connection then
				popupData.Connection:Disconnect()
				popupData.Connection = nil
			end
		end
	end
end

function Window:IsPointInside(guiObject, point)
	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize

	return point.X >= position.X
		and point.X <= position.X + size.X
		and point.Y >= position.Y
		and point.Y <= position.Y + size.Y
end

function Window:RegisterPopup(trigger, popup, getSize)
	local popupData = {
		Trigger = trigger,
		Popup = popup,
		GetSize = getSize,
		Connection = nil
	}

	table.insert(self.Popups, popupData)

	local function updatePosition()
		local size = popupData.GetSize and popupData.GetSize() or Vector2.new(trigger.AbsoluteSize.X, popup.AbsoluteSize.Y)
		popup.Size = UDim2.fromOffset(size.X, size.Y)
		popup.Position = UDim2.fromOffset(trigger.AbsolutePosition.X, trigger.AbsolutePosition.Y + trigger.AbsoluteSize.Y + 6)
	end

	local controller = {}

	function controller:Open()
		self._open = true
		Window.ClosePopups(self.Window, popup)
		popup.Visible = true
		updatePosition()

		if popupData.Connection then
			popupData.Connection:Disconnect()
		end

		popupData.Connection = RunService.RenderStepped:Connect(function()
			if not popup.Visible then
				popupData.Connection:Disconnect()
				popupData.Connection = nil
				return
			end

			updatePosition()
		end)
	end

	function controller:Close()
		popup.Visible = false
		if popupData.Connection then
			popupData.Connection:Disconnect()
			popupData.Connection = nil
		end
	end

	controller.Window = self
	return controller
end

function Window:SetVisible(visible)
	self.Visible = visible
	self.Frame.Visible = visible
	setVisibleForChildren(self.ProfileFolder, visible)
	self.Launcher.ImageTransparency = visible and 0.2 or 0
	if not visible then
		self:ClosePopups()
	end
	return visible
end

function Window:Toggle()
	return self:SetVisible(not self.Visible)
end

function Window:SetTitle(text)
	self.TitleLabel.Text = tostring(text or "Cloudy")
end

function Window:RefreshTabButtons()
	local count = #self.Tabs
	if count == 0 or not self.TabButtonHolder then
		return
	end

	local holderWidth = math.max(self.TabButtonHolder.AbsoluteSize.X, 1)
	local padding = self.TabListLayout and self.TabListLayout.Padding.Offset or 8
	local totalPadding = math.max(0, (count - 1) * padding)
	local width = math.floor((holderWidth - totalPadding) / count)
	local buttonWidth = math.max(self.MinTabWidth or 88, width)
	local canvasWidth = buttonWidth * count + totalPadding

	for _, tab in ipairs(self.Tabs) do
		tab.Button.Size = UDim2.fromOffset(buttonWidth, self.TabBarHeight - 12)
		tab.Button.TextSize = self.TabTextSize or 12
	end

	self.TabButtonHolder.CanvasSize = UDim2.fromOffset(canvasWidth, 0)
end

function Window:ApplyResponsiveLayout()
	local metrics = getResponsiveMetrics(self.PreferredWidth, self.PreferredHeight)
	self.Metrics = metrics
	self.TabBarHeight = metrics.TabBarHeight
	self.MinTabWidth = metrics.MinTabWidth
	self.TabTextSize = metrics.TabTextSize

	self.Frame.Size = UDim2.fromOffset(metrics.Width, metrics.Height)
	self.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.TopBar.Size = UDim2.new(1, 0, 0, metrics.TopbarHeight)
	self.ContentFrame.Position = UDim2.fromOffset(0, metrics.TopbarHeight + 12)
	self.ContentFrame.Size = UDim2.new(1, 0, 1, -(metrics.TopbarHeight + metrics.TabBarHeight + 24))
	self.TitleLabel.TextSize = metrics.TitleSize
	self.SubtitleLabel.TextSize = metrics.SubtitleSize
	self.TabBar.Size = UDim2.fromOffset(math.min(metrics.MaxTabBarWidth, metrics.Width - (metrics.BarMargin * 2)), metrics.TabBarHeight)
	self.TabBar.Position = UDim2.new(0.5, 0, 1, -metrics.BarMargin)
	self.ProfileImage.Position = UDim2.new(0, metrics.ProfileX, 1, -(metrics.ProfileImageSize + metrics.BottomInset + 6))
	self.ProfileImage.Size = UDim2.fromOffset(metrics.ProfileImageSize, metrics.ProfileImageSize)
	self.DisplayNameLabel.Position = UDim2.new(0, metrics.ProfileTextX, 1, -(metrics.BottomInset + 26))
	self.DisplayNameLabel.Size = UDim2.fromOffset(math.min(220, metrics.Width - metrics.ProfileTextX - 16), 18)
	self.DisplayNameLabel.TextSize = metrics.Device == "Phone" and 12 or 13
	self.UsernameLabel.Position = UDim2.new(0, metrics.ProfileTextX, 1, -(metrics.BottomInset + 8))
	self.UsernameLabel.Size = UDim2.fromOffset(math.min(220, metrics.Width - metrics.ProfileTextX - 16), 14)
	self.UsernameLabel.TextSize = metrics.Device == "Phone" and 10 or 11
	self:RefreshTabButtons()
end

function Window:SelectTab(tabObject)
	for _, tab in ipairs(self.Tabs) do
		local selected = tab == tabObject
		tab.Page.Visible = selected
		tab.Button.BackgroundColor3 = selected and self.Theme.PanelAlt or self.Theme.Panel
		tab.Button.TextColor3 = selected and self.Theme.Text or self.Theme.Muted
		tab.Button.BorderColor3 = selected and self.Theme.AccentDark or self.Theme.BorderSoft
	end
end

function Window:Destroy()
	if self.ViewportConnection then
		self.ViewportConnection:Disconnect()
		self.ViewportConnection = nil
	end

	if self.CameraSwapConnection then
		self.CameraSwapConnection:Disconnect()
		self.CameraSwapConnection = nil
	end

	if self.TabResizeConnection then
		self.TabResizeConnection:Disconnect()
		self.TabResizeConnection = nil
	end

	if self.Screen then
		self.Screen:Destroy()
		self.Screen = nil
	end
end

function Window:AddTab(options)
	options = normalizeOptions(options, "Title")

	local tabButton = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = self.Theme.Panel,
		BorderColor3 = self.Theme.BorderSoft,
		BorderSizePixel = 1,
		Font = Enum.Font.GothamBold,
		Name = tostring(options.Title or "Tab") .. "Button",
		Size = UDim2.fromOffset(options.Width or 112, (self.TabBarHeight or 44) - 12),
		Text = tostring(options.Title or "Tab"),
		TextColor3 = self.Theme.Muted,
		TextSize = self.TabTextSize or 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = self.TabButtonHolder
	})

	local page = create("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Name = tostring(options.Title or "Tab") .. "Page",
		Position = UDim2.new(),
		ScrollBarImageColor3 = self.Theme.Border,
		ScrollBarThickness = 3,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		Parent = self.PageHolder
	})

	local columnHolder = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -18, 0, 0),
		Position = UDim2.fromOffset(9, 0),
		Parent = page
	})

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = columnHolder
	})

	local leftColumn = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Name = "LeftColumn",
		Size = UDim2.new(0.5, -6, 0, 0),
		Parent = columnHolder
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = leftColumn
	})

	local rightColumn = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Name = "RightColumn",
		Size = UDim2.new(0.5, -6, 0, 0),
		Parent = columnHolder
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = rightColumn
	})

	local tabObject = setmetatable({
		Window = self,
		Theme = self.Theme,
		Button = tabButton,
		Page = page,
		LeftColumn = leftColumn,
		RightColumn = rightColumn
	}, Tab)

	table.insert(self.Tabs, tabObject)

	tabButton.MouseButton1Click:Connect(function()
		self:SelectTab(tabObject)
	end)

	if #self.Tabs == 1 then
		self:SelectTab(tabObject)
	end

	self:RefreshTabButtons()

	return tabObject
end

function Tab:AddSection(options)
	options = normalizeOptions(options, "Title")
	local side = tostring(options.Side or "Left")
	local parentColumn = side == "Right" and self.RightColumn or self.LeftColumn

	local sectionFrame = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = self.Theme.Section,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Name = tostring(options.Title or "Section"),
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parentColumn
	})

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.Theme.SectionAlt),
			ColorSequenceKeypoint.new(1, self.Theme.Section)
		}),
		Rotation = 90,
		Parent = sectionFrame
	})

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(12, 10),
		Size = UDim2.new(1, -24, 0, 18),
		Text = tostring(options.Title or "Section"),
		TextColor3 = self.Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sectionFrame
	})

	local subtitle = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(12, 28),
		Size = UDim2.new(1, -24, 0, options.Description and 14 or 0),
		Text = tostring(options.Description or ""),
		TextColor3 = self.Theme.Muted,
		TextSize = 11,
		TextTransparency = options.Description and 0 or 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sectionFrame
	})

	local content = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, options.Description and 52 or 42),
		Size = UDim2.new(1, 0, 0, 0),
		Parent = sectionFrame
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = content
	})

	applyPadding(content, 10, 10, 0, 10)

	local sectionObject = setmetatable({
		Tab = self,
		Window = self.Window,
		Theme = self.Theme,
		Frame = sectionFrame,
		Content = content,
		Title = title,
		Subtitle = subtitle
	}, Section)

	local function resizeSection()
		sectionFrame.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + (options.Description and 62 or 52))
		local maxHeight = math.max(self.LeftColumn.AbsoluteSize.Y, self.RightColumn.AbsoluteSize.Y)
		self.Page.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 20)
	end

	content:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeSection)
	self.LeftColumn:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeSection)
	self.RightColumn:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeSection)
	resizeSection()

	return sectionObject
end

function Section:_createRow(height)
	return create("Frame", {
		BackgroundColor3 = self.Theme.Panel,
		BorderColor3 = self.Theme.BorderSoft,
		BorderSizePixel = 1,
		Size = UDim2.new(1, 0, 0, height),
		Parent = self.Content
	})
end

function Section:_createValueText(text)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(0, 96, 1, 0),
		Text = tostring(text or ""),
		TextColor3 = self.Theme.Muted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	end

function Section:AddLabel(options)
	options = normalizeOptions(options, "Text")

	local label = create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 0),
		Text = tostring(options.Text or "Label"),
		TextColor3 = options.Color or self.Theme.Text,
		TextSize = options.Size or 12,
		TextWrapped = true,
		TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
		Parent = self.Content
	})

	return {
		Instance = label,
		Set = function(_, text)
			label.Text = tostring(text)
		end
	}
end

function Section:AddDivider(options)
	options = normalizeOptions(options, "Text")

	local row = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 14),
		Parent = self.Content
	})

	create("Frame", {
		BackgroundColor3 = self.Theme.Border,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, -1),
		Size = UDim2.new(0.5, -32, 0, 1),
		Parent = row
	})

	create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = self.Theme.Border,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, -1),
		Size = UDim2.new(0.5, -32, 0, 1),
		Parent = row
	})

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0.5, -60, 0, 0),
		Size = UDim2.fromOffset(120, 14),
		Text = tostring(options.Text or "Divider"),
		TextColor3 = self.Theme.Muted,
		TextSize = 10,
		Parent = row
	})

	return {
		Instance = row,
		Set = function(_, text)
			label.Text = tostring(text)
		end
	}
end

function Section:AddButton(options)
	options = normalizeOptions(options, "Text")
	local row = self:_createRow(34)

	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = self.Theme.PanelAlt,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(1, -16, 0, 18),
		Text = tostring(options.Text or "Button"),
		Font = Enum.Font.GothamBold,
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		Parent = row
	})

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = self.Theme.BorderSoft
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = self.Theme.PanelAlt
	end)

	button.MouseButton1Click:Connect(function()
		safeCallback(options.Callback)
	end)

	return {
		Instance = row,
		Button = button,
		Fire = function()
			safeCallback(options.Callback)
		end,
		Set = function(_, text)
			button.Text = tostring(text)
		end
	}
end

function Section:AddTextbox(options)
	options = normalizeOptions(options, "Text")
	local row = self:_createRow(42)
	applyPadding(row, 8, 8, 7, 7)

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(0.42, 0, 1, 0),
		Text = tostring(options.Text or "Textbox"),
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = self.Theme.PanelAlt,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderColor3 = self.Theme.Muted,
		PlaceholderText = tostring(options.Placeholder or "Enter text"),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0.58, 0, 0, 26),
		Text = tostring(options.Default or ""),
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	setFlag(options.Flag, box.Text)

	box.FocusLost:Connect(function(enterPressed)
		setFlag(options.Flag, box.Text)
		safeCallback(options.Callback, box.Text, enterPressed)
	end)

	return {
		Instance = row,
		Input = box,
		Get = function()
			return box.Text
		end,
		Set = function(_, value)
			box.Text = tostring(value)
			setFlag(options.Flag, box.Text)
			safeCallback(options.Callback, box.Text, false)
		end
	}
end

function Section:AddKeybind(options)
	options = normalizeOptions(options, "Text")
	local row = self:_createRow(42)
	applyPadding(row, 8, 8, 7, 7)

	local current = options.Default or Enum.KeyCode.Unknown
	local waiting = false

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(0.55, 0, 1, 0),
		Text = tostring(options.Text or "Keybind"),
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	local bindButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = self.Theme.PanelAlt,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 92, 0, 26),
		Text = current ~= Enum.KeyCode.Unknown and current.Name or "NONE",
		TextColor3 = self.Theme.Text,
		TextSize = 11,
		Parent = row
	})

	local function updateLabel()
		bindButton.Text = waiting and "..." or (current ~= Enum.KeyCode.Unknown and current.Name or "NONE")
	end

	local function assign(keyCode)
		current = keyCode or Enum.KeyCode.Unknown
		updateLabel()
		setFlag(options.Flag, current)
		safeCallback(options.Changed, current)
	end

	assign(current)

	bindButton.MouseButton1Click:Connect(function()
		waiting = true
		updateLabel()
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
			waiting = false
			if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
				assign(Enum.KeyCode.Unknown)
			else
				assign(input.KeyCode)
			end
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and current ~= Enum.KeyCode.Unknown and input.KeyCode == current then
			safeCallback(options.Callback, current)
		end
	end)

	return {
		Instance = row,
		Get = function()
			return current
		end,
		Set = function(_, keyCode)
			assign(keyCode)
		end
	}
end

function Section:AddSlider(options)
	options = normalizeOptions(options, "Text")
	local minimum = options.Min or 0
	local maximum = options.Max or 100
	local decimals = options.Decimals or 0
	local increment = options.Increment or (decimals > 0 and 0.1 or 1)
	local default = clamp(options.Default or minimum, minimum, maximum)

	local row = self:_createRow(58)
	applyPadding(row, 8, 8, 8, 8)

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -90, 0, 14),
		Text = tostring(options.Text or "Slider"),
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	local valueBox = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 84, 0, 14),
		Text = "",
		TextColor3 = self.Theme.Muted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row
	})

	local rail = create("Frame", {
		BackgroundColor3 = self.Theme.BorderSoft,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 0, 16),
		Parent = row
	})

	local fill = create("Frame", {
		BackgroundColor3 = self.Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(),
		Parent = rail
	})

	local dragging = false
	local current = default

	local function snap(value)
		return math.floor((value / increment) + 0.5) * increment
	end

	local function setValue(value)
		current = clamp(snap(value), minimum, maximum)
		local alpha = (current - minimum) / math.max(maximum - minimum, 0.0001)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		valueBox.Text = formatSliderValue(current, decimals)
		setFlag(options.Flag, current)
		safeCallback(options.Callback, current)
	end

	local function setFromPosition(position)
		local alpha = clamp((position.X - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
		setValue(minimum + (maximum - minimum) * alpha)
	end

	rail.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = true
		setFromPosition(input.Position)
	end)

	rail.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromPosition(input.Position)
		end
	end)

	valueBox.FocusLost:Connect(function()
		local number = tonumber(valueBox.Text)
		if number then
			setValue(number)
		else
			valueBox.Text = formatSliderValue(current, decimals)
		end
	end)

	setValue(default)

	return {
		Instance = row,
		Get = function()
			return current
		end,
		Set = function(_, value)
			setValue(value)
		end
	}
end

local function createColorPickerPopup(section, trigger, options, compact)
	local window = section.Window
	local theme = section.Theme
	local initial = options.Default or Color3.fromRGB(255, 255, 255)
	local hue, saturation, value = initial:ToHSV()
	local alpha = options.Transparency or 0

	local popup = create("Frame", {
		BackgroundColor3 = theme.Panel,
		BorderColor3 = theme.Border,
		BorderSizePixel = 1,
		Name = tostring(options.Text or options.Flag or "ColorPicker") .. "Popup",
		Visible = false,
		Parent = window.Screen
	})

	local popupPadding = compact and 10 or 12
	applyPadding(popup, popupPadding, popupPadding, popupPadding, popupPadding)

	local sizeX = compact and 212 or 240
	local sizeY = compact and 206 or 222

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 16),
		Text = tostring(options.Text or "Color Picker"),
		TextColor3 = theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = popup
	})

	local satVal = create("Frame", {
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		BorderColor3 = theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.fromOffset(170, 130),
		Parent = popup
	})

	local whiteGradient = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = satVal
	})

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rotation = 0,
		Parent = whiteGradient
	})

	local darkGradient = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = satVal
	})

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Rotation = 90,
		Parent = darkGradient
	})

	local satValCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		Size = UDim2.fromOffset(6, 6),
		Parent = satVal
	})

	local hueBar = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderColor3 = theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.fromOffset(178, 24),
		Size = UDim2.fromOffset(14, 130),
		Parent = popup
	})

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		}),
		Rotation = 90,
		Parent = hueBar
	})

	local hueCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 2, 0, 4),
		Parent = hueBar
	})

	local alphaBar = create("Frame", {
		BackgroundColor3 = theme.SectionAlt,
		BorderColor3 = theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.fromOffset(198, 24),
		Size = UDim2.fromOffset(14, 130),
		Parent = popup
	})

	local alphaFill = create("Frame", {
		BackgroundColor3 = initial,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = alphaBar
	})

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rotation = 90,
		Parent = alphaFill
	})

	local alphaCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 2, 0, 4),
		Parent = alphaBar
	})

	local preview = create("Frame", {
		BackgroundColor3 = initial,
		BorderColor3 = theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.fromOffset(0, 164),
		Size = UDim2.fromOffset(48, 34),
		Parent = popup
	})

	local info = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(58, 164),
		Size = UDim2.fromOffset(sizeX - 58, 34),
		Text = "",
		TextColor3 = theme.Muted,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = popup
	})

	local controller = window:RegisterPopup(trigger, popup, function()
		return Vector2.new(sizeX, sizeY)
	end)

	local state = {
		Color = initial,
		Transparency = alpha
	}

	local function updateVisuals(fireCallback)
		local color = Color3.fromHSV(hue, saturation, value)
		state.Color = color
		state.Transparency = alpha
		satVal.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		alphaFill.BackgroundColor3 = color
		preview.BackgroundColor3 = color
		satValCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
		hueCursor.Position = UDim2.new(0.5, 0, hue, 0)
		alphaCursor.Position = UDim2.new(0.5, 0, alpha, 0)
		info.Text = string.format("RGB %d, %d, %d\nALPHA %.2f", color.R * 255, color.G * 255, color.B * 255, 1 - alpha)
		setFlag(options.Flag, color)
		if options.TransparencyFlag then
			setFlag(options.TransparencyFlag, alpha)
		end
		if fireCallback ~= false then
			safeCallback(options.Callback, color, alpha)
		end
	end

	bindDrag(satVal, function(position)
		saturation = clamp((position.X - satVal.AbsolutePosition.X) / math.max(satVal.AbsoluteSize.X, 1), 0, 1)
		value = 1 - clamp((position.Y - satVal.AbsolutePosition.Y) / math.max(satVal.AbsoluteSize.Y, 1), 0, 1)
		updateVisuals()
	end)

	bindDrag(hueBar, function(position)
		hue = clamp((position.Y - hueBar.AbsolutePosition.Y) / math.max(hueBar.AbsoluteSize.Y, 1), 0, 1)
		updateVisuals()
	end)

	bindDrag(alphaBar, function(position)
		alpha = clamp((position.Y - alphaBar.AbsolutePosition.Y) / math.max(alphaBar.AbsoluteSize.Y, 1), 0, 1)
		updateVisuals()
	end)

	updateVisuals(false)

	return {
		Popup = popup,
		Open = function()
			controller:Open()
		end,
		Close = function()
			controller:Close()
		end,
		Get = function()
			return state.Color, state.Transparency
		end,
		Set = function(_, color, transparency)
			hue, saturation, value = (color or state.Color):ToHSV()
			alpha = transparency or alpha
			updateVisuals()
		end
	}
end

function Section:AddColorPicker(options)
	options = normalizeOptions(options, "Text")
	local row = self:_createRow(42)
	applyPadding(row, 8, 8, 7, 7)

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(0.55, 0, 1, 0),
		Text = tostring(options.Text or "Color Picker"),
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	local previewButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = options.Default or Color3.fromRGB(255, 255, 255),
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 58, 0, 26),
		Text = "",
		Parent = row
	})

	local picker = createColorPickerPopup(self, previewButton, {
		Text = options.Text,
		Flag = options.Flag,
		TransparencyFlag = options.TransparencyFlag,
		Default = options.Default,
		Transparency = options.Transparency,
		Callback = function(color, transparency)
			previewButton.BackgroundColor3 = color
			safeCallback(options.Callback, color, transparency)
		end
	})

	previewButton.MouseButton1Click:Connect(function()
		if picker.Popup.Visible then
			picker:Close()
		else
			picker:Open()
		end
	end)

	return {
		Instance = row,
		Button = previewButton,
		Open = function()
			picker:Open()
		end,
		Close = function()
			picker:Close()
		end,
		Get = function()
			return picker:Get()
		end,
		Set = function(_, color, transparency)
			previewButton.BackgroundColor3 = color
			picker:Set(color, transparency)
		end
	}
end

function Section:AddToggle(options)
	options = normalizeOptions(options, "Text")
	local current = not not options.Default
	local row = self:_createRow(42)
	applyPadding(row, 8, 8, 7, 7)

	local checkbox = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = self.Theme.Section,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.fromOffset(0, 5),
		Size = UDim2.fromOffset(16, 16),
		Text = "",
		Parent = row
	})

	local fill = create("Frame", {
		BackgroundColor3 = self.Theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(10, 10),
		Visible = current,
		Parent = checkbox
	})

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Text = tostring(options.Text or "Toggle"),
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	local rightHolder = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(86, 24),
		Parent = row
	})

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = rightHolder
	})

	local stateLabel = create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Size = UDim2.fromOffset(0, 24),
		Text = current and "ON" or "OFF",
		TextColor3 = current and self.Theme.Accent or self.Theme.Muted,
		TextSize = 11,
		Parent = rightHolder
	})

	local function setState(value)
		current = not not value
		fill.Visible = current
		stateLabel.Text = current and "ON" or "OFF"
		stateLabel.TextColor3 = current and self.Theme.Accent or self.Theme.Muted
		setFlag(options.Flag, current)
		safeCallback(options.Callback, current)
	end

	local function toggle()
		setState(not current)
	end

	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggle()
		end
	end)

	checkbox.MouseButton1Click:Connect(toggle)
	setState(current)

	local api = {
		Instance = row,
		Get = function()
			return current
		end,
		Set = function(_, value)
			setState(value)
		end
	}

	function api:AddColorPicker(colorOptions)
		colorOptions = normalizeOptions(colorOptions, "Text")
		local button = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = colorOptions.Default or Color3.fromRGB(255, 255, 255),
			BorderColor3 = self.Theme.Border,
			BorderSizePixel = 1,
			Size = UDim2.fromOffset(24, 24),
			Text = "",
			Parent = rightHolder
		})

		local picker = createColorPickerPopup(self, button, {
			Text = colorOptions.Text or options.Text,
			Flag = colorOptions.Flag,
			TransparencyFlag = colorOptions.TransparencyFlag,
			Default = colorOptions.Default,
			Transparency = colorOptions.Transparency,
			Callback = function(color, transparency)
				button.BackgroundColor3 = color
				safeCallback(colorOptions.Callback, color, transparency)
			end
		}, true)

		button.MouseButton1Click:Connect(function()
			if picker.Popup.Visible then
				picker:Close()
			else
				picker:Open()
			end
		end)

		return {
			Button = button,
			Get = function()
				return picker:Get()
			end,
			Set = function(_, color, transparency)
				button.BackgroundColor3 = color
				picker:Set(color, transparency)
			end,
			Open = function()
				picker:Open()
			end,
			Close = function()
				picker:Close()
			end
		}
	end

	return api
end

function Section:AddDropdown(options)
	options = normalizeOptions(options, "Text")
	local items = options.Values or options.Options or {}
	local multi = not not options.Multi
	local current = multi and {} or (options.Default or items[1])

	local row = self:_createRow(42)
	applyPadding(row, 8, 8, 7, 7)

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(0.42, 0, 1, 0),
		Text = tostring(options.Text or "Dropdown"),
		TextColor3 = self.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})

	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = self.Theme.PanelAlt,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Font = Enum.Font.Gotham,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0.58, 0, 0, 26),
		Text = "",
		TextColor3 = self.Theme.Text,
		TextSize = 11,
		Parent = row
	})

	local buttonLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -26, 1, 0),
		Text = "",
		TextColor3 = self.Theme.Text,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button
	})

	create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		Text = "V",
		TextColor3 = self.Theme.Muted,
		TextSize = 10,
		Parent = button
	})

	local popup = create("Frame", {
		BackgroundColor3 = self.Theme.Panel,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Visible = false,
		Parent = self.Window.Screen
	})

	local popupList = create("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromOffset(8, 8),
		ScrollBarImageColor3 = self.Theme.Border,
		ScrollBarThickness = 3,
		Size = UDim2.new(1, -16, 1, -16),
		Parent = popup
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = popupList
	})

	local controller = self.Window:RegisterPopup(button, popup, function()
		local height = clamp(#items * 24 + 16, 48, 180)
		return Vector2.new(button.AbsoluteSize.X, height)
	end)

	local optionButtons = {}

	local function isSelected(value)
		if multi then
			return table.find(current, value) ~= nil
		end
		return current == value
	end

	local function updateLabel()
		if multi then
			buttonLabel.Text = #current > 0 and table.concat(current, ", ") or tostring(options.Placeholder or "Select")
		else
			buttonLabel.Text = current and tostring(current) or tostring(options.Placeholder or "Select")
		end
	end

	local function fire()
		setFlag(options.Flag, current)
		safeCallback(options.Callback, current)
	end

	local function refreshButtons()
		for value, optionButton in pairs(optionButtons) do
			local selected = isSelected(value)
			optionButton.BackgroundColor3 = selected and self.Theme.BorderSoft or self.Theme.PanelAlt
			optionButton.TextColor3 = selected and self.Theme.Text or self.Theme.Muted
		end
		updateLabel()
	end

	local function choose(value)
		if multi then
			local existing = table.find(current, value)
			if existing then
				table.remove(current, existing)
			else
				table.insert(current, value)
			end
		else
			current = value
			controller:Close()
		end

		refreshButtons()
		fire()
	end

	for _, value in ipairs(items) do
		local optionButton = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = self.Theme.PanelAlt,
			BorderColor3 = self.Theme.BorderSoft,
			BorderSizePixel = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 0, 20),
			Text = tostring(value),
			TextColor3 = self.Theme.Muted,
			TextSize = 11,
			Parent = popupList
		})

		optionButton.MouseButton1Click:Connect(function()
			choose(value)
		end)

		optionButtons[value] = optionButton
	end

	button.MouseButton1Click:Connect(function()
		if popup.Visible then
			controller:Close()
		else
			controller:Open()
		end
	end)

	if multi and type(options.Default) == "table" then
		for _, value in ipairs(options.Default) do
			table.insert(current, value)
		end
	end

	refreshButtons()
	setFlag(options.Flag, current)

	return {
		Instance = row,
		Get = function()
			return current
		end,
		Set = function(_, value)
			if multi then
				current = type(value) == "table" and value or {}
			else
				current = value
			end
			refreshButtons()
			fire()
		end,
		Refresh = function(_, newValues)
			for _, child in ipairs(popupList:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			table.clear(optionButtons)
			items = newValues or {}
			for _, value in ipairs(items) do
				local optionButton = create("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = self.Theme.PanelAlt,
					BorderColor3 = self.Theme.BorderSoft,
					BorderSizePixel = 1,
					Font = Enum.Font.Gotham,
					Size = UDim2.new(1, 0, 0, 20),
					Text = tostring(value),
					TextColor3 = self.Theme.Muted,
					TextSize = 11,
					Parent = popupList
				})

				optionButton.MouseButton1Click:Connect(function()
					choose(value)
				end)

				optionButtons[value] = optionButton
			end
			refreshButtons()
		end
	}
end

function CloudyUI:CreateWindow(options)
	options = normalizeOptions(options, "Title")
	destroyExisting()
	local metrics = getResponsiveMetrics(options.Width, options.Height)

	local screen = protectGui(create("ScreenGui", {
		DisplayOrder = 100,
		IgnoreGuiInset = true,
		Name = "CloudyUILibrary",
		ResetOnSpawn = false,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = getGuiParent()
	}))

	local launcher = create("ImageButton", {
		AnchorPoint = Vector2.new(1, 1),
		AutoButtonColor = false,
		BackgroundColor3 = self.Theme.Panel,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Image = "rbxassetid://77380393395155",
		ImageColor3 = self.Theme.Text,
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(42, 42),
		Parent = screen
	})

	local profileFolder = create("Folder", {
		Name = "ProfileOverlay",
		Parent = screen
	})

	local profileImage = create("ImageLabel", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = getPlayerThumbnail(),
		Position = UDim2.new(0, 18, 1, -72),
		Size = UDim2.fromOffset(56, 56),
		Parent = profileFolder
	})

	local displayName = create("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 84, 1, -44),
		Size = UDim2.fromOffset(220, 18),
		Text = LocalPlayer and LocalPlayer.DisplayName or "Player",
		TextColor3 = self.Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profileFolder
	})

	local username = create("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Position = UDim2.new(0, 84, 1, -24),
		Size = UDim2.fromOffset(220, 14),
		Text = LocalPlayer and ("@" .. LocalPlayer.Name) or "@Player",
		TextColor3 = self.Theme.Muted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profileFolder
	})

	local frame = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = self.Theme.Background,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(metrics.Width, metrics.Height),
		Parent = screen
	})

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.Theme.PanelAlt),
			ColorSequenceKeypoint.new(1, self.Theme.Background)
		}),
		Rotation = 90,
		Parent = frame
	})

	local topBar = create("Frame", {
		BackgroundColor3 = self.Theme.Panel,
		BorderColor3 = self.Theme.BorderSoft,
		BorderSizePixel = 1,
		Size = UDim2.new(1, 0, 0, metrics.TopbarHeight),
		Parent = frame
	})

	local title = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(16, 10),
		Size = UDim2.new(1, -32, 0, 18),
		Text = tostring(options.Title or "Cloudy UI"),
		TextColor3 = self.Theme.Text,
		TextSize = metrics.TitleSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar
	})

	local subtitle = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(16, 30),
		Size = UDim2.new(1, -32, 0, 14),
		Text = tostring(options.Subtitle or "Dark utility library"),
		TextColor3 = self.Theme.Muted,
		TextSize = metrics.SubtitleSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar
	})

	local contentFrame = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, metrics.TopbarHeight + 12),
		Size = UDim2.new(1, 0, 1, -(metrics.TopbarHeight + metrics.TabBarHeight + 24)),
		Parent = frame
	})

	local pageHolder = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = contentFrame
	})

	local tabBar = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = self.Theme.Panel,
		BorderColor3 = self.Theme.Border,
		BorderSizePixel = 1,
		Position = UDim2.new(0.5, 0, 1, -metrics.BarMargin),
		Size = UDim2.fromOffset(math.min(metrics.MaxTabBarWidth, metrics.Width - (metrics.BarMargin * 2)), metrics.TabBarHeight),
		Parent = frame
	})

	local tabButtonHolder = create("ScrollingFrame", {
		Active = true,
		CanvasSize = UDim2.new(),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = self.Theme.Border,
		ScrollBarThickness = 0,
		Size = UDim2.new(1, -12, 1, -12),
		Position = UDim2.fromOffset(6, 6),
		ScrollingDirection = Enum.ScrollingDirection.X,
		Parent = tabBar
	})

	local tabListLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = tabButtonHolder
	})

	makeDraggable(topBar, frame)

	local window = setmetatable({
		Theme = self.Theme,
		Screen = screen,
		Frame = frame,
		TopBar = topBar,
		ContentFrame = contentFrame,
		TitleLabel = title,
		SubtitleLabel = subtitle,
		Launcher = launcher,
		ProfileFolder = profileFolder,
		ProfileImage = profileImage,
		DisplayNameLabel = displayName,
		UsernameLabel = username,
		PageHolder = pageHolder,
		TabBar = tabBar,
		TabButtonHolder = tabButtonHolder,
		TabListLayout = tabListLayout,
		PreferredWidth = options.Width or 780,
		PreferredHeight = options.Height or 530,
		TabBarHeight = metrics.TabBarHeight,
		MinTabWidth = metrics.MinTabWidth,
		TabTextSize = metrics.TabTextSize,
		Tabs = {},
		Popups = {},
		Visible = true
	}, Window)

	window:ApplyResponsiveLayout()
	window.TabResizeConnection = tabButtonHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		window:RefreshTabButtons()
	end)

	local function hookViewport(camera)
		if window.ViewportConnection then
			window.ViewportConnection:Disconnect()
			window.ViewportConnection = nil
		end

		if camera then
			window.ViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				window:ApplyResponsiveLayout()
			end)
		end
	end

	hookViewport(workspace.CurrentCamera)
	window.CameraSwapConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		hookViewport(workspace.CurrentCamera)
		window:ApplyResponsiveLayout()
	end)

	launcher.MouseButton1Click:Connect(function()
		window:Toggle()
	end)

	if options.ToggleKey then
		UserInputService.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == options.ToggleKey then
				window:Toggle()
			end
		end)
	end

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local point = input.Position
		for _, popupData in ipairs(window.Popups) do
			if popupData.Popup.Visible then
				if window:IsPointInside(popupData.Popup, point) or window:IsPointInside(popupData.Trigger, point) then
					return
				end
			end
		end

		window:ClosePopups()
	end)

	return window
end

return CloudyUI
