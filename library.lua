-- // variables
local library = {}
local pages = {}
local sections = {}
local multisections = {}
local mssections = {}
local toggles = {}
local buttons = {}
local sliders = {}
local dropdowns = {}
local multiboxs = {}
local buttonboxs = {}
local textboxs = {}
local keybinds = {}
local colorpickers = {}
local configloaders = {}
local watermarks = {}
local loaders = {}
--
local customfonts = {}
--
do
	local fontbase = "https://raw.githubusercontent.com/hvhstarrr1337-art/evolution-utils/main/"
	local fontlist = {
		["Proggy Clean"] = "ProggyClean",
		["Tahoma"] = "Tahoma"
	}
	pcall(function()
		if not isfolder("evolution-utils") then
			makefolder("evolution-utils")
		end
		for name,file in pairs(fontlist) do
			local ttf = "evolution-utils/"..file..".ttf"
			if not isfile(ttf) then
				writefile(ttf, game:HttpGet(fontbase..file..".ttf"))
			end
			local json = "evolution-utils/"..file..".json"
			writefile(json, game:GetService("HttpService"):JSONEncode({
				name = name,
				faces = {
					{
						name = "Regular",
						weight = 400,
						style = "normal",
						assetId = getcustomasset(ttf)
					}
				}
			}))
			local key = name:lower():gsub(" ","")
			customfonts[key] = Font.new(getcustomasset(json))
		end
	end)
end
--
local utility = {}
--
local check_exploit = (syn and "Synapse") or (KRNL_LOADED and "Krnl") or (isourclosure and "ScriptWare") or nil
local plrs = game:GetService("Players")
local cre = game:GetService("CoreGui")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService") 
local uis = game:GetService("UserInputService") 
local hs = game:GetService("HttpService")
local ws = game:GetService("Workspace")
local plr = plrs.LocalPlayer
local cam = ws.CurrentCamera
-- // indexes
library.__index = library
pages.__index = pages
sections.__index = sections
multisections.__index = multisections
mssections.__index = mssections
toggles.__index = toggles
buttons.__index = buttons
sliders.__index = sliders
dropdowns.__index = dropdowns
multiboxs.__index = multiboxs
buttonboxs.__index = buttonboxs
textboxs.__index = textboxs
keybinds.__index = keybinds
colorpickers.__index = colorpickers
configloaders.__index = configloaders
watermarks.__index = watermarks
loaders.__index = loaders
-- // shared visible method
for i,meta in pairs({toggles,buttons,sliders,dropdowns,multiboxs,buttonboxs,textboxs,keybinds,colorpickers}) do
	meta.setvisible = function(self,bool)
		if self.holder then
			self.holder.Visible = bool
		end
	end
end
-- // functions
utility.new = function(instance,properties) 
	-- // instance
	local ins = Instance.new(instance)
	-- // properties setting
	for property,value in pairs(properties) do
		if property == "Font" and type(value) == "string" then
			local key = value:lower():gsub(" ","")
			if customfonts[key] then
				ins.FontFace = (typeof(customfonts[key]) == "Font") and customfonts[key] or Font.new(customfonts[key])
			else
				pcall(function() ins.Font = value end)
			end
		else
			ins[property] = value
		end
	end
	-- // return
	return ins
end
--
utility.dragify = function(ins,touse)
	local dragging
	local dragInput
	local dragStart
	local startPos
	--
	local function update(input)
		local delta = input.Position - dragStart
		touse:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
	end
	--
	ins.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = touse.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	--
	ins.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	--
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end
--
utility.round = function(n,d)
	return tonumber(string.format("%."..(d or 0).."f",n))
end
--
utility.zigzag = function(X)
	return math.acos(math.cos(X*math.pi))/math.pi
end
--
utility.capatalize = function(s)
	local l = ""
	for v in s:gmatch('%u') do
		l = l..v
	end
	return l
end
--
utility.splitenum = function(enum)
	local s = tostring(enum):split(".")
	return s[#s]
end
--
utility.from_hex = function(h)
	local r,g,b = string.match(h,"^#?(%w%w)(%w%w)(%w%w)$")
	return Color3.fromRGB(tonumber(r,16), tonumber(g,16), tonumber(b,16))
end
--
utility.to_hex = function(c)
	return string.format("#%02X%02X%02X",c.R *255,c.G *255,c.B *255)
end
--
utility.removespaces = function(s)
   return s:gsub(" ","")
end
-- // main
function library:new(props)
	-- // properties
	local textsize = props.textsize or props.TextSize or props.textSize or props.Textsize or 12
	local font = props.font or props.Font or "Tahoma"
	local name = props.name or props.Name or props.UiName or props.Uiname or props.uiName or props.username or props.Username or props.UserName or props.userName or "new ui"
	local color = props.color or props.Color or props.mainColor or props.maincolor or props.MainColor or props.Maincolor or props.Accent or props.accent or Color3.fromRGB(225, 58, 81)
	local unload = props.unload or props.Unload or props.unloadcallback or props.Unloadcallback or props.UnloadCallback or props.unloadCallback or function()end
	-- // variables
	local window = {}
	-- // main
	local screen = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = 9999,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)
	--
        if (check_exploit == "Synapse" and syn.request) then
	syn.protect_gui(screen)
        end
	-- // root container (for fade animation)
	local root = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = screen
		}
	)
	-- 1
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Active = true,
			Size = UDim2.new(0,500,0,606),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = root
		}
	)
	--
	-- // glow
	local glow = utility.new(
		"ImageLabel",
		{
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=18245826428",
			ImageColor3 = color,
			ImageTransparency = 0.8,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(21, 21, 79, 79),
			Position = UDim2.new(0,-20,0,-20),
			Size = UDim2.new(1,40,1,40),
			ZIndex = 0,
			Parent = outline
		}
	)
	--
	-- 2
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline
		}
	)
	-- 3
	local indent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline2
		}
	)
	-- 4
	local main = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-10,1,-12),
			Position = UDim2.new(0.5,0,1,-5),
			Parent = outline2
		}
	)
	--
	local title = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Parent = outline2
		}
	)
	--
	local accentline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-8,0,1),
			Position = UDim2.new(0.5,0,0,3),
			ZIndex = 5,
			Parent = outline2
		}
	)
	-- 5
	local outline3 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	--
	local titletext = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = font,
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextXAlignment = "Left",
			TextSize = textsize,
			TextStrokeTransparency = 0,
			Parent = title
		}
	)
	-- 6
	local holder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-6,1,-6),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	-- 7
	local holder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-6,1,-6),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	-- 8
	local tabs = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = holder
		}
	)
	-- 9
	local outline4 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabs
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(205, 205, 205))},
			Rotation = 90,
			Parent = outline4
		}
	)
	-- // tabbar
	local tabsoutline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Active = true,
			Size = UDim2.new(0,40,0,37),
			Position = UDim2.new(0.5,0,0,40),
			ZIndex = 10,
			Parent = root
		}
	)
	--
	local tabsoutline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 10,
			Parent = tabsoutline
		}
	)
	--
	local tabsline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-6,0,1),
			Position = UDim2.new(0.5,0,0,2),
			ZIndex = 12,
			Parent = tabsoutline2
		}
	)
	--
	local tabsindent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 10,
			Parent = tabsoutline2
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Horizontal",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Top",
			Padding = UDim.new(0,3),
			Parent = tabsindent
		}
	)
	--
	utility.new(
		"UIPadding",
		{
			PaddingTop = UDim.new(0,3),
			PaddingBottom = UDim.new(0,3),
			PaddingLeft = UDim.new(0,3),
			PaddingRight = UDim.new(0,3),
			Parent = tabsindent
		}
	)
	--
	utility.dragify(title,outline)
	utility.dragify(tabsoutline,tabsoutline)
	utility.dragify(tabsindent,tabsoutline)
	-- // window tbl
	window = {
		["screen"] = screen,
		["root"] = root,
		["holder"] = holder,
		["labels"] = {},
		["tabs"] = outline4,
		["tabsbuttons"] = tabsindent,
		["tabsbar"] = tabsoutline,
		["outline"] = outline,
		["pages"] = {},
		["pointers"] = {},
		["dropdowns"] = {},
		["multiboxes"] = {},
		["buttonboxs"] = {},
		["colorpickers"] = {},
		["whitelist"] = {},
		["connections"] = {},
		["floatingwindows"] = {},
		["floatingguis"] = {},
		["extratabs"] = 0,
		["x"] = true,
		["y"] = true,
		["animation"] = "slide",
		["unloadcallback"] = unload,
		["key"] = Enum.KeyCode.RightShift,
		["textsize"] = textsize,
		["font"] = font,
		["name"] = name,
		["theme"] = {
			["accent"] = color,
			["background"] = Color3.fromRGB(20, 20, 20)
		},
		["bgframes"] = {},
		["themeitems"] = {
			["accent"] = {
				["BackgroundColor3"] = {},
				["BorderColor3"] = {},
				["TextColor3"] = {},
				["ImageColor3"] = {}
			}
		}
	}
	--
	table.insert(window.themeitems["accent"]["BackgroundColor3"],accentline)
	table.insert(window.themeitems["accent"]["BackgroundColor3"],tabsline)
	table.insert(window.themeitems["accent"]["ImageColor3"],glow)
	-- // notifications
	local notifyscreen = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = 20000,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)
	if (check_exploit == "Synapse" and syn.request) then
		syn.protect_gui(notifyscreen)
	end
	table.insert(window.floatingguis,notifyscreen)
	--
	local notifyholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,1),
			BackgroundTransparency = 1,
			Size = UDim2.new(0,280,1,-20),
			Position = UDim2.new(1,-10,1,-10),
			Parent = notifyscreen
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			HorizontalAlignment = "Right",
			VerticalAlignment = "Bottom",
			SortOrder = "LayoutOrder",
			Padding = UDim.new(0,8),
			Parent = notifyholder
		}
	)
	--
	window.notifyscreen = notifyscreen
	window.notifyholder = notifyholder
	-- // watermark
	local wmholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = "X",
			Size = UDim2.new(0,0,0,28),
			Position = UDim2.new(0,10,0,10),
			ZIndex = 9900,
			Parent = screen
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
			Padding = UDim.new(0,6),
			Parent = wmholder
		}
	)
	--
	window.watermark = wmholder
	--
	local wmsegment = function(text)
		local box = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderSizePixel = 1,
				Active = true,
				Size = UDim2.new(0,80,0,28),
				ZIndex = 9900,
				Parent = wmholder
			}
		)
		--
		local box2 = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderSizePixel = 1,
				Size = UDim2.new(1,-4,1,-4),
				Position = UDim2.new(0.5,0,0.5,0),
				ZIndex = 9901,
				Parent = box
			}
		)
		--
		local indent = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderSizePixel = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0.5,0,0.5,0),
				ZIndex = 9902,
				Parent = box2
			}
		)
		--
		local line = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Size = UDim2.new(1,-8,0,1),
				Position = UDim2.new(0.5,0,0,3),
				ZIndex = 9903,
				Parent = indent
			}
		)
		--
		table.insert(window.themeitems["accent"]["BackgroundColor3"],line)
		--
		local label = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0.5,0),
				Font = font,
				Text = text,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = textsize,
				TextStrokeTransparency = 0,
				ZIndex = 9903,
				Parent = indent
			}
		)
		--
		label:GetPropertyChangedSignal("TextBounds"):Connect(function()
			box.Size = UDim2.new(0,math.max(label.TextBounds.X+28,72),0,28)
		end)
		box.Size = UDim2.new(0,math.max(label.TextBounds.X+28,72),0,28)
		--
		utility.dragify(indent,wmholder)
		utility.dragify(box,wmholder)
		--
		window.labels[#window.labels+1] = label
		--
		return label
	end
	--
	local wmname = wmsegment(name)
	local wmfps = wmsegment("0 fps")
	local wmping = wmsegment("0 ms")
	local wmtime = wmsegment(os.date("%H:%M:%S"))
	local wmplace = wmsegment("Place")
	local wmuser = wmsegment(plr.Name)
	--
	coroutine.wrap(function()
		local ok,info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		if ok and info and info.Name then
			wmplace.Text = info.Name
		end
	end)()
	--
	local frames = 0
	local lastsecond = tick()
	--
	window.watermarkconnection = rs.RenderStepped:Connect(function()
		frames = frames + 1
		if tick() - lastsecond >= 1 then
			local fps = frames
			frames = 0
			lastsecond = tick()
			local ping = 0
			pcall(function()
				ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			wmfps.Text = fps.." fps"
			wmping.Text = ping.." ms"
			wmtime.Text = os.date("%H:%M:%S")
		end
	end)
	--
	local toggled = true
	local saved = outline.Position
	local savedtab = tabsoutline.Position
	--
	local menuanimating = false
	local animtoken = 0
	local function startanim(dur)
		menuanimating = true
		window.menuanimating = true
		animtoken = animtoken + 1
		local id = animtoken
		task.delay(dur, function()
			if id == animtoken then
				menuanimating = false
				window.menuanimating = false
			end
		end)
	end
	--
	outline:GetPropertyChangedSignal("Position"):Connect(function()
		if not menuanimating then saved = outline.Position end
	end)
	tabsoutline:GetPropertyChangedSignal("Position"):Connect(function()
		if not menuanimating then savedtab = tabsoutline.Position end
	end)
	--
	local outlinescale = utility.new(
		"UIScale",
		{
			Scale = 1,
			Parent = outline
		}
	)
	--
	local tabscaler = utility.new(
		"UIScale",
		{
			Scale = 1,
			Parent = tabsoutline
		}
	)
	--
	local doclose = function(frame, scale, pos)
		local anim = window.animation
		if anim == "scale" then
			ts:Create(scale, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Scale = 0}):Play()
		elseif anim == "spin" then
			ts:Create(scale, TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Scale = 0}):Play()
			ts:Create(frame, TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Rotation = 200}):Play()
		elseif anim == "left" then
			ts:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(-1.5,0,pos.Y.Scale,pos.Y.Offset)}):Play()
		elseif anim == "right" then
			ts:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1.5,0,pos.Y.Scale,pos.Y.Offset)}):Play()
		elseif anim == "top" then
			ts:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(pos.X.Scale,pos.X.Offset,-1.5,0)}):Play()
		elseif anim == "bottom" then
			ts:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(pos.X.Scale,pos.X.Offset,1.5,0)}):Play()
		else
			local xx,yy = 3,3
			if (frame.AbsolutePosition.X+(frame.AbsoluteSize.X/2)) < (cam.ViewportSize.X/2) then
				xx = -3
			end
			if (frame.AbsolutePosition.Y+(frame.AbsoluteSize.Y/2)) < (cam.ViewportSize.Y/2) then
				yy = -3
			end
			ts:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(xx,0,yy,0)}):Play()
		end
	end
	--
	local doopen = function(frame, scale, pos)
		ts:Create(scale, TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Scale = 1}):Play()
		ts:Create(frame, TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position = pos, Rotation = 0}):Play()
	end
	--
	local fadeid = 0
	local fadealpha = 0
	local fadeitems = {}
	--
	local function collectfade()
		fadeitems = {}
		for i,d in pairs(root:GetDescendants()) do
			if d:IsA("GuiObject") then
				table.insert(fadeitems,{d,"BackgroundTransparency",d.BackgroundTransparency})
			end
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				table.insert(fadeitems,{d,"TextTransparency",d.TextTransparency})
				table.insert(fadeitems,{d,"TextStrokeTransparency",d.TextStrokeTransparency})
			end
			if d:IsA("ImageLabel") or d:IsA("ImageButton") then
				table.insert(fadeitems,{d,"ImageTransparency",d.ImageTransparency})
			end
			if d:IsA("ScrollingFrame") then
				table.insert(fadeitems,{d,"ScrollBarImageTransparency",d.ScrollBarImageTransparency})
			end
		end
	end
	--
	local function applyfade(a)
		fadealpha = a
		for i,it in pairs(fadeitems) do
			if it[1].Parent then
				it[1][it[2]] = it[3] + (1 - it[3]) * a
			end
		end
	end
	--
	local fade = function(target)
		if next(fadeitems) == nil then
			collectfade()
		end
		fadeid = fadeid + 1
		local id = fadeid
		local start = fadealpha
		local dur = 0.3
		local elapsed = 0
		coroutine.wrap(function()
			while elapsed < dur and id == fadeid do
				elapsed = elapsed + rs.RenderStepped:Wait()
				local a = elapsed / dur
				if a > 1 then a = 1 end
				applyfade(start + (target - start) * a)
			end
			if id == fadeid then
				applyfade(target)
				if target >= 1 and toggled == false then
					root.Visible = false
				end
			end
		end)()
	end
	--
	local function fwcollect(fw)
		fw.fadeitems = {}
		for i,d in pairs(fw.frame:GetDescendants()) do
			if d:IsA("GuiObject") then
				table.insert(fw.fadeitems,{d,"BackgroundTransparency",d.BackgroundTransparency})
			end
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				table.insert(fw.fadeitems,{d,"TextTransparency",d.TextTransparency})
				table.insert(fw.fadeitems,{d,"TextStrokeTransparency",d.TextStrokeTransparency})
			end
			if d:IsA("ImageLabel") or d:IsA("ImageButton") then
				table.insert(fw.fadeitems,{d,"ImageTransparency",d.ImageTransparency})
			end
			if d:IsA("ScrollingFrame") then
				table.insert(fw.fadeitems,{d,"ScrollBarImageTransparency",d.ScrollBarImageTransparency})
			end
		end
		table.insert(fw.fadeitems,{fw.frame,"BackgroundTransparency",fw.frame.BackgroundTransparency})
	end
	--
	local function fwapply(fw,a)
		if not fw.fadeitems then fwcollect(fw) end
		fw.fadealpha = a
		for i,it in pairs(fw.fadeitems) do
			if it[1].Parent then
				it[1][it[2]] = it[3] + (1 - it[3]) * a
			end
		end
	end
	--
	local function fwfade(fw,target,hide)
		if not fw.fadeitems then fwcollect(fw) end
		fw.fadeid = (fw.fadeid or 0) + 1
		local id = fw.fadeid
		local start = fw.fadealpha or 0
		local dur = 0.3
		local elapsed = 0
		coroutine.wrap(function()
			while elapsed < dur and id == fw.fadeid do
				elapsed = elapsed + rs.RenderStepped:Wait()
				local a = elapsed / dur
				if a > 1 then a = 1 end
				fwapply(fw,start + (target - start) * a)
			end
			if id == fw.fadeid then
				fwapply(fw,target)
				if hide and target >= 1 then
					fw.gui.Enabled = false
				end
			end
		end)()
	end
	--
	local function fwanim(fw,open)
		if open then
			if not fw.isopen then
				fw.gui.Enabled = false
				return
			end
			fw.gui.Enabled = true
			if window.animation == "instant" then
				fwapply(fw,0)
				fw.frame.Position = fw.saved
				fw.frame.Rotation = 0
				fw.scale.Scale = 1
			elseif window.animation == "fading" then
				fw.frame.Position = fw.saved
				fw.frame.Rotation = 0
				fw.scale.Scale = 1
				fwapply(fw,1)
				fwfade(fw,0)
			else
				fwapply(fw,0)
				doopen(fw.frame, fw.scale, fw.saved)
			end
		else
			if not fw.isopen then
				fw.gui.Enabled = false
				return
			end
			if window.animation == "instant" then
				fw.gui.Enabled = false
			elseif window.animation == "fading" then
				fwfade(fw,1,true)
			else
				doclose(fw.frame, fw.scale, fw.saved)
				local id = fw.animid and (fw.animid + 1) or 1
				fw.animid = id
				task.delay(0.55,function()
					if fw.animid == id and toggled == false then
						fw.gui.Enabled = false
					end
				end)
			end
		end
	end
	--
	local function opencloseanim(open)
		startanim(window.animation == "instant" and 0.05 or 0.55)
		if open then
			toggled = true
			window.opened = true
			screen.Enabled = true
			root.Visible = true
			if window.animation == "instant" then
				applyfade(0)
				outline.Position = saved
				outline.Rotation = 0
				outlinescale.Scale = 1
				tabsoutline.Position = savedtab
				tabsoutline.Rotation = 0
				tabscaler.Scale = 1
			elseif window.animation == "fading" then
				outline.Position = saved
				outline.Rotation = 0
				outlinescale.Scale = 1
				tabsoutline.Position = savedtab
				tabsoutline.Rotation = 0
				tabscaler.Scale = 1
				if next(fadeitems) == nil then
					collectfade()
				end
				applyfade(1)
				fade(0)
			else
				applyfade(0)
				doopen(outline, outlinescale, saved)
				doopen(tabsoutline, tabscaler, savedtab)
			end
		else
			toggled = false
			window.opened = false
			if window.animation == "instant" then
				root.Visible = false
			elseif window.animation == "fading" then
				fade(1)
			else
				applyfade(0)
				doclose(outline, outlinescale, saved)
				doclose(tabsoutline, tabscaler, savedtab)
			end
		end
		for i,fw in pairs(window.floatingwindows) do
			if fw.gui then
				fwanim(fw,open)
			end
		end
	end
	--
	window.opened = true
	--
	function window.setmenu(state)
		if state == nil then state = not toggled end
		if state == toggled then return end
		opencloseanim(state)
	end
	--
	window.toggleconnection = uis.InputBegan:Connect(function(Input, gpe)
		if gpe then return end
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == window.key then
			window.setmenu(not toggled)
		end
	end)
	--
	window.labels[#window.labels+1] = titletext
	-- // metatable indexing + return
	setmetatable(window, library)
	return window
end
--
function library:watermark()
	local watermark = {}
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = self.theme.accent,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,300,0,26),
			Position = UDim2.new(1,-10,0,10),
			ZIndex = 9900,
			Visible = false,
			Parent = self.screen
		}
	)
	--
	table.insert(self.themeitems["accent"]["BackgroundColor3"],outline)
	--
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9901,
			Parent = outline
		}
	)
	--
	local indent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9902,
			Parent = outline2
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.font,
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextXAlignment = "Left",
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = indent
		}
	)
	--
	local con
	con = title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		outline.Size = UDim2.new(0,title.TextBounds.X+20,0,26)
	end)
	--
	watermark = {
		["outline"] = outline,
		["outline2"] = outline2,
		["indent"] = indent,
		["title"] = title,
		["connection"] = con
	}
	--
	self.labels[#self.labels+1] = title
	--
	setmetatable(watermark,watermarks)
	return watermark
end
--
function watermarks:update(content)
	local content = content or {}
	local watermark = self
	--
	local text = ""
	--
	for i,v in pairs(content) do
		text = text..i..": "..v.."  "
	end
	--
	text = text:sub(0, -3)
	--
	watermark.title.Text = text
end
--
function watermarks:updateside(side)
	side = utility.removespaces(tostring(side):lower())
	--
	local sides = {
		topright = {
			AnchorPoint = Vector2.new(1,0),
			Position = UDim2.new(1,-10,0,10)
		},
		topleft = {
			AnchorPoint = Vector2.new(0,0),
			Position = UDim2.new(0,10,0,10)
		},
		bottomright = {
			AnchorPoint = Vector2.new(1,1),
			Position = UDim2.new(1,-10,1,-10)
		},
		bottomleft = {
			AnchorPoint = Vector2.new(0,1),
			Position = UDim2.new(0,10,1,-10)
		}
	}
	--
	if sides[side] then
		self.outline.AnchorPoint = sides[side].AnchorPoint
		self.outline.Position = sides[side].Position
	end
end
--
function library:loader(props)
	local name = props.name or props.Name or props.LoaderName or props.Loadername or props.loaderName or props.loadername or "Loader"
	local scriptname = props.scriptname or props.Scriptname or props.ScriptName or props.scriptName or "Universal"
	local closed = props.close or props.Close or props.closecallback or props.Closecallback or props.CloseCallback or props.closeCallback or function()end
	local logedin = props.login or props.Login or props.logincallback or props.Logincallback or props.LoginCallback or props.loginCallback or function()end
	local loader = {}
	--
	local screen = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = 9999,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)
        if (check_exploit == "Synapse" and syn.request) then
	syn.protect_gui(screen)
        end
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(168, 52, 235),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,300,0,90),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9900,
			Visible = false,
			Parent = screen
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9901,
			Parent = outline
		}
	)
	--
	local indent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9902,
			Parent = outline2
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Font = "RobotoMono",
			Text = name,
			TextColor3 = Color3.fromRGB(168, 52, 235),
			TextXAlignment = "Center",
			TextSize = 12,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = indent
		}
	)
	--
	local scripttitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,20),
			Font = "RobotoMono",
			Text = "Script: "..scriptname,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = "Center",
			TextSize = 12,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = indent
		}
	)
	--
	local makebutton = function(name,parent)
		local button_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 9904,
				Parent = parent
			}
		)
		--
		local button_outline = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 9905,
				Parent = button_holder
			}
		)
		--
		local button_outline2 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 9906,
				Parent = button_outline
			}
		)
		--
		local button_color = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 9907,
				Parent = button_outline2
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = button_color
			}
		)
		--
		local button_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = 12,
				TextStrokeTransparency = 0,
				Font = "RobotoMono",
				ZIndex = 9908,
				Parent = button_holder
			}
		)
		--
		return {button_holder,button_outline,button_button}
	end
	--
	local close = makebutton("close",indent)
	local login = makebutton("login",indent)
	--
	close[1].AnchorPoint = Vector2.new(0.5,0)
	close[1].Size = UDim2.new(0.5,0,0,20)
	close[1].Position = UDim2.new(0.5,0,0,40)
	--
	login[1].AnchorPoint = Vector2.new(0.5,0)
	login[1].Size = UDim2.new(0.5,0,0,20)
	login[1].Position = UDim2.new(0.5,0,0,62)
	--
	close[3].MouseButton1Down:Connect(function()
		close[2].BorderColor3 = Color3.fromRGB(168, 52, 235)
		outline:TweenPosition(UDim2.new(-1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.75,true)
		closed()
		wait(0.05)
		close[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait(0.7)
		screen:Remove()
	end)
	--
	login[3].MouseButton1Down:Connect(function()
		login[2].BorderColor3 = Color3.fromRGB(168, 52, 235)
		outline:TweenPosition(UDim2.new(1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.75,true)
		logedin()
		wait(0.05)
		login[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait(0.7)
		screen:Remove()
	end)
	--
	loader = {
		["outline"] = outline,
		["outline2"] = outline2,
		["indent"] = indent,
		["title"] = title
	}
	--
	setmetatable(loader,loaders)
	return loader
end
--
function loaders:toggle()
	self.outline.Visible = true
end
--
function watermarks:toggle(bool)
	local watermark = self
	--
	watermark.outline.Visible = bool
end
--
function library:saveconfig()
	local cfg = {}
	--
	for i,v in pairs(self.pointers) do
		cfg[i] = {}
		for c,d in pairs(v) do
			cfg[i][c] = {}
			for x,z in pairs(d) do
				if typeof(z.current) == "Color3" then
					cfg[i][c][x] = {z.current.R,z.current.G,z.current.B}
				else
					cfg[i][c][x] = z.current
				end
			end
		end
	end
	--
	return hs:JSONEncode(cfg)
end
--
function library:loadconfig(cfg)
	local cfg = hs:JSONDecode(readfile(cfg))
	for i,v in pairs(cfg) do
		for c,d in pairs(v) do
			for x,z in pairs(d) do
				if z ~= nil then
					if self.pointers[i] ~= nil and self.pointers[i][c] ~= nil and self.pointers[i][c][x] ~= nil then
						self.pointers[i][c][x]:set(z)
					end
				end
			end
		end
	end
end
--
function library:settheme(theme,color,alpha)
	local window = self
	--
	if theme == "background" then
		window.theme.background = color
		if next(window.bgframes) == nil then
			for i,v in pairs(window.screen:GetDescendants()) do
				if (v:IsA("Frame") or v:IsA("ScrollingFrame")) and window.bgframes[v] == nil then
					local c = v.BackgroundColor3
					local r = math.floor(c.R*255+0.5)
					if c.R == c.G and c.G == c.B and (r == 20 or r == 24 or r == 30) then
						window.bgframes[v] = r - 20
					end
				end
			end
		end
		for frame,offset in pairs(window.bgframes) do
			if frame.Parent then
				frame.BackgroundColor3 = Color3.fromRGB(
					math.clamp(math.floor(color.R*255+0.5)+offset,0,255),
					math.clamp(math.floor(color.G*255+0.5)+offset,0,255),
					math.clamp(math.floor(color.B*255+0.5)+offset,0,255)
				)
				if alpha ~= nil then
					frame.BackgroundTransparency = 1 - alpha
				end
			end
		end
		return
	end
	--
	if window.theme[theme] then
		window.theme[theme] = color
	end
	--
	if window.themeitems[theme] then
		local transprop = {
			["BackgroundColor3"] = "BackgroundTransparency",
			["ImageColor3"] = "ImageTransparency",
			["TextColor3"] = "TextTransparency"
		}
		for i,v in pairs(window.themeitems[theme]) do
			for z,x in pairs(v) do
				x[i] = color
				if alpha ~= nil and transprop[i] then
					x[transprop[i]] = 1 - alpha
				end
			end
		end
	end
	--
	if theme == "accent" then
		for i,v in pairs(window.pages) do
			if v.open then
				if v.outline then v.outline.BorderColor3 = color end
				if v.icon then v.icon.ImageColor3 = color end
				if v.label then v.label.TextColor3 = color end
			end
		end
	end
end
--
function library:setkey(key)
	if typeof(key) == "EnumItem" then
		local window = self
		window.key = key
		if window.keylabel then
			local capd = utility.capatalize(key.Name)
			if #capd > 1 then
				window.keylabel.Text = capd
			else
				window.keylabel.Text = key.Name
			end
			window.keylabel.Parent.Size = UDim2.new(0,window.keylabel.TextBounds.X+20,0,16)
		end
	end
end
--
function library:settoggle(side,bool)
	if side == "x" then
		self.x = bool
	else
		self.y = bool
	end
end
--
function library:setanimation(name)
	local anims = {
		["slide"] = true,
		["left"] = true,
		["right"] = true,
		["top"] = true,
		["bottom"] = true,
		["scale"] = true,
		["spin"] = true,
		["fading"] = true,
		["instant"] = true
	}
	name = utility.removespaces(tostring(name):lower())
	if anims[name] then
		self.animation = name
	end
end
--
function library:setwatermark(bool)
	if self.watermark then
		self.watermark.Visible = bool
	end
end
--
function library:setwatermarkside(side)
	if not self.watermark then return end
	side = utility.removespaces(tostring(side):lower())
	local sides = {
		topright = {Vector2.new(1,0), UDim2.new(1,-10,0,10)},
		topleft = {Vector2.new(0,0), UDim2.new(0,10,0,10)},
		bottomright = {Vector2.new(1,1), UDim2.new(1,-10,1,-10)},
		bottomleft = {Vector2.new(0,1), UDim2.new(0,10,1,-10)}
	}
	if sides[side] then
		self.watermark.AnchorPoint = sides[side][1]
		self.watermark.Position = sides[side][2]
	end
end
--
function library:notify(props)
	local window = self
	if not window.notifyholder then return end
	if type(props) ~= "table" then
		props = {["text"] = tostring(props)}
	end
	local title = props.title or props.Title
	local text = props.text or props.Text or props.content or props.Content or props.message or props.Message or props.desc or props.Desc or ""
	local duration = props.duration or props.Duration or props.time or props.Time or 5
	local col = props.color or props.Color or window.theme.accent
	local themed = (props.color == nil and props.Color == nil)
	text = tostring(text)
	-- // measure
	local width = 280
	local innerw = width - 24
	local bounds = game:GetService("TextService"):GetTextSize(text, window.textsize, Enum.Font.Gotham, Vector2.new(innerw,9999))
	local titleh = title and 16 or 0
	local texth = (#text > 0) and bounds.Y or 0
	local total = 10 + titleh + texth + 10
	if total < 30 then total = 30 end
	-- // chrome
	local holder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,total),
			Parent = window.notifyholder
		}
	)
	--
	local box = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Active = true,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(1,20,0,0),
			Parent = holder
		}
	)
	--
	local box2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = box
		}
	)
	--
	local indent = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = box2
		}
	)
	--
	local bar = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0.5),
			BackgroundColor3 = col,
			BorderSizePixel = 0,
			Size = UDim2.new(0,2,1,-8),
			Position = UDim2.new(0,3,0.5,0),
			Parent = indent
		}
	)
	--
	if themed then
		table.insert(window.themeitems["accent"]["BackgroundColor3"],bar)
	end
	-- // text
	local y = 8
	if title then
		local t = utility.new(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-18,0,16),
				Position = UDim2.new(0,12,0,6),
				Font = window.font,
				Text = tostring(title),
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = window.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				Parent = indent
			}
		)
		window.labels[#window.labels+1] = t
		y = 24
	end
	--
	if #text > 0 then
		local d = utility.new(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-18,0,texth),
				Position = UDim2.new(0,12,0,y),
				Font = window.font,
				Text = text,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextSize = window.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				TextWrapped = true,
				Parent = indent
			}
		)
		window.labels[#window.labels+1] = d
	end
	-- // animate
	ts:Create(box, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position = UDim2.new(1,0,0,0)}):Play()
	--
	coroutine.wrap(function()
		wait(duration)
		ts:Create(box, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1,20,0,0)}):Play()
		wait(0.35)
		if themed then
			local find = table.find(window.themeitems["accent"]["BackgroundColor3"],bar)
			if find then
				table.remove(window.themeitems["accent"]["BackgroundColor3"],find)
			end
		end
		holder:Destroy()
	end)()
end
--
function library:unload()
	local window = self
	--
	pcall(window.unloadcallback)
	--
	if window.toggleconnection then
		window.toggleconnection:Disconnect()
	end
	--
	if window.watermarkconnection then
		window.watermarkconnection:Disconnect()
	end
	--
	if window.connections then
		for i,v in pairs(window.connections) do
			pcall(function() v:Disconnect() end)
		end
	end
	--
	if window.floatingguis then
		for i,v in pairs(window.floatingguis) do
			pcall(function() v:Destroy() end)
		end
	end
	--
	if window.screen then
		window.screen:Destroy()
	end
end
--
function library:configtab(props)
	local props = props or {}
	local name = props.name or props.Name or "Configs"
	local icon = props.icon or props.Icon or props.image or props.Image or nil
	local folder = props.folder or props.Folder or "evolution_configs"
	--
	if not isfolder(folder) then
		makefolder(folder)
	end
	if folder:sub(-1) ~= "/" then
		folder = folder.."/"
	end
	-- // page
	local page = self:page({name = name, icon = icon})
	-- // configs
	local configs = page:section({name = "Configs", side = "left", size = 250})
	configs:configloader({folder = folder})
	-- // theme
	local theme = page:section({name = "Theme", side = "right", size = 80})
	theme:colorpicker({name = "Accent Color", def = self.theme.accent, callback = function(color, alpha)
		self:settheme("accent", color, alpha)
	end})
	theme:colorpicker({name = "Background", def = self.theme.background, callback = function(color, alpha)
		self:settheme("background", color, alpha)
	end})
	-- // menu
	local menu = page:section({name = "Menu", side = "right", size = 210})
	menu:dropdown({name = "Animation", options = {"slide", "left", "right", "top", "bottom", "scale", "spin", "fading", "instant"}, def = self.animation, callback = function(option)
		self:setanimation(option)
	end})
	menu:dropdown({name = "Font", options = {"Gotham", "SourceSans", "Ubuntu", "Proggy Clean", "Tahoma"}, def = self.font, callback = function(option)
		self:setfont(option)
	end})
	menu:dropdown({name = "ESP Preview Animation", options = {"Spin", "Static", "Slow Spin", "Sway", "Float"}, def = "Spin", callback = function(option)
		self:setpreviewanimation(option)
	end})
	menu:toggle({name = "Watermark", def = true, callback = function(state)
		self:setwatermark(state)
	end})
	menu:keybind({name = "Menu Key", def = self.key, callback = function(key)
		if typeof(key) == "EnumItem" then
			self:setkey(key)
		end
	end})
	menu:button({name = "Unload", callback = function()
		self:unload()
	end})
	--
	return page
end
--
function library:setfont(font)
	if font ~= nil then
		local window = self
		local key = utility.removespaces(tostring(font):lower())
		local face = customfonts[key]
		if face then
			local fontobj = (typeof(face) == "Font") and face or Font.new(face)
			window.font = font
			for i,v in pairs(window.labels) do
				if v ~= nil then
					v.FontFace = fontobj
				end
			end
		else
			if pcall(function() return Enum.Font[font] end) then
				window.font = font
				for i,v in pairs(window.labels) do
					if v ~= nil then
						v.Font = font
					end
				end
			end
		end
	end
end
--
function library.addfont(name,font)
	customfonts[utility.removespaces(tostring(name):lower())] = font
end
--
function library:settextsize(size)
	if size ~= nil then
		local window = self
		for i,v in pairs(window.labels) do
			if v ~= nil then
				v.TextSize = size
			end
		end
	end
end
--
function library:page(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local icon = props.icon or props.Icon or props.image or props.Image or props.imageid or props.ImageId or nil
	-- // variables
	local page = {}
	-- // main
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,26,0,26),
			ZIndex = 11,
			Parent = self.tabsbuttons
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ZIndex = 11,
			Parent = tabbutton
		}
	)
	--
	local image = utility.new(
		"ImageLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(0,16,0,16),
			Position = UDim2.new(0.5,0,0.5,0),
			Image = icon or "",
			ImageColor3 = Color3.fromRGB(200, 200, 200),
			Visible = icon ~= nil,
			ZIndex = 12,
			Parent = outline
		}
	)
	--
	local label = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Font = self.font,
			Text = icon and "" or name:sub(1,1):upper(),
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			Visible = icon == nil,
			ZIndex = 12,
			Parent = outline
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			ZIndex = 13,
			Parent = tabbutton
		}
	)
	--
	local pageholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,-20),
			Position = UDim2.new(0.5,0,0.5,0),
			Visible = false,
			Parent = self.tabs
		}
	)
	--
	local left = utility.new(
		"ScrollingFrame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.35,
			ScrollBarImageColor3 = Color3.fromRGB(120,120,120),
			ScrollBarThickness = 3,
			ClipsDescendants = true,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = pageholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = left
		}
	)
	--
	local right = utility.new(
		"ScrollingFrame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(1,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.35,
			ScrollBarImageColor3 = Color3.fromRGB(120,120,120),
			ScrollBarThickness = 3,
			ClipsDescendants = true,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = pageholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = right
		}
	)
	-- // page tbl
	page = {
		["library"] = self,
		["outline"] = outline,
		["icon"] = image,
		["label"] = label,
		["page"] = pageholder,
		["left"] = left,
		["right"] = right,
		["open"] = false,
		["pointers"] = {}
	}
	--
	table.insert(self.pages,page)
	--
	local count = #self.pages + (self.extratabs or 0)
	self.tabsbar.Size = UDim2.new(0, count*26 + (count-1)*3 + 10, 0, 37)
	--
	button.MouseButton1Down:Connect(function()
		if page.open == false then
			for i,v in pairs(self.pages) do
				if v ~= page then
					if v.open then
						v.page.Visible = false
						v.open = false
						v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
						v.outline.BorderColor3 = Color3.fromRGB(56, 56, 56)
						v.icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
						v.label.TextColor3 = Color3.fromRGB(200, 200, 200)
					end
				end
			end
			--
			self:closewindows()
			--
			page.page.Visible = true
			page.open = true
			page.outline.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			page.outline.BorderColor3 = self.theme.accent
			page.icon.ImageColor3 = self.theme.accent
			page.label.TextColor3 = self.theme.accent
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		self.pointers[tostring(pointer)] = page.pointers
	end
	--
	self.labels[#self.labels+1] = label
	-- // metatable indexing + return
	setmetatable(page, pages)
	return page
end
--
function pages:openpage()
	local page = self
	--
	if page.open == false then
		for i,v in pairs(page.library.pages) do
			if v ~= page then
				if v.open then
					v.page.Visible = false
					v.open = false
					v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					v.outline.BorderColor3 = Color3.fromRGB(56, 56, 56)
					v.icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
					v.label.TextColor3 = Color3.fromRGB(200, 200, 200)
				end
			end
		end
		--
		page.page.Visible = true
		page.open = true
		page.outline.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		page.outline.BorderColor3 = page.library.theme.accent
		page.icon.ImageColor3 = page.library.theme.accent
		page.label.TextColor3 = page.library.theme.accent
	end
end
--
function pages:subtab(props)
	-- // properties
	local props = props or {}
	local name = props.name or props.Name or props.subtab or props.Subtab or props.subtabname or props.Subtabname or props.SubtabName or props.subtabName or "new ui"
	-- // lazy tab bar
	if not self.subtabs then
		self.subtabs = {}
		self.left.Visible = false
		self.right.Visible = false
		self.subtabbar = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1,-8,0,25),
				Position = UDim2.new(0.5,0,0,-2),
				ZIndex = 2,
				Parent = self.page
			}
		)
		--
		utility.new(
			"UIListLayout",
			{
				FillDirection = "Horizontal",
				Padding = UDim.new(0,0),
				Parent = self.subtabbar
			}
		)
	end
	-- // tab button
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 2,
			Parent = self.subtabbar
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ZIndex = 2,
			Parent = tabbutton
		}
	)
	--
	local line = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,1),
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,1),
			Position = UDim2.new(0,0,1,0),
			ZIndex = 3,
			Parent = outline
		}
	)
	--
	local label = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,-2),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 3,
			Parent = outline
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			ZIndex = 4,
			Parent = tabbutton
		}
	)
	-- // content
	local content = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-8,1,-31),
			Position = UDim2.new(0.5,0,0,29),
			Visible = false,
			Parent = self.page
		}
	)
	--
	local left = utility.new(
		"ScrollingFrame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.35,
			ScrollBarImageColor3 = Color3.fromRGB(120,120,120),
			ScrollBarThickness = 3,
			ClipsDescendants = true,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = content
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = left
		}
	)
	--
	local right = utility.new(
		"ScrollingFrame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(1,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.35,
			ScrollBarImageColor3 = Color3.fromRGB(120,120,120),
			ScrollBarThickness = 3,
			ClipsDescendants = true,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = content
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = right
		}
	)
	-- // subtab tbl
	local subtab = {
		["library"] = self.library,
		["page"] = self.page,
		["content"] = content,
		["tab"] = tabbutton,
		["outline"] = outline,
		["line"] = line,
		["button"] = button,
		["left"] = left,
		["right"] = right,
		["open"] = false,
		["pointers"] = {}
	}
	--
	table.insert(self.subtabs,subtab)
	--
	local count = #self.subtabs
	for i,v in pairs(self.subtabs) do
		v.tab.Size = UDim2.new(1/count,0,1,0)
	end
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = subtab.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = label
	--
	local function open()
		for i,v in pairs(self.subtabs) do
			if v ~= subtab then
				if v.open then
					v.content.Visible = false
					v.open = false
					v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					v.line.Size = UDim2.new(1,0,0,1)
					v.line.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
					local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],v.line)
					if find then
						table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find)
					end
				end
			end
		end
		--
		subtab.content.Visible = true
		subtab.open = true
		subtab.outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		subtab.line.Size = UDim2.new(1,0,0,2)
		subtab.line.BackgroundColor3 = self.library.theme.accent
		if not table.find(self.library.themeitems["accent"]["BackgroundColor3"],subtab.line) then
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],subtab.line)
		end
	end
	--
	button.MouseButton1Down:Connect(open)
	--
	if count == 1 then
		open()
	end
	-- // metatable indexing + return
	setmetatable(subtab, pages)
	return subtab
end
--
function pages:section(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local side = props.side or props.Side or props.sectionside or props.Sectionside or props.SectionSide or props.sectionSide or "left"
	local size = props.size or props.Size or props.yaxis or props.yAxis or props.YAxis or props.Yaxis or 200
	side = side:lower()
	-- // variables
	local section = {}
	-- // main
	local sectionholder = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,size),
			Parent = self[side]
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			Parent = outline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(210, 210, 210))},
			Rotation = 90,
			Parent = outline
		}
	)
	--
	local content = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-12,1,-25),
			Position = UDim2.new(0.5,0,1,-5),
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-5,0,20),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = outline
		}
	)
	--
	local layout = utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,5),
			Parent = content
		}
	)
	--
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sectionholder.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y + 55)
	end)
	-- // section tbl
	section = {
		["library"] = self.library,
		["sectionholder"] = sectionholder,
		["color"] = color,
		["content"] = content,
		["pointers"] = {}
	}
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = section.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(section, sections)
	return section
end
--
function pages:multisection(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local side = props.side or props.Side or props.sectionside or props.Sectionside or props.SectionSide or props.sectionSide or "left"
	local size = props.size or props.Size or props.yaxis or props.yAxis or props.YAxis or props.Yaxis or 200
	side = side:lower()
	-- // variables
	local multisection = {}
	-- // main
	local sectionholder = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,size),
			Parent = self[side]
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			Parent = outline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	local tabsholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,-15),
			Position = UDim2.new(0,0,1,0),
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-5,0,20),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = outline
		}
	)
	--
	local buttons = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-6,0,20),
			Position = UDim2.new(0.5,0,0,5),
			Parent = tabsholder
		}
	)
	--
	local tabs = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-6,1,-27),
			Position = UDim2.new(0.5,0,1,-3),
			Parent = tabsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Horizontal",
			Padding = UDim.new(0,2),
			Parent = buttons
		}
	)
	--
	local tabs_outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabs
		}
	)
	-- // section tbl
	multisection = {
		["library"] = self.library,
		["sectionholder"] = sectionholder,
		["color"] = color,
		["tabsholder"] = tabsholder,
		["mssections"] = {},
		["buttons"] = buttons,
		["tabs"] = tabs,
		["tabs_outline"] = tabs_outline,
		["pointers"] = {}
	}
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = multisection.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(multisection,multisections)
	return multisection
end
--
function multisections:section(props)
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	-- // variables
	local mssection = {}
	-- // main
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,60,0,20),
			Parent = self.buttons
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabbutton
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = tabbutton
		}
	)
	--
	local r_line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(1,0,1,1),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local l_line = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(0,0,1,1),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,2),
			Position = UDim2.new(0,0,1,0),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local label = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Parent = outline
		}
	)
	--
	local content = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-6,1,-27),
			Position = UDim2.new(0.5,0,1,-3),
			Parent = self.tabs_outline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,5),
			Parent = content
		}
	)
	-- // mssection tbl
	mssection = {
		["library"] = self.library,
		["outline"] = outline,
		["r_line"] = r_line,
		["l_line"] = l_line,
		["line"] = line,
		["content"] = content,
		["open"] = false,
		["pointers"] = {}
	}
	--
	table.insert(self.mssections,mssection)
	--
	button.MouseButton1Down:Connect(function()
		if mssection.open == false then
			for i,v in pairs(self.mssections) do
				if v ~= mssection then
					if v.open then
						v.page.Visible = false
						v.open = false
						v.outline.BackgroundColor3 = Color3.fromRGB(31, 31 ,31)
						v.line.Size = UDim2.new(1,0,0,2)
						v.line.BackgroundColor3 = Color3.fromRGB(31, 31 ,31)
					end
				end
			end
			--
			mssection.library:closewindows()
			--
			mssection.content.Visible = true
			mssection.open = true
			mssection.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			mssection.line.Size = UDim2.new(1,0,0,3)
			mssection.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = mssection.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = label
	-- // metatable indexing + return
	setmetatable(mssection,mssections)
	return mssection
end
--
function sections:toggle(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or props.toggle or props.Toggle or props.toggled or props.Toggled or false
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local toggle = {}
	-- // main
	local toggleholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,15,0,15),
			Parent = toggleholder
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = toggleholder
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,20,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = toggleholder
		}
	)
	--
	local col = Color3.fromRGB(20, 20, 20)
	if def then
		col = self.library.theme.accent
	end
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = col,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	if def then
		table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	end
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local hover = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 2,
			Parent = outline
		}
	)
	-- // toggle tbl
	toggle = {
		["library"] = self.library,
		["toggleholder"] = toggleholder,
		["title"] = title,
		["color"] = color,
		["callback"] = callback,
		["current"] = def
	}
	--
	button.MouseButton1Down:Connect(function()
		if toggle.current then
			toggle.callback(false)
			toggle.color.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			if find then
				table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find)
			end
			toggle.current = false
		else
			toggle.callback(true)
			toggle.color.BackgroundColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			toggle.current = true
		end
	end)
	--
	button.MouseEnter:Connect(function()
		ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.9}):Play()
	end)
	--
	button.MouseLeave:Connect(function()
		ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = toggle
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(toggle, toggles)
	toggle.holder = toggleholder
	if props.visible == false or props.Visible == false then toggleholder.Visible = false end
	return toggle
end
--
function toggles:set(bool)
	if bool ~= nil then
		local toggle = self
		toggle.callback(bool)
		toggle.current = bool
		if bool then
			toggle.color.BackgroundColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
		else
			toggle.color.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			if find then
				table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find)
			end
		end
	end
end
--
function sections:button(props)
	-- // properties
	local name = props.name or props.Name or "new button"
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local button = {}
	-- // main
	local buttonholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = buttonholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	local gradient = utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local buttonpress = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = buttonholder
		}
	)
	--
	buttonpress.MouseButton1Down:Connect(function()
		callback()
		outline.BorderColor3 = self.library.theme.accent
		table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
		wait(0.05)
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end)
	--
	buttonpress.MouseEnter:Connect(function()
		local b = self.library.theme.background
		ts:Create(color, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(
			math.clamp(math.floor(b.R*255+0.5)+25,0,255),
			math.clamp(math.floor(b.G*255+0.5)+25,0,255),
			math.clamp(math.floor(b.B*255+0.5)+25,0,255)
		)}):Play()
	end)
	--
	buttonpress.MouseLeave:Connect(function()
		local b = self.library.theme.background
		ts:Create(color, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(
			math.clamp(math.floor(b.R*255+0.5)+10,0,255),
			math.clamp(math.floor(b.G*255+0.5)+10,0,255),
			math.clamp(math.floor(b.B*255+0.5)+10,0,255)
		)}):Play()
	end)
	-- // button tbl
	button = {
		["library"] = self.library
	}
	--
	self.library.labels[#self.library.labels+1] = buttonpress
	-- // metatable indexing + return
	setmetatable(button, buttons)
	button.holder = buttonholder
	if props.visible == false or props.Visible == false then buttonholder.Visible = false end
	return button
end
--
function sections:slider(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or 0
	local max = props.max or props.Max or props.maximum or props.Maximum or 100
	local min = props.min or props.Min or props.minimum or props.Minimum or 0
	local rounding = props.rounding or props.Rounding or props.round or props.Round or props.decimals or props.Decimals or false
	local ticking = props.tick or props.Tick or props.ticking or props.Ticking or false
	local measurement = props.measurement or props.Measurement or props.digit or props.Digit or props.calc or props.Calc or ""
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	def = math.clamp(def,min,max)
	-- // variables
	local slider = {}
	-- // main
	local sliderholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,33),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,16),
			Position = UDim2.new(0,0,0,15),
			Parent = sliderholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)	
	--
	local value = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = def..measurement.."/"..max..measurement,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 3,
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local slide = utility.new(
		"Frame",
		{
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new((1 / color.AbsoluteSize.X) * (color.AbsoluteSize.X / (max - min) * (def - min)),0,1,0),
			ZIndex = 2,
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],slide)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = slide
		}
	)
	--
	local hoverfill = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ZIndex = 1,
			Parent = outline
		}
	)
	--
	local sliderbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = sliderholder
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = sliderholder
		}
	)
	-- // slider tbl
	slider = {
		["library"] = self.library,
		["outline"] = outline,
		["sliderbutton"] = sliderbutton,
		["title"] = title,
		["value"] = value,
		["slide"] = slide,
		["color"] = color,
		["max"] = max,
		["min"] = min,
		["current"] = def,
		["measurement"] = measurement,
		["tick"] = ticking,
		["rounding"] = rounding,
		["callback"] = callback
	}
	--
	local function slide()
		local size = math.clamp(plr:GetMouse().X - slider.color.AbsolutePosition.X ,0 ,slider.color.AbsoluteSize.X)
		local result = (slider.max - slider.min) / slider.color.AbsoluteSize.X * size + slider.min
		if slider.rounding then
			local newres = math.floor(result)
			value.Text = newres..slider.measurement.."/"..slider.max..slider.measurement
			slider.current = newres
			slider.callback(newres)
			if slider.tick then
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * (slider.color.AbsoluteSize.X / (slider.max - slider.min) * (newres - slider.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			else
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			end
		else
			local newres = utility.round(result ,2)
			value.Text = newres..slider.measurement.."/"..slider.max..slider.measurement
			slider.current = newres
			slider.callback(newres)
			if slider.tick then
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * (slider.color.AbsoluteSize.X / (slider.max - slider.min) * (newres - slider.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			else
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			end
		end
	end
	--
	sliderbutton.MouseButton1Down:Connect(function()
		slider.holding = true
		slide()
		table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
		outline.BorderColor3 = self.library.theme.accent
	end)
	--
	uis.InputChanged:Connect(function()
		if slider.holding then
			slide()
		end
	end)
	--
	uis.InputEnded:Connect(function(Input)
		if Input.UserInputType.Name == 'MouseButton1' and slider.holding then
			slider.holding = false
			outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
			local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
			if find then
				table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
			end
		end
	end)
	--
	sliderbutton.MouseEnter:Connect(function()
		ts:Create(hoverfill, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.8}):Play()
	end)
	--
	sliderbutton.MouseLeave:Connect(function()
		ts:Create(hoverfill, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	end)
	--
	sliderbutton.MouseMoved:Connect(function(x)
		local s = math.clamp(x - slider.color.AbsolutePosition.X, 0, slider.color.AbsoluteSize.X)
		ts:Create(hoverfill, TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size = UDim2.new((1 / slider.color.AbsoluteSize.X) * s, 0, 1, 0)}):Play()
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = slider
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = value
	-- // metatable indexing + return
	setmetatable(slider, sliders)
	slider.holder = sliderholder
	if props.visible == false or props.Visible == false then sliderholder.Visible = false end
	return slider
end
--
function sliders:set(value)
	local size = math.clamp((self.color.AbsoluteSize.X / (self.max - self.min) * (value - self.min)) ,0 ,self.color.AbsoluteSize.X)
	local result = value
	if self.rounding then
		local newres = math.floor(result)
		self.value.Text = newres..self.measurement.."/"..self.max..self.measurement
		self.current = newres
		self.callback(newres)
		if self.tick then
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * (self.color.AbsoluteSize.X / (self.max - self.min) * (newres - self.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		else
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		end
	else
		local newres = utility.round(result ,2)
		self.value.Text = newres..self.measurement.."/"..self.max..self.measurement
		self.current = newres
		self.callback(newres)
		if self.tick then
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * (self.color.AbsoluteSize.X / (self.max - self.min) * (newres - self.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		else
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		end
	end
end
--
function library:closewindows(ignore)
	local window = self
	--
	for i,v in pairs(window.dropdowns) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "-"
				v.open = false
			end
		end
	end
	--
	for i,v in pairs(window.multiboxes) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "-"
				v.open = false
			end
		end
	end
	--
	for i,v in pairs(window.buttonboxs) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "-"
				v.open = false
			end
		end
	end
	--
	for i,v in pairs(window.colorpickers) do
		if v ~= ignore then
			if v.open then
				v.cpholder.Visible = false
				v.open = false
			end
		end
	end
end
--
function sections:dropdown(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local dropdown = {}
	-- // main
	local dropdownholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = dropdownholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local value = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = def,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = dropdownholder
		}
	)
	--
	local dropdownbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = dropdownholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = dropdownholder
		}
	)
	--
	local size = #options
	--
	size = math.clamp(size,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,size,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = optionsoutline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	-- // dropdown tbl
	dropdown = {
		["library"] = self.library,
		["optionsholder"] = optionsholder,
		["indicator"] = indicator,
		["options"] = options,
		["title"] = title,
		["value"] = value,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback
	}
	--
	table.insert(dropdown.library.dropdowns,dropdown)
	--
	local opensz = UDim2.new(1,0,size,2)
	--
	local function openlist()
		optionsholder.Visible = true
		optionsoutline.Size = UDim2.new(1,0,0,0)
		ts:Create(optionsoutline, TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size = opensz}):Play()
	end
	--
	local function closelist()
		local t = ts:Create(optionsoutline, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Size = UDim2.new(1,0,0,0)})
		t:Play()
		t.Completed:Connect(function()
			if not dropdown.open then
				optionsholder.Visible = false
			end
		end)
	end
	--
	for i,v in pairs(options) do
		local ddoptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local hover = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = ddoptionbutton
			}
		)
		--
		local ddoptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
			ClipsDescendants = true,
				ZIndex = 6,
				Parent = ddoptionbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = ddoptiontitle
		--
		table.insert(dropdown.titles,ddoptiontitle)
		--
		if v == dropdown.current then ddoptiontitle.TextColor3 = self.library.theme.accent end
		--
		ddoptionbutton.MouseEnter:Connect(function()
			ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.92}):Play()
		end)
		--
		ddoptionbutton.MouseLeave:Connect(function()
			ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		end)
		--
		ddoptionbutton.MouseButton1Down:Connect(function()
			dropdown.open = false
			indicator.Text = "+"
			closelist()
			for z,x in pairs(dropdown.titles) do
				if x.TextColor3 == self.library.theme.accent then
					x.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
			dropdown.current = v
			dropdown.value.Text = v
			dropdown.value.TextColor3 = self.library.theme.accent
			ts:Create(dropdown.value, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			ddoptiontitle.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],ddoptiontitle)
			dropdown.callback(v)
		end)
	end
	--
	dropdownbutton.MouseButton1Down:Connect(function()
		dropdown.library:closewindows(dropdown)
		for i,v in pairs(dropdown.titles) do
			if v.Text == dropdown.current then
				v.TextColor3 = dropdown.library.theme.accent
			else
				v.TextColor3 = Color3.fromRGB(255,255,255)
			end
		end
		dropdown.open = not dropdown.open
		if dropdown.open then
			indicator.Text = "-"
			openlist()
		else
			indicator.Text = "+"
			closelist()
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = dropdown
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = value
	-- // metatable indexing + return
	setmetatable(dropdown, dropdowns)
	dropdown.holder = dropdownholder
	if props.visible == false or props.Visible == false then dropdownholder.Visible = false end
	return dropdown
end
--
function sections:buttonbox(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local buttonbox = {}
	-- // main
	local buttonboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = buttonboxholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = buttonboxholder
		}
	)
	--
	local buttonboxbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = buttonboxholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = buttonboxholder
		}
	)
	--
	local size = #options
	--
	size = math.clamp(size,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,size,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = optionsoutline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	-- // buttonbox tbl
	buttonbox = {
		["library"] = self.library,
		["optionsholder"] = optionsholder,
		["indicator"] = indicator,
		["options"] = options,
		["title"] = title,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback
	}
	--
	table.insert(buttonbox.library.buttonboxs,buttonbox)
	--
	local opensz = UDim2.new(1,0,size,2)
	--
	local function openlist()
		optionsholder.Visible = true
		optionsoutline.Size = UDim2.new(1,0,0,0)
		ts:Create(optionsoutline, TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size = opensz}):Play()
	end
	--
	local function closelist()
		local t = ts:Create(optionsoutline, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Size = UDim2.new(1,0,0,0)})
		t:Play()
		t.Completed:Connect(function()
			if not buttonbox.open then
				optionsholder.Visible = false
			end
		end)
	end
	--
	for i,v in pairs(options) do
		local bboptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local hover = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = bboptionbutton
			}
		)
		--
		local bboptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
			ClipsDescendants = true,
				ZIndex = 6,
				Parent = bboptionbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = bboptiontitle
		--
		table.insert(buttonbox.titles,bboptiontitle)
		--
		bboptionbutton.MouseEnter:Connect(function()
			ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.92}):Play()
		end)
		--
		bboptionbutton.MouseLeave:Connect(function()
			ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		end)
		--
		bboptionbutton.MouseButton1Down:Connect(function()
			optionsholder.Visible = false
			buttonbox.open = false
			indicator.Text = "+"
			buttonbox.current = v
			buttonbox.callback(v)
		end)
	end
	--
	buttonboxbutton.MouseButton1Down:Connect(function()
		buttonbox.library:closewindows(buttonbox)
		buttonbox.open = not buttonbox.open
		if buttonbox.open then
			indicator.Text = "-"
			openlist()
		else
			indicator.Text = "+"
			closelist()
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = buttonbox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(buttonbox, buttonboxs)
	buttonbox.holder = buttonboxholder
	if props.visible == false or props.Visible == false then buttonboxholder.Visible = false end
	return buttonbox
end
--
function dropdowns:set(value)
	if value ~= nil then
		local dropdown = self
		if table.find(dropdown.options,value) then
			self.current = tostring(value)
			self.value.Text = tostring(value)
			self.callback(tostring(value))
			for z,x in pairs(dropdown.titles) do
				if x.Text == value then
					x.TextColor3 = dropdown.library.theme.accent
				else
					x.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
		end
	end
end
--
function sections:multibox(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or {}
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local defstr = ""
	if #def > 1 then
		for i,v in pairs(def) do
			if i == #def then
				defstr = defstr..v
			else
				defstr = defstr..v..", "
			end
		end
	else
		for i,v in pairs(def) do
			defstr = defstr..v
		end
	end
	-- // variables
	local multibox = {}
	-- // main
	local multiboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = multiboxholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local value = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = defstr,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = multiboxholder
		}
	)
	--
	local dropdownbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = multiboxholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = multiboxholder
		}
	)
	--
	local size = #options
	--
	size = math.clamp(size,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,size,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = optionsoutline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	-- // dropdown tbl
	multibox = {
		["library"] = self.library,
		["indicator"] = indicator,
		["optionsholder"] = optionsholder,
		["options"] = options,
		["value"] = value,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback
	}
	--
	table.insert(multibox.library.multiboxes,multibox)
	--
	local opensz = UDim2.new(1,0,size,2)
	--
	local function openlist()
		optionsholder.Visible = true
		optionsoutline.Size = UDim2.new(1,0,0,0)
		ts:Create(optionsoutline, TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size = opensz}):Play()
	end
	--
	local function closelist()
		local t = ts:Create(optionsoutline, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Size = UDim2.new(1,0,0,0)})
		t:Play()
		t.Completed:Connect(function()
			if not multibox.open then
				optionsholder.Visible = false
			end
		end)
	end
	--
	for i,v in pairs(options) do
		local ddoptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local hover = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = ddoptionbutton
			}
		)
		--
		local ddoptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
			ClipsDescendants = true,
				ZIndex = 6,
				Parent = ddoptionbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = ddoptiontitle
		--
		table.insert(multibox.titles,ddoptiontitle)
		--
		ddoptionbutton.MouseEnter:Connect(function()
			ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.92}):Play()
		end)
		--
		ddoptionbutton.MouseLeave:Connect(function()
			ts:Create(hover, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		end)
		--
		for c,b in pairs(def) do if v == b then ddoptiontitle.TextColor3 = self.library.theme.accent end end
		--
		ddoptionbutton.MouseButton1Down:Connect(function()
			local find = table.find(multibox.current,v)
			if find == nil then
				table.insert(multibox.current,v)
				local str = ""
				if #multibox.current > 1 then
					for i,v in pairs(multibox.current) do
						if i == #multibox.current then
							str = str..v
						else
							str = str..v..", "
						end
					end
				else
					for i,v in pairs(multibox.current) do
						str = str..v
					end
				end
				value.Text = str
				value.TextColor3 = self.library.theme.accent
				ts:Create(value, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				ddoptiontitle.TextColor3 = self.library.theme.accent
				table.insert(self.library.themeitems["accent"]["TextColor3"],ddoptiontitle)
				multibox.callback(multibox.current)
			else
				table.remove(multibox.current,find)
				local str = ""
				if #multibox.current > 1 then
					for i,v in pairs(multibox.current) do
						if i == #multibox.current then
							str = str..v
						else
							str = str..v..", "
						end
					end
				else
					for i,v in pairs(multibox.current) do
						str = str..v
					end
				end
				value.Text = str
				value.TextColor3 = self.library.theme.accent
				ts:Create(value, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				ddoptiontitle.TextColor3 = Color3.fromRGB(255,255,255)
				multibox.callback(multibox.current)
			end
		end)
	end
	--
	dropdownbutton.MouseButton1Down:Connect(function()
		multibox.library:closewindows(multibox)
		for i,v in pairs(multibox.titles) do
			if v.TextColor3 ~= Color3.fromRGB(255,255,255) then
				v.TextColor3 = self.library.theme.accent
			end
		end
		multibox.open = not multibox.open
		if multibox.open then
			indicator.Text = "-"
			openlist()
		else
			indicator.Text = "+"
			closelist()
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = multibox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = value
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(multibox, multiboxs)
	multibox.holder = multiboxholder
	if props.visible == false or props.Visible == false then multiboxholder.Visible = false end
	return multibox
end
--
function buttonboxs:set(value)
	if value ~= nil then
		local dropdown = self
		if table.find(dropdown.options,value) then
			self.current = tostring(value)
			self.callback(tostring(value))
		end
	end
end
--
function multiboxs:set(tbl)
	if tbl then
		local multibox = self
		if typeof(tbl) == "table" then
			multibox.current = {}
			for i,v in pairs(tbl) do
				if table.find(multibox.options,v) then
					table.insert(multibox.current,v)
				end
			end
			--
			for i,v in pairs(multibox.titles) do
				if v.TextColor3 == multibox.library.theme.accent then
					v.TextColor3 = Color3.fromRGB(255,255,255)
				end
				if table.find(tbl,v.Text) then
					v.TextColor3 = multibox.library.theme.accent
				end
			end
			--
			local str = ""
			if #multibox.current > 1 then
				for i,v in pairs(multibox.current) do
					if i == #multibox.current then
						str = str..v
					else
						str = str..v..", "
					end
				end
			else
				for i,v in pairs(multibox.current) do
					str = str..v
				end
			end
			--
			multibox.value.Text = str
		end
	end
end
--
function sections:textbox(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local placeholder = props.placeholder or props.Placeholder or props.placeHolder or props.PlaceHolder or props.placeholdertext or props.PlaceHolderText or props.PlaceHoldertext or props.placeHolderText or props.placeHoldertext or props.Placeholdertext or props.PlaceholderText or props.placeholderText or ""
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local textbox = {}
	-- // main
	local textboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = textboxholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	local gradient = utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = textboxholder
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = textboxholder
		}
	)
	--
	local tbox = utility.new(
		"TextBox",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,15),
			PlaceholderText = placeholder,
			Text = def,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextTruncate = "AtEnd",
			Font = self.library.font,
			Parent = textboxholder
		}
	)
	-- // textbox tbl
	textbox = {
		["library"] = self.library,
		["tbox"] = tbox,
		["current"] = def,
		["callback"] = callback
	}
	--
	button.MouseButton1Down:Connect(function()
		tbox:CaptureFocus()
	end)
	--
	tbox.Focused:Connect(function()
		outline.BorderColor3 = self.library.theme.accent
		table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
	end)
	--
	tbox.FocusLost:Connect(function(enterPressed)
		textbox.current = tbox.Text
		callback(tbox.Text)
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = textbox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = tbox
	-- // metatable indexing + return
	setmetatable(textbox, textboxs)
	textbox.holder = textboxholder
	if props.visible == false or props.Visible == false then textboxholder.Visible = false end
	return textbox
end
--
function textboxs:set(value)
	self.tbox.Text = value
	self.current = value
	self.callback(value)
end
--
function sections:keybind(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or nil
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local allowed = props.allowed or props.Allowed or 1
	local mode = props.mode or props.Mode or props.defaultmode or props.Defaultmode or props.DefaultMode or "hotkey"
	mode = utility.removespaces(tostring(mode):lower())
	if mode ~= "hotkey" and mode ~= "toggle" and mode ~= "always" then
		mode = "hotkey"
	end
	--
	local default = ".."
	local typeis = nil
	--
	if typeof(def) == "EnumItem" then
		if def == Enum.UserInputType.MouseButton1 then
			if allowed == 1 then
				default = "MB1"
				typeis = "UserInputType"
			end
		elseif def == Enum.UserInputType.MouseButton2 then
			if allowed == 1 then
				default = "MB2"
				typeis = "UserInputType"
			end
		elseif def == Enum.UserInputType.MouseButton3 then
			if allowed == 1 then
				default = "MB3"
				typeis = "UserInputType"
			end
		else
			local capd = utility.capatalize(def.Name)
			if #capd > 1 then
				default = capd
			else
				default = def.Name
			end
			typeis = "KeyCode"
		end
	end
	-- // variables
	local keybind = {}
	-- // main
	local keybindholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,17),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,40,1,0),
			Position = UDim2.new(1,0,0,0),
			Parent = keybindholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local value = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = default,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = outline
		}
	)
	--
	outline.Size = UDim2.new(0,value.TextBounds.X+20,1,0)
	--
	value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		outline.Size = UDim2.new(0,value.TextBounds.X+20,1,0)
	end)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = keybindholder
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = keybindholder
		}
	)
	-- // keybind tbl
	keybind = {
		["library"] = self.library,
		["down"] = false,
		["outline"] = outline,
		["value"] = value,
		["allowed"] = allowed,
		["current"] = {typeis,utility.splitenum(def)},
		["mode"] = mode,
		["state"] = (mode == "always"),
		["open"] = false,
		["callback"] = callback
	}
	-- // mode popup
	local modenames = {"on hotkey","on toggle","always on"}
	local modeids = {"hotkey","toggle","always"}
	--
	local modeholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,90,0,56),
			Position = UDim2.new(1,0,1,4),
			Visible = false,
			ZIndex = 7,
			Parent = keybindholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			VerticalAlignment = "Center",
			Parent = modeholder
		}
	)
	--
	local modebuttons = {}
	--
	for i,mname in pairs(modenames) do
		local mbtn = utility.new(
			"TextButton",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,16),
				Font = self.library.font,
				Text = mname,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				ZIndex = 8,
				Parent = modeholder
			}
		)
		--
		self.library.labels[#self.library.labels+1] = mbtn
		--
		modebuttons[modeids[i]] = mbtn
	end
	--
	local function refreshmodes()
		for id,btn in pairs(modebuttons) do
			if id == keybind.mode then
				btn.TextColor3 = self.library.theme.accent
			else
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
	--
	refreshmodes()
	--
	for id,btn in pairs(modebuttons) do
		btn.MouseButton1Down:Connect(function()
			keybind.mode = id
			keybind.open = false
			modeholder.Visible = false
			refreshmodes()
			if id == "always" then
				keybind.state = true
				keybind.callback(true)
			else
				keybind.state = false
				keybind.callback(false)
			end
		end)
	end
	--
	local function turn(typeis,current)
		outline.Size = UDim2.new(0,value.TextBounds.X+20,1,0)
		keybind.down = false
		keybind.current = {typeis,utility.splitenum(current)}
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end
	--
	local function unbind()
		keybind.down = false
		keybind.current = {nil,nil}
		keybind.state = false
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
		value.Text = ".."
		outline.Size = UDim2.new(0,value.TextBounds.X+20,1,0)
		keybind.callback(false)
	end
	--
	local function kmatch(Input)
		if keybind.current[1] == "KeyCode" then
			return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == keybind.current[2]
		elseif keybind.current[1] == "UserInputType" then
			return Input.UserInputType.Name == keybind.current[2]
		end
		return false
	end
	--
	button.MouseButton1Down:Connect(function()
		if keybind.down == false then
			keybind.open = false
			modeholder.Visible = false
			outline.BorderColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
			wait()
			keybind.down = true
		end
	end)
	--
	button.MouseButton2Down:Connect(function()
		if keybind.down == false then
			keybind.open = not keybind.open
			modeholder.Visible = keybind.open
		end
	end)
	--
	uis.InputBegan:Connect(function(Input,gpe)
		if keybind.down then
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if Input.KeyCode == Enum.KeyCode.Escape then
					unbind()
				else
					local capd = utility.capatalize(Input.KeyCode.Name)
					if #capd > 1 then
						value.Text = capd
					else
						value.Text = Input.KeyCode.Name
					end
					turn("KeyCode",Input.KeyCode)
					keybind.callback(Input.KeyCode)
				end
			elseif allowed == 1 then
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					value.Text = "MB1"
					turn("UserInputType",Enum.UserInputType.MouseButton1)
					keybind.callback(Enum.UserInputType.MouseButton1)
				elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
					value.Text = "MB2"
					turn("UserInputType",Enum.UserInputType.MouseButton2)
					keybind.callback(Enum.UserInputType.MouseButton2)
				elseif Input.UserInputType == Enum.UserInputType.MouseButton3 then
					value.Text = "MB3"
					turn("UserInputType",Enum.UserInputType.MouseButton3)
					keybind.callback(Enum.UserInputType.MouseButton3)
				end
			end
		else
			if gpe then return end
			if keybind.mode == "always" then return end
			if keybind.current[1] and kmatch(Input) then
				if keybind.mode == "hotkey" then
					keybind.state = true
					keybind.callback(true)
				elseif keybind.mode == "toggle" then
					keybind.state = not keybind.state
					keybind.callback(keybind.state)
				end
			end
		end
	end)
	--
	uis.InputEnded:Connect(function(Input)
		if keybind.down == false and keybind.mode == "hotkey" and keybind.current[1] then
			if kmatch(Input) and keybind.state then
				keybind.state = false
				keybind.callback(false)
			end
		end
	end)
	--
	if keybind.mode == "always" then
		keybind.callback(true)
	end
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = keybind
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = value
	-- // metatable indexing + return
	setmetatable(keybind, keybinds)
	keybind.holder = keybindholder
	if props.visible == false or props.Visible == false then keybindholder.Visible = false end
	return keybind
end
--
function keybinds:set(key)
	if key then
		if typeof(key) == "EnumItem" or typeof(key) == "table" then
			if typeof(key) == "table" then
				if key[1] and key[2] then
					key = Enum[key[1]][key[2]]
				else
					return
				end
			end
			local keybind = self
			local typeis = ""
			--
			local default = ".."
			--
			if key == Enum.UserInputType.MouseButton1 then
				if keybind.allowed == 1 then
					default = "MB1"
					typeis = "UserInputType"
				end
			elseif key == Enum.UserInputType.MouseButton2 then
				if keybind.allowed == 1 then
					default = "MB2"
					typeis = "UserInputType"
				end
			elseif key == Enum.UserInputType.MouseButton3 then
				if keybind.allowed == 1 then
					default = "MB3"
					typeis = "UserInputType"
				end
			else
				local capd = utility.capatalize(key.Name)
				if #capd > 1 then
					default = capd
				else
					default = key.Name
				end
				typeis = "KeyCode"
			end
			--
			keybind.value.Text = default
			keybind.current = {typeis,utility.splitenum(key)}
			keybind.callback(keybind.current)
			keybind.outline.Size = UDim2.new(0,keybind.value.TextBounds.X+20,1,0)
			--
			if keybind.down then
				keybind.down = false
				keybind.outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
				local find = table.find(self.library.themeitems["accent"]["BorderColor3"],keybind.outline)
				if find then
					table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
				end
			end
		end
	end
end
--
function sections:colorpicker(props)
	-- // properties
	local name = props.name or props.Name or "new colorpicker"
	local cpname = props.cpname or props.Cpname or props.CPname or props.CPName or props.cPname or props.cpName or props.colorpickername or nil
	local def = props.def or props.Def or props.default or props.Default or Color3.fromRGB(255,255,255)
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	--
	local h,s,v = def:ToHSV()
	-- // variables
	local colorpicker = {}
	-- // main
	local colorpickerholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,30,1,0),
			Position = UDim2.new(1,0,0,0),
			Parent = colorpickerholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local cpcolor = utility.new(
		"Frame",
		{
			BackgroundColor3 = def,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = cpcolor
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = colorpickerholder
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = colorpickerholder
		}
	)
	--
	local cpholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,40,0,232),
			Position = UDim2.new(0,-20,1,5),
			Visible = false,
			ZIndex = 5,
			Parent = colorpickerholder
		}
	)
	--
	local cpcatcher = utility.new(
		"TextButton",
		{
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Text = "",
			ZIndex = 4,
			Parent = cpholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = cpholder
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	local cptitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = cpname or name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	local cpholder2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.875,0,0,150),
			Position = UDim2.new(0,5,0,20),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	local outline3 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromHSV(h,1,1),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = cpholder2
		}
	)
	--
	local cpimage = utility.new(
		"ImageButton",
		{
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Image = "rbxassetid://7074305282",
			Parent = outline3
		}
	)
	--
	local cpcursor = utility.new(
		"ImageLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0,6,0,6),
			Position = UDim2.new(s,0,1-v,0),
			ZIndex = 5,
			Image = "rbxassetid://7074391319",
			Parent = cpimage
		}
	)
	--
	local huepicker = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.05,0,0,150),
			Position = UDim2.new(1,-5,0,20),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	local outline4 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = huepicker
		}
	)
	--
	local huebutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			ZIndex = 5,
			Parent = huepicker
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 153, 0)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(209, 255, 0)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(55, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 102)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 102, 255)), ColorSequenceKeypoint.new(0.70, Color3.fromRGB(51, 0, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(204, 0, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 153)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},
			Rotation = 90,
			Parent = outline4
		}
	)
	--
	local huecursor = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,12,0,6),
			Position = UDim2.new(0.5,0,h,0),
			ZIndex = 5,
			Parent = outline4
		}
	)
	--
	local huecursor_inline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromHSV(h,1,1),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ZIndex = 5,
			Parent = huecursor
		}
	)
	--
	local function textbox(parent,size,position)
		local textbox_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = position,
				Size = size,
				ZIndex = 5,
				Parent = parent
			}
		)
		--
		local outline5 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local outline6 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = outline5
			}
		)
		--
		local color2 = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 5,
				Parent = outline6
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = color2
			}
		)
		--
		local tbox = utility.new(
			"TextBox",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0.5,0,0,0),
				PlaceholderColor3 = Color3.fromRGB(255,255,255),
				PlaceholderText = "",
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local tbox_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		tbox_button.MouseButton1Down:Connect(function()
			tbox:CaptureFocus()
		end)
		--
		return {textbox_holder,tbox,outline5}
	end
	--
	-- // alpha bar
	local alphaholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.875,0,0,16),
			Position = UDim2.new(0,5,0,178),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	utility.new(
		"ImageLabel",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Image = "rbxassetid://18274452449",
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.new(0,10,0,10),
			ZIndex = 5,
			Parent = alphaholder
		}
	)
	--
	local alphacolor = utility.new(
		"Frame",
		{
			BackgroundColor3 = def,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 6,
			Parent = alphaholder
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)},
			Parent = alphacolor
		}
	)
	--
	local alphabutton = utility.new(
		"TextButton",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Text = "",
			ZIndex = 7,
			Parent = alphaholder
		}
	)
	--
	local alphacursor = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,4,1,2),
			Position = UDim2.new(1,0,0.5,0),
			ZIndex = 8,
			Parent = alphaholder
		}
	)
	-- // preview swatch
	local previewholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.05,0,0,16),
			Position = UDim2.new(1,-5,0,178),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	utility.new(
		"ImageLabel",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Image = "rbxassetid://18274452449",
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.new(0,10,0,10),
			ZIndex = 5,
			Parent = previewholder
		}
	)
	--
	local preview = utility.new(
		"Frame",
		{
			BackgroundColor3 = def,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 6,
			Parent = previewholder
		}
	)
	-- // rainbow toggle
	local rainbowholder = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,14,0,14),
			Position = UDim2.new(0,5,0,205),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	local rainbowfill = utility.new(
		"Frame",
		{
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Visible = false,
			ZIndex = 6,
			Parent = rainbowholder
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = rainbowfill
		}
	)
	--
	local rainbowbutton = utility.new(
		"TextButton",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Text = "",
			ZIndex = 7,
			Parent = rainbowholder
		}
	)
	--
	local rainbowlabel = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(0,80,0,14),
			Position = UDim2.new(0,24,0,205),
			Font = self.library.font,
			Text = "Rainbow",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	self.library.labels[#self.library.labels+1] = rainbowlabel
	-- // copy + paste buttons
	local function popbutton(text,xoffset)
		local h = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(1,0),
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Size = UDim2.new(0,62,0,18),
				Position = UDim2.new(1,xoffset,0,203),
				ZIndex = 5,
				Parent = outline2
			}
		)
		local o = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = h
			}
		)
		local b = utility.new(
			"TextButton",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Font = self.library.font,
				Text = text,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				ZIndex = 6,
				Parent = h
			}
		)
		self.library.labels[#self.library.labels+1] = b
		return o,b
	end
	--
	local copyoutline,copybtn = popbutton("Copy",-72)
	local pasteoutline,pastebtn = popbutton("Paste",-5)
	-- // colorpicker tbl
	colorpicker = {
		["library"] = self.library,
		["cpholder"] = cpholder,
		["cpcolor"] = cpcolor,
		["huecursor"] = huecursor,
		["outline3"] = outline3,
		["huecursor_inline"] = huecursor_inline,
		["cpcursor"] = cpcursor,
		["alphacolor"] = alphacolor,
		["alphacursor"] = alphacursor,
		["preview"] = preview,
		["current"] = def,
		["open"] = false,
		["cp"] = false,
		["hue"] = false,
		["alphadrag"] = false,
		["rainbow"] = false,
		["hsv"] = {h,s,v},
		["alpha"] = 1,
		["callback"] = callback
	}
	--
	table.insert(self.library.colorpickers,colorpicker)
	--
	local function updateboxes()
		alphacolor.BackgroundColor3 = colorpicker.current
		preview.BackgroundColor3 = colorpicker.current
		preview.BackgroundTransparency = 1 - colorpicker.alpha
		alphacursor.Position = UDim2.new(colorpicker.alpha,0,0.5,0)
	end
	--
	updateboxes()
	--
	local function movehue()
		local posy = math.clamp(plr:GetMouse().Y-outline3.AbsolutePosition.Y,0,outline3.AbsoluteSize.Y)
		local resy = (1/outline3.AbsoluteSize.Y)*posy
		outline3.BackgroundColor3 = Color3.fromHSV(resy,1,1)
		huecursor_inline.BackgroundColor3 = Color3.fromHSV(resy,1,1)
		colorpicker.hsv[1] = resy
		colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
		cpcolor.BackgroundColor3 = colorpicker.current
		updateboxes()
		colorpicker.callback(colorpicker.current, colorpicker.alpha)
		huecursor:TweenPosition(UDim2.new(0.5,0,resy,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
	end
	--
	local function movecp()
		local posx,posy = math.clamp(plr:GetMouse().X-outline3.AbsolutePosition.X,0,outline3.AbsoluteSize.X),math.clamp(plr:GetMouse().Y-outline3.AbsolutePosition.Y,0,outline3.AbsoluteSize.Y)
		local resx,resy = (1/outline3.AbsoluteSize.X)*posx,(1/outline3.AbsoluteSize.Y)*posy
		colorpicker.hsv[2] = resx
		colorpicker.hsv[3] = 1-resy
		colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
		cpcolor.BackgroundColor3 = colorpicker.current
		updateboxes()
		colorpicker.callback(colorpicker.current, colorpicker.alpha)
		cpcursor:TweenPosition(UDim2.new(resx,0,resy,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
	end
	--
	local function movealpha()
		local posx = math.clamp(plr:GetMouse().X-alphaholder.AbsolutePosition.X,0,alphaholder.AbsoluteSize.X)
		colorpicker.alpha = (1/alphaholder.AbsoluteSize.X)*posx
		alphacolor.BackgroundColor3 = colorpicker.current
		preview.BackgroundTransparency = 1 - colorpicker.alpha
		alphacursor.Position = UDim2.new(colorpicker.alpha,0,0.5,0)
		colorpicker.callback(colorpicker.current, colorpicker.alpha)
	end
	--
	button.MouseButton1Down:Connect(function()
		self.library:closewindows(colorpicker)
		cpholder.Visible = not colorpicker.open
		colorpicker.open = not colorpicker.open
	end)
	--
	uis.InputBegan:Connect(function(input)
		if colorpicker.open and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			if cpholder.Parent == nil then
				return
			end
			local m = uis:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
			local function inside(gui)
				local p,s = gui.AbsolutePosition,gui.AbsoluteSize
				return m.X >= p.X and m.X <= p.X+s.X and m.Y >= p.Y and m.Y <= p.Y+s.Y
			end
			if not inside(cpholder) and not inside(button) then
				cpholder.Visible = false
				colorpicker.open = false
			end
		end
	end)
	--
	huebutton.MouseButton1Down:Connect(function()
		colorpicker.hue = true
		movehue()
	end)
	--
	cpimage.MouseButton1Down:Connect(function()
		colorpicker.cp = true
		movecp()
	end)
	--
	uis.InputChanged:Connect(function()
		if colorpicker.cp then
			movecp()
		end
		if colorpicker.hue then
			movehue()
		end
		if colorpicker.alphadrag then
			movealpha()
		end
	end)
	--
	uis.InputEnded:Connect(function(Input)
		if Input.UserInputType.Name == 'MouseButton1'  then
			if colorpicker.cp then
				colorpicker.cp = false
			end
			if colorpicker.hue then
				colorpicker.hue = false
			end
			if colorpicker.alphadrag then
				colorpicker.alphadrag = false
			end
		end
	end)
	--
	alphabutton.MouseButton1Down:Connect(function()
		colorpicker.alphadrag = true
		movealpha()
	end)
	--
	local rainbowconn
	local function setrainbow(on)
		colorpicker.rainbow = on
		rainbowfill.Visible = on
		if on then
			if not rainbowconn then
				rainbowconn = rs.RenderStepped:Connect(function()
					colorpicker.hsv[1] = (tick()*0.4) % 1
					colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
					outline3.BackgroundColor3 = Color3.fromHSV(colorpicker.hsv[1],1,1)
					huecursor_inline.BackgroundColor3 = Color3.fromHSV(colorpicker.hsv[1],1,1)
					cpcolor.BackgroundColor3 = colorpicker.current
					alphacolor.BackgroundColor3 = colorpicker.current
					preview.BackgroundColor3 = colorpicker.current
					huecursor.Position = UDim2.new(0.5,0,colorpicker.hsv[1],0)
					colorpicker.callback(colorpicker.current, colorpicker.alpha)
				end)
				table.insert(self.library.connections,rainbowconn)
			end
		else
			if rainbowconn then
				rainbowconn:Disconnect()
				rainbowconn = nil
			end
		end
	end
	--
	colorpicker.setrainbow = setrainbow
	--
	rainbowbutton.MouseButton1Down:Connect(function()
		setrainbow(not colorpicker.rainbow)
	end)
	--
	copybtn.MouseButton1Down:Connect(function()
		self.library.copiedcolor = colorpicker.current
		self.library.copiedalpha = colorpicker.alpha
		self.library.copiedrainbow = colorpicker.rainbow
		copyoutline.BorderColor3 = self.library.theme.accent
		wait(0.05)
		copyoutline.BorderColor3 = Color3.fromRGB(56, 56, 56)
	end)
	--
	pastebtn.MouseButton1Down:Connect(function()
		if self.library.copiedcolor then
			colorpicker.alpha = self.library.copiedalpha or 1
			colorpicker:set(self.library.copiedcolor)
			setrainbow(self.library.copiedrainbow or false)
		end
		pasteoutline.BorderColor3 = self.library.theme.accent
		wait(0.05)
		pasteoutline.BorderColor3 = Color3.fromRGB(56, 56, 56)
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = colorpicker
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = cptitle
	-- // metatable indexing + return
	setmetatable(colorpicker, colorpickers)
	colorpicker.holder = colorpickerholder
	if props.visible == false or props.Visible == false then colorpickerholder.Visible = false end
	return colorpicker
end
--
function colorpickers:set(color,alpha)
	if color then
		if typeof(color) == "table" then
			color = Color3.fromRGB(color[1]*255,color[2]*255,color[3]*255)
		end
		local colorpicker = self
		local h,s,v = color:ToHSV()
		colorpicker.hsv = {h,s,v}
		if alpha ~= nil then colorpicker.alpha = alpha end
		colorpicker.current = Color3.fromHSV(h,s,v)
		colorpicker.outline3.BackgroundColor3 = Color3.fromHSV(h,1,1)
		colorpicker.huecursor_inline.BackgroundColor3 = Color3.fromHSV(h,1,1)
		colorpicker.cpcolor.BackgroundColor3 = colorpicker.current
		colorpicker.alphacolor.BackgroundColor3 = colorpicker.current
		colorpicker.preview.BackgroundColor3 = colorpicker.current
		colorpicker.preview.BackgroundTransparency = 1 - colorpicker.alpha
		colorpicker.huecursor:TweenPosition(UDim2.new(0.5,0,h,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
		colorpicker.cpcursor:TweenPosition(UDim2.new(s,0,1-v,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
		colorpicker.alphacursor.Position = UDim2.new(colorpicker.alpha,0,0.5,0)
		colorpicker.callback(colorpicker.current, colorpicker.alpha)
	end
end
--
function sections:configloader(props)
	-- // properties
	local folder = props.folder or props.Folder
	-- // variables
	local configloader = {}
	-- // main
	local clholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,222),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = clholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,3),
			Font = self.library.font,
			Text = "configs",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = outline
		}
	)
	--
	self.library.labels[#self.library.labels+1] = title
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-6,0,1),
			Position = UDim2.new(0.5,0,0,19),
			Parent = outline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	local buttonsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,64),
			Position = UDim2.new(0,0,0,150),
			Parent = outline
		}
	)
	--
	local configsholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-10,0,120),
			Position = UDim2.new(0.5,0,0,25),
			Parent = outline
		}
	)
	--
	local outline3 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = configsholder
		}
	)
	--
	local outline4 = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			Parent = outline3
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,0),
			Parent = outline4
		}
	)
	--
	local createdbuttons = {}
	local selected
	--
	local makebutton = function(name,toggled)
		local createdbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Position = UDim2.new(0,0,0,0),
				Text = "",
				Parent = outline4
			}
		)
		--
		local grey = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundColor3 = Color3.fromRGB(125, 125, 125),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Size = UDim2.new(1,-4,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Visible = false,
				Parent = createdbutton
			}
		)
		--
		local createdtitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,	
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				Parent = createdbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = createdtitle
		--
		local createdb = {
			["button"] = createdbutton,
			["grey"] = grey,
			["title"] = createdtitle,
			["name"] = name
		}
		--
		table.insert(createdbuttons,createdb)
		--
		if toggled then
			createdb.grey.Visible = true
			createdb.title.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],createdb.title)
			selected = createdb
		end
		--
		createdbutton.MouseButton1Down:Connect(function()
			for i,v in pairs(createdbuttons) do
				if v ~= createdb then
					v.grey.Visible = false
					v.title.TextColor3 = Color3.fromRGB(255,255,255)
					local find = table.find(self.library.themeitems["accent"]["TextColor3"],v.title)
					if find then
						table.remove(self.library.themeitems["accent"]["TextColor3"],find)
					end
				end
			end
			--
			createdb.grey.Visible = true
			createdb.title.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],createdb.title)
			selected = createdb
		end)
	end
	--
	local newbutton = function(parent,name)
		local button_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = parent
			}
		)
		--
		local button_outline = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = button_holder
			}
		)
		--
		local button_outline2 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = button_outline
			}
		)
		--
		local button_color = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 5,
				Parent = button_outline2
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = button_color
			}
		)
		--
		local button_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = button_holder
			}
		)
		--
		self.library.labels[#self.library.labels+1] = button_button
		--
		return {button_holder,button_outline,button_button}
	end
	--
	local function textbox(parent)
		local textbox_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = parent
			}
		)
		--
		local outline5 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local outline6 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = outline5
			}
		)
		--
		local color2 = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 5,
				Parent = outline6
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = color2
			}
		)
		--
		local tbox = utility.new(
			"TextBox",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0.5,0,0,0),
				PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
				PlaceholderText = "",
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local tbox_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		tbox_button.MouseButton1Down:Connect(function()
			tbox:CaptureFocus()
		end)
		--
		return {textbox_holder,tbox,outline5}
	end
	--
	local refresh = function()
		for i,v in pairs(createdbuttons) do
			v.button:Remove()
			v.grey:Remove()
			v.title:Remove()
		end
		createdbuttons = {}
		for i,v in pairs(listfiles(folder)) do
			if v:sub(-4) == ".cfg" then
				local nm = v:gsub("\\","/"):match("([^/]+)%.cfg$") or v:sub(#tostring(folder)+1, -5)
				makebutton(nm, i == 1)
			end
		end
	end
	--
	refresh()
	--
	local name = textbox(buttonsholder)
	local load = newbutton(buttonsholder,"Load")
	local delete = newbutton(buttonsholder,"Delete")
	local save = newbutton(buttonsholder,"Save")
	local create = newbutton(buttonsholder,"Create")
	--
	name[1].Size = UDim2.new(1,-10,0,20)
	load[1].Size = UDim2.new(0.5,-6,0,20)
	delete[1].Size = UDim2.new(0.5,-6,0,20)
	save[1].Size = UDim2.new(0.5,-6,0,20)
	create[1].Size = UDim2.new(0.5,-6,0,20)
	--
	name[1].Position = UDim2.new(0.5,0,0,0)
	name[1].AnchorPoint = Vector2.new(0.5,0)
	--
	load[1].Position = UDim2.new(0,5,0,22)
	load[1].AnchorPoint = Vector2.new(0,0)
	--
	delete[1].Position = UDim2.new(1,-5,0,22)
	delete[1].AnchorPoint = Vector2.new(1,0)
	--
	save[1].Position = UDim2.new(0,5,0,44)
	save[1].AnchorPoint = Vector2.new(0,0)
	--
	create[1].Position = UDim2.new(1,-5,0,44)
	create[1].AnchorPoint = Vector2.new(1,0)
	--
	name[2].PlaceholderText = "Name"
	--
	local currentname = nil
	--
	name[2].Focused:Connect(function()
		name[3].BorderColor3 = self.library.theme.accent
	end)
	--
	name[2].FocusLost:Connect(function()
		local saved = name[2].Text
		if #saved >= 3 and #saved <= 15 then
			currentname = saved
		else
			name[2].Text = ""
			currentname = nil
		end
		name[3].BorderColor3 = Color3.fromRGB(12,12,12)
	end)
	--
	load[3].MouseButton1Down:Connect(function()
		self.library:loadconfig(folder..selected.name..".cfg")
		load[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		load[2].BorderColor3 = Color3.fromRGB(12,12,12)
	end)
	--
	delete[3].MouseButton1Down:Connect(function()
		delfile(folder..selected.name..".cfg")
		delete[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		delete[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait()
		refresh()
	end)
	--
	save[3].MouseButton1Down:Connect(function()
		writefile(folder..selected.name..".cfg", self.library:saveconfig())
		save[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		save[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait()
		refresh()
	end)
	--
	create[3].MouseButton1Down:Connect(function()
		writefile(folder..currentname..".cfg", self.library:saveconfig())
		create[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		create[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait()
		refresh()
	end)
	-- // button tbl
	configloader = {
		["library"] = self.library
	}
	-- // metatable indexing + return
	setmetatable(configloader, configloaders)
	return configloader 
end
--
function sections:playerlist(props)
	-- // properties
	local props = props or {}
	local name = props.name or props.Name or "Players"
	local height = props.height or props.Height or props.size or props.Size or 250
	local callback = props.callback or props.Callback or props.callBack or props.CallBack or function()end
	-- // variables
	local playerlist = {}
	local rows = {}
	-- // main
	local plholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,height),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = plholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,3),
			Font = self.library.font,
			Text = name:lower(),
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = outline
		}
	)
	--
	self.library.labels[#self.library.labels+1] = title
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-6,0,1),
			Position = UDim2.new(0.5,0,0,19),
			Parent = outline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	-- // search
	local searchholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,25),
			Parent = outline
		}
	)
	--
	local searchoutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = searchholder
		}
	)
	--
	local search = utility.new(
		"TextBox",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-8,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Font = self.library.font,
			PlaceholderText = "search..",
			PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClearTextOnFocus = false,
			Parent = searchholder
		}
	)
	--
	self.library.labels[#self.library.labels+1] = search
	-- // list
	local listholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-10,1,-56),
			Position = UDim2.new(0.5,0,0,50),
			Parent = outline
		}
	)
	--
	local listoutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = listholder
		}
	)
	--
	local scroll = utility.new(
		"ScrollingFrame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			ClipsDescendants = true,
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			Parent = listoutline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,0),
			Parent = scroll
		}
	)
	-- // playerlist tbl
	playerlist = {
		["library"] = self.library,
		["callback"] = callback,
		["rows"] = rows
	}
	-- // row builder
	local makerow = function(player)
		local rowbutton = utility.new(
			"TextButton",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				Parent = scroll
			}
		)
		--
		local grey = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1,-4,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Parent = rowbutton
			}
		)
		--
		local rowtitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0,0.5),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-72,1,0),
				Position = UDim2.new(0,8,0.5,0),
				Font = self.library.font,
				Text = player.Name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				TextTruncate = "AtEnd",
				Parent = rowbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = rowtitle
		--
		local prio = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(1,0.5),
				BackgroundTransparency = 1,
				Size = UDim2.new(0,40,1,0),
				Position = UDim2.new(1,-22,0.5,0),
				Font = self.library.font,
				Text = "",
				TextColor3 = Color3.fromRGB(150,150,150),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Right",
				Visible = false,
				Parent = rowbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = prio
		--
		local checkoutline = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(1,0.5),
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Size = UDim2.new(0,10,0,10),
				Position = UDim2.new(1,-8,0.5,0),
				Parent = rowbutton
			}
		)
		--
		local check = utility.new(
			"Frame",
			{
				BackgroundColor3 = self.library.theme.accent,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				Visible = false,
				Parent = checkoutline
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = check
			}
		)
		--
		local row = {
			["player"] = player,
			["button"] = rowbutton,
			["grey"] = grey,
			["title"] = rowtitle,
			["prio"] = prio,
			["check"] = check
		}
		-- // draw helper (reflects whitelist state on the row)
		local function draw()
			local entry = self.library.whitelist[player.UserId]
			if entry then
				check.Visible = true
				prio.Visible = true
				prio.Text = entry.priority
				if not table.find(self.library.themeitems["accent"]["TextColor3"],rowtitle) then
					rowtitle.TextColor3 = self.library.theme.accent
					table.insert(self.library.themeitems["accent"]["TextColor3"],rowtitle)
				end
				if not table.find(self.library.themeitems["accent"]["BackgroundColor3"],check) then
					check.BackgroundColor3 = self.library.theme.accent
					table.insert(self.library.themeitems["accent"]["BackgroundColor3"],check)
				end
				if entry.priority == "high" then
					prio.TextColor3 = self.library.theme.accent
					if not table.find(self.library.themeitems["accent"]["TextColor3"],prio) then
						table.insert(self.library.themeitems["accent"]["TextColor3"],prio)
					end
				else
					prio.TextColor3 = Color3.fromRGB(150,150,150)
					local f = table.find(self.library.themeitems["accent"]["TextColor3"],prio)
					if f then table.remove(self.library.themeitems["accent"]["TextColor3"],f) end
				end
			else
				check.Visible = false
				prio.Visible = false
				rowtitle.TextColor3 = Color3.fromRGB(255,255,255)
				local f1 = table.find(self.library.themeitems["accent"]["TextColor3"],rowtitle)
				if f1 then table.remove(self.library.themeitems["accent"]["TextColor3"],f1) end
				local f2 = table.find(self.library.themeitems["accent"]["BackgroundColor3"],check)
				if f2 then table.remove(self.library.themeitems["accent"]["BackgroundColor3"],f2) end
				local f3 = table.find(self.library.themeitems["accent"]["TextColor3"],prio)
				if f3 then table.remove(self.library.themeitems["accent"]["TextColor3"],f3) end
			end
		end
		--
		draw()
		--
		rowbutton.MouseEnter:Connect(function()
			ts:Create(grey, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.92}):Play()
		end)
		--
		rowbutton.MouseLeave:Connect(function()
			ts:Create(grey, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		end)
		-- // left click = toggle whitelist (defaults to low priority)
		rowbutton.MouseButton1Down:Connect(function()
			if self.library.whitelist[player.UserId] then
				self.library.whitelist[player.UserId] = nil
				draw()
				callback(player,false,nil)
			else
				self.library.whitelist[player.UserId] = {["name"] = player.Name, ["userid"] = player.UserId, ["priority"] = "low"}
				draw()
				callback(player,true,"low")
			end
		end)
		-- // right click = cycle priority low <-> high
		rowbutton.MouseButton2Down:Connect(function()
			local entry = self.library.whitelist[player.UserId]
			if not entry then return end
			entry.priority = (entry.priority == "low") and "high" or "low"
			draw()
			callback(player,true,entry.priority)
		end)
		--
		table.insert(rows,row)
	end
	-- // refresh
	local refresh = function()
		for i,v in pairs(rows) do
			local find = table.find(self.library.themeitems["accent"]["TextColor3"],v.title)
			if find then
				table.remove(self.library.themeitems["accent"]["TextColor3"],find)
			end
			local find2 = table.find(self.library.themeitems["accent"]["BackgroundColor3"],v.check)
			if find2 then
				table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find2)
			end
			local find3 = table.find(self.library.themeitems["accent"]["TextColor3"],v.prio)
			if find3 then
				table.remove(self.library.themeitems["accent"]["TextColor3"],find3)
			end
			v.button:Destroy()
		end
		rows = {}
		playerlist.rows = rows
		--
		local query = utility.removespaces(tostring(search.Text):lower())
		for i,v in pairs(plrs:GetPlayers()) do
			if v ~= plr then
				if query == "" or v.Name:lower():find(query,1,true) or v.DisplayName:lower():find(query,1,true) then
					makerow(v)
				end
			end
		end
	end
	--
	playerlist.refresh = refresh
	--
	refresh()
	-- // connections
	table.insert(self.library.connections, plrs.PlayerAdded:Connect(function()
		refresh()
	end))
	table.insert(self.library.connections, plrs.PlayerRemoving:Connect(function()
		task.wait()
		refresh()
	end))
	--
	search:GetPropertyChangedSignal("Text"):Connect(function()
		refresh()
	end)
	-- // metatable indexing + return
	setmetatable(playerlist, configloaders)
	return playerlist
end
--
function library:playerlist(props)
	local props = props or {}
	local name = props.name or props.Name or "Playerlist"
	local icon = props.icon or props.Icon or props.image or props.Image or nil
	local priorities = props.priorities or props.Priorities or {"Neutral","Low","High"}
	local callback = props.callback or props.Callback or function()end
	local buttonname = props.buttonname or props.ButtonName or props.button or props.Button or "Example Button!"
	local buttoncallback = props.buttoncallback or props.ButtonCallback or props.buttoncallBack or function()end
	-- // variables
	local playerlist = {}
	local rows = {}
	local selected = nil
	local W,H = 520,430
	-- // tab button
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,26,0,26),
			ZIndex = 11,
			Parent = self.tabsbuttons
		}
	)
	--
	local taboutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 11,
			Parent = tabbutton
		}
	)
	--
	local tabimage = utility.new(
		"ImageLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(0,16,0,16),
			Position = UDim2.new(0.5,0,0.5,0),
			Image = icon or "",
			ImageColor3 = Color3.fromRGB(200, 200, 200),
			Visible = icon ~= nil,
			ZIndex = 12,
			Parent = taboutline
		}
	)
	--
	local tablabel = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Font = self.font,
			Text = icon and "" or name:sub(1,1):upper(),
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			Visible = icon == nil,
			ZIndex = 12,
			Parent = taboutline
		}
	)
	--
	local tabclick = utility.new(
		"TextButton",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Text = "",
			ZIndex = 13,
			Parent = tabbutton
		}
	)
	--
	self.extratabs = (self.extratabs or 0) + 1
	local count = #self.pages + self.extratabs
	self.tabsbar.Size = UDim2.new(0, count*26 + (count-1)*3 + 10, 0, 37)
	self.labels[#self.labels+1] = tablabel
	-- // window chrome
	self.topdisplay = (self.topdisplay or 10000) + 1
	local fwgui = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = self.topdisplay,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Enabled = false,
			Parent = cre
		}
	)
	if (check_exploit == "Synapse" and syn.request) then
		syn.protect_gui(fwgui)
	end
	table.insert(self.floatingguis,fwgui)
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Active = true,
			Size = UDim2.new(0,W,0,H),
			Position = UDim2.new(0.5,540,0.5,0),
			Visible = false,
			Parent = fwgui
		}
	)
	--
	local scale = utility.new("UIScale",{Scale = 1, Parent = outline})
	--
	local glow = utility.new(
		"ImageLabel",
		{
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=18245826428",
			ImageColor3 = self.theme.accent,
			ImageTransparency = 0.8,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(21, 21, 79, 79),
			Position = UDim2.new(0,-20,0,-20),
			Size = UDim2.new(1,40,1,40),
			ZIndex = 0,
			Parent = outline
		}
	)
	--
	table.insert(self.themeitems["accent"]["ImageColor3"],glow)
	--
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline
		}
	)
	--
	local body = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline2
		}
	)
	--
	local wline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-8,0,1),
			Position = UDim2.new(0.5,0,0,3),
			ZIndex = 5,
			Parent = body
		}
	)
	--
	table.insert(self.themeitems["accent"]["BackgroundColor3"],wline)
	--
	local titletext = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-24,0,16),
			Position = UDim2.new(0,12,0,8),
			Font = self.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = body
		}
	)
	--
	self.labels[#self.labels+1] = titletext
	--
	utility.dragify(titletext,outline)
	-- // section box
	local sectionholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-16,1,-40),
			Position = UDim2.new(0.5,0,0,32),
			Parent = body
		}
	)
	--
	local section = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(210, 210, 210))},
			Rotation = 90,
			Parent = section
		}
	)
	--
	local sectiontitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(0,60,0,14),
			Position = UDim2.new(0,10,0,6),
			Font = self.font,
			Text = "Players",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = section
		}
	)
	--
	self.labels[#self.labels+1] = sectiontitle
	--
	local sectionline = utility.new(
		"Frame",
		{
			BackgroundColor3 = self.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-80,0,1),
			Position = UDim2.new(0,70,0,13),
			Parent = section
		}
	)
	--
	table.insert(self.themeitems["accent"]["BackgroundColor3"],sectionline)
	-- // search
	local searchholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-16,0,20),
			Position = UDim2.new(0.5,0,0,26),
			Parent = section
		}
	)
	--
	utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = searchholder
		}
	)
	--
	local search = utility.new(
		"TextBox",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Font = self.font,
			PlaceholderText = "Search...",
			PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClearTextOnFocus = false,
			Parent = searchholder
		}
	)
	--
	self.labels[#self.labels+1] = search
	-- // column header
	local header = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-16,0,16),
			Position = UDim2.new(0.5,0,0,52),
			Parent = section
		}
	)
	--
	local function headercol(text,pos,size,align)
		local l = utility.new(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				Size = size,
				Position = pos,
				Font = self.font,
				Text = text,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextSize = self.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = align,
				Parent = header
			}
		)
		self.labels[#self.labels+1] = l
	end
	--
	headercol("Name",UDim2.new(0,12,0,0),UDim2.new(0.4,-12,1,0),"Left")
	headercol("Team",UDim2.new(0.4,0,0,0),UDim2.new(0.32,0,1,0),"Center")
	headercol("Priority",UDim2.new(0.72,0,0,0),UDim2.new(0.28,0,1,0),"Center")
	-- // list
	local listholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-16,1,-192),
			Position = UDim2.new(0.5,0,0,70),
			Parent = section
		}
	)
	--
	utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = listholder
		}
	)
	--
	local scroll = utility.new(
		"ScrollingFrame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,1,-2),
			Position = UDim2.new(0,1,0,1),
			ClipsDescendants = true,
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 4,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			Parent = listholder
		}
	)
	--
	utility.new("UIListLayout",{FillDirection = "Vertical", Padding = UDim.new(0,0), Parent = scroll})
	-- // detail panel
	local detail = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-16,0,108),
			Position = UDim2.new(0.5,0,1,-10),
			Parent = section
		}
	)
	--
	utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = detail
		}
	)
	--
	local avataroutline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,72,0,72),
			Position = UDim2.new(0,10,0.5,0),
			Parent = detail
		}
	)
	--
	local avatar = utility.new(
		"ImageLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Image = "",
			Parent = avataroutline
		}
	)
	--
	local info = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-262,1,-16),
			Position = UDim2.new(0,90,0,8),
			Font = self.font,
			Text = "Name: -\nPriority: -\nTeam: -",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Parent = detail
		}
	)
	--
	self.labels[#self.labels+1] = info
	--
	local priolabel = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(0,150,0,14),
			Position = UDim2.new(1,-10,0,10),
			Font = self.font,
			Text = "Priority",
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = detail
		}
	)
	--
	self.labels[#self.labels+1] = priolabel
	-- // priority dropdown (compact)
	local ddholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,150,0,20),
			Position = UDim2.new(1,-10,0,28),
			ZIndex = 20,
			Parent = detail
		}
	)
	--
	utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 20,
			Parent = ddholder
		}
	)
	--
	local ddvalue = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,6,0,0),
			Font = self.font,
			Text = priorities[1],
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ZIndex = 21,
			Parent = ddholder
		}
	)
	--
	self.labels[#self.labels+1] = ddvalue
	--
	local ddarrow = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(1,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(0,16,1,0),
			Position = UDim2.new(1,-4,0.5,0),
			Font = self.font,
			Text = "...",
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 21,
			Parent = ddholder
		}
	)
	--
	self.labels[#self.labels+1] = ddarrow
	--
	local ddlist = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,#priorities*18),
			Position = UDim2.new(0,0,1,2),
			Visible = false,
			ZIndex = 30,
			Parent = ddholder
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(215, 215, 215))},
			Rotation = 90,
			Parent = ddlist
		}
	)
	--
	utility.new("UIListLayout",{FillDirection = "Vertical", Padding = UDim.new(0,0), Parent = ddlist})
	--
	local ddbutton = utility.new(
		"TextButton",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Text = "",
			ZIndex = 22,
			Parent = ddholder
		}
	)
	-- // example button
	local btnholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,150,0,20),
			Position = UDim2.new(1,-10,0,54),
			Parent = detail
		}
	)
	--
	local btnoutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = btnholder
		}
	)
	--
	local btn = utility.new(
		"TextButton",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Font = self.font,
			Text = buttonname,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			Parent = btnholder
		}
	)
	--
	self.labels[#self.labels+1] = btn
	-- // helpers
	local function trunc(s,n)
		s = tostring(s)
		if #s > n then
			return s:sub(1,n)..".."
		end
		return s
	end
	--
	local function priorityof(player)
		if self.whitelist[player.UserId] then
			return self.whitelist[player.UserId].priority
		end
		return priorities[1]
	end
	--
	local function updatedetail()
		if not selected or not selected.player then return end
		local p = selected.player
		avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..p.UserId.."&w=150&h=150"
		local nm = trunc(p.Name,14)
		local extra = (p.DisplayName ~= p.Name) and (" ("..trunc(p.DisplayName,10)..")") or ""
		info.Text = "Name: "..nm..extra.."\nPriority: "..priorityof(p).."\nTeam: "..trunc(p.Team and p.Team.Name or "None",14)
		ddvalue.Text = priorityof(p)
	end
	--
	local function setpriority(player,value)
		if value == priorities[1] then
			self.whitelist[player.UserId] = nil
		else
			self.whitelist[player.UserId] = {["name"] = player.Name, ["userid"] = player.UserId, ["priority"] = value}
		end
		for i,v in pairs(rows) do
			if v.player == player then
				v.prio.Text = value
				if value == priorities[1] then
					v.prio.TextColor3 = Color3.fromRGB(200, 200, 200)
					local f = table.find(self.themeitems["accent"]["TextColor3"],v.prio)
					if f then table.remove(self.themeitems["accent"]["TextColor3"],f) end
				else
					v.prio.TextColor3 = self.theme.accent
					if not table.find(self.themeitems["accent"]["TextColor3"],v.prio) then
						table.insert(self.themeitems["accent"]["TextColor3"],v.prio)
					end
				end
			end
		end
		if selected and selected.player == player then
			updatedetail()
		end
		callback(player,value)
	end
	--
	for i,v in pairs(priorities) do
		local opt = utility.new(
			"TextButton",
			{
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,18),
				Font = self.font,
				Text = v,
				TextColor3 = Color3.fromRGB(220, 220, 220),
				TextSize = self.textsize,
				TextStrokeTransparency = 0,
				ZIndex = 31,
				Parent = ddlist
			}
		)
		self.labels[#self.labels+1] = opt
		opt.MouseEnter:Connect(function()
			ts:Create(opt, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.85}):Play()
		end)
		opt.MouseLeave:Connect(function()
			ts:Create(opt, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		end)
		opt.MouseButton1Down:Connect(function()
			ddlist.Visible = false
			if selected and selected.player then
				setpriority(selected.player,v)
			end
		end)
	end
	--
	ddbutton.MouseButton1Down:Connect(function()
		ddlist.Visible = not ddlist.Visible
	end)
	--
	btn.MouseButton1Down:Connect(function()
		buttoncallback(selected and selected.player or nil)
		btnoutline.BorderColor3 = self.theme.accent
		wait(0.05)
		btnoutline.BorderColor3 = Color3.fromRGB(56, 56, 56)
	end)
	-- // row builder
	local function makerow(player)
		local rowbutton = utility.new(
			"TextButton",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,20),
				Text = "",
				Parent = scroll
			}
		)
		--
		local grey = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				Parent = rowbutton
			}
		)
		--
		utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundColor3 = Color3.fromRGB(56, 56, 56),
				BorderSizePixel = 0,
				Size = UDim2.new(0,1,0.6,0),
				Position = UDim2.new(0.4,0,0.5,0),
				Parent = rowbutton
			}
		)
		--
		utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundColor3 = Color3.fromRGB(56, 56, 56),
				BorderSizePixel = 0,
				Size = UDim2.new(0,1,0.6,0),
				Position = UDim2.new(0.72,0,0.5,0),
				Parent = rowbutton
			}
		)
		--
		local rowname = utility.new(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(0.4,-12,1,0),
				Position = UDim2.new(0,12,0,0),
				Font = self.font,
				Text = player.Name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				TextTruncate = "AtEnd",
				Parent = rowbutton
			}
		)
		--
		self.labels[#self.labels+1] = rowname
		--
		local rowteam = utility.new(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(0.32,0,1,0),
				Position = UDim2.new(0.4,0,0,0),
				Font = self.font,
				Text = player.Team and player.Team.Name or "None",
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextSize = self.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Center",
				TextTruncate = "AtEnd",
				Parent = rowbutton
			}
		)
		--
		self.labels[#self.labels+1] = rowteam
		--
		local rowprio = utility.new(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				Size = UDim2.new(0.28,0,1,0),
				Position = UDim2.new(0.72,0,0,0),
				Font = self.font,
				Text = priorityof(player),
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = self.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Center",
				Parent = rowbutton
			}
		)
		--
		self.labels[#self.labels+1] = rowprio
		--
		local row = {
			["player"] = player,
			["button"] = rowbutton,
			["grey"] = grey,
			["name"] = rowname,
			["team"] = rowteam,
			["prio"] = rowprio
		}
		--
		if self.whitelist[player.UserId] then
			rowprio.TextColor3 = self.theme.accent
			table.insert(self.themeitems["accent"]["TextColor3"],rowprio)
		end
		--
		rowbutton.MouseEnter:Connect(function()
			if selected ~= row then
				ts:Create(grey, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 0.94}):Play()
			end
		end)
		--
		rowbutton.MouseLeave:Connect(function()
			if selected ~= row then
				ts:Create(grey, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end
		end)
		--
		rowbutton.MouseButton1Down:Connect(function()
			if selected and selected ~= row then
				selected.grey.BackgroundTransparency = 1
				selected.name.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			selected = row
			playerlist.selected = player
			grey.BackgroundTransparency = 0.9
			rowname.TextColor3 = self.theme.accent
			ddlist.Visible = false
			updatedetail()
		end)
		--
		table.insert(rows,row)
	end
	-- // refresh
	local refresh = function()
		local keep = selected and selected.player or nil
		for i,v in pairs(rows) do
			local f = table.find(self.themeitems["accent"]["TextColor3"],v.prio)
			if f then table.remove(self.themeitems["accent"]["TextColor3"],f) end
			v.button:Destroy()
		end
		rows = {}
		selected = nil
		--
		local query = utility.removespaces(tostring(search.Text):lower())
		for i,v in pairs(plrs:GetPlayers()) do
			if query == "" or v.Name:lower():find(query,1,true) or v.DisplayName:lower():find(query,1,true) then
				makerow(v)
			end
		end
		--
		if keep then
			for i,v in pairs(rows) do
				if v.player == keep then
					selected = v
					playerlist.selected = keep
					v.grey.BackgroundTransparency = 0.9
					v.name.TextColor3 = self.theme.accent
					updatedetail()
				end
			end
		end
	end
	--
	playerlist.refresh = refresh
	refresh()
	-- // connections
	table.insert(self.connections, plrs.PlayerAdded:Connect(function() refresh() end))
	table.insert(self.connections, plrs.PlayerRemoving:Connect(function() task.wait() refresh() end))
	search:GetPropertyChangedSignal("Text"):Connect(function() refresh() end)
	-- // floating window register + toggle
	local fw = {["frame"] = outline, ["scale"] = scale, ["saved"] = outline.Position, ["isopen"] = false, ["gui"] = fwgui}
	table.insert(self.floatingwindows,fw)
	--
	outline:GetPropertyChangedSignal("Position"):Connect(function()
		if not self.menuanimating then fw.saved = outline.Position end
	end)
	--
	outline.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.topdisplay = (self.topdisplay or 10000) + 1
			fwgui.DisplayOrder = self.topdisplay
		end
	end)
	--
	local function highlight(on)
		if on then
			taboutline.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			taboutline.BorderColor3 = self.theme.accent
			tabimage.ImageColor3 = self.theme.accent
			tablabel.TextColor3 = self.theme.accent
		else
			taboutline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			taboutline.BorderColor3 = Color3.fromRGB(56, 56, 56)
			tabimage.ImageColor3 = Color3.fromRGB(200, 200, 200)
			tablabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end
	--
	tabclick.MouseButton1Down:Connect(function()
		if fw.isopen then
			fw.isopen = false
			outline.Visible = false
			fwgui.Enabled = false
			highlight(false)
		else
			fw.isopen = true
			fwgui.Enabled = true
			self.topdisplay = (self.topdisplay or 10000) + 1
			fwgui.DisplayOrder = self.topdisplay
			outline.Visible = true
			scale.Scale = 0.9
			ts:Create(scale, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Scale = 1}):Play()
			highlight(true)
		end
	end)
	-- // playerlist tbl
	playerlist.library = self
	playerlist.window = outline
	playerlist.refresh = refresh
	playerlist.rows = rows
	setmetatable(playerlist, configloaders)
	return playerlist
end
--
function library:esppreview(props)
	local props = props or {}
	local name = props.name or props.Name or "ESP Preview"
	local icon = props.icon or props.Icon or props.image or props.Image or nil
	local speed = props.speed or props.Speed or 1
	local W,H = 380,440
	-- // variables
	local esppreview = {}
	local currentmodel = nil
	local modelcenter = Vector3.new()
	local angle = 0
	-- // tab button
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,26,0,26),
			ZIndex = 11,
			Parent = self.tabsbuttons
		}
	)
	--
	local taboutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 11,
			Parent = tabbutton
		}
	)
	--
	local tabimage = utility.new(
		"ImageLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(0,16,0,16),
			Position = UDim2.new(0.5,0,0.5,0),
			Image = icon or "",
			ImageColor3 = Color3.fromRGB(200, 200, 200),
			Visible = icon ~= nil,
			ZIndex = 12,
			Parent = taboutline
		}
	)
	--
	local tablabel = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Font = self.font,
			Text = icon and "" or name:sub(1,1):upper(),
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			Visible = icon == nil,
			ZIndex = 12,
			Parent = taboutline
		}
	)
	--
	local tabclick = utility.new(
		"TextButton",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Text = "",
			ZIndex = 13,
			Parent = tabbutton
		}
	)
	--
	self.extratabs = (self.extratabs or 0) + 1
	local count = #self.pages + self.extratabs
	self.tabsbar.Size = UDim2.new(0, count*26 + (count-1)*3 + 10, 0, 37)
	self.labels[#self.labels+1] = tablabel
	-- // window chrome
	self.topdisplay = (self.topdisplay or 10000) + 1
	local fwgui = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = self.topdisplay,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Enabled = false,
			Parent = cre
		}
	)
	if (check_exploit == "Synapse" and syn.request) then
		syn.protect_gui(fwgui)
	end
	table.insert(self.floatingguis,fwgui)
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Active = true,
			Size = UDim2.new(0,W,0,H),
			Position = UDim2.new(0.5,-490,0.5,0),
			Visible = false,
			Parent = fwgui
		}
	)
	--
	local scale = utility.new("UIScale",{Scale = 1, Parent = outline})
	--
	local glow = utility.new(
		"ImageLabel",
		{
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=18245826428",
			ImageColor3 = self.theme.accent,
			ImageTransparency = 0.8,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(21, 21, 79, 79),
			Position = UDim2.new(0,-20,0,-20),
			Size = UDim2.new(1,40,1,40),
			ZIndex = 0,
			Parent = outline
		}
	)
	--
	table.insert(self.themeitems["accent"]["ImageColor3"],glow)
	--
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline
		}
	)
	--
	local body = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline2
		}
	)
	--
	local wline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-8,0,1),
			Position = UDim2.new(0.5,0,0,3),
			ZIndex = 5,
			Parent = body
		}
	)
	--
	table.insert(self.themeitems["accent"]["BackgroundColor3"],wline)
	--
	local titletext = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-24,0,16),
			Position = UDim2.new(0,12,0,8),
			Font = self.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = body
		}
	)
	--
	self.labels[#self.labels+1] = titletext
	--
	utility.dragify(titletext,outline)
	-- // section box
	local sectionholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-16,1,-40),
			Position = UDim2.new(0.5,0,0,32),
			Parent = body
		}
	)
	--
	local section = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	--
	local sectioncolor = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			Parent = section
		}
	)
	--
	table.insert(self.themeitems["accent"]["BackgroundColor3"],sectioncolor)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(210, 210, 210))},
			Rotation = 90,
			Parent = section
		}
	)
	--
	local sectiontitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0,8,0,3),
			Font = self.font,
			Text = "Main",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = section
		}
	)
	--
	self.labels[#self.labels+1] = sectiontitle
	-- // viewport
	local viewport = utility.new(
		"ViewportFrame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(18, 18, 18),
			BorderSizePixel = 0,
			Size = UDim2.new(1,-12,1,-30),
			Position = UDim2.new(0.5,0,1,-6),
			Ambient = Color3.fromRGB(190, 190, 190),
			LightColor = Color3.fromRGB(255, 255, 255),
			LightDirection = Vector3.new(-0.2,-0.6,-1),
			Parent = section
		}
	)
	--
	local worldmodel = utility.new("WorldModel",{Parent = viewport})
	--
	local vpcam = utility.new("Camera",{Parent = viewport})
	viewport.CurrentCamera = vpcam
	-- // model builder
	local function buildmodel()
		if currentmodel then
			currentmodel:Destroy()
			currentmodel = nil
		end
		local char = plr.Character
		if not char then return end
		local ok,clone = pcall(function()
			char.Archivable = true
			local c = char:Clone()
			char.Archivable = false
			return c
		end)
		if not ok or not clone then return end
		for i,d in pairs(clone:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Anchored = true
				d.CanCollide = false
			elseif d:IsA("Script") or d:IsA("LocalScript") then
				d:Destroy()
			end
		end
		clone.Parent = worldmodel
		currentmodel = clone
		clone:PivotTo(CFrame.new())
		local bbcf,bbsize = clone:GetBoundingBox()
		modelcenter = bbcf.Position
		local dist = math.max(bbsize.X,bbsize.Y,bbsize.Z) * 1.05 + 1.5
		vpcam.CFrame = CFrame.lookAt(modelcenter + Vector3.new(0,0,-dist), modelcenter)
		angle = 0
	end
	--
	buildmodel()
	-- // spin
	if not self.previewanimation then self.previewanimation = "spin" end
	table.insert(self.connections, rs.RenderStepped:Connect(function(dt)
		if not outline.Visible then return end
		if not currentmodel then return end
		local mode = self.previewanimation or "spin"
		if mode == "static" then
			currentmodel:PivotTo(CFrame.new())
		elseif mode == "slowspin" then
			angle = angle + dt * speed * 0.4
			currentmodel:PivotTo(CFrame.Angles(0,angle,0))
		elseif mode == "sway" then
			angle = angle + dt * speed
			currentmodel:PivotTo(CFrame.Angles(0, math.sin(angle) * 0.6, 0))
		elseif mode == "float" then
			angle = angle + dt * speed
			currentmodel:PivotTo(CFrame.new(0, math.sin(angle*2)*0.25, 0) * CFrame.Angles(0,angle,0))
		else
			angle = angle + dt * speed
			currentmodel:PivotTo(CFrame.Angles(0,angle,0))
		end
	end))
	--
	table.insert(self.connections, plr.CharacterAdded:Connect(function()
		task.wait(1)
		buildmodel()
	end))
	-- // floating window register + toggle
	local fw = {["frame"] = outline, ["scale"] = scale, ["saved"] = outline.Position, ["isopen"] = false, ["gui"] = fwgui}
	table.insert(self.floatingwindows,fw)
	--
	outline:GetPropertyChangedSignal("Position"):Connect(function()
		if not self.menuanimating then fw.saved = outline.Position end
	end)
	--
	outline.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.topdisplay = (self.topdisplay or 10000) + 1
			fwgui.DisplayOrder = self.topdisplay
		end
	end)
	--
	local function highlight(on)
		if on then
			taboutline.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			taboutline.BorderColor3 = self.theme.accent
			tabimage.ImageColor3 = self.theme.accent
			tablabel.TextColor3 = self.theme.accent
		else
			taboutline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			taboutline.BorderColor3 = Color3.fromRGB(56, 56, 56)
			tabimage.ImageColor3 = Color3.fromRGB(200, 200, 200)
			tablabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end
	--
	local function openwin()
		fw.isopen = true
		fwgui.Enabled = true
		self.topdisplay = (self.topdisplay or 10000) + 1
		fwgui.DisplayOrder = self.topdisplay
		outline.Visible = true
		scale.Scale = 0.9
		ts:Create(scale, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Scale = 1}):Play()
		highlight(true)
	end
	--
	local function closewin()
		fw.isopen = false
		outline.Visible = false
		fwgui.Enabled = false
		highlight(false)
	end
	--
	tabclick.MouseButton1Down:Connect(function()
		if fw.isopen then closewin() else openwin() end
	end)
	-- // esppreview tbl
	esppreview.library = self
	esppreview.window = outline
	esppreview.rebuild = buildmodel
	self.previewwindow = esppreview
	setmetatable(esppreview, configloaders)
	return esppreview
end
--
function library:setpreviewanimation(mode)
	if mode ~= nil then
		self.previewanimation = utility.removespaces(tostring(mode):lower())
	end
end
--
function library:iswhitelisted(player)
	if not player then return false end
	local id = (typeof(player) == "Instance") and player.UserId or player
	return self.whitelist[id] ~= nil
end
--
function library:getpriority(player)
	if not player then return nil end
	local id = (typeof(player) == "Instance") and player.UserId or player
	local entry = self.whitelist[id]
	return entry and entry.priority or nil
end
--
function library:playertab(props)
	local props = props or {}
	local name = props.name or props.Name or "Players"
	local icon = props.icon or props.Icon or props.image or props.Image or nil
	local callback = props.callback or props.Callback or function()end
	-- // page
	local page = self:page({name = name, icon = icon})
	-- // list
	local section = page:section({name = "Player List", side = "left", size = 300})
	section:playerlist({name = "Players", height = 270, callback = callback})
	--
	return page
end
return library
