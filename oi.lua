local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local OPEN_BUTTON_IMAGE = "rbxassetid://77380393395155"
local DEFAULT_FEEDBACK_ENDPOINT = "https://your-domain.com/feedback"

local CloudyUI = {}
CloudyUI.__index = CloudyUI

local Theme = {
	Background = Color3.fromRGB(3, 3, 4),
	WindowTop = Color3.fromRGB(3, 3, 4),
	WindowBottom = Color3.fromRGB(3, 3, 4),
	Sidebar = Color3.fromRGB(4, 4, 5),
	Section = Color3.fromRGB(6, 6, 7),
	SectionSoft = Color3.fromRGB(9, 9, 10),
	Stroke = Color3.fromRGB(228, 228, 230),
	Text = Color3.fromRGB(242, 242, 244),
	MutedText = Color3.fromRGB(182, 182, 186),
	Input = Color3.fromRGB(8, 8, 9),
	InputSoft = Color3.fromRGB(10, 10, 11),
	Success = Color3.fromRGB(78, 196, 139),
	Danger = Color3.fromRGB(215, 92, 92),
	Accent = Color3.fromRGB(235, 235, 236),
	AccentSoft = Color3.fromRGB(18, 18, 20)
}

local function getGuiParent()
	if type(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end

	if type(get_hidden_gui) == "function" then
		local ok, result = pcall(get_hidden_gui)
		if ok and result then
			return result
		end
	end

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	return playerGui or CoreGui
end

local function create(className, properties)
	local object = Instance.new(className)
	for key, value in pairs(properties or {}) do
		object[key] = value
	end
	return object
end

local function tween(object, properties, duration)
	local info = TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(object, info, properties):Play()
end

local function addCorner(object, radius)
	local corner = create("UICorner", {
		CornerRadius = UDim.new(0, radius or 12),
		Parent = object
	})
	return corner
end

local function addStroke(object, color, thickness, transparency)
	local stroke = create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency == nil and 0.78 or transparency,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = object
	})
	return stroke
end

local function addShadow(object, opacity)
	local shadow = create("ImageLabel", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = opacity or 0.4,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Size = UDim2.new(1, 56, 1, 56),
		Position = UDim2.new(0.5, 0, 0.5, 8),
		Parent = object.Parent
	})
	shadow.ZIndex = math.max(0, object.ZIndex - 1)
	return shadow
end

local function addPadding(object, top, right, bottom, left)
	create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		Parent = object
	})
end

local function addList(object, padding, horizontal)
	local layout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 0),
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = object
	})
	return layout
end

local function addTextConstraint(object, minSize, maxSize)
	create("UITextSizeConstraint", {
		MinTextSize = minSize or 10,
		MaxTextSize = maxSize or 18,
		Parent = object
	})
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local function getGameImage()
	return ("rbxthumb://type=GameIcon&id=%s&w=512&h=512"):format(tostring(game.PlaceId))
end

local function getGameImageForPlace(placeId)
	if placeId and tostring(placeId) ~= "" then
		return ("rbxthumb://type=GameIcon&id=%s&w=512&h=512"):format(tostring(placeId))
	end
	return "rbxasset://textures/ui/GuiImagePlaceholder.png"
end

local function getProfile()
	local viewport = getViewportSize()
	local isPhone = UserInputService.TouchEnabled and (viewport.X < 780 or viewport.Y < 780)
	local isTablet = UserInputService.TouchEnabled and not isPhone

	local widthScale = isPhone and 0.84 or (isTablet and 0.68 or 0.52)
	local heightScale = isPhone and 0.74 or (isTablet and 0.7 or 0.64)

	local width = math.clamp(math.floor(viewport.X * widthScale), isPhone and 292 or 600, isPhone and 372 or 900)
	local height = math.clamp(math.floor(viewport.Y * heightScale), isPhone and 388 or 450, isPhone and 620 or 650)
	local sidebarWidth = isPhone and 92 or (isTablet and 104 or 112)

	return {
		Device = isPhone and "Phone" or (isTablet and "Tablet" or "PC"),
		IsPhone = isPhone,
		Size = UDim2.fromOffset(width, height),
		Position = UDim2.fromOffset(math.floor((viewport.X - width) * 0.5), math.floor((viewport.Y - height) * 0.5)),
		SidebarWidth = sidebarWidth,
		Viewport = viewport
	}
end

local function clampPosition(position, size)
	local viewport = getViewportSize()
	local inset = GuiService:GetGuiInset()
	local topInset = inset.Y
	local x = math.clamp(position.X.Offset, 8, math.max(8, viewport.X - size.X.Offset - 8))
	local y = math.clamp(position.Y.Offset, topInset + 8, math.max(topInset + 8, viewport.Y - size.Y.Offset - 8))
	return UDim2.fromOffset(x, y)
end

local function safeCallback(callback, ...)
	if type(callback) ~= "function" then
		return
	end

	local ok, errorMessage = pcall(callback, ...)
	if not ok then
		warn("CloudyUI callback error:", errorMessage)
	end
end

local function makeDraggable(handle, target, onChanged)
	local dragging = false
	local dragStart
	local targetStart

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		targetStart = target.Position

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
		local nextPosition = UDim2.fromOffset(targetStart.X.Offset + delta.X, targetStart.Y.Offset + delta.Y)
		nextPosition = clampPosition(nextPosition, target.Size)
		target.Position = nextPosition

		if onChanged then
			onChanged(nextPosition)
		end
	end)
end

local function makeResizable(handle, target, minimum, onChanged)
	local resizing = false
	local resizeStart
	local startSize

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		resizing = true
		resizeStart = input.Position
		startSize = target.AbsoluteSize

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not resizing then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local viewport = getViewportSize()
		local delta = input.Position - resizeStart
		local width = math.clamp(startSize.X + delta.X, minimum.X, math.floor(viewport.X * 0.96))
		local height = math.clamp(startSize.Y + delta.Y, minimum.Y, math.floor(viewport.Y * 0.92))
		local nextSize = UDim2.fromOffset(width, height)
		target.Size = nextSize
		target.Position = clampPosition(target.Position, nextSize)

		if onChanged then
			onChanged(nextSize)
		end
	end)
end

local function resolveRequestFunction(preferred)
	if type(preferred) == "function" then
		return preferred
	end

	local candidates = {
		syn and syn.request,
		http_request,
		request,
		fluxus and fluxus.request,
		KRNL_LOADED and request,
		(Sentinel and Sentinel.request)
	}

	for _, candidate in ipairs(candidates) do
		if type(candidate) == "function" then
			return candidate
		end
	end
end

local function getExecutorName()
	if type(identifyexecutor) == "function" then
		local ok, name = pcall(identifyexecutor)
		if ok and name then
			return tostring(name)
		end
	end
	return "Unknown"
end

local function getAvatarUrl(userId)
	local ok, content = pcall(function()
		local image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		return image
	end)

	if ok then
		return content
	end

	return ""
end

local function executeScriptEntry(entry)
	entry = entry or {}

	if entry.Url and entry.Url ~= "" then
		local ok, response = pcall(function()
			return game:HttpGet(entry.Url, true)
		end)
		if not ok or type(response) ~= "string" or response:gsub("%s+", "") == "" then
			return false, "Failed to download script"
		end

		local chunk, loadError = loadstring(response)
		if not chunk then
			return false, tostring(loadError)
		end

		local ran, runError = pcall(chunk)
		if not ran then
			return false, tostring(runError)
		end

		return true
	end

	if entry.File and entry.File ~= "" and type(readfile) == "function" then
		local ok, content = pcall(readfile, entry.File)
		if ok and type(content) == "string" and content:gsub("%s+", "") ~= "" then
			local chunk, loadError = loadstring(content)
			if not chunk then
				return false, tostring(loadError)
			end

			local ran, runError = pcall(chunk)
			if not ran then
				return false, tostring(runError)
			end

			return true
		end
		return false, "Missing or empty script file"
	end

	return false, "No loader configured"
end

local function makeCard(parent, radius)
	local card = create("Frame", {
		Parent = parent,
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = false,
		Size = UDim2.new(1, -12, 0, 0),
		Position = UDim2.new(0, 6, 0, 0)
	})

	addCorner(card, radius or 18)
	addStroke(card, Theme.Stroke, 1, 0.76)
	return card
end

local function makeTextLabel(parent, props)
	local label = create("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		TextColor3 = Theme.Text,
		TextSize = 14,
		RichText = true,
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})

	for key, value in pairs(props or {}) do
		label[key] = value
	end

	return label
end

local function makeInputBox(parent, props)
	local input = create("TextBox", {
		Parent = parent,
		BackgroundColor3 = Theme.InputSoft,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		PlaceholderColor3 = Theme.MutedText,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		MultiLine = false,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, 0, 0, 40),
		Text = ""
	})

	addCorner(input, 10)

	for key, value in pairs(props or {}) do
		input[key] = value
	end

	return input
end

local Section = {}
Section.__index = Section

local function bindHover(button, background, color, defaultColor)
	button.MouseEnter:Connect(function()
		tween(background, {BackgroundColor3 = color}, 0.14)
	end)

	button.MouseLeave:Connect(function()
		local leaveColor = defaultColor
		if type(defaultColor) == "function" then
			leaveColor = defaultColor()
		end
		tween(background, {BackgroundColor3 = leaveColor or Theme.Input}, 0.14)
	end)
end

local function createRow(section, height)
	local row = create("Frame", {
		Parent = section.Container,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, height or 0)
	})
	return row
end

local function controlObject(initialValue)
	local object = {
		Value = initialValue
	}

	function object:Get()
		return self.Value
	end

	function object:Set(value)
		self.Value = value
		return value
	end

	return object
end

local function colorToHex(color)
	return string.format("#%02X%02X%02X",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
	)
end

local function hexToColor(text)
	local value = tostring(text or ""):gsub("#", "")
	if #value == 3 then
		value = value:sub(1, 1):rep(2) .. value:sub(2, 2):rep(2) .. value:sub(3, 3):rep(2)
	end

	if #value ~= 6 then
		return nil
	end

	local red = tonumber(value:sub(1, 2), 16)
	local green = tonumber(value:sub(3, 4), 16)
	local blue = tonumber(value:sub(5, 6), 16)
	if not red or not green or not blue then
		return nil
	end

	return Color3.fromRGB(red, green, blue)
end

local function createColorPickerWidget(parent, defaultColor, callback)
	local item = controlObject(defaultColor or Theme.Accent)
	local hue, saturation, value = Color3.toHSV(item.Value)
	local draggingMode
	local visibilityCallback

	local function isPointInside(guiObject, position)
		if not guiObject or not guiObject.AbsolutePosition or not guiObject.AbsoluteSize then
			return false
		end

		local objectPosition = guiObject.AbsolutePosition
		local objectSize = guiObject.AbsoluteSize
		return position.X >= objectPosition.X
			and position.X <= objectPosition.X + objectSize.X
			and position.Y >= objectPosition.Y
			and position.Y <= objectPosition.Y + objectSize.Y
	end

	local shell = create("Frame", {
		Parent = parent,
		BackgroundColor3 = Color3.fromRGB(58, 58, 58),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.fromOffset(156, 214),
		Visible = false,
		ClipsDescendants = true
	})
	addCorner(shell, 8)
	addStroke(shell, Theme.Stroke, 1, 0.66)

	local header = create("Frame", {
		Parent = shell,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 6),
		Size = UDim2.new(1, -16, 0, 16)
	})

	makeTextLabel(header, {
		Text = "Palette",
		TextColor3 = Theme.Text,
		TextSize = 12,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -40, 0, 16),
		TextWrapped = false
	})

	local preview = create("Frame", {
		Parent = header,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -22, 0.5, 0),
		BackgroundColor3 = item.Value,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(14, 14)
	})
	addCorner(preview, 999)
	addStroke(preview, Theme.Stroke, 1, 0.58)

	local closeButton = create("TextButton", {
		Parent = header,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(14, 14),
		Text = "x",
		TextColor3 = Theme.Text,
		TextSize = 12,
		FontFace = Font.fromEnum(Enum.Font.GothamBold)
	})

	local colorArea = create("TextButton", {
		Parent = shell,
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Position = UDim2.fromOffset(6, 26),
		Size = UDim2.fromOffset(144, 144)
	})
	addCorner(colorArea, 4)
	addStroke(colorArea, Theme.Stroke, 1, 0.7)

	local whiteLayer = create("Frame", {
		Parent = colorArea,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0)
	})
	addCorner(whiteLayer, 4)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Rotation = 0,
		Parent = whiteLayer
	})

	local blackLayer = create("Frame", {
		Parent = colorArea,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0)
	})
	addCorner(blackLayer, 4)
	create("UIGradient", {
		Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Rotation = 90,
		Parent = blackLayer
	})

	local areaCursor = create("Frame", {
		Parent = colorArea,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Rotation = 45,
		Size = UDim2.fromOffset(6, 6)
	})
	addStroke(areaCursor, Color3.new(0, 0, 0), 1.5, 0)

	local hueBar = create("TextButton", {
		Parent = shell,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Position = UDim2.fromOffset(6, 176),
		Size = UDim2.fromOffset(144, 10)
	})
	addCorner(hueBar, 2)
	addStroke(hueBar, Theme.Stroke, 1, 0.7)
	create("UIGradient", {
		Rotation = 0,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.1666667, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(0.3333333, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.6666667, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.8333333, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		}),
		Parent = hueBar
	})

	local hueCursor = create("Frame", {
		Parent = hueBar,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(252, 252, 252),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0)
	})

	local valueText = makeTextLabel(shell, {
		Position = UDim2.fromOffset(8, 192),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -16, 0, 14),
		Text = colorToHex(item.Value),
		TextColor3 = Theme.Text,
		TextSize = 11,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Center
	})

	local function updateVisuals(skipCallback)
		local color = Color3.fromHSV(hue, saturation, value)
		item.Value = color
		preview.BackgroundColor3 = color
		colorArea.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		areaCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
		hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
		valueText.Text = colorToHex(color)
		if not skipCallback then
			safeCallback(callback, color)
		end
	end

	local function setFromArea(position)
		saturation = math.clamp((position.X - colorArea.AbsolutePosition.X) / colorArea.AbsoluteSize.X, 0, 1)
		value = 1 - math.clamp((position.Y - colorArea.AbsolutePosition.Y) / colorArea.AbsoluteSize.Y, 0, 1)
		updateVisuals()
	end

	local function setFromHue(position)
		hue = math.clamp((position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
		updateVisuals()
	end

	colorArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingMode = "Area"
			setFromArea(input.Position)
		end
	end)

	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingMode = "Hue"
			setFromHue(input.Position)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not draggingMode then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if draggingMode == "Area" then
			setFromArea(input.Position)
		else
			setFromHue(input.Position)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingMode = nil
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		item:SetVisible(false)
	end)

	UserInputService.InputBegan:Connect(function(input)
		if not shell.Visible then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local position = input.Position
		if isPointInside(shell, position) then
			return
		end

		if isPointInside(item.TriggerObject, position) then
			return
		end

		item:SetVisible(false)
	end)

	function item:Set(color)
		if typeof(color) ~= "Color3" then
			return self.Value
		end
		hue, saturation, value = Color3.toHSV(color)
		updateVisuals()
		return self.Value
	end

	function item:SetVisible(state)
		shell.Visible = state == true
		if visibilityCallback then
			visibilityCallback(shell.Visible)
		end
		return shell.Visible
	end

	function item:ToggleVisible()
		shell.Visible = not shell.Visible
		if visibilityCallback then
			visibilityCallback(shell.Visible)
		end
		return shell.Visible
	end

	function item:SetTriggerObject(triggerObject)
		self.TriggerObject = triggerObject
		return self.TriggerObject
	end

	function item:OnVisibilityChanged(callbackFunction)
		visibilityCallback = callbackFunction
	end

	item.Frame = shell
	updateVisuals(true)
	return item
end

function Section:AddLabel(text)
	local row = createRow(self, 0)
	makeTextLabel(row, {
		Text = text or "Label",
		TextColor3 = Theme.MutedText,
		TextSize = 13
	})
	return row
end

function Section:AddParagraph(title, text)
	local row = createRow(self, 0)
	local wrap = create("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})
	addList(wrap, 4, false)

	makeTextLabel(wrap, {
		Text = title or "Paragraph",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	local body = makeTextLabel(wrap, {
		Text = text or "",
		TextColor3 = Theme.MutedText,
		TextSize = 13
	})

	return {
		Frame = wrap,
		SetText = function(_, value)
			body.Text = value
		end
	}
end

function Section:AddDivider(text)
	local row = createRow(self, 20)
	local lineLeft = create("Frame", {
		Parent = row,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0.5, -28, 0, 1),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0
	})

	local lineRight = lineLeft:Clone()
	lineRight.AnchorPoint = Vector2.new(1, 0.5)
	lineRight.Position = UDim2.new(1, 0, 0.5, 0)
	lineRight.Parent = row

	makeTextLabel(row, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 140, 0, 18),
		AutomaticSize = Enum.AutomaticSize.None,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = text or "Divider",
		TextColor3 = Theme.MutedText,
		TextSize = 12
	})

	return row
end

function Section:AddButton(options)
	options = options or {}
	local row = createRow(self, 0)
	local button = create("TextButton", {
		Parent = row,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Text = ""
	})
	addCorner(button, 12)
	addStroke(button, Theme.Stroke, 1, 0.16)
	addPadding(button, 12, 12, 12, 12)
	addList(button, 4, false)

	makeTextLabel(button, {
		Text = options.Title or "Button",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	if options.Description then
		makeTextLabel(button, {
			Text = options.Description,
			TextColor3 = Theme.MutedText,
			TextSize = 12
		})
	end

	button.MouseEnter:Connect(function()
		tween(button, {BackgroundTransparency = 0.02}, 0.14)
	end)
	button.MouseLeave:Connect(function()
		tween(button, {BackgroundTransparency = 0}, 0.14)
	end)
	button.MouseButton1Click:Connect(function()
		safeCallback(options.Callback)
	end)

	return button
end

function Section:AddToggle(options)
	options = options or {}
	local item = controlObject(options.Default == true)
	item.Color = options.Color
	item.Window = self.Window
	item.Section = self
	local row = createRow(self, 0)
	local shell = create("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 42)
	})

	local header = create("TextButton", {
		Parent = shell,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, options.Description and options.Description ~= "" and 42 or 22),
		Text = ""
	})

	local title = makeTextLabel(header, {
		Position = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -82, 0, 16),
		Text = options.Title or "Toggle",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	local description = makeTextLabel(header, {
		Position = UDim2.new(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -82, 0, 14),
		Text = options.Description or "Enable or disable this option.",
		TextColor3 = Theme.MutedText,
		TextSize = 12
	})

	local accessoryWrap = create("Frame", {
		Parent = header,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 20)
	})
	local accessoryLayout = addList(accessoryWrap, 8, true)
	accessoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	accessoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local box = create("Frame", {
		Parent = accessoryWrap,
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = Theme.SectionSoft,
		BorderSizePixel = 0
	})
	addCorner(box, 6)

	local fill = create("Frame", {
		Parent = box,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = item.Color or self.Window.AccentColor,
		BorderSizePixel = 0
	})
	addCorner(fill, 4)

	local panel = create("Frame", {
		Parent = shell,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false
	})
	addPadding(panel, 0, 12, 12, 12)
	addList(panel, 8, false)

	local colorButton
	local colorButtonGradient
	local colorPickerObject
	local draggingBar

	local function getActiveColor()
		return item.Color or self.Window.AccentColor
	end

	local function updateLabelWidths()
		local accessoriesWidth = accessoryWrap.AbsoluteSize.X
		local rightInset = 26 + accessoriesWidth
		title.Size = UDim2.new(1, -rightInset, 0, 16)
		description.Size = UDim2.new(1, -rightInset, 0, 14)
	end

	local function apply(value)
		item.Value = value
		if value then
			box.BackgroundColor3 = Theme.Input
			fill.BackgroundColor3 = getActiveColor()
			tween(fill, {Size = UDim2.fromOffset(12, 12)}, 0.16)
		else
			box.BackgroundColor3 = Theme.SectionSoft
			tween(fill, {Size = UDim2.fromOffset(0, 0)}, 0.16)
		end
		safeCallback(options.Callback, value)
	end

	function item:Set(value)
		apply(value == true)
		return self.Value
	end

	function item:SetColor(color)
		self.Color = color
		if colorButton then
			if self.ColorButtonInner then
				self.ColorButtonInner.BackgroundColor3 = color
			end
		end
		if self.Value then
			fill.BackgroundColor3 = color
		end
		return self.Color
	end

	function item:Colorpicker(pickerOptions)
		if colorPickerObject then
			return colorPickerObject
		end

		pickerOptions = pickerOptions or {}
		local defaultColor = pickerOptions.Default or self.Color or self.Window.AccentColor
		self.Color = defaultColor

		colorButton = create("TextButton", {
			Parent = accessoryWrap,
			BackgroundColor3 = Color3.fromRGB(42, 42, 42),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			LayoutOrder = -1,
			Size = UDim2.new(0, 18, 0, 18),
			Text = ""
		})
		addCorner(colorButton, 999)
		addStroke(colorButton, Color3.fromRGB(120, 120, 120), 1, 0.18)
		local colorButtonInner = create("Frame", {
			Parent = colorButton,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = defaultColor,
			BorderSizePixel = 0
		})
		addCorner(colorButtonInner, 999)

		local pickerObject = createColorPickerWidget(panel, defaultColor, function(color)
			item:SetColor(color)
			safeCallback(pickerOptions.Callback, color, item.Value)
		end)
		pickerObject.Frame.Parent = panel
		pickerObject:SetTriggerObject(colorButton)
		pickerObject:OnVisibilityChanged(function(state)
			panel.Visible = state
		end)

		colorButton.MouseButton1Click:Connect(function()
			local visible = pickerObject:ToggleVisible()
			panel.Visible = visible
		end)

		colorPickerObject = {
			Frame = pickerObject.Frame,
			Set = function(_, color)
				pickerObject:Set(color)
				item:SetColor(color)
			end,
			Get = function()
				return item.Color
			end
		}

		pickerObject:Set(defaultColor)
		updateLabelWidths()
		item.ColorButtonInner = colorButtonInner
		return colorPickerObject
	end

	header.MouseButton1Click:Connect(function()
		item:Set(not item.Value)
	end)

	self.Window:OnAccentChanged(function(color)
		if item.Value and not item.Color then
			fill.BackgroundColor3 = color
		end
	end)

	accessoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLabelWidths)
	updateLabelWidths()

	item:Set(item.Value)
	return item
end

function Section:AddSlider(options)
	options = options or {}
	local minimum = tonumber(options.Min) or 0
	local maximum = tonumber(options.Max) or 100
	local decimals = math.max(0, tonumber(options.Decimals) or 0)
	local suffix = options.Suffix or ""
	local default = tonumber(options.Default)
	if default == nil then
		default = minimum
	end

	local item = controlObject(default)
	local row = createRow(self, 0)
	local shell = create("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 62)
	})

	makeTextLabel(shell, {
		Position = UDim2.new(0, 12, 0, 10),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -100, 0, 16),
		Text = options.Title or "Slider",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	local valueBox = makeInputBox(shell, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 8),
		Size = UDim2.new(0, 76, 0, 26),
		BackgroundColor3 = Theme.Input,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = ""
	})

	local track = create("Frame", {
		Parent = shell,
		Position = UDim2.new(0, 12, 0, 42),
		Size = UDim2.new(1, -24, 0, 8),
		BackgroundColor3 = Theme.InputSoft,
		BorderSizePixel = 0
	})
	addCorner(track, 999)

	local fill = create("Frame", {
		Parent = track,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = self.Window.AccentColor,
		BorderSizePixel = 0
	})
	addCorner(fill, 999)

	local dragging = false

	local function formatValue(value)
		return string.format("%0." .. decimals .. "f%s", value, suffix)
	end

	local function setFromRatio(alpha)
		alpha = math.clamp(alpha, 0, 1)
		local raw = minimum + ((maximum - minimum) * alpha)
		local factor = 10 ^ decimals
		local snapped = math.floor(raw * factor + 0.5) / factor
		item.Value = snapped
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		valueBox.Text = formatValue(snapped)
		safeCallback(options.Callback, snapped)
	end

	function item:Set(value)
		local alpha = (math.clamp(value, minimum, maximum) - minimum) / (maximum - minimum)
		setFromRatio(alpha)
		return self.Value
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local ratio = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setFromRatio(ratio)
		end
	end)

	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local ratio = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setFromRatio(ratio)
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
		setFromRatio(ratio)
	end)

	valueBox.FocusLost:Connect(function()
		local cleaned = valueBox.Text:gsub(suffix, "")
		local numeric = tonumber(cleaned)
		if numeric then
			item:Set(numeric)
		else
			valueBox.Text = formatValue(item.Value)
		end
	end)

	self.Window:OnAccentChanged(function(color)
		fill.BackgroundColor3 = color
	end)

	item:Set(default)
	return item
end

function Section:AddTextbox(options)
	options = options or {}
	local item = controlObject(options.Default or "")
	local lines = math.max(1, tonumber(options.Lines) or 1)
	local height = lines > 1 and math.clamp(lines * 22 + 18, 78, 180) or 40

	local row = createRow(self, 0)
	local shell = create("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})
	addPadding(shell, 0, 0, 0, 0)
	addList(shell, 8, false)

	makeTextLabel(shell, {
		Text = options.Title or "Textbox",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	local input = makeInputBox(shell, {
		PlaceholderText = options.Placeholder or "Type here...",
		MultiLine = lines > 1,
		BackgroundColor3 = Theme.Input,
		Text = item.Value,
		Size = UDim2.new(1, 0, 0, height),
		TextYAlignment = lines > 1 and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
	})
	addPadding(input, 10, 10, 10, 10)

	function item:Set(value)
		self.Value = tostring(value or "")
		input.Text = self.Value
		return self.Value
	end

	input.FocusLost:Connect(function(enterPressed)
		item.Value = input.Text
		safeCallback(options.Callback, item.Value, enterPressed)
	end)

	item:Set(item.Value)
	return item
end

function Section:AddDropdown(options)
	options = options or {}
	local values = options.Items or options.Values or {}
	local item = controlObject(options.Default or values[1])
	local opened = false

	local row = createRow(self, 0)
	local shell = create("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})
	addPadding(shell, 0, 0, 0, 0)
	addList(shell, 8, false)

	makeTextLabel(shell, {
		Text = options.Title or "Dropdown",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	local current = create("TextButton", {
		Parent = shell,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 36),
		Text = ""
	})
	addCorner(current, 10)
	addStroke(current, Theme.Stroke, 1, 0.16)

	local valueLabel = makeTextLabel(current, {
		Position = UDim2.new(0, 12, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -42, 0, 16),
		Text = tostring(item.Value or "..."),
		TextSize = 13
	})

	local caret = makeTextLabel(current, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(0, 16, 0, 16),
		Text = "v",
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = Theme.MutedText,
		TextSize = 14
	})

	local optionsFrame = create("Frame", {
		Parent = shell,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false
	})
	addCorner(optionsFrame, 10)
	addStroke(optionsFrame, Theme.Stroke, 1, 0.16)
	addPadding(optionsFrame, 6, 6, 6, 6)
	addList(optionsFrame, 4, false)

	local function apply(value)
		item.Value = value
		valueLabel.Text = tostring(value)
		safeCallback(options.Callback, value)
	end

	for _, value in ipairs(values) do
		local optionButton = create("TextButton", {
			Parent = optionsFrame,
			BackgroundColor3 = Theme.InputSoft,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 30),
			Text = ""
		})
		addCorner(optionButton, 8)

		makeTextLabel(optionButton, {
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, -20, 0, 16),
			Text = tostring(value),
			TextColor3 = Theme.Text,
			TextSize = 13
		})

		optionButton.MouseButton1Click:Connect(function()
			apply(value)
			opened = false
			optionsFrame.Visible = false
			caret.Text = "v"
		end)
	end

	function item:Set(value)
		apply(value)
		return self.Value
	end

	current.MouseButton1Click:Connect(function()
		opened = not opened
		optionsFrame.Visible = opened
		caret.Text = opened and "^" or "v"
	end)

	item:Set(item.Value)
	return item
end

function Section:AddKeybind(options)
	options = options or {}
	local item = controlObject(options.Default or "RightShift")
	item.Mode = options.Mode or "Toggle"
	item.Active = false

	local row = createRow(self, 0)
	local shell = create("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48)
	})

	makeTextLabel(shell, {
		Position = UDim2.new(0, 12, 0, 9),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -110, 0, 16),
		Text = options.Title or "Keybind",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	makeTextLabel(shell, {
		Position = UDim2.new(0, 12, 0, 25),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -110, 0, 14),
		Text = "Mode: " .. item.Mode,
		TextColor3 = Theme.MutedText,
		TextSize = 12
	})

	local bindButton = create("TextButton", {
		Parent = shell,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = UDim2.new(0, 92, 0, 28),
		Text = ""
	})
	addCorner(bindButton, 10)
	addStroke(bindButton, Theme.Stroke, 1, 0.16)

	local bindText = makeTextLabel(bindButton, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -10, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = "[ " .. tostring(item.Value) .. " ]",
		TextSize = 12
	})

	local listening = false

	function item:Set(value)
		self.Value = tostring(value)
		bindText.Text = "[ " .. self.Value .. " ]"
		return self.Value
	end

	bindButton.MouseButton1Click:Connect(function()
		listening = true
		bindText.Text = "[ ... ]"
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if listening then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				listening = false
				item:Set(input.KeyCode.Name)
			end
			return
		end

		if input.KeyCode.Name ~= item.Value then
			return
		end

		if item.Mode == "Hold" then
			safeCallback(options.Callback, true, false)
		else
			item.Active = not item.Active
			safeCallback(options.Callback, item.Active, true)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if item.Mode == "Hold" and input.KeyCode.Name == item.Value then
			safeCallback(options.Callback, false, false)
		end
	end)

	item:Set(item.Value)
	return item
end

function Section:AddColorPicker(options)
	options = options or {}
	local default = options.Default or Theme.Accent
	local item = controlObject(default)

	local row = createRow(self, 0)
	local shell = create("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})
	addPadding(shell, 0, 0, 0, 0)
	addList(shell, 8, false)

	local header = create("TextButton", {
		Parent = shell,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 24),
		Text = ""
	})

	makeTextLabel(header, {
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -70, 0, 16),
		Text = options.Title or "Color Picker",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 14
	})

	local preview = create("Frame", {
		Parent = header,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -20, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundColor3 = Color3.fromRGB(42, 42, 42),
		BorderSizePixel = 0
	})
	addCorner(preview, 999)
	addStroke(preview, Color3.fromRGB(120, 120, 120), 1, 0.18)
	local previewInner = create("Frame", {
		Parent = preview,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = default,
		BorderSizePixel = 0
	})
	addCorner(previewInner, 999)

	local picker = createColorPickerWidget(shell, default, function(color)
		item.Value = color
		previewInner.BackgroundColor3 = color
		safeCallback(options.Callback, color)
	end)
	picker.Frame.Parent = shell
	picker:SetTriggerObject(header)

	function item:Set(value)
		self.Value = picker:Set(value)
		previewInner.BackgroundColor3 = self.Value
		return self.Value
	end

	header.MouseButton1Click:Connect(function()
		picker:ToggleVisible()
	end)

	item:Set(default)
	return item
end

Section.Label = Section.AddLabel
Section.Paragraph = Section.AddParagraph
Section.Divider = Section.AddDivider
Section.Button = Section.AddButton
Section.Toggle = Section.AddToggle
Section.Slider = Section.AddSlider
Section.Textbox = Section.AddTextbox
Section.Dropdown = Section.AddDropdown
Section.Keybind = Section.AddKeybind
Section.Colorpicker = Section.AddColorPicker

local Tab = {}
Tab.__index = Tab

local function resolveTabColumn(tab, options)
	options = options or {}
	if options.FullWidth or tab.Window.Profile.IsPhone then
		return tab.LeftColumn
	end

	if options.Column == "right" then
		return tab.RightColumn
	end

	if options.Column == "left" then
		return tab.LeftColumn
	end

	tab.SectionCount = (tab.SectionCount or 0) + 1
	if tab.SectionCount % 2 == 0 then
		return tab.RightColumn
	end
	return tab.LeftColumn
end

function Tab:AddSection(title, description, options)
	local parentColumn = resolveTabColumn(self, options)
	local card = makeCard(parentColumn, 18)
	card.BackgroundTransparency = 0
	addPadding(card, 16, 16, 16, 16)
	local container = create("Frame", {
		Parent = card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})
	addList(container, 10, false)

	makeTextLabel(container, {
		Text = title or "Section",
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 15
	})

	if description and description ~= "" then
		makeTextLabel(container, {
			Text = description,
			TextColor3 = Theme.MutedText,
			TextSize = 12
		})
	end

	local section = setmetatable({
		Window = self.Window,
		Tab = self,
		Frame = card,
		Container = container
	}, Section)

	return section
end

function Tab:AddCustomCard(builder, options)
	local parentColumn = resolveTabColumn(self, options)
	local card = makeCard(parentColumn, 18)
	card.BackgroundTransparency = 0
	addPadding(card, 16, 16, 16, 16)
	local container = create("Frame", {
		Parent = card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})
	if builder then
		builder(card, container)
	end
	return card
end

function Tab:Select()
	self.Window:SelectTab(self.Name)
end

Tab.Section = Tab.AddSection
Tab.Card = Tab.AddCustomCard

function CloudyUI:OnAccentChanged(callback)
	table.insert(self.AccentListeners, callback)
	safeCallback(callback, self.AccentColor)
end

function CloudyUI:SetAccent(color)
	self.AccentColor = color
	for _, callback in ipairs(self.AccentListeners) do
		safeCallback(callback, color)
	end
	self:RefreshTabVisuals()
end

function CloudyUI:RefreshTabVisuals()
	for _, tab in pairs(self.Tabs) do
		local selected = self.CurrentTab == tab
		if tab.NavButton then
			tween(tab.NavButton, {
				BackgroundColor3 = selected and Color3.fromRGB(14, 14, 16) or Color3.fromRGB(6, 6, 7)
			}, 0.16)
			if tab.NavIconWrap then
				tween(tab.NavIconWrap, {
					BackgroundColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
				}, 0.16)
			end
			tab.NavDot.BackgroundTransparency = 0
			tab.NavDot.BackgroundColor3 = selected and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
			tab.NavTitle.TextColor3 = selected and Theme.Text or Theme.MutedText
			if tab.NavMeta then
				tab.NavMeta.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Theme.MutedText
			end
		end

		if tab.QuickButton then
			tween(tab.QuickButton, {
				BackgroundColor3 = selected and Color3.fromRGB(230, 230, 230) or Theme.Input,
				TextColor3 = selected and Color3.fromRGB(8, 8, 10) or Theme.Text
			}, 0.16)
		end
	end

	if self.ToggleGlow then
		self.ToggleGlow.Color = self.AccentColor
	end
	if self.ResizeIcon then
		self.ResizeIcon.ImageColor3 = self.AccentColor
	end
	if self.SidebarAccent then
		self.SidebarAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
end

function CloudyUI:SelectTab(name)
	local tab = self.Tabs[name]
	if not tab then
		return
	end

	self.CurrentTab = tab
	for _, otherTab in pairs(self.Tabs) do
		if otherTab == tab then
			otherTab.Page.Visible = true
			otherTab.Page.Position = UDim2.new(0, 10, 0, 0)
			tween(otherTab.Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.18)
		else
			otherTab.Page.Visible = false
		end
	end
	self:RefreshTabVisuals()
end

function CloudyUI:ToggleVisible()
	self.Enabled = not self.Enabled
	self.Main.Visible = self.Enabled
end

function CloudyUI:SetVisible(value)
	self.Enabled = value == true
	self.Main.Visible = self.Enabled
end

function CloudyUI:SetFeedbackEndpoint(endpoint)
	self.FeedbackConfig = self.FeedbackConfig or {}
	self.FeedbackConfig.Endpoint = endpoint
	return endpoint
end

function CloudyUI:Destroy()
	if self.Screen then
		self.Screen:Destroy()
		self.Screen = nil
	end
	self.Main = nil
	self.ToggleButton = nil
	self.Tabs = {}
end

function CloudyUI:CreateTab(name, options)
	options = options or {}
	local tab = setmetatable({
		Window = self,
		Name = name,
		Options = options
	}, Tab)

	local page = create("ScrollingFrame", {
		Parent = self.PageHolder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Visible = false
	})
	addPadding(page, 0, 4, 6, 0)

	local columns = create("Frame", {
		Parent = page,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0)
	})
	local columnsLayout = addList(columns, 12, true)
	columnsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	local leftColumn = create("Frame", {
		Parent = columns,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(0.5, -6, 0, 0)
	})
	addList(leftColumn, 12, false)

	local rightColumn = create("Frame", {
		Parent = columns,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(0.5, -6, 0, 0)
	})
	addList(rightColumn, 12, false)

	tab.Page = page
	tab.Columns = columns
	tab.LeftColumn = leftColumn
	tab.RightColumn = rightColumn
	tab.SectionCount = 0
	self.Tabs[name] = tab

	if self.ShowSidebarTabs and self.NavList and not options.HideSidebarButton then
		local nav = create("TextButton", {
			Parent = self.NavList,
			BackgroundColor3 = Color3.fromRGB(6, 6, 7),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 54),
			Text = ""
		})
		addCorner(nav, 12)
		addStroke(nav, Theme.Stroke, 1, 0.92)

		local iconWrap = create("Frame", {
			Parent = nav,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.new(0, 22, 0, 22),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0
		})
		addCorner(iconWrap, 999)
		addStroke(iconWrap, Theme.Stroke, 1, 0.88)

		local dot = create("Frame", {
			Parent = iconWrap,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 8, 0, 8),
			BackgroundColor3 = Color3.fromRGB(112, 112, 118),
			BackgroundTransparency = 0.58,
			BorderSizePixel = 0
		})
		addCorner(dot, 999)

		local title = makeTextLabel(nav, {
			Position = UDim2.new(0, 42, 0, 10),
			AnchorPoint = Vector2.new(0, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, -50, 0, 15),
			Text = name,
			TextColor3 = Theme.MutedText,
			TextSize = 13,
			FontFace = Font.fromEnum(Enum.Font.GothamMedium)
		})

		local meta = makeTextLabel(nav, {
			Position = UDim2.new(0, 42, 0, 26),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, -50, 0, 12),
			Text = options.NavDescription or ("Open " .. string.lower(name)),
			TextColor3 = Color3.fromRGB(108, 108, 114),
			TextSize = 10,
			TextWrapped = false
		})

		nav.MouseButton1Click:Connect(function()
			self:SelectTab(name)
		end)
		tab.NavButton = nav
		tab.NavIconWrap = iconWrap
		tab.NavDot = dot
		tab.NavTitle = title
		tab.NavMeta = meta
	end

	if not options.HideQuickButton then
		local quick = create("TextButton", {
			Parent = self.QuickTabs,
			BackgroundColor3 = Theme.Input,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Size = UDim2.new(0, 78, 0, 28),
			Text = options.QuickName or name,
			FontFace = Font.fromEnum(Enum.Font.GothamMedium),
			TextSize = 11,
			TextColor3 = Theme.Text
		})
		addCorner(quick, 999)
		addStroke(quick, Theme.Stroke, 1, 0.9)
		quick.MouseButton1Click:Connect(function()
			self:SelectTab(name)
		end)
		tab.QuickButton = quick
	end

	if not self.CurrentTab then
		self:SelectTab(name)
	end

	return tab
end

function CloudyUI:ConfigureFeedback(config)
	self.FeedbackConfig = config or {}
	self.FeedbackRequest = resolveRequestFunction(self.FeedbackConfig.Request)
	return self.FeedbackConfig
end

function CloudyUI:SubmitFeedback(message, extra)
	extra = extra or {}
	local endpoint = extra.Endpoint or (self.FeedbackConfig and self.FeedbackConfig.Endpoint)
	local requestFunction = resolveRequestFunction(extra.Request or self.FeedbackRequest)

	if not endpoint or endpoint == "" then
		return false, "Missing feedback endpoint"
	end

	if not requestFunction then
		return false, "No request function found in this executor"
	end

	if type(message) ~= "string" or message:gsub("%s+", "") == "" then
		return false, "Feedback message is empty"
	end

	local payload = {
		username = LocalPlayer.Name,
		display_name = LocalPlayer.DisplayName,
		user_id = LocalPlayer.UserId,
		avatar_url = getAvatarUrl(LocalPlayer.UserId),
		game_id = game.GameId,
		place_id = game.PlaceId,
		job_id = game.JobId,
		executor = getExecutorName(),
		message = message,
		submitted_at = os.date("!%Y-%m-%dT%H:%M:%SZ")
	}

	for key, value in pairs(extra) do
		if payload[key] == nil and key ~= "Endpoint" and key ~= "Request" then
			payload[key] = value
		end
	end

	local ok, response = pcall(requestFunction, {
		Url = endpoint,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	})

	if not ok then
		return false, tostring(response)
	end

	local statusCode = response.StatusCode or response.Status or 0
	if statusCode >= 200 and statusCode < 300 then
		return true, response.Body
	end

	return false, response.Body or ("HTTP " .. tostring(statusCode))
end

function CloudyUI:ApplyResponsiveLayout(forceCenter)
	local profile = getProfile()
	self.Profile = profile

	if self.AutoSize and not self.ManualSize then
		self.Main.Size = profile.Size
		if forceCenter then
			self.Main.Position = profile.Position
		else
			self.Main.Position = clampPosition(self.Main.Position, profile.Size)
		end
	end

	self.Sidebar.Size = UDim2.new(0, profile.SidebarWidth, 1, 0)
	self.ContentShell.Size = UDim2.new(1, -(profile.SidebarWidth + 16), 1, 0)
	self.ContentShell.Position = UDim2.new(0, profile.SidebarWidth + 16, 0, 0)
	self.BrandCard.Size = UDim2.new(1, 0, 0, profile.IsPhone and 126 or 138)
	self.ToggleButton.Size = profile.IsPhone and UDim2.fromOffset(48, 48) or UDim2.fromOffset(52, 52)
	if self.QuickTabsShell then
		self.QuickTabsShell.Size = UDim2.new(0, math.min(self.ContentShell.AbsoluteSize.X - 12, profile.IsPhone and 304 or 356), 0, 44)
	end
	self.QuickTabs.Size = UDim2.new(1, -12, 1, -10)
	self.ResizeHandle.Visible = not profile.IsPhone
	for _, tab in pairs(self.Tabs) do
		if tab.LeftColumn and tab.RightColumn then
			if profile.IsPhone then
				tab.LeftColumn.Size = UDim2.new(1, 0, 0, 0)
				tab.RightColumn.Visible = false
			else
				tab.LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
				tab.RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
				tab.RightColumn.Visible = true
			end
		end
	end
	self.Main.Position = clampPosition(self.Main.Position, self.Main.Size)
end

function CloudyUI:BuildHome(tab)
	tab:AddCustomCard(function(card, container)
		container.AutomaticSize = Enum.AutomaticSize.None
		container.Size = UDim2.new(1, 0, 0, 224)

		local title = makeTextLabel(container, {
			Position = UDim2.new(0, 0, 0, 4),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, -10, 0, 88),
			Text = "Cloudy Developer | Script Hub",
			FontFace = Font.fromEnum(Enum.Font.GothamBold),
			TextSize = 34,
			TextWrapped = true
		})
		addTextConstraint(title, 20, 34)

		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 0, 100),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, -40, 0, 44),
			Text = "Fast script access, responsive layout, and a cleaner black-and-white shell without the old background treatment.",
			TextColor3 = Theme.MutedText,
			TextSize = 13
		})

		local stats = makeTextLabel(container, {
			Position = UDim2.new(0, 0, 0, 152),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 16),
			Text = "@" .. LocalPlayer.Name .. "   /   " .. getExecutorName() .. "   /   " .. tostring(LocalPlayer.UserId),
			TextColor3 = Theme.MutedText,
			TextSize = 11,
			TextWrapped = false
		})
		stats.TextTruncate = Enum.TextTruncate.AtEnd

		local actions = create("Frame", {
			Parent = container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -40),
			Size = UDim2.new(1, 0, 0, 30)
		})
		local actionsLayout = addList(actions, 8, true)
		actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		local function makeHeroButton(text, inverted, callback)
			local button = create("TextButton", {
				Parent = actions,
				BackgroundColor3 = inverted and Color3.fromRGB(255, 255, 255) or Theme.Input,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Size = UDim2.new(0, inverted and 108 or 118, 0, 30),
				Text = text,
				TextColor3 = inverted and Color3.fromRGB(5, 5, 6) or Theme.Text,
				TextSize = 12,
				FontFace = Font.fromEnum(Enum.Font.GothamMedium)
			})
			addCorner(button, 999)
			addStroke(button, Theme.Stroke, 1, inverted and 0.94 or 0.82)
			button.MouseButton1Click:Connect(callback)
			return button
		end

		makeHeroButton("Open Scripts", true, function()
			self:SelectTab("Scripts")
		end)
		makeHeroButton("Open Feedback", false, function()
			self:SelectTab("Feedback")
		end)
		makeHeroButton("Hide Window", false, function()
			self:ToggleVisible()
		end)
	end, {FullWidth = true})

	tab:AddCustomCard(function(card, container)
		container.AutomaticSize = Enum.AutomaticSize.None
		container.Size = UDim2.new(1, 0, 0, 126)

		makeTextLabel(container, {
			Text = "Responsive Layout",
			FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
			TextSize = 16
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 56),
			Text = "Phone and PC sizing stay active, but the shell is flatter and tighter so the page reads cleaner.",
			TextColor3 = Theme.MutedText,
			TextSize = 12
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 1, -16),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 14),
			Text = "Sizing / Layout",
			TextColor3 = Theme.Text,
			TextSize = 11,
			TextWrapped = false
		})
	end, {Column = "left"})

	tab:AddCustomCard(function(card, container)
		container.AutomaticSize = Enum.AutomaticSize.None
		container.Size = UDim2.new(1, 0, 0, 126)

		makeTextLabel(container, {
			Text = "Clean Surface",
			FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
			TextSize = 16
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 56),
			Text = "The older grey gradients, faded overlays, and soft background treatment are removed for a harder black-and-white look.",
			TextColor3 = Theme.MutedText,
			TextSize = 12
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 1, -16),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 14),
			Text = "Black / White",
			TextColor3 = Theme.Text,
			TextSize = 11,
			TextWrapped = false
		})
	end, {Column = "right"})

	tab:AddCustomCard(function(card, container)
		container.AutomaticSize = Enum.AutomaticSize.None
		container.Size = UDim2.new(1, 0, 0, 126)

		makeTextLabel(container, {
			Text = "Quick Access",
			FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
			TextSize = 16
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 56),
			Text = "Use the left rail for built-in pages and the bottom row for gameplay tabs. Home still opens from the profile block.",
			TextColor3 = Theme.MutedText,
			TextSize = 12
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 1, -16),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 14),
			Text = "Navigation",
			TextColor3 = Theme.Text,
			TextSize = 11,
			TextWrapped = false
		})
	end, {Column = "left"})

	tab:AddCustomCard(function(card, container)
		container.AutomaticSize = Enum.AutomaticSize.None
		container.Size = UDim2.new(1, 0, 0, 126)

		makeTextLabel(container, {
			Text = "Feedback Ready",
			FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
			TextSize = 16
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 56),
			Text = "The built-in feedback page still sends avatar, username, place data, and message to your endpoint.",
			TextColor3 = Theme.MutedText,
			TextSize = 12
		})
		makeTextLabel(container, {
			Position = UDim2.new(0, 0, 1, -16),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, 0, 0, 14),
			Text = "API / Live",
			TextColor3 = Theme.Text,
			TextSize = 11,
			TextWrapped = false
		})
	end, {Column = "right"})
end

function CloudyUI:CreateDefaultWindow(config)
	config = config or {}

	for _, child in ipairs(getGuiParent():GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "CloudyUIRoot" then
			child:Destroy()
		end
	end

	local profile = getProfile()

	local selfObject = setmetatable({
		AccentColor = config.AccentColor or Theme.Accent,
		AccentListeners = {},
		Tabs = {},
		Profile = profile,
		Enabled = true,
		AutoSize = config.AutoSize ~= false,
		ManualSize = false,
		FeedbackConfig = {
			Endpoint = config.FeedbackEndpoint or DEFAULT_FEEDBACK_ENDPOINT
		}
	}, CloudyUI)

	local screen = create("ScreenGui", {
		Name = "CloudyUIRoot",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = getGuiParent()
	})
	local main = create("Frame", {
		Parent = screen,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Size = profile.Size,
		Position = profile.Position,
		ClipsDescendants = true
	})
	addCorner(main, 10)
	addStroke(main, Theme.Stroke, 1, 0.94)

	local toggleButton = create("ImageButton", {
		Parent = screen,
		BackgroundColor3 = Color3.fromRGB(3, 3, 4),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Image = OPEN_BUTTON_IMAGE,
		Size = profile.IsPhone and UDim2.fromOffset(48, 48) or UDim2.fromOffset(52, 52),
		Position = UDim2.new(1, -66, 0, 14),
		ImageColor3 = Color3.new(1, 1, 1)
	})
	addCorner(toggleButton, 12)
	local toggleGlow = addStroke(toggleButton, Theme.Stroke, 1, 0.9)

	local topbar = create("Frame", {
		Parent = main,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -28, 0, 36),
		Position = UDim2.new(0, 14, 0, 10)
	})

	makeTextLabel(topbar, {
		Text = config.Title or "Cloudy Developer",
		FontFace = Font.fromEnum(Enum.Font.GothamBold),
		TextSize = 15,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 1)
	})

	makeTextLabel(topbar, {
		Text = config.Subtitle or "Clean panel with responsive layout, working controls, and live feedback support.",
		TextColor3 = Theme.MutedText,
		TextSize = 10,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 0, 19)
	})

	local body = create("Frame", {
		Parent = main,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -28, 1, -58),
		Position = UDim2.new(0, 14, 0, 44)
	})

	local sidebar = create("Frame", {
		Parent = body,
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Size = UDim2.new(0, profile.SidebarWidth, 1, 0)
	})
	addCorner(sidebar, 0)
	addStroke(sidebar, Theme.Stroke, 1, 0.94)

	local sidebarContent = create("Frame", {
		Parent = sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -18, 1, -18),
		Position = UDim2.new(0, 12, 0, 9)
	})

	local brandCard = create("TextButton", {
		Parent = sidebarContent,
		BackgroundColor3 = Color3.fromRGB(3, 3, 4),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, profile.IsPhone and 126 or 138),
		Text = ""
	})
	addCorner(brandCard, 10)
	addStroke(brandCard, Theme.Stroke, 1, 0.92)

	local brandAvatar = create("ImageLabel", {
		Parent = brandCard,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Size = profile.IsPhone and UDim2.fromOffset(42, 42) or UDim2.fromOffset(46, 46),
		Image = getAvatarUrl(LocalPlayer.UserId)
	})
	addCorner(brandAvatar, 999)
	addStroke(brandAvatar, Theme.Stroke, 1, 0.84)

	local brandName = makeTextLabel(brandCard, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, profile.IsPhone and 62 or 68),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -18, 0, 16),
		Text = LocalPlayer.DisplayName,
		FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
		TextSize = 11,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Center
	})
	addTextConstraint(brandName, 8, 11)

	makeTextLabel(brandCard, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, profile.IsPhone and 80 or 86),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, -18, 0, 14),
		Text = "@" .. LocalPlayer.Name,
		TextColor3 = Theme.MutedText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Center
	})

	local contentShell = create("Frame", {
		Parent = body,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, profile.SidebarWidth + 16, 0, 0),
		Size = UDim2.new(1, -(profile.SidebarWidth + 16), 1, 0)
	})

	local pageHolder = create("Frame", {
		Parent = contentShell,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -46)
	})

	local quickTabsShell = create("Frame", {
		Parent = contentShell,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		BackgroundColor3 = Theme.Section,
		BorderSizePixel = 0,
		Size = UDim2.new(0, math.min(contentShell.AbsoluteSize.X - 12, profile.IsPhone and 304 or 356), 0, 44)
	})
	addCorner(quickTabsShell, 12)
	addStroke(quickTabsShell, Theme.Stroke, 1, 0.86)

	local quickTabs = create("Frame", {
		Parent = quickTabsShell,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -12, 1, -10)
	})
	local quickLayout = addList(quickTabs, 8, true)
	quickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local resizeHandle = create("ImageButton", {
		Parent = main,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Image = "rbxassetid://7368471234",
		ImageColor3 = selfObject.AccentColor,
		Size = UDim2.fromOffset(18, 18),
		Visible = not profile.IsPhone
	})

	selfObject.Screen = screen
	selfObject.Main = main
	selfObject.ShowSidebarTabs = config.ShowSidebarTabs == true
	selfObject.Sidebar = sidebar
	selfObject.BrandCard = brandCard
	selfObject.NavList = nil
	selfObject.ContentShell = contentShell
	selfObject.PageHolder = pageHolder
	selfObject.QuickTabsShell = quickTabsShell
	selfObject.QuickTabs = quickTabs
	selfObject.ResizeHandle = resizeHandle
	selfObject.ResizeIcon = resizeHandle
	selfObject.ToggleButton = toggleButton
	selfObject.ToggleGlow = toggleGlow

	makeDraggable(toggleButton, toggleButton)
	toggleButton.MouseButton1Click:Connect(function()
		selfObject:ToggleVisible()
	end)

	makeDraggable(topbar, main, function(position)
		selfObject.ManualPosition = true
		selfObject.Main.Position = position
	end)

	makeResizable(resizeHandle, main, Vector2.new(740, 520), function(size)
		selfObject.ManualSize = true
		selfObject.Main.Size = size
		selfObject:ApplyResponsiveLayout(false)
	end)

	selfObject:ApplyResponsiveLayout(true)

	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			selfObject:ApplyResponsiveLayout(false)
		end)
	end

	return selfObject
end

function CloudyUI:CreateWindow(config)
	return self:CreateDefaultWindow(config)
end

function CloudyUI:Tab(name, options)
	return self:CreateTab(name, options)
end

CloudyUI.Theme = Theme
CloudyUI.DefaultFeedbackEndpoint = DEFAULT_FEEDBACK_ENDPOINT

return CloudyUI
