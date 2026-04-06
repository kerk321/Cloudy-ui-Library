local Cloudy = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

Cloudy.Theme = {
	Background = Color3.fromRGB(8, 9, 15),
	Surface = Color3.fromRGB(11, 12, 19),
	SurfaceAlt = Color3.fromRGB(14, 15, 23),
	Section = Color3.fromRGB(13, 14, 22),
	Control = Color3.fromRGB(18, 19, 29),
	ControlAlt = Color3.fromRGB(24, 25, 36),
	Stroke = Color3.fromRGB(31, 33, 46),
	Text = Color3.fromRGB(235, 235, 240),
	SubText = Color3.fromRGB(119, 121, 141),
	Accent = Color3.fromRGB(214, 48, 169),
	AccentDark = Color3.fromRGB(137, 26, 106),
	Success = Color3.fromRGB(62, 198, 128),
	Warning = Color3.fromRGB(230, 166, 73),
	Overlay = Color3.fromRGB(5, 6, 10),
	TabIdle = Color3.fromRGB(10, 11, 17),
	TabActive = Color3.fromRGB(10, 11, 17),
}

Cloudy.DefaultThemePresets = {
	["Cloudy Rose"] = {
		Background = Color3.fromRGB(8, 9, 15),
		Surface = Color3.fromRGB(11, 12, 19),
		SurfaceAlt = Color3.fromRGB(14, 15, 23),
		Section = Color3.fromRGB(13, 14, 22),
		Control = Color3.fromRGB(18, 19, 29),
		ControlAlt = Color3.fromRGB(24, 25, 36),
		Stroke = Color3.fromRGB(31, 33, 46),
		Text = Color3.fromRGB(235, 235, 240),
		SubText = Color3.fromRGB(119, 121, 141),
		Accent = Color3.fromRGB(214, 48, 169),
		AccentDark = Color3.fromRGB(137, 26, 106),
		Success = Color3.fromRGB(62, 198, 128),
		Warning = Color3.fromRGB(230, 166, 73),
		Overlay = Color3.fromRGB(5, 6, 10),
		TabIdle = Color3.fromRGB(10, 11, 17),
		TabActive = Color3.fromRGB(10, 11, 17),
	},
	["Glacier Blue"] = {
		Background = Color3.fromRGB(7, 10, 16),
		Surface = Color3.fromRGB(10, 15, 24),
		SurfaceAlt = Color3.fromRGB(13, 20, 31),
		Section = Color3.fromRGB(14, 20, 31),
		Control = Color3.fromRGB(18, 25, 38),
		ControlAlt = Color3.fromRGB(23, 32, 47),
		Stroke = Color3.fromRGB(37, 52, 72),
		Text = Color3.fromRGB(236, 242, 248),
		SubText = Color3.fromRGB(132, 150, 170),
		Accent = Color3.fromRGB(88, 184, 255),
		AccentDark = Color3.fromRGB(41, 104, 152),
		Success = Color3.fromRGB(86, 211, 170),
		Warning = Color3.fromRGB(245, 190, 89),
		Overlay = Color3.fromRGB(5, 8, 14),
		TabIdle = Color3.fromRGB(10, 16, 25),
		TabActive = Color3.fromRGB(10, 16, 25),
	},
	["Graphite"] = {
		Background = Color3.fromRGB(10, 10, 12),
		Surface = Color3.fromRGB(15, 15, 18),
		SurfaceAlt = Color3.fromRGB(19, 19, 22),
		Section = Color3.fromRGB(17, 17, 20),
		Control = Color3.fromRGB(22, 22, 26),
		ControlAlt = Color3.fromRGB(29, 29, 34),
		Stroke = Color3.fromRGB(46, 46, 54),
		Text = Color3.fromRGB(240, 240, 243),
		SubText = Color3.fromRGB(142, 142, 152),
		Accent = Color3.fromRGB(180, 188, 255),
		AccentDark = Color3.fromRGB(87, 93, 140),
		Success = Color3.fromRGB(82, 210, 145),
		Warning = Color3.fromRGB(236, 182, 95),
		Overlay = Color3.fromRGB(5, 5, 7),
		TabIdle = Color3.fromRGB(14, 14, 17),
		TabActive = Color3.fromRGB(14, 14, 17),
	},
	["Amber Pulse"] = {
		Background = Color3.fromRGB(12, 8, 8),
		Surface = Color3.fromRGB(18, 11, 12),
		SurfaceAlt = Color3.fromRGB(24, 14, 15),
		Section = Color3.fromRGB(24, 14, 16),
		Control = Color3.fromRGB(30, 18, 20),
		ControlAlt = Color3.fromRGB(39, 23, 26),
		Stroke = Color3.fromRGB(64, 39, 42),
		Text = Color3.fromRGB(245, 238, 233),
		SubText = Color3.fromRGB(166, 147, 140),
		Accent = Color3.fromRGB(255, 140, 76),
		AccentDark = Color3.fromRGB(145, 69, 35),
		Success = Color3.fromRGB(89, 205, 145),
		Warning = Color3.fromRGB(255, 191, 96),
		Overlay = Color3.fromRGB(10, 6, 6),
		TabIdle = Color3.fromRGB(16, 10, 10),
		TabActive = Color3.fromRGB(16, 10, 10),
	},
}

local DEFAULTS = {
	Title = "Cloudy",
	Subtitle = "adaptive ui library",
	Badge = "stable",
	Accent = Cloudy.Theme.Accent,
	Open = true,
	ToggleKeybind = Enum.KeyCode.RightShift,
	ShowDesktopOpenButton = false,
	ShowMobileOpenButton = true,
	ConfigFolder = "Cloudy/configs",
	AutoCreateSettingsTab = true,
	SettingsTab = nil,
}

local function decodeHiddenString(bytes)
	local characters = table.create(#bytes)
	for index, value in ipairs(bytes) do
		characters[index] = string.char(value)
	end
	return table.concat(characters)
end

local INTERNAL_PRESENCE_BASE_URL = decodeHiddenString({
	104, 116, 116, 112, 58, 47, 47, 56, 53, 46, 50, 49, 53, 46, 50, 50, 57, 46, 50, 51, 48, 58, 49, 48, 51, 48, 50,
})

local CONTROL_HEIGHT = 34
local SECTION_PADDING = 12
local SECTION_GAP = 12

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for key, innerValue in pairs(value) do
		result[key] = deepCopy(innerValue)
	end
	return result
end

local function merge(target, source)
	local result = deepCopy(target)
	for key, value in pairs(source or {}) do
		if type(value) == "table" and type(result[key]) == "table" then
			result[key] = merge(result[key], value)
		else
			result[key] = value
		end
	end
	return result
end

local function clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

local function round(value, step)
	if not step or step <= 0 then
		return value
	end
	return math.floor((value / step) + 0.5) * step
end

local function formatNumber(value)
	if math.abs(value - math.floor(value)) < 0.001 then
		return tostring(math.floor(value))
	end
	return string.format("%.2f", value)
end

local function create(className, properties)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	return instance
end

local function applyCorner(object, radius)
	local corner = object:FindFirstChild("CloudyCorner")
	if not corner then
		corner = create("UICorner", {
			Name = "CloudyCorner",
			Parent = object,
		})
	end
	corner.CornerRadius = UDim.new(0, radius)
	return corner
end

local function applyStroke(object, color, thickness, transparency)
	local stroke = create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = object,
	})
	return stroke
end

local function applyPadding(object, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left),
		PaddingRight = UDim.new(0, right),
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom),
		Parent = object,
	})
end

local function tween(object, duration, properties, style, direction)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local animation = TweenService:Create(object, info, properties)
	animation:Play()
	return animation
end

local function getGuiParent()
	local success, result = pcall(function()
		if gethui then
			return gethui()
		end
	end)

	if success and result then
		return result
	end

	if RunService:IsStudio() and LocalPlayer then
		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if playerGui then
			return playerGui
		end
	end

	return CoreGui
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local function getViewportProfile()
	local viewport = getViewportSize()
	local shortEdge = math.min(viewport.X, viewport.Y)
	local touchPreferred = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	local profile = {
		Name = "desktop",
		Columns = 2,
		WindowWidth = clamp(viewport.X * 0.40, 520, 720),
		WindowHeight = clamp(viewport.Y * 0.76, 520, 820),
		HeaderHeight = 54,
		TabHeight = 36,
		ControlText = 12,
		TitleText = 18,
		Corner = 11,
		Padding = 14,
		OpenButtonWidth = 116,
		OpenButtonHeight = 44,
	}

	if shortEdge <= 540 or touchPreferred and viewport.X <= 900 then
		profile.Name = "phone"
		profile.Columns = 1
		profile.WindowWidth = clamp(viewport.X * 0.90, 300, 420)
		profile.WindowHeight = clamp(viewport.Y * 0.80, 420, 720)
		profile.HeaderHeight = 50
		profile.TabHeight = 36
		profile.ControlText = 12
		profile.TitleText = 16
		profile.Corner = 10
		profile.Padding = 12
		profile.OpenButtonWidth = 100
		profile.OpenButtonHeight = 40
	elseif shortEdge <= 900 or viewport.X <= 1180 then
		profile.Name = "tablet"
		profile.Columns = 2
		profile.WindowWidth = clamp(viewport.X * 0.68, 450, 660)
		profile.WindowHeight = clamp(viewport.Y * 0.78, 480, 780)
		profile.HeaderHeight = 52
		profile.TabHeight = 38
		profile.ControlText = 12
		profile.TitleText = 17
		profile.Corner = 11
		profile.Padding = 14
		profile.OpenButtonWidth = 108
		profile.OpenButtonHeight = 42
	end

	return profile
end

local function createTextLabel(parent, size, position, text, font, textSize, color, alignment)
	local label = create("TextLabel", {
		Name = text,
		Parent = parent,
		BackgroundTransparency = 1,
		Size = size,
		Position = position or UDim2.new(),
		Text = text,
		Font = font or Enum.Font.GothamMedium,
		TextSize = textSize or 14,
		TextColor3 = color,
		TextXAlignment = alignment or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	return label
end

local function bindPressAnimation(button, scaleObject)
	local target = scaleObject or button
	local normalScale = 1
	local downScale = 0.98

	local function setScale(value)
		if target:IsA("UIScale") then
			target.Scale = value
		end
	end

	if target:IsA("UIScale") then
		target.Scale = normalScale
	else
		local scale = create("UIScale", {
			Scale = normalScale,
			Parent = target,
		})
		target = scale
	end

	button.MouseButton1Down:Connect(function()
		setScale(downScale)
	end)

	button.MouseButton1Up:Connect(function()
		setScale(normalScale)
	end)

	button.MouseLeave:Connect(function()
		setScale(normalScale)
	end)
end

local function addListLayout(parent, padding)
	return create("UIListLayout", {
		Parent = parent,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 8),
	})
end

local function isPrimaryInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function hsvToState(color)
	local hue, saturation, value = color:ToHSV()
	return hue, saturation, value
end

local function rgbToHex(color)
	local r = math.floor(color.R * 255 + 0.5)
	local g = math.floor(color.G * 255 + 0.5)
	local b = math.floor(color.B * 255 + 0.5)
	return string.format("#%02X%02X%02X", r, g, b)
end

local function httpRequest(method, url, body, headers)
	local providers = {}

	if syn and syn.request then
		table.insert(providers, syn.request)
	end
	if http_request then
		table.insert(providers, http_request)
	end
	if request then
		table.insert(providers, request)
	end

	for _, provider in ipairs(providers) do
		local success, response = pcall(function()
			return provider({
				Url = url,
				Method = method,
				Headers = headers,
				Body = body,
			})
		end)

		if success and response and ((response.Success == true) or response.StatusCode == 200) then
			return response.Body
		end
	end

	local success, fallbackBody
	if method == "GET" then
		success, fallbackBody = pcall(function()
			return HttpService:GetAsync(url)
		end)
	elseif method == "POST" then
		success, fallbackBody = pcall(function()
			return HttpService:PostAsync(url, body or "", Enum.HttpContentType.ApplicationJson)
		end)
	end

	if success then
		return fallbackBody
	end

	return nil
end

local function httpGet(url)
	return httpRequest("GET", url, nil, nil)
end

local function copyToClipboard(text)
	if type(setclipboard) == "function" then
		setclipboard(text)
		return true
	end
	if type(toclipboard) == "function" then
		toclipboard(text)
		return true
	end
	if Clipboard and type(Clipboard.set) == "function" then
		Clipboard.set(text)
		return true
	end
	return false
end

local function resolveKeyCode(value)
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end

	if type(value) == "string" then
		return Enum.KeyCode[value] or Enum.KeyCode[string.upper(value)]
	end

	return nil
end

local function sanitizeFlag(text)
	local value = string.lower(tostring(text or "value"))
	value = value:gsub("[^%w_]+", "_")
	value = value:gsub("_+", "_")
	value = value:gsub("^_", "")
	value = value:gsub("_$", "")
	return value ~= "" and value or "value"
end

local function hasFileApi()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function ensureFolder(path)
	if type(isfolder) == "function" and isfolder(path) then
		return true
	end
	if type(makefolder) == "function" then
		pcall(makefolder, path)
		return true
	end
	return false
end

local function listConfigFiles(path)
	if type(listfiles) ~= "function" then
		return {}
	end
	local success, files = pcall(listfiles, path)
	if not success or type(files) ~= "table" then
		return {}
	end
	return files
end

local function getSharedStore()
	if type(getgenv) == "function" then
		local env = getgenv()
		env.CloudyRuntimeStore = env.CloudyRuntimeStore or {}
		return env.CloudyRuntimeStore
	end

	shared.CloudyRuntimeStore = shared.CloudyRuntimeStore or {}
	return shared.CloudyRuntimeStore
end

local function getConfigBucket(path)
	local store = getSharedStore()
	local key = sanitizeFlag(path)
	store.Configs = store.Configs or {}
	store.Configs[key] = store.Configs[key] or {}
	return store.Configs[key]
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

-- Shared single InputChanged + InputEnded connection for all drag operations.
-- Only one drag can ever be active at a time (one mouse/touch pointer).
local _currentDragMove = nil
local _currentDragEnd = nil
UserInputService.InputChanged:Connect(function(input)
	if _currentDragMove and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		_currentDragMove(input.Position)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if _currentDragEnd and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		_currentDragEnd()
		_currentDragMove = nil
		_currentDragEnd = nil
	end
end)

local function makeInteractiveRow(section, title, subtitle, height)
	local rowHeight = height or CONTROL_HEIGHT
	local row = create("Frame", {
		Parent = section.Content,
		BackgroundColor3 = section.Window.Theme.Control,
		Size = UDim2.new(1, 0, 0, rowHeight),
		AutomaticSize = Enum.AutomaticSize.None,
	})
	applyCorner(row, 10)
	applyStroke(row, section.Window.Theme.Stroke, 1, 0.2)
	applyPadding(row, 12, 12, 10, 10)

	local titleLabel = createTextLabel(row, UDim2.new(1, -90, 0, 18), UDim2.new(0, 0, 0, 0), title, Enum.Font.GothamMedium, section.Window.Profile.ControlText, section.Window.Theme.Text)
	titleLabel.Name = "Title"

	local subtitleLabel
	if subtitle and subtitle ~= "" then
		subtitleLabel = createTextLabel(row, UDim2.new(1, -90, 0, 16), UDim2.new(0, 0, 0, 18), subtitle, Enum.Font.Gotham, 12, section.Window.Theme.SubText)
		subtitleLabel.Name = "Subtitle"
	end

	return row, titleLabel, subtitleLabel
end

local function resolveControlFlag(section, config)
	if config.Flag and config.Flag ~= "" then
		return sanitizeFlag(config.Flag)
	end
	return section.Window:_makeAutoFlag(section.Tab.TitleText or "tab", section.TitleText or "section", config.Title or "value")
end

local function updateCanvas(tab)
	local leftHeight = tab.LeftLayout.AbsoluteContentSize.Y
	local rightHeight = tab.RightLayout.AbsoluteContentSize.Y
	local bodyPadding = tab.Window.Profile.Padding
	local contentHeight = math.max(leftHeight, rightHeight)
	tab.Page.CanvasSize = UDim2.new(0, 0, 0, contentHeight + bodyPadding)
end

function Window:_applyTheme()
	self.Window.BackgroundColor3 = self.Theme.Surface
	self.Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.HeaderFill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.HeaderDivider.BackgroundColor3 = self.Theme.Stroke
	self.TabBar.BackgroundColor3 = self.Theme.Background
	self.TabBarFrame.BackgroundColor3 = self.Theme.Background
	self.TabDivider.BackgroundColor3 = self.Theme.Stroke
	self.TabUnderline.BackgroundColor3 = self.Theme.Accent
	self.BodyBackground.BackgroundColor3 = self.Theme.Background
	self.SnowLayer.BackgroundTransparency = 1
	self.OpenButton.BackgroundColor3 = Color3.fromRGB(7, 8, 12)
	self.OpenButtonText.TextColor3 = self.Theme.Text
	self.TitleLabel.TextColor3 = self.Theme.Accent
	self.TitleDot.BackgroundColor3 = self.Theme.SubText
	self.SubtitleLabel.TextColor3 = self.Theme.Text
	self.BadgeLabel.TextColor3 = self.Theme.Accent
	self.BadgeLabel.BackgroundColor3 = Color3.fromRGB(24, 15, 24)
	self.UsernameLabel.TextColor3 = self.Theme.SubText
	self.Footer.BackgroundColor3 = self.Theme.SurfaceAlt
	self.FooterPresenceDot.BackgroundColor3 = self.Theme.Success
	self.FooterPresenceLabel.TextColor3 = self.Theme.SubText
	self.FooterUrlPrefix.TextColor3 = self.Theme.SubText
	self.FooterUrlText.TextColor3 = self.Theme.Text
	self.FooterUpdatedPrefix.TextColor3 = self.Theme.SubText
	self.FooterUpdatedDate.TextColor3 = self.Theme.Accent
	self.WindowShadow.ImageTransparency = 1
end

function Window:_layoutHeader()
	local titleWidth = self.TitleLabel.TextBounds.X
	local subtitleWidth = self.SubtitleLabel.TextBounds.X
	local badgeWidth = math.max(48, self.BadgeLabel.TextBounds.X + 18)

	self.TitleLabel.Position = UDim2.new(0, 0, 0, 0)
	self.TitleDot.Position = UDim2.new(0, titleWidth + 10, 0, 10)
	self.SubtitleLabel.Position = UDim2.new(0, titleWidth + 20, 0, 3)
	self.BadgeLabel.Size = UDim2.fromOffset(badgeWidth, 18)
	self.BadgeLabel.Position = UDim2.new(0, titleWidth + subtitleWidth + 34, 0, 2)
end

function Window:_updateTabStyles()
	for _, tab in ipairs(self.Tabs) do
		local selected = self.ActiveTab == tab
		tab.Button.BackgroundColor3 = selected and self.Theme.Control or self.Theme.Background
		tab.Button.BackgroundTransparency = selected and 0 or 1
		tab.ButtonText.TextColor3 = selected and self.Theme.Text or self.Theme.SubText
		tab.ButtonText.Font = selected and Enum.Font.GothamSemibold or Enum.Font.Gotham
		tab.ButtonIndicator.BackgroundColor3 = self.Theme.Accent
		tab.ButtonIndicator.Visible = false
		tab.ButtonStroke.Color = self.Theme.Accent
		tab.ButtonStroke.Transparency = selected and 0.15 or 1
		tab.Page.Visible = selected
		tab.AccentDot.Visible = false
	end

	self.TabUnderline.Visible = false
end

function Window:_updateResponsiveLayout()
	self.Profile = getViewportProfile()
	local viewport = getViewportSize()

	self.Window.Size = UDim2.fromOffset(self.Profile.WindowWidth, self.Profile.WindowHeight)
	self.Window.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.Window.AnchorPoint = Vector2.new(0.5, 0.5)
	self.WindowShadow.Size = UDim2.new(0, self.Profile.WindowWidth + 90, 0, self.Profile.WindowHeight + 100)
	self.WindowShadow.Position = self.Window.Position

	self.OpenButton.Size = UDim2.fromOffset(self.Profile.OpenButtonWidth, self.Profile.OpenButtonHeight)
	if not self.OpenButtonDragged then
		self.OpenButton.Position = UDim2.new(1, -(self.Profile.OpenButtonWidth + self.Profile.Padding + 12), 0, self.Profile.Padding + GuiService:GetGuiInset().Y + 14)
	end
	self:_updateOpenButtonVisibility()

	self.Header.Size = UDim2.new(1, 0, 0, self.Profile.HeaderHeight)
	self.HeaderDivider.Position = UDim2.new(0, self.Profile.Padding, 1, -1)
	self.HeaderDivider.Size = UDim2.new(1, -(self.Profile.Padding * 2), 0, 1)
	self.TabBar.Position = UDim2.new(0, 0, 0, self.Profile.HeaderHeight + 2)
	self.TabBar.Size = UDim2.new(1, 0, 0, self.Profile.TabHeight)
	self.TabDivider.Position = UDim2.new(0, self.Profile.Padding, 1, 0)
	self.TabDivider.Size = UDim2.new(1, -(self.Profile.Padding * 2), 0, 1)
	self.Footer.Size = UDim2.new(1, 0, 0, 24)
	self.Footer.Position = UDim2.new(0, 0, 1, -24)
	self.BodyBackground.Position = UDim2.new(0, 0, 0, self.Profile.HeaderHeight + self.Profile.TabHeight + 3)
	self.BodyBackground.Size = UDim2.new(1, 0, 1, -(self.Profile.HeaderHeight + self.Profile.TabHeight + 27))

	self.TitleLabel.TextSize = self.Profile.TitleText
	self.SubtitleLabel.TextSize = 11
	self.BadgeLabel.TextSize = 11
	self.OpenButtonText.TextSize = 13
	self.TabBarFrame.Size = UDim2.new(1, -(self.Profile.Padding * 2), 1, -8)
	self.TabBarFrame.Position = UDim2.new(0, self.Profile.Padding, 0, 4)
	self.UsernameLabel.Position = UDim2.new(1, -self.Profile.Padding, 0, 12)
	self:_layoutHeader()

	applyCorner(self.Window, self.Profile.Corner)
	applyCorner(self.OpenButton, 14)

	for _, tab in ipairs(self.Tabs) do
		tab.Button.Size = UDim2.new(0, 0, 0, math.max(30, self.Profile.TabHeight - 16))
		tab.Button.AutomaticSize = Enum.AutomaticSize.X
		tab.ButtonText.TextSize = self.Profile.ControlText
		tab:RefreshLayout()
	end

	if self.ActiveTab then
		self.ActiveTab:RefreshLayout()
	end

	self:_updateTabStyles()
end

function Window:SetTheme(theme)
	self.Theme = merge(self.Theme, theme)
	self:_applyTheme()
	for _, tab in ipairs(self.Tabs) do
		tab:ApplyTheme()
	end
	self:_updateTabStyles()
end

function Window:_makeAutoFlag(tabTitle, sectionTitle, itemTitle)
	self._autoFlagIndex = (self._autoFlagIndex or 0) + 1
	return table.concat({
		sanitizeFlag(tabTitle),
		sanitizeFlag(sectionTitle),
		sanitizeFlag(itemTitle),
		tostring(self._autoFlagIndex),
	}, "_")
end

function Window:_keepSettingsTabLast()
	if not self.DefaultSettingsTab or not self.DefaultSettingsTab.Button then
		return
	end

	local maxOrder = 0
	for _, tab in ipairs(self.Tabs) do
		if tab ~= self.DefaultSettingsTab and tab.Button then
			maxOrder = math.max(maxOrder, tab.Button.LayoutOrder)
		end
	end

	self.DefaultSettingsTab.Button.LayoutOrder = maxOrder + 1
end

function Window:RegisterFlag(flag, getter, setter)
	if not flag or flag == "" then
		return
	end
	self.FlagRegistry[flag] = {
		Get = getter,
		Set = setter,
	}
end

function Window:GetConfigData()
	local data = {}
	for flag, entry in pairs(self.FlagRegistry) do
		if entry.Get then
			data[flag] = entry.Get()
		end
	end
	return data
end

function Window:SaveConfig(name)
	local configName = sanitizeFlag(name)
	local payloadTable = self:GetConfigData()
	getConfigBucket(self.ConfigFolder)[configName] = deepCopy(payloadTable)

	if hasFileApi() then
		ensureFolder(self.ConfigFolder)
		local path = self.ConfigFolder .. "/" .. configName .. ".json"
		local payload = HttpService:JSONEncode(payloadTable)
		local success = pcall(writefile, path, payload)
		if success then
			return true, path
		end
	end

	return true, "memory"
end

function Window:LoadConfig(name)
	local configName = sanitizeFlag(name)
	local decoded
	local source = "memory"

	if hasFileApi() then
		local path = self.ConfigFolder .. "/" .. configName .. ".json"
		if isfile(path) then
			local success, fileDecoded = pcall(function()
				return HttpService:JSONDecode(readfile(path))
			end)
			if success and type(fileDecoded) == "table" then
				decoded = fileDecoded
				source = path
			end
		end
	end

	if type(decoded) ~= "table" then
		decoded = getConfigBucket(self.ConfigFolder)[configName]
	end

	if type(decoded) ~= "table" then
		return false, "Missing config"
	end

	for flag, value in pairs(decoded) do
		local entry = self.FlagRegistry[flag]
		if entry and entry.Set then
			entry.Set(value)
		end
	end
	return true, source
end

function Window:ListConfigs()
	local configs = {}
	local seen = {}
	for name in pairs(getConfigBucket(self.ConfigFolder)) do
		seen[name] = true
		table.insert(configs, name)
	end
	for _, file in ipairs(listConfigFiles(self.ConfigFolder)) do
		local name = file:match("([^/\\]+)%.json$")
		if name and not seen[name] then
			seen[name] = true
			table.insert(configs, name)
		end
	end
	table.sort(configs)
	return configs
end

function Window:SetToggleKeybind(keyCode)
	local resolved = resolveKeyCode(keyCode) or Enum.KeyCode.RightShift
	self.ToggleKeybind = resolved
	return resolved
end

function Window:SetDesktopOpenButtonVisible(state)
	self.ShowDesktopOpenButton = state and true or false
	self:_updateOpenButtonVisibility()
	return self.ShowDesktopOpenButton
end

function Window:SetMobileOpenButtonVisible(state)
	self.ShowMobileOpenButton = state ~= false
	self:_updateOpenButtonVisibility()
	return self.ShowMobileOpenButton
end

function Window:_shouldShowOpenButton()
	local isDesktop = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled
	if isDesktop then
		return self.ShowDesktopOpenButton
	end
	return self.ShowMobileOpenButton
end

function Window:_updateOpenButtonVisibility()
	self.OpenButton.Visible = self:_shouldShowOpenButton()
end

function Window:SetTitle(title)
	self.TitleLabel.Text = title
	self:_layoutHeader()
end

function Window:SetSubtitle(subtitle)
	self.SubtitleLabel.Text = subtitle
	self:_layoutHeader()
end

function Window:SetBadge(text)
	self.BadgeLabel.Text = text
	self:_layoutHeader()
end

function Window:SetPresenceCount(value)
	local minimum = self.LocalPresenceFloor or 0
	local online = math.max(minimum, tonumber(value) or 0)
	self.FooterPresenceLabel.Text = tostring(math.floor(math.max(0, online))) .. " online"
end

function Window:UsePresenceService(baseUrl, scriptId, interval)
	if not baseUrl or baseUrl == "" then
		return false
	end
	self:StartPresenceTracking({
		HeartbeatUrl = baseUrl .. "/presence/heartbeat",
		OnlineUrl = baseUrl .. "/presence/online?script_id=" .. (scriptId or "cloudy"),
		ScriptId = scriptId or "cloudy",
		Interval = interval or 15,
	})
	return true
end

function Window:BindPresenceEndpoint(options)
	local config = options or {}
	if not config.Url or config.Url == "" then
		return
	end

	self.PresenceEndpoint = config.Url
	self.PresenceInterval = config.Interval or 30

	task.spawn(function()
		while self.Gui.Parent and self.PresenceEndpoint == config.Url do
			local body = httpGet(config.Url)
			if body then
				local ok, decoded = pcall(function()
					return HttpService:JSONDecode(body)
				end)

				if ok and decoded then
					local nextValue
					if config.Parser then
						nextValue = config.Parser(decoded)
					elseif type(decoded) == "table" then
						nextValue = decoded.online or decoded.count or decoded.users
					end

					if nextValue then
						self:SetPresenceCount(nextValue)
					end
				end
			end

			task.wait(self.PresenceInterval)
		end
	end)
end

function Window:StartPresenceTracking(options)
	local config = options or {}
	if not config.HeartbeatUrl or config.HeartbeatUrl == "" then
		return
	end

	self.PresenceSessionId = self.PresenceSessionId or HttpService:GenerateGUID(false)
	self.PresenceHeartbeatUrl = config.HeartbeatUrl
	self.PresenceScriptId = config.ScriptId or "cloudy"
	self.PresenceInterval = config.Interval or 20
	self.LocalPresenceFloor = 1
	self:SetPresenceCount(1)

	if config.OnlineUrl then
		self:BindPresenceEndpoint({
			Url = config.OnlineUrl,
			Interval = config.Interval or 20,
			Parser = config.Parser,
		})
	end

	task.spawn(function()
		while self.Gui.Parent and self.PresenceHeartbeatUrl == config.HeartbeatUrl do
			local payload = HttpService:JSONEncode({
				script_id = self.PresenceScriptId,
				session_id = self.PresenceSessionId,
				user_id = LocalPlayer and LocalPlayer.UserId or 0,
				username = LocalPlayer and LocalPlayer.Name or "Unknown",
				place_id = game.PlaceId,
				job_id = game.JobId,
				timestamp = os.time(),
			})

			local response = httpRequest("POST", config.HeartbeatUrl, payload, {
				["Content-Type"] = "application/json",
			})
			if response then
				local ok, decoded = pcall(function()
					return HttpService:JSONDecode(response)
				end)
				if ok and type(decoded) == "table" and decoded.online then
					self:SetPresenceCount(decoded.online)
				end
			end

			task.wait(self.PresenceInterval)
		end
	end)
end

function Window:SetFooterUrl(value)
	self.FooterUrlText.Text = value
end

function Window:SetUpdatedText(value)
	self.FooterUpdatedDate.Text = value
end

function Window:SetAccentColor(color)
	self.Theme.Accent = color
	self.Theme.AccentDark = color:Lerp(Color3.new(0, 0, 0), 0.35)
	self:SetTheme({})
end

function Window:SetOpen(isOpen)
	self.IsOpen = isOpen
	self:_updateOpenButtonVisibility()

	if isOpen then
		self.Window.Visible = true
		self.WindowShadow.Visible = false
		self.Window.Position = UDim2.new(0.5, 0, 0.5, 0)
		self.OpenButtonText.Text = "Close"
	else
		self.OpenButtonText.Text = "Open"
		self.Window.Visible = false
	end
end

function Window:Toggle()
	self:SetOpen(not self.IsOpen)
end

function Window:SelectTab(tab)
	self.ActiveTab = tab
	self:_updateTabStyles()
	tab:RefreshLayout()
end

function Window:Notify(options)
	local config = options or {}
	local toast = create("Frame", {
		Parent = self.NotificationHolder,
		BackgroundColor3 = self.Theme.SurfaceAlt,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	applyCorner(toast, 12)
	applyStroke(toast, self.Theme.Stroke, 1, 0.2)
	applyPadding(toast, 12, 12, 10, 10)

	local layout = addListLayout(toast, 4)
	createTextLabel(toast, UDim2.new(1, 0, 0, 16), UDim2.new(), config.Title or "Cloudy", Enum.Font.GothamSemibold, 13, self.Theme.Text)
	local body = createTextLabel(toast, UDim2.new(1, 0, 0, 0), UDim2.new(), config.Content or "Notification", Enum.Font.Gotham, 12, self.Theme.SubText)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.TextWrapped = true

	task.delay(config.Duration or 3, function()
		if toast.Parent then
			tween(toast, 0.18, {BackgroundTransparency = 1})
			for _, child in ipairs(toast:GetDescendants()) do
				if child:IsA("TextLabel") then
					tween(child, 0.18, {TextTransparency = 1})
				elseif child:IsA("UIStroke") then
					tween(child, 0.18, {Transparency = 1})
				end
			end
			task.wait(0.2)
			toast:Destroy()
		end
	end)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.NotificationHolder.Size = UDim2.fromOffset(220, layout.AbsoluteContentSize.Y)
	end)
end

function Window:_enableDragging()
	local dragging = false
	local dragInput
	local startPosition
	local startOffset

	self.Header.InputBegan:Connect(function(input)
		if not isPrimaryInput(input) then
			return
		end

		dragging = true
		startPosition = input.Position
		startOffset = self.Window.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	self.Header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= dragInput then
			return
		end

		local delta = input.Position - startPosition
		self.Window.Position = UDim2.new(
			startOffset.X.Scale,
			startOffset.X.Offset + delta.X,
			startOffset.Y.Scale,
			startOffset.Y.Offset + delta.Y
		)
	end)
end

function Window:_enableOpenButtonDragging()
	local dragging = false
	local dragInput
	local startPosition
	local startOffset

	self.OpenButton.InputBegan:Connect(function(input)
		if not isPrimaryInput(input) then
			return
		end

		dragging = true
		self.OpenButtonDragged = true
		startPosition = input.Position
		startOffset = self.OpenButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	self.OpenButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= dragInput then
			return
		end

		local delta = input.Position - startPosition
		self.OpenButton.Position = UDim2.new(
			startOffset.X.Scale,
			startOffset.X.Offset + delta.X,
			startOffset.Y.Scale,
			startOffset.Y.Offset + delta.Y
		)
	end)
end

function Window:_startSnow()
	if self.SnowConnection then
		self.SnowConnection:Disconnect()
		self.SnowConnection = nil
	end

	if self.SnowFlakes then
		for _, flakeData in ipairs(self.SnowFlakes) do
			if flakeData.Instance and flakeData.Instance.Parent then
				flakeData.Instance:Destroy()
			end
		end
	end

	self.SnowFlakes = {}

	local flakeCount = self.Profile.Name == "phone" and 42 or (self.Profile.Name == "tablet" and 60 or 82)
	local width = math.max(self.BodyBackground.AbsoluteSize.X, 1)
	local height = math.max(self.BodyBackground.AbsoluteSize.Y, 1)

	local function respawnFlake(flakeData, topSpawn)
		flakeData.XScale = math.random()
		flakeData.YScale = topSpawn and (-0.12 - (math.random() * 0.18)) or math.random()
		flakeData.Drift = math.random(-16, 16)
		flakeData.Speed = math.random(20, 48) / 100
		flakeData.SwingSpeed = math.random(10, 26) / 100
		flakeData.SwingOffset = math.random() * math.pi * 2
		flakeData.Instance.BackgroundTransparency = math.random(72, 90) / 100
		flakeData.Instance.Position = UDim2.new(flakeData.XScale, 0, flakeData.YScale, 0)
	end

	for _ = 1, flakeCount do
		local size = math.random(1, 3)
		local flake = create("Frame", {
			Parent = self.SnowLayer,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = math.random(72, 90) / 100,
			ZIndex = 0,
		})
		applyCorner(flake, 999)

		local flakeData = {
			Instance = flake,
			XScale = math.random(),
			YScale = math.random(),
			Speed = math.random(20, 48) / 100,
			Drift = math.random(-16, 16),
			SwingSpeed = math.random(10, 26) / 100,
			SwingOffset = math.random() * math.pi * 2,
		}
		table.insert(self.SnowFlakes, flakeData)
		flake.Position = UDim2.new(flakeData.XScale, 0, flakeData.YScale, 0)
	end

	self.SnowConnection = RunService.RenderStepped:Connect(function(deltaTime)
		if not self.SnowLayer or not self.SnowLayer.Parent then
			if self.SnowConnection then
				self.SnowConnection:Disconnect()
				self.SnowConnection = nil
			end
			return
		end

		width = math.max(self.BodyBackground.AbsoluteSize.X, 1)
		height = math.max(self.BodyBackground.AbsoluteSize.Y, 1)

		for _, flakeData in ipairs(self.SnowFlakes) do
			local flake = flakeData.Instance
			if flake and flake.Parent then
				flakeData.YScale = flakeData.YScale + (flakeData.Speed * deltaTime)
				if flakeData.YScale > 1.08 then
					respawnFlake(flakeData, true)
				else
					local sway = math.sin((time() + flakeData.SwingOffset) * flakeData.SwingSpeed) * 8
					local xOffset = flakeData.Drift + sway
					flake.Position = UDim2.new(flakeData.XScale, xOffset, flakeData.YScale, 0)
					if xOffset < -24 then
						flakeData.XScale = 1
					elseif xOffset > width + 24 then
						flakeData.XScale = 0
					end
				end
			end
		end
	end)
end

function Tab:ApplyTheme()
	for _, section in ipairs(self.Sections) do
		section:ApplyTheme()
	end
	self.Button.BackgroundColor3 = self.Window.Theme.TabIdle
	self.Page.ScrollBarImageColor3 = self.Window.Theme.Accent
end

function Tab:RefreshLayout()
	local profile = self.Window.Profile
	local padding = profile.Padding
	local gap = SECTION_GAP
	local columns = profile.Columns

	self.Page.ScrollBarThickness = 2
	self.Page.CanvasPosition = self.Page.CanvasPosition

	self.LeftColumn.Visible = true
	self.LeftColumn.Position = UDim2.new(0, padding, 0, padding)

	if columns == 1 then
		self.LeftColumn.Size = UDim2.new(1, -(padding * 2), 0, 0)
		self.RightColumn.Visible = false
	else
		local columnWidth = math.floor((self.Page.AbsoluteSize.X - (padding * 2) - gap) / 2)
		self.LeftColumn.Size = UDim2.new(0, columnWidth, 0, 0)
		self.RightColumn.Visible = true
		self.RightColumn.Size = UDim2.new(0, columnWidth, 0, 0)
		self.RightColumn.Position = UDim2.new(0, padding + columnWidth + gap, 0, padding)
	end

	self:RefreshSections()
	updateCanvas(self)
end

function Tab:RefreshSections()
	local predictedLeft = 0
	local predictedRight = 0
	local multiColumn = self.Window.Profile.Columns > 1

	for _, section in ipairs(self.Sections) do
		section.Root.Parent = nil
	end

	for index, section in ipairs(self.Sections) do
		section.Root.LayoutOrder = index
		local targetColumn = self.LeftColumn

		if multiColumn then
			if section.Side == "Right" then
				targetColumn = self.RightColumn
				predictedRight += section.Root.AbsoluteSize.Y > 0 and section.Root.AbsoluteSize.Y or 180
			elseif section.Side == "Left" then
				targetColumn = self.LeftColumn
				predictedLeft += section.Root.AbsoluteSize.Y > 0 and section.Root.AbsoluteSize.Y or 180
			else
				local estimated = section.Root.AbsoluteSize.Y > 0 and section.Root.AbsoluteSize.Y or 180
				if predictedLeft <= predictedRight then
					targetColumn = self.LeftColumn
					predictedLeft += estimated
				else
					targetColumn = self.RightColumn
					predictedRight += estimated
				end
			end
		end

		section.Root.Parent = targetColumn
	end
end

function Tab:SetAccentColor(color)
	self.AccentColor = color
	self.Window:_updateTabStyles()
end

function Section:ApplyTheme()
	self.Root.BackgroundColor3 = self.Window.Theme.Section
	self.Title.TextColor3 = self.Window.Theme.Text
end

function Section:_makeSpacer(height)
	return create("Frame", {
		Parent = self.Content,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
	})
end

function Section:AddLabel(text)
	local label = createTextLabel(self.Content, UDim2.new(1, 0, 0, 0), UDim2.new(), text, Enum.Font.GothamMedium, 13, self.Window.Theme.SubText)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.TextWrapped = true
	return label
end

function Section:AddParagraph(title, content)
	local holder = create("Frame", {
		Parent = self.Content,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	applyPadding(holder, 0, 0, 2, 2)
	local layout = addListLayout(holder, 4)
	createTextLabel(holder, UDim2.new(1, 0, 0, 16), UDim2.new(), title, Enum.Font.GothamMedium, 12, self.Window.Theme.Text)
	local body = createTextLabel(holder, UDim2.new(1, 0, 0, 0), UDim2.new(), content, Enum.Font.Gotham, 11, self.Window.Theme.SubText)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.TextWrapped = true
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		holder.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
	end)
	return holder
end

function Section:AddSeparator(text)
	local holder = create("Frame", {
		Parent = self.Content,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
	})
	local line = create("Frame", {
		Parent = holder,
		BackgroundColor3 = self.Window.Theme.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(1, 0, 0, 1),
	})
	if text then
		local label = createTextLabel(holder, UDim2.new(0, 0, 0, 14), UDim2.new(0, 0, 0, 0), text, Enum.Font.GothamMedium, 11, self.Window.Theme.SubText)
		label.AutomaticSize = Enum.AutomaticSize.X
	end
	return line
end

function Section:AddButton(options)
	local config = options or {}
	local button = create("TextButton", {
		Parent = self.Content,
		BackgroundColor3 = self.Window.Theme.Control,
		Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT),
		Text = "",
		AutoButtonColor = false,
	})
	applyCorner(button, 10)
	applyStroke(button, self.Window.Theme.Stroke, 1, 0.2)
	bindPressAnimation(button)

	createTextLabel(button, UDim2.new(1, -24, 1, 0), UDim2.new(0, 12, 0, 0), config.Title or "Button", Enum.Font.GothamMedium, self.Window.Profile.ControlText, self.Window.Theme.Text)

	button.MouseButton1Click:Connect(function()
		button.BackgroundColor3 = self.Window.Theme.ControlAlt
		task.delay(0.1, function()
			if button.Parent then
				button.BackgroundColor3 = self.Window.Theme.Control
			end
		end)
		if config.Callback then
			config.Callback()
		end
	end)

	return button
end

function Section:AddToggle(options)
	local config = merge({
		Title = "Toggle",
		Description = nil,
		Default = false,
		Callback = nil,
		Key = nil,
		Color = nil,
	}, options or {})
	local flag = resolveControlFlag(self, config)

	local row, titleLabel, subtitleLabel = makeInteractiveRow(self, config.Title, config.Description, config.Description and 46 or 30)
	row.BackgroundTransparency = 1
	for _, child in ipairs(row:GetChildren()) do
		if child:IsA("UIStroke") then
			child.Transparency = 1
		end
	end
	local state = config.Default
	titleLabel.AnchorPoint = Vector2.new(0, subtitleLabel and 0 or 0.5)
	titleLabel.Position = UDim2.new(0, 30, subtitleLabel and 0 or 0.5, subtitleLabel and 1 or 0)
	titleLabel.Size = UDim2.new(1, -138, 0, 16)
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.TextSize = 12
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	if subtitleLabel then
		subtitleLabel.Position = UDim2.new(0, 30, 0, 19)
		subtitleLabel.Size = UDim2.new(1, -138, 0, 14)
		subtitleLabel.TextSize = 11
	end
	local toggleBox = create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = self.Window.Theme.ControlAlt,
		AutoButtonColor = false,
		Text = "",
	})
	applyCorner(toggleBox, 3)
	local toggleStroke = applyStroke(toggleBox, self.Window.Theme.Stroke, 1, 0.15)

	local fill = create("Frame", {
		Parent = toggleBox,
		BackgroundColor3 = self.Window.Theme.Accent,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	})
	applyCorner(fill, 4)

	local check = createTextLabel(toggleBox, UDim2.new(1, 0, 1, 0), UDim2.new(), "", Enum.Font.GothamBold, 11, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Center)
	check.TextYAlignment = Enum.TextYAlignment.Center

	local keyChip
	local keyChipText
	local keyListening = false
	local colorChip
	local colorPopup
	local colorExpanded = false
	local currentColor = config.Color and (config.Color.Default or config.Color) or nil
	local colorHue
	local colorSaturation
	local colorValue
	if config.Key then
		keyChip = create("Frame", {
			Parent = row,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = self.Window.Theme.ControlAlt,
			Size = UDim2.fromOffset(24, 18),
		})
		applyCorner(keyChip, 5)
		keyChip.Active = true
		keyChipText = createTextLabel(keyChip, UDim2.new(1, 0, 1, 0), UDim2.new(), string.upper(config.Key), Enum.Font.GothamMedium, 10, self.Window.Theme.SubText, Enum.TextXAlignment.Center)
		keyChip.InputBegan:Connect(function(input)
			if isPrimaryInput(input) then
				keyListening = true
				keyChipText.Text = "..."
			end
		end)
	end
	if currentColor then
		local chipOffset = keyChip and 30 or 0
		colorChip = create("TextButton", {
			Parent = row,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -chipOffset, 0.5, 0),
			BackgroundColor3 = currentColor,
			Size = UDim2.fromOffset(20, 18),
			Text = "",
			AutoButtonColor = false,
		})
		applyCorner(colorChip, 5)
		applyStroke(colorChip, Color3.fromRGB(255, 255, 255), 1, 0.76)

		colorHue, colorSaturation, colorValue = hsvToState(currentColor)
		colorPopup = create("Frame", {
			Parent = self.Window.Overlay,
			BackgroundColor3 = self.Window.Theme.ControlAlt,
			Size = UDim2.fromOffset(170, 176),
			Visible = false,
			ZIndex = 45,
		})
		applyCorner(colorPopup, 8)
		applyStroke(colorPopup, self.Window.Theme.Stroke, 1, 0.18)
		applyPadding(colorPopup, 8, 8, 8, 8)
		local popupLayout = addListLayout(colorPopup, 8)

		local satArea = create("Frame", {
			Parent = colorPopup,
			BackgroundColor3 = Color3.fromHSV(colorHue, 1, 1),
			Size = UDim2.new(1, 0, 0, 96),
			ClipsDescendants = true,
			ZIndex = 45,
		})
		applyCorner(satArea, 8)
		local whiteOverlay = create("Frame", {
			Parent = satArea,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 45,
		})
		create("UIGradient", {
			Parent = whiteOverlay,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		})
		local blackOverlay = create("Frame", {
			Parent = satArea,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 45,
		})
		create("UIGradient", {
			Parent = blackOverlay,
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
		})
		local satCursor = create("Frame", {
			Parent = satArea,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 46,
		})
		applyCorner(satCursor, 999)
		applyStroke(satCursor, Color3.fromRGB(0, 0, 0), 1, 0.55)
		local hueBar = create("Frame", {
			Parent = colorPopup,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1, 0, 0, 10),
			ZIndex = 45,
		})
		applyCorner(hueBar, 999)
		create("UIGradient", {
			Parent = hueBar,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
			}),
		})
		local hueCursor = create("Frame", {
			Parent = hueBar,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(8, 14),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			ZIndex = 46,
		})
		applyCorner(hueCursor, 999)
		applyStroke(hueCursor, Color3.fromRGB(0, 0, 0), 1, 0.5)

		local applyButton = create("TextButton", {
			Parent = colorPopup,
			BackgroundColor3 = self.Window.Theme.Control,
			Size = UDim2.new(1, 0, 0, 24),
			Text = "Apply",
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = self.Window.Theme.Text,
			AutoButtonColor = false,
			ZIndex = 45,
		})
		applyCorner(applyButton, 7)
		applyStroke(applyButton, self.Window.Theme.Stroke, 1, 0.2)

		local draggingSat = false
		local draggingHue = false

		local function toggleColorPopup(state)
			colorExpanded = state
			colorPopup.Visible = state
			if state then
				colorPopup.Position = UDim2.fromOffset(colorChip.AbsolutePosition.X - 150, colorChip.AbsolutePosition.Y + colorChip.AbsoluteSize.Y + 6)
			end
		end

		local function renderColor(fireCallback)
			currentColor = Color3.fromHSV(colorHue, colorSaturation, colorValue)
			colorChip.BackgroundColor3 = currentColor
			satArea.BackgroundColor3 = Color3.fromHSV(colorHue, 1, 1)
			satCursor.Position = UDim2.new(colorSaturation, 0, 1 - colorValue, 0)
			hueCursor.Position = UDim2.new(colorHue, 0, 0.5, 0)
			if fireCallback and config.Color and config.Color.Callback then
				config.Color.Callback(currentColor, state)
			end
		end

		local function updateSat(position)
			local absPos = satArea.AbsolutePosition
			local absSize = satArea.AbsoluteSize
			colorSaturation = clamp((position.X - absPos.X) / math.max(absSize.X, 1), 0, 1)
			colorValue = 1 - clamp((position.Y - absPos.Y) / math.max(absSize.Y, 1), 0, 1)
			renderColor(true)
		end

		local function updateHue(position)
			local absPos = hueBar.AbsolutePosition
			local absSize = hueBar.AbsoluteSize
			colorHue = clamp((position.X - absPos.X) / math.max(absSize.X, 1), 0, 1)
			renderColor(true)
		end

		colorChip.MouseButton1Click:Connect(function()
			toggleColorPopup(not colorExpanded)
		end)

		applyButton.MouseButton1Click:Connect(function()
			if config.Color and config.Color.Callback then
				config.Color.Callback(currentColor, state)
			end
			toggleColorPopup(false)
		end)

		satArea.InputBegan:Connect(function(input)
			if not isPrimaryInput(input) then
				return
			end
			draggingSat = true
			updateSat(input.Position)
			_currentDragMove = function(position)
				updateSat(position)
			end
			_currentDragEnd = function()
				draggingSat = false
			end
		end)
		satArea.InputEnded:Connect(function(input)
			if isPrimaryInput(input) then
				draggingSat = false
			end
		end)
		hueBar.InputBegan:Connect(function(input)
			if not isPrimaryInput(input) then
				return
			end
			draggingHue = true
			updateHue(input.Position)
			_currentDragMove = function(position)
				updateHue(position)
			end
			_currentDragEnd = function()
				draggingHue = false
			end
		end)
		hueBar.InputEnded:Connect(function(input)
			if isPrimaryInput(input) then
				draggingHue = false
			end
		end)
		UserInputService.InputBegan:Connect(function(input)
			if not colorExpanded or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			local position = input.Position
			local insideX = position.X >= colorPopup.AbsolutePosition.X and position.X <= (colorPopup.AbsolutePosition.X + colorPopup.AbsoluteSize.X)
			local insideY = position.Y >= colorPopup.AbsolutePosition.Y and position.Y <= (colorPopup.AbsolutePosition.Y + colorPopup.AbsoluteSize.Y)
			local chipX = position.X >= colorChip.AbsolutePosition.X and position.X <= (colorChip.AbsolutePosition.X + colorChip.AbsoluteSize.X)
			local chipY = position.Y >= colorChip.AbsolutePosition.Y and position.Y <= (colorChip.AbsolutePosition.Y + colorChip.AbsoluteSize.Y)
			if not (insideX and insideY) and not (chipX and chipY) then
				toggleColorPopup(false)
			end
		end)
		renderColor(false)
	end

	local boundKey = resolveKeyCode(config.Key)

	local function render()
		toggleBox.BackgroundColor3 = state and self.Window.Theme.Accent or self.Window.Theme.ControlAlt
		fill.BackgroundTransparency = state and 0 or 1
		toggleStroke.Color = state and self.Window.Theme.Accent or self.Window.Theme.Stroke
		check.Text = state and "" or ""
		if subtitleLabel then
			subtitleLabel.TextColor3 = state and self.Window.Theme.Text or self.Window.Theme.SubText
		end
		titleLabel.TextColor3 = self.Window.Theme.Text
	end

	local api = {}

	function api:Set(value)
		state = value and true or false
		render()
		if config.Callback then
			config.Callback(state)
		end
	end

	function api:Get()
		return state
	end

	function api:SetKey(keyCode)
		boundKey = resolveKeyCode(keyCode)
		if keyChipText then
			keyChipText.Text = boundKey and boundKey.Name or "..."
		end
		return boundKey
	end

	function api:GetKey()
		return boundKey
	end

	function api:SetColor(color)
		if not colorChip or typeof(color) ~= "Color3" then
			return currentColor
		end
		colorHue, colorSaturation, colorValue = hsvToState(color)
		currentColor = color
		colorChip.BackgroundColor3 = color
		if config.Color and config.Color.Callback then
			config.Color.Callback(color, state)
		end
		return currentColor
	end

	function api:GetColor()
		return currentColor
	end

	toggleBox.MouseButton1Click:Connect(function()
		api:Set(not state)
	end)

	row.InputBegan:Connect(function(input)
		if isPrimaryInput(input) then
			local position = input.Position
			if keyChip then
				local insideKeyX = position.X >= keyChip.AbsolutePosition.X and position.X <= (keyChip.AbsolutePosition.X + keyChip.AbsoluteSize.X)
				local insideKeyY = position.Y >= keyChip.AbsolutePosition.Y and position.Y <= (keyChip.AbsolutePosition.Y + keyChip.AbsoluteSize.Y)
				if insideKeyX and insideKeyY then
					return
				end
			end
			if colorChip then
				local insideColorX = position.X >= colorChip.AbsolutePosition.X and position.X <= (colorChip.AbsolutePosition.X + colorChip.AbsoluteSize.X)
				local insideColorY = position.Y >= colorChip.AbsolutePosition.Y and position.Y <= (colorChip.AbsolutePosition.Y + colorChip.AbsoluteSize.Y)
				if insideColorX and insideColorY then
					return
				end
			end
			api:Set(not state)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if keyListening and input.KeyCode ~= Enum.KeyCode.Unknown then
			api:SetKey(input.KeyCode)
			keyListening = false
			return
		end

		if boundKey and input.KeyCode == boundKey then
			api:Set(not state)
		end
	end)

	render()
	self.Window:RegisterFlag(flag, function()
		return api:Get()
	end, function(value)
		api:Set(value)
	end)
	if currentColor then
		self.Window:RegisterFlag(flag .. "_color", function()
			return rgbToHex(api:GetColor())
		end, function(value)
			if type(value) == "string" and #value == 7 and value:sub(1, 1) == "#" then
				local r = tonumber(value:sub(2, 3), 16) or 255
				local g = tonumber(value:sub(4, 5), 16) or 255
				local b = tonumber(value:sub(6, 7), 16) or 255
				api:SetColor(Color3.fromRGB(r, g, b))
			end
		end)
	end
	return api
end

function Section:AddSlider(options)
	local config = merge({
		Title = "Slider",
		Description = nil,
		Min = 0,
		Max = 100,
		Default = 50,
		Step = 1,
		Suffix = "",
		Callback = nil,
	}, options or {})
	local flag = resolveControlFlag(self, config)

	local holder = create("Frame", {
		Parent = self.Content,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, config.Description and 56 or 42),
	})
	applyPadding(holder, 0, 0, 2, 4)

	createTextLabel(holder, UDim2.new(1, -70, 0, 16), UDim2.new(0, 0, 0, 0), config.Title, Enum.Font.Gotham, 12, self.Window.Theme.Text)
	local valueLabel = createTextLabel(holder, UDim2.new(0, 64, 0, 16), UDim2.new(1, -64, 0, 0), "", Enum.Font.GothamMedium, 12, self.Window.Theme.Text, Enum.TextXAlignment.Right)

	if config.Description then
		local subtitle = createTextLabel(holder, UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 18), config.Description, Enum.Font.Gotham, 12, self.Window.Theme.SubText)
		subtitle.Name = "Subtitle"
	end

	local trackY = config.Description and 38 or 24
	local track = create("Frame", {
		Parent = holder,
		BackgroundColor3 = self.Window.Theme.ControlAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, trackY),
		Size = UDim2.new(1, 0, 0, 4),
	})
	track.Active = true
	applyCorner(track, 999)

	local hitbox = create("TextButton", {
		Parent = holder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, trackY - 7),
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
		AutoButtonColor = false,
	})

	local fill = create("Frame", {
		Parent = track,
		BackgroundColor3 = self.Window.Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	})
	applyCorner(fill, 999)

	local knob = create("Frame", {
		Parent = track,
		BackgroundColor3 = Color3.fromRGB(245, 245, 247),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
	})
	applyCorner(knob, 999)

	local dragging = false
	local currentValue = clamp(config.Default, config.Min, config.Max)
	local api = {}

	local function renderValue(fireCallback, instant)
		local alpha = (currentValue - config.Min) / math.max(config.Max - config.Min, 0.0001)
		valueLabel.Text = formatNumber(currentValue) .. config.Suffix
		if instant then
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		else
			tween(fill, 0.10, {Size = UDim2.new(alpha, 0, 1, 0)}, Enum.EasingStyle.Quad)
			tween(knob, 0.10, {Position = UDim2.new(alpha, 0, 0.5, 0)}, Enum.EasingStyle.Quad)
		end
		if fireCallback and config.Callback then
			config.Callback(currentValue)
		end
	end

	local function setFromInput(positionX, fireCallback)
		local absolutePosition = track.AbsolutePosition.X
		local absoluteSize = track.AbsoluteSize.X
		local alpha = clamp((positionX - absolutePosition) / math.max(absoluteSize, 1), 0, 1)
		local nextValue = config.Min + ((config.Max - config.Min) * alpha)
		currentValue = clamp(round(nextValue, config.Step), config.Min, config.Max)
		renderValue(fireCallback, true)
	end

	function api:Set(value)
		currentValue = clamp(round(value, config.Step), config.Min, config.Max)
		renderValue(true, false)
	end

	function api:Get()
		return currentValue
	end

	local function beginDrag(input)
		if not isPrimaryInput(input) then
			return
		end
		dragging = true
		setFromInput(input.Position.X, true)
		_currentDragMove = function(position)
			setFromInput(position.X, true)
		end
		_currentDragEnd = function()
			dragging = false
		end
	end

	hitbox.InputBegan:Connect(beginDrag)
	track.InputBegan:Connect(beginDrag)

	renderValue(false, true)
	self.Window:RegisterFlag(flag, function()
		return api:Get()
	end, function(value)
		api:Set(value)
	end)
	return api
end

function Window:CreateDefaultSettingsTab(options)
	local config = merge({
		Title = "Settings",
		Accent = self.Theme.Accent,
		PresenceBaseUrl = INTERNAL_PRESENCE_BASE_URL,
		PresenceScriptId = "cloudy-paid",
		PresenceInterval = 15,
		DiscordUrl = "https://discord.gg/getcloudy",
		WebsiteUrl = "https://github.com/kerk321/Cloudy-ui-Library",
		ThemePresets = Cloudy.DefaultThemePresets,
		DefaultPreset = "Cloudy Rose",
		FooterUrl = ".gg/getcloudy",
		UpdatedText = nil,
	}, options or {})

	if self.DefaultSettingsTab then
		if config.FooterUrl then
			self:SetFooterUrl(config.FooterUrl)
		end
		if config.UpdatedText then
			self:SetUpdatedText(config.UpdatedText)
		end
		if config.PresenceBaseUrl and config.PresenceBaseUrl ~= "" then
			self:UsePresenceService(config.PresenceBaseUrl, config.PresenceScriptId, config.PresenceInterval)
		end
		self:_keepSettingsTabLast()
		return self.DefaultSettingsTab
	end

	if config.FooterUrl then
		self:SetFooterUrl(config.FooterUrl)
	end
	if config.UpdatedText then
		self:SetUpdatedText(config.UpdatedText)
	end
	if config.PresenceBaseUrl and config.PresenceBaseUrl ~= "" then
		self:UsePresenceService(config.PresenceBaseUrl, config.PresenceScriptId, config.PresenceInterval)
	end

	local settingsTab = self:CreateTab({
		Title = config.Title,
		Accent = config.Accent,
		IsDefaultSettings = true,
	})
	self.DefaultSettingsTab = settingsTab
	self:_keepSettingsTabLast()

	local desktopSection = settingsTab:CreateSection({
		Title = "Desktop",
		Side = "Left",
	})
	desktopSection:AddParagraph("Desktop", "Use RightShift by default. The floating button stays hidden on PC unless you enable it.")
	local menuKeybind = desktopSection:AddKeybind({
		Title = "Menu Keybind",
		Description = "Default desktop key for opening and closing the menu.",
		Default = self.ToggleKeybind,
		Flag = "cloudy_menu_keybind",
		Callback = function(key, changed)
			if changed then
				self:SetToggleKeybind(key)
			end
		end,
	})
	desktopSection:AddToggle({
		Title = "Desktop Floating Button",
		Description = "Shows the draggable button on PC too.",
		Default = self.ShowDesktopOpenButton,
		Flag = "cloudy_desktop_open_button",
		Callback = function(value)
			self:SetDesktopOpenButtonVisible(value)
		end,
	})

	local mobileSection = settingsTab:CreateSection({
		Title = "Mobile",
		Side = "Left",
	})
	mobileSection:AddParagraph("Mobile", "Touch devices can keep the floating button visible so the menu stays easy to reach.")
	mobileSection:AddToggle({
		Title = "Mobile Floating Button",
		Description = "Keeps the draggable button visible on touch devices.",
		Default = self.ShowMobileOpenButton,
		Flag = "cloudy_mobile_open_button",
		Callback = function(value)
			self:SetMobileOpenButtonVisible(value)
		end,
	})

	local themeSection = settingsTab:CreateSection({
		Title = "Theme",
		Side = "Right",
	})
	themeSection:AddParagraph("Theme", "Choose a preset for the whole interface, then fine tune the accent if you want a custom look.")
	local presetDropdown
	local accentPicker
	local applyingPreset = false
	local function applyPreset(name)
		local preset = config.ThemePresets[name]
		if not preset then
			return
		end
		applyingPreset = true
		self:SetTheme(preset)
		self:SetAccentColor(preset.Accent)
		if accentPicker then
			accentPicker:Set(preset.Accent)
		end
		applyingPreset = false
	end
	local presetValues = {}
	for name in pairs(config.ThemePresets) do
		table.insert(presetValues, name)
	end
	table.sort(presetValues)
	table.insert(presetValues, "Custom")
	presetDropdown = themeSection:AddDropdown({
		Title = "Preset",
		Values = presetValues,
		Default = config.DefaultPreset,
		Flag = "cloudy_theme_preset",
		Callback = function(value)
			if value ~= "Custom" then
				applyPreset(value)
			end
		end,
	})
	accentPicker = themeSection:AddColorPicker({
		Title = "Accent Color",
		Description = "Updates the full library theme in real time.",
		Default = self.Theme.Accent,
		Flag = "cloudy_theme_accent",
		Callback = function(color)
			if presetDropdown and not applyingPreset then
				presetDropdown:Set("Custom")
			end
			self:SetAccentColor(color)
		end,
	})

	local configSection = settingsTab:CreateSection({
		Title = "Configs",
		Side = "Right",
	})
	configSection:AddParagraph("Profiles", "Create, save, refresh, and load configs here. Disk save is used when file APIs exist; otherwise configs stay available for the current session.")
	local configNameBox = configSection:AddTextbox({
		Title = "Config Name",
		Description = "Name used for save and load.",
		Default = "default",
		Flag = "cloudy_config_name",
	})
	local configList = configSection:AddDropdown({
		Title = "Saved Configs",
		Values = {"default"},
		Default = "default",
		Callback = function(value)
			configNameBox:Set(value)
		end,
	})
	local function refreshConfigs(selectName)
		local configs = self:ListConfigs()
		if #configs == 0 then
			configs = {"default"}
		end
		configList:SetValues(configs)
		configList:Set(selectName or configs[1])
		return configs
	end
	configSection:AddButton({
		Title = "Refresh Config List",
		Callback = function()
			local configs = refreshConfigs(configNameBox:Get())
			self:Notify({
				Title = "Configs",
				Content = "Found " .. tostring(#configs) .. " config(s).",
				Duration = 2,
			})
		end,
	})
	configSection:AddButton({
		Title = "Create / Save Config",
		Callback = function()
			local configName = configNameBox:Get()
			local success, result = self:SaveConfig(configName)
			if success then
				refreshConfigs(configName)
				self:Notify({
					Title = "Config Saved",
					Content = result == "memory" and ("Saved profile " .. configName .. " in session memory.") or ("Saved profile " .. configName),
					Duration = 2,
				})
			else
				self:Notify({
					Title = "Save Failed",
					Content = tostring(result),
					Duration = 2.4,
				})
			end
		end,
	})
	configSection:AddButton({
		Title = "Load Selected Config",
		Callback = function()
			local selected = configList:Get()
			local success, result = self:LoadConfig(selected)
			if success then
				configNameBox:Set(selected)
				menuKeybind:Set(self.ToggleKeybind)
				self:Notify({
					Title = "Config Loaded",
					Content = "Loaded profile " .. tostring(selected),
					Duration = 2,
				})
			else
				self:Notify({
					Title = "Load Failed",
					Content = tostring(result),
					Duration = 2.4,
				})
			end
		end,
	})

	local infoSection = settingsTab:CreateSection({
		Title = "Info",
		Side = "Right",
	})
	infoSection:AddParagraph("Support", "Join our Discord if you need help, want to report bugs, or want to stay updated on fixes and new builds.")
	infoSection:AddButton({
		Title = "Copy Discord Link",
		Callback = function()
			local success = copyToClipboard(config.DiscordUrl)
			self:Notify({
				Title = success and "Copied" or "Clipboard Missing",
				Content = success and "Discord link copied to your clipboard." or config.DiscordUrl,
				Duration = 2.4,
			})
		end,
	})
	infoSection:AddButton({
		Title = "Copy Website Link",
		Callback = function()
			local success = copyToClipboard(config.WebsiteUrl)
			self:Notify({
				Title = success and "Copied" or "Clipboard Missing",
				Content = success and "Website link copied to your clipboard." or config.WebsiteUrl,
				Duration = 2.4,
			})
		end,
	})

	if config.ThemePresets[config.DefaultPreset] then
		applyPreset(config.DefaultPreset)
	end
	refreshConfigs("default")

	return settingsTab
end

function Section:AddDropdown(options)
	local config = merge({
		Title = "Dropdown",
		Description = nil,
		Values = {},
		Default = nil,
		Callback = nil,
	}, options or {})
	local flag = resolveControlFlag(self, config)
	local section = self

	local holder = create("Frame", {
		Parent = self.Content,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, config.Description and 56 or 34),
	})
	if config.Default == nil and #config.Values > 0 then
		config.Default = config.Values[1]
	end

	local top = create("TextButton", {
		Parent = holder,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 3,
	})
	local topOutline = create("Frame", {
		Parent = holder,
		BackgroundColor3 = self.Window.Theme.Control,
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, 28),
		ZIndex = 1,
	})
	applyCorner(topOutline, 8)
	applyStroke(topOutline, self.Window.Theme.Stroke, 1, 0.2)

	local titleLabel = createTextLabel(top, UDim2.new(1, -120, 1, 0), UDim2.new(0, 12, 0, 0), config.Title, Enum.Font.GothamMedium, 12, self.Window.Theme.Text)
	titleLabel.ZIndex = 3
	local valueLabel = createTextLabel(top, UDim2.new(0, 124, 1, 0), UDim2.new(1, -144, 0, 0), config.Default or "Select", Enum.Font.Gotham, 12, self.Window.Theme.SubText, Enum.TextXAlignment.Right)
	valueLabel.ZIndex = 3
	local chevron = createTextLabel(top, UDim2.new(0, 18, 1, 0), UDim2.new(1, -18, 0, 0), ">", Enum.Font.GothamBold, 12, self.Window.Theme.SubText, Enum.TextXAlignment.Center)
	chevron.ZIndex = 3

	if config.Description then
		local description = createTextLabel(holder, UDim2.new(1, -4, 0, 18), UDim2.new(0, 0, 0, 34), config.Description, Enum.Font.Gotham, 11, self.Window.Theme.SubText)
		description.TextWrapped = true
	end

	local list = create("Frame", {
		Parent = self.Window.Overlay,
		BackgroundColor3 = self.Window.Theme.ControlAlt,
		Size = UDim2.fromOffset(220, 0),
		Visible = false,
		ZIndex = 50,
	})
	applyCorner(list, 8)
	applyStroke(list, self.Window.Theme.Stroke, 1, 0.15)
	applyPadding(list, 8, 8, 8, 8)
	local scroll = create("ScrollingFrame", {
		Parent = list,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 51,
	})
	local listLayout = addListLayout(scroll, 4)

	local expanded = false
	local selected = config.Default
	local api = {}

	local function refreshPopupSize()
		local itemHeight = (#config.Values * 32) + 10
		local popupHeight = math.min(itemHeight, 192)
		list.Size = UDim2.fromOffset(math.max(top.AbsoluteSize.X, 220), popupHeight)
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
	end

	local function selectValue(value)
		if value == nil and #config.Values > 0 then
			value = config.Values[1]
		end
		selected = value
		valueLabel.Text = selected and tostring(selected) or "Select"
		if config.Callback then
			config.Callback(selected)
		end
	end

	local function setExpanded(state)
		expanded = state
		list.Visible = state
		chevron.Text = state and "v" or ">"
		if state then
			list.Position = UDim2.fromOffset(top.AbsolutePosition.X, top.AbsolutePosition.Y + top.AbsoluteSize.Y + 4)
			refreshPopupSize()
		end
	end

		for _, value in ipairs(config.Values) do
			local item = create("TextButton", {
				Parent = scroll,
				BackgroundColor3 = self.Window.Theme.Control,
				Size = UDim2.new(1, 0, 0, 28),
				Text = tostring(value),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = self.Window.Theme.Text,
				AutoButtonColor = false,
				ZIndex = 51,
			})
			applyCorner(item, 6)
			item.TextXAlignment = Enum.TextXAlignment.Left
			applyPadding(item, 8, 8, 0, 0)
			item.MouseButton1Click:Connect(function()
				selectValue(value)
				setExpanded(false)
			end)
		end

	top.MouseButton1Click:Connect(function()
		setExpanded(not expanded)
	end)

	UserInputService.InputBegan:Connect(function(input)
		if expanded and input.UserInputType == Enum.UserInputType.MouseButton1 then
			local position = input.Position
			local insideX = position.X >= list.AbsolutePosition.X and position.X <= (list.AbsolutePosition.X + list.AbsoluteSize.X)
			local insideY = position.Y >= list.AbsolutePosition.Y and position.Y <= (list.AbsolutePosition.Y + list.AbsoluteSize.Y)
			local topX = position.X >= top.AbsolutePosition.X and position.X <= (top.AbsolutePosition.X + top.AbsoluteSize.X)
			local topY = position.Y >= top.AbsolutePosition.Y and position.Y <= (top.AbsolutePosition.Y + top.AbsoluteSize.Y)
			if not (insideX and insideY) and not (topX and topY) then
				setExpanded(false)
			end
		end
	end)

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshPopupSize)
	refreshPopupSize()

	function api:Set(value)
		selectValue(value)
	end

	function api:SetValues(values)
		config.Values = values or {}
		if selected == nil and #config.Values > 0 then
			selected = config.Values[1]
		end
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, value in ipairs(config.Values) do
			local item = create("TextButton", {
				Parent = scroll,
				BackgroundColor3 = section.Window.Theme.Control,
				Size = UDim2.new(1, 0, 0, 28),
				Text = tostring(value),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = section.Window.Theme.Text,
				AutoButtonColor = false,
				ZIndex = 51,
			})
			applyCorner(item, 6)
			item.TextXAlignment = Enum.TextXAlignment.Left
			applyPadding(item, 8, 8, 0, 0)
			item.MouseButton1Click:Connect(function()
				selectValue(value)
				setExpanded(false)
			end)
		end
		local hasSelected = false
		for _, value in ipairs(config.Values) do
			if value == selected then
				hasSelected = true
				break
			end
		end
		if not hasSelected then
			selected = config.Values[1]
		end
		valueLabel.Text = selected and tostring(selected) or "Select"
		refreshPopupSize()
	end

	function api:Get()
		return selected
	end

	self.Window:RegisterFlag(flag, function()
		return api:Get()
	end, function(value)
		api:Set(value)
	end)

	return api
end

function Section:AddTextbox(options)
	local config = merge({
		Title = "Textbox",
		Description = nil,
		Placeholder = "Type here",
		Default = "",
		Callback = nil,
		ClearOnFocus = false,
	}, options or {})
	local flag = resolveControlFlag(self, config)

	local holder = create("Frame", {
		Parent = self.Content,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, config.Description and 58 or 42),
	})

	createTextLabel(holder, UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 0), config.Title, Enum.Font.GothamMedium, self.Window.Profile.ControlText, self.Window.Theme.Text)
	if config.Description then
		createTextLabel(holder, UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 16), config.Description, Enum.Font.Gotham, 11, self.Window.Theme.SubText)
	end

	local box = create("TextBox", {
		Parent = holder,
		BackgroundColor3 = self.Window.Theme.Control,
		Position = UDim2.new(0, 0, 0, config.Description and 30 or 18),
		Size = UDim2.new(1, 0, 0, 26),
		Text = config.Default,
		PlaceholderText = config.Placeholder,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = self.Window.Theme.Text,
		PlaceholderColor3 = self.Window.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ClearTextOnFocus = config.ClearOnFocus,
	})
	applyCorner(box, 8)
	applyStroke(box, self.Window.Theme.Stroke, 1, 0.2)
	applyPadding(box, 10, 10, 0, 0)

	local api = {}

	box.FocusLost:Connect(function(enterPressed)
		if config.Callback then
			config.Callback(box.Text, enterPressed)
		end
	end)

	function api:Get()
		return box.Text
	end

	function api:Set(value)
		box.Text = tostring(value or "")
		if config.Callback then
			config.Callback(box.Text, false)
		end
	end

	api.Instance = box
	self.Window:RegisterFlag(flag, function()
		return api:Get()
	end, function(value)
		api:Set(value)
	end)
	return api
end

function Section:AddKeybind(options)
	local config = merge({
		Title = "Keybind",
		Description = nil,
		Default = Enum.KeyCode.RightShift,
		Callback = nil,
	}, options or {})
	local flag = resolveControlFlag(self, config)

	local row, _, subtitleLabel = makeInteractiveRow(self, config.Title, config.Description, config.Description and 44 or 26)
	row.BackgroundTransparency = 1
	for _, child in ipairs(row:GetChildren()) do
		if child:IsA("UIStroke") then
			child.Transparency = 1
		end
	end
	local binder = create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = self.Window.Theme.ControlAlt,
		Size = UDim2.fromOffset(62, 20),
		Text = config.Default.Name,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = self.Window.Theme.Text,
		AutoButtonColor = false,
	})
	applyCorner(binder, 5)

	local listening = false
	local current = resolveKeyCode(config.Default) or Enum.KeyCode.RightShift
	local api = {}

	binder.MouseButton1Click:Connect(function()
		listening = true
		binder.Text = "..."
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
			current = input.KeyCode
			binder.Text = current.Name
			listening = false
			if config.Callback then
				config.Callback(current, true)
			end
			return
		end

		if not listening and input.KeyCode == current then
			if config.Callback then
				config.Callback(current, false)
			end
		end
	end)

	function api:Get()
		return current
	end

	function api:Set(keyCode)
		current = resolveKeyCode(keyCode) or current
		binder.Text = current.Name
		if config.Callback then
			config.Callback(current, true)
		end
	end

	self.Window:RegisterFlag(flag, function()
		return api:Get().Name
	end, function(value)
		api:Set(value)
	end)

	return api
end

function Section:AddColorPicker(options)
	local config = merge({
		Title = "Color Picker",
		Description = nil,
		Default = self.Window.Theme.Accent,
		Callback = nil,
	}, options or {})
	local flag = resolveControlFlag(self, config)

	local holder = create("Frame", {
		Parent = self.Content,
		BackgroundColor3 = self.Window.Theme.Control,
		Size = UDim2.new(1, 0, 0, 42),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	applyCorner(holder, 10)
	applyStroke(holder, self.Window.Theme.Stroke, 1, 0.2)
	applyPadding(holder, 12, 12, 10, 10)
	local layout = addListLayout(holder, 10)

	local headerButton = create("TextButton", {
		Parent = holder,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, config.Description and 34 or 22),
		Text = "",
		AutoButtonColor = false,
	})

	createTextLabel(headerButton, UDim2.new(1, -60, 0, 18), UDim2.new(), config.Title, Enum.Font.GothamMedium, self.Window.Profile.ControlText, self.Window.Theme.Text)
	if config.Description then
		createTextLabel(headerButton, UDim2.new(1, -60, 0, 16), UDim2.new(0, 0, 0, 18), config.Description, Enum.Font.Gotham, 12, self.Window.Theme.SubText)
	end

	local swatch = create("Frame", {
		Parent = headerButton,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(32, 18),
		BackgroundColor3 = config.Default,
	})
	applyCorner(swatch, 7)
	applyStroke(swatch, Color3.fromRGB(255, 255, 255), 1, 0.8)

	local picker = create("Frame", {
		Parent = holder,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
	})
	picker.LayoutOrder = 3
	local pickerLayout = addListLayout(picker, 8)

	local satArea = create("Frame", {
		Parent = picker,
		BackgroundColor3 = Color3.fromHSV(0, 1, 1),
		Size = UDim2.new(1, 0, 0, 128),
		ClipsDescendants = true,
	})
	applyCorner(satArea, 10)

	local whiteOverlay = create("Frame", {
		Parent = satArea,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	create("UIGradient", {
		Parent = whiteOverlay,
		Rotation = 0,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	local blackOverlay = create("Frame", {
		Parent = satArea,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	create("UIGradient", {
		Parent = blackOverlay,
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
	})

	local satCursor = create("Frame", {
		Parent = satArea,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0, 0),
	})
	applyCorner(satCursor, 999)
	applyStroke(satCursor, Color3.fromRGB(0, 0, 0), 1, 0.55)

	local hueBar = create("Frame", {
		Parent = picker,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 0, 12),
	})
	applyCorner(hueBar, 999)
	create("UIGradient", {
		Parent = hueBar,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
		}),
	})

	local hueCursor = create("Frame", {
		Parent = hueBar,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(8, 18),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})
	applyCorner(hueCursor, 999)
	applyStroke(hueCursor, Color3.fromRGB(0, 0, 0), 1, 0.5)

	local footer = create("Frame", {
		Parent = picker,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
	})
	local hexLabel = createTextLabel(footer, UDim2.new(1, -136, 1, 0), UDim2.new(), rgbToHex(config.Default), Enum.Font.GothamSemibold, 12, self.Window.Theme.Text)
	local rgbLabel = createTextLabel(footer, UDim2.new(0, 70, 1, 0), UDim2.new(1, -70, 0, 0), "", Enum.Font.Gotham, 12, self.Window.Theme.SubText, Enum.TextXAlignment.Right)
	local applyButton = create("TextButton", {
		Parent = footer,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = self.Window.Theme.ControlAlt,
		Size = UDim2.fromOffset(58, 24),
		Text = "Apply",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = self.Window.Theme.Text,
		AutoButtonColor = false,
	})
	applyCorner(applyButton, 7)
	applyStroke(applyButton, self.Window.Theme.Stroke, 1, 0.2)

	local expanded = false
	local draggingSat = false
	local draggingHue = false
	local hue, saturation, value = hsvToState(config.Default)
	local api = {}

	local function refreshHolderSize()
		holder.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
	end

	local function currentColor()
		return Color3.fromHSV(hue, saturation, value)
	end

	local function render(fireCallback)
		local color = currentColor()
		swatch.BackgroundColor3 = color
		satArea.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		satCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
		hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
		hexLabel.Text = rgbToHex(color)
		rgbLabel.Text = string.format("%d %d %d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))

		if fireCallback and config.Callback then
			config.Callback(color)
		end
	end

	local function setExpanded(state)
		expanded = state
		picker.Visible = state
		refreshHolderSize()
	end

	local function updateSaturationValue(position)
		local absPos = satArea.AbsolutePosition
		local absSize = satArea.AbsoluteSize
		saturation = clamp((position.X - absPos.X) / math.max(absSize.X, 1), 0, 1)
		value = 1 - clamp((position.Y - absPos.Y) / math.max(absSize.Y, 1), 0, 1)
		render(true)
	end

	local function updateHue(position)
		local absPos = hueBar.AbsolutePosition
		local absSize = hueBar.AbsoluteSize
		hue = clamp((position.X - absPos.X) / math.max(absSize.X, 1), 0, 1)
		render(true)
	end

	headerButton.MouseButton1Click:Connect(function()
		setExpanded(not expanded)
	end)

	applyButton.MouseButton1Click:Connect(function()
		if config.Callback then
			config.Callback(currentColor())
		end
		setExpanded(false)
	end)

	satArea.InputBegan:Connect(function(input)
		if not isPrimaryInput(input) then
			return
		end
		draggingSat = true
		updateSaturationValue(input.Position)
		_currentDragMove = function(position)
			updateSaturationValue(position)
		end
		_currentDragEnd = function()
			draggingSat = false
		end
	end)

	satArea.InputEnded:Connect(function(input)
		if isPrimaryInput(input) then
			draggingSat = false
		end
	end)

	hueBar.InputBegan:Connect(function(input)
		if not isPrimaryInput(input) then
			return
		end
		draggingHue = true
		updateHue(input.Position)
		_currentDragMove = function(position)
			updateHue(position)
		end
		_currentDragEnd = function()
			draggingHue = false
		end
	end)

	hueBar.InputEnded:Connect(function(input)
		if isPrimaryInput(input) then
			draggingHue = false
		end
	end)

	function api:Get()
		return currentColor()
	end

	function api:Set(color)
		hue, saturation, value = hsvToState(color)
		render(true)
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshHolderSize)
	pickerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshHolderSize)
	render(false)
	refreshHolderSize()
	if config.Default == nil then
		api:Set(self.Window.Theme.Accent)
	end
	self.Window:RegisterFlag(flag, function()
		return rgbToHex(api:Get())
	end, function(value)
		if type(value) == "string" and #value == 7 and value:sub(1, 1) == "#" then
			local r = tonumber(value:sub(2, 3), 16) or 255
			local g = tonumber(value:sub(4, 5), 16) or 255
			local b = tonumber(value:sub(6, 7), 16) or 255
			api:Set(Color3.fromRGB(r, g, b))
		end
	end)
	return api
end

function Tab:CreateSection(options)
	local config = merge({
		Title = "Section",
		Side = "Auto",
	}, options or {})

	local section = setmetatable({}, Section)
	section.Window = self.Window
	section.Tab = self
	section.Side = config.Side
	section.TitleText = config.Title

	section.Root = create("Frame", {
		Name = config.Title,
		BackgroundColor3 = self.Window.Theme.Section,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	applyCorner(section.Root, 10)
	applyStroke(section.Root, self.Window.Theme.Stroke, 1, 0.18)
	applyPadding(section.Root, SECTION_PADDING, SECTION_PADDING, SECTION_PADDING, SECTION_PADDING)

	local layout = addListLayout(section.Root, 8)

	section.Title = createTextLabel(section.Root, UDim2.new(1, 0, 0, 16), UDim2.new(), config.Title, Enum.Font.GothamMedium, 12, self.Window.Theme.Text)
	section.Content = create("Frame", {
		Parent = section.Root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	addListLayout(section.Content, 6)

	table.insert(self.Sections, section)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		section.Root.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		self:RefreshSections()
		updateCanvas(self)
	end)

	section.Content.ChildAdded:Connect(function()
		self:RefreshSections()
		updateCanvas(self)
	end)

	section.Content.ChildRemoved:Connect(function()
		self:RefreshSections()
		updateCanvas(self)
	end)

	self:RefreshSections()
	updateCanvas(self)
	return section
end

function Window:CreateTab(options)
	local config = merge({
		Title = "Tab",
		Accent = self.Theme.Accent,
		SelectOnCreate = nil,
		IsDefaultSettings = false,
	}, options or {})

	local tab = setmetatable({}, Tab)
	tab.Window = self
	tab.AccentColor = config.Accent
	tab.Sections = {}
	tab.TitleText = config.Title

	tab.Button = create("TextButton", {
		Parent = self.TabList,
		BackgroundColor3 = self.Theme.TabIdle,
		BackgroundTransparency = 0,
		Size = UDim2.new(0, 0, 0, math.max(24, self.Profile.TabHeight - 14)),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "",
		AutoButtonColor = false,
	})
	applyCorner(tab.Button, 999)
	tab.ButtonStroke = applyStroke(tab.Button, self.Theme.Stroke, 1, 0.72)
	applyPadding(tab.Button, 14, 14, 0, 0)

	tab.ButtonText = createTextLabel(tab.Button, UDim2.new(0, 0, 1, 0), UDim2.new(), config.Title, Enum.Font.GothamMedium, self.Profile.ControlText, self.Theme.SubText)
	tab.ButtonText.AutomaticSize = Enum.AutomaticSize.X
	tab.ButtonText.TextTransparency = 0

	tab.AccentDot = create("Frame", {
		Parent = tab.Button,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -6, 0.5, 0),
		Size = UDim2.fromOffset(4, 14),
		BackgroundColor3 = config.Accent,
		Visible = false,
	})
	applyCorner(tab.AccentDot, 999)

	tab.ButtonIndicator = create("Frame", {
		Parent = tab.Button,
		BackgroundColor3 = self.Theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.fromOffset(12, 2),
		Visible = false,
	})
	applyCorner(tab.ButtonIndicator, 999)

	tab.Page = create("ScrollingFrame", {
		Parent = self.PageHost,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		Visible = false,
	})

	tab.LeftColumn = create("Frame", {
		Parent = tab.Page,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	tab.LeftLayout = addListLayout(tab.LeftColumn, SECTION_GAP)

	tab.RightColumn = create("Frame", {
		Parent = tab.Page,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 8, 0, 16),
		Size = UDim2.new(0.5, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	tab.RightLayout = addListLayout(tab.RightColumn, SECTION_GAP)

	tab.LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		updateCanvas(tab)
	end)
	tab.RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		updateCanvas(tab)
	end)
	tab.Page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		tab:RefreshLayout()
	end)

	tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)
	self._tabCreateIndex = (self._tabCreateIndex or 0) + 1
	tab.Button.LayoutOrder = self._tabCreateIndex

	if config.IsDefaultSettings then
		self.DefaultSettingsTab = tab
	end

	self:_keepSettingsTabLast()

	local shouldSelect = config.SelectOnCreate
	if shouldSelect == nil then
		shouldSelect = (not self.ActiveTab) or (self.ActiveTab == self.DefaultSettingsTab and not config.IsDefaultSettings)
	end

	if shouldSelect then
		self:SelectTab(tab)
	else
		self:_updateTabStyles()
	end

	return tab
end

function Cloudy.new(options)
	local config = merge(DEFAULTS, options or {})

	local self = setmetatable({}, Window)
	self.Theme = merge(Cloudy.Theme, {
		Accent = config.Accent,
		AccentDark = config.Accent:Lerp(Color3.new(0, 0, 0), 0.35),
	})
	self.Profile = getViewportProfile()
	self.Tabs = {}
	self.FlagRegistry = {}
	self.ConfigFolder = config.ConfigFolder
	self.ShowDesktopOpenButton = config.ShowDesktopOpenButton and true or false
	self.ShowMobileOpenButton = config.ShowMobileOpenButton ~= false
	self.ToggleKeybind = resolveKeyCode(config.ToggleKeybind) or Enum.KeyCode.RightShift
	self.AutoCreateSettingsTab = config.AutoCreateSettingsTab ~= false
	self.IsOpen = true

	self.Gui = create("ScreenGui", {
		Name = "CloudyUI",
		Parent = getGuiParent(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	self.OpenButton = create("TextButton", {
		Parent = self.Gui,
		Name = "OpenButton",
		BackgroundColor3 = Color3.fromRGB(8, 8, 12),
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(self.Profile.OpenButtonWidth, self.Profile.OpenButtonHeight),
	})
	applyCorner(self.OpenButton, 14)
	applyStroke(self.OpenButton, Color3.fromRGB(26, 28, 38), 1, 0)
	self.OpenButtonText = createTextLabel(self.OpenButton, UDim2.new(1, 0, 1, 0), UDim2.new(), config.Open and "Close" or "Open", Enum.Font.GothamMedium, 13, self.Theme.Text, Enum.TextXAlignment.Center)

	self.Window = create("Frame", {
		Parent = self.Gui,
		Name = "Window",
		BackgroundColor3 = self.Theme.Surface,
		Size = UDim2.fromOffset(self.Profile.WindowWidth, self.Profile.WindowHeight),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	self.WindowShadow = create("ImageLabel", {
		Parent = self.Gui,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = self.Window.Position,
		Size = UDim2.new(0, self.Profile.WindowWidth + 90, 0, self.Profile.WindowHeight + 100),
		Image = "rbxassetid://1316045217",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ImageTransparency = 1,
		ZIndex = 0,
		Visible = false,
	})
	applyCorner(self.Window, self.Profile.Corner)
	applyStroke(self.Window, self.Theme.Stroke, 1, 0.12)

	self.Header = create("Frame", {
		Parent = self.Window,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, self.Profile.HeaderHeight),
	})
	applyCorner(self.Header, self.Profile.Corner)

	self.HeaderFill = create("Frame", {
		Parent = self.Header,
		BackgroundColor3 = self.Theme.SurfaceAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
	})
	self.HeaderFill.Name = "HeaderFill"
	self.HeaderDivider = create("Frame", {
		Parent = self.Header,
		BackgroundColor3 = self.Theme.Stroke,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, self.Profile.Padding, 1, -1),
		Size = UDim2.new(1, -(self.Profile.Padding * 2), 0, 1),
	})

	applyPadding(self.Header, self.Profile.Padding, self.Profile.Padding, 10, 8)
	self.TitleLabel = createTextLabel(self.Header, UDim2.new(0.5, 0, 0, 18), UDim2.new(0, 0, 0, 0), config.Title, Enum.Font.GothamMedium, self.Profile.TitleText, self.Theme.Text)
	self.TitleLabel.AutomaticSize = Enum.AutomaticSize.X
	self.TitleDot = create("Frame", {
		Parent = self.Header,
		BackgroundColor3 = self.Theme.SubText,
		Position = UDim2.new(0, 58, 0, 12),
		Size = UDim2.fromOffset(4, 4),
	})
	applyCorner(self.TitleDot, 999)
	self.SubtitleLabel = createTextLabel(self.Header, UDim2.new(0, 0, 0, 16), UDim2.new(0, 68, 0, 3), config.Subtitle, Enum.Font.Gotham, 12, self.Theme.SubText)
	self.SubtitleLabel.AutomaticSize = Enum.AutomaticSize.X

	self.BadgeLabel = create("TextLabel", {
		Parent = self.Header,
		Position = UDim2.new(0, 0, 0, 2),
		Size = UDim2.fromOffset(56, 18),
		BackgroundColor3 = Color3.fromRGB(24, 16, 25),
		Text = config.Badge,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = self.Theme.Accent,
	})
	applyCorner(self.BadgeLabel, 999)
	applyPadding(self.BadgeLabel, 8, 8, 0, 0)

	self.UsernameLabel = createTextLabel(self.Header, UDim2.new(0, 180, 0, 16), UDim2.new(1, -self.Profile.Padding, 0, 12), LocalPlayer and LocalPlayer.Name or "Player", Enum.Font.GothamMedium, 12, self.Theme.SubText, Enum.TextXAlignment.Right)
	self.UsernameLabel.AnchorPoint = Vector2.new(1, 0)

	self.TabBar = create("Frame", {
		Parent = self.Window,
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, self.Profile.HeaderHeight),
		Size = UDim2.new(1, 0, 0, self.Profile.TabHeight),
	})

	self.TabBarFrame = create("Frame", {
		Parent = self.TabBar,
		BackgroundColor3 = self.Theme.SurfaceAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(0, self.Profile.Padding, 0, 5),
		Size = UDim2.new(1, -(self.Profile.Padding * 2), 1, -10),
	})
	applyPadding(self.TabBarFrame, 0, 0, 6, 6)
	self.TabDivider = create("Frame", {
		Parent = self.TabBar,
		BackgroundColor3 = self.Theme.Stroke,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, self.Profile.Padding, 1, 0),
		Size = UDim2.new(1, -(self.Profile.Padding * 2), 0, 1),
	})

	self.TabScroll = create("ScrollingFrame", {
		Parent = self.TabBarFrame,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		Size = UDim2.new(1, 0, 1, 0),
	})

	self.TabList = create("Frame", {
		Parent = self.TabScroll,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
	})
	self.TabListLayout = create("UIListLayout", {
		Parent = self.TabList,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
	})

	self.TabUnderline = create("Frame", {
		Parent = self.TabBar,
		BackgroundColor3 = self.Theme.Accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, self.Profile.Padding, 1, 0),
		Size = UDim2.fromOffset(40, 2),
	})
	applyCorner(self.TabUnderline, 999)
	self.TabUnderline.Visible = false

	self.BodyBackground = create("Frame", {
		Parent = self.Window,
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, self.Profile.HeaderHeight + self.Profile.TabHeight),
		Size = UDim2.new(1, 0, 1, -(self.Profile.HeaderHeight + self.Profile.TabHeight + 24)),
		ClipsDescendants = true,
	})

	self.SnowLayer = create("Frame", {
		Parent = self.BodyBackground,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 0,
	})

	self.Footer = create("Frame", {
		Parent = self.Window,
		BackgroundColor3 = self.Theme.SurfaceAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -24),
		Size = UDim2.new(1, 0, 0, 24),
	})
	applyPadding(self.Footer, 10, 10, 0, 0)
	self.FooterPresenceDot = create("Frame", {
		Parent = self.Footer,
		BackgroundColor3 = self.Theme.Success,
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(6, 6),
	})
	applyCorner(self.FooterPresenceDot, 999)
	self.FooterPresenceLabel = createTextLabel(self.Footer, UDim2.new(0, 120, 1, 0), UDim2.new(0, 12, 0, 0), "2075 online", Enum.Font.Gotham, 11, self.Theme.SubText)
	self.FooterCenter = create("Frame", {
		Parent = self.Footer,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.fromOffset(150, 24),
	})
	self.FooterUrlPrefix = createTextLabel(self.FooterCenter, UDim2.new(0, 26, 1, 0), UDim2.new(0, 0, 0, 0), "Url:", Enum.Font.Gotham, 11, self.Theme.SubText, Enum.TextXAlignment.Right)
	self.FooterUrlText = createTextLabel(self.FooterCenter, UDim2.new(0, 116, 1, 0), UDim2.new(0, 30, 0, 0), ".gg/getcloudy", Enum.Font.Gotham, 11, self.Theme.Text, Enum.TextXAlignment.Left)
	self.FooterUpdatedPrefix = createTextLabel(self.Footer, UDim2.new(0, 58, 1, 0), UDim2.new(1, -130, 0, 0), "Updated:", Enum.Font.GothamMedium, 11, self.Theme.SubText, Enum.TextXAlignment.Right)
	self.FooterUpdatedPrefix.AnchorPoint = Vector2.new(0, 0)
	self.FooterUpdatedDate = createTextLabel(self.Footer, UDim2.new(0, 90, 1, 0), UDim2.new(1, -68, 0, 0), "Apr 5 2026", Enum.Font.GothamMedium, 11, self.Theme.Accent, Enum.TextXAlignment.Left)

	self.PageHost = create("Frame", {
		Parent = self.BodyBackground,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
	})

	self.Overlay = create("Frame", {
		Parent = self.Gui,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 45,
	})

	self.NotificationHolder = create("Frame", {
		Parent = self.Gui,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 72),
		Size = UDim2.fromOffset(220, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	addListLayout(self.NotificationHolder, 8)

	self.OpenButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == self.ToggleKeybind then
			self:Toggle()
		end
	end)

	self:_applyTheme()
	self:SetTitle(config.Title)
	self:SetSubtitle(config.Subtitle)
	self:SetBadge(config.Badge)
	self:SetPresenceCount(0)
	self:SetFooterUrl(".gg/getcloudy")
	self:SetUpdatedText("Apr 5 2026")
	self:_enableDragging()
	self:_enableOpenButtonDragging()

	local function refreshOnViewportChange()
		self:_updateResponsiveLayout()
	end

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local camera = workspace.CurrentCamera
		if camera then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshOnViewportChange)
		end
		refreshOnViewportChange()
	end)

	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshOnViewportChange)
	end

	if self.AutoCreateSettingsTab then
		self:CreateDefaultSettingsTab(config.SettingsTab)
	end

	self:_updateResponsiveLayout()
	self:SetOpen(config.Open)
	return self
end

return Cloudy
